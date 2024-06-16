import 'package:marcci/main.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class FeedModel {
  static String tableName = 'feeds';
  static String endpoint = 'feeds';
  String feedID;
  String feedName;
  String quantity;
  String date;
  String farmID;
  bool isSynced;

  FeedModel({
    this.feedID = '',
    this.feedName = '',
    this.quantity = '',
    this.date = '',
    this.farmID = '',
    this.isSynced = false,
  });

  static FeedModel fromJson(dynamic m) {
    if (m == null) {
      return FeedModel();
    }
    return FeedModel(
      feedID: Utils.to_str(m['feedID'], ''),
      feedName: Utils.to_str(m['feedName'], ''),
      quantity: Utils.to_str(m['quantity'], ''),
      date: Utils.to_str(m['date'], ''),
      farmID: Utils.to_str(m['farmID'], ''),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedID': feedID.isEmpty ? Utils.generateUniqueId() : feedID,
      'feedName': feedName,
      'quantity': quantity,
      'date': date,
      'farmID': farmID,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'feedName',
      'quantity',
      'date',
      'farmID',
    ];
    List<Map> tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');

    List<String> existingColumns =
        tableInfo.map((row) => row['name'].toString()).toList();

    for (String column in requiredColumns) {
      if (!existingColumns.contains(column)) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $column TEXT');
        print("Column $column added to $tableName");
      }
    }
  }

  static Future<void> syncLocalDataToServer() async {
    final Database db = await Utils.getDb();
    print("Database instance obtained.");

    final List<Map<String, dynamic>> unsyncedFeeds = await db.query(
      tableName,
      where: 'isSynced = 0',
    );
    print("Fetched unsynced feeds count: ${unsyncedFeeds.length}");

    int syncedCount = 0;

    for (var feed in unsyncedFeeds) {
      FeedModel data = FeedModel.fromJson(feed);
      print("JSON payload being sent: ${feed}");

      bool success = await SyncFeedToServer(data);
      if (success) {
        print("Feed with ID: ${data.feedID} synced successfully.");
        await db.update(
          tableName,
          {'isSynced': 1},
          where: 'feedID = ?',
          whereArgs: [data.feedID],
        );
        syncedCount++;
      } else {
        print("Failed to sync feed with ID: ${data.feedID}");
      }
    }

    if (syncedCount > 0) {
      print("$syncedCount feeds have been successfully synced.");
      await showNotification("Sync Complete",
          "$syncedCount records have been successfully synced.");
    } else {
      print("No feeds were synced in this run.");
    }
  }

  static Future<bool> SyncFeedToServer(FeedModel feedData) async {
    try {
      Map<String, dynamic> feed = feedData.toJson();
      feed.remove('isSynced');

      print("JSON payload being sent: ${feed}");

      RespondModel response =
          RespondModel(await Utils.http_post(FeedModel.endpoint, feed));

      print("Response Status: ${response.code}");
      print("Response Body: ${response.data}");

      if (response.code == 1) {
        print("Sync successful.");
        return true;
      } else {
        print("Server error: ${response.message}");
        return false;
      }
    } catch (e) {
      print('Error syncing feed to server: $e');
      return false;
    }
  }

  static Future<FeedModel> getItemById(String id) async {
    FeedModel item = FeedModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'feedID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = FeedModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch feed: ${e.toString()}');
    }
    return item;
  }

  static Future<int> feed_count() async {
    try {
      List<FeedModel> items = await get_items();
      print("Feeds count: ${items.length}");
      return items.length;
    } catch (e) {
      print("Error counting feeds: ${e.toString()}");
      return 0;
    }
  }

  static Future<List<FeedModel>> get_items({String where = '1'}) async {
    List<FeedModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await FeedModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      FeedModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<FeedModel>> getOnlineItems() async {
    List<FeedModel> data = [];

    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;

    RespondModel resp =
        RespondModel(await Utils.http_get('${FeedModel.endpoint}', {}));
    print("Feeds response: ${resp.data}");

    if (resp.code != 1) {
      return [];
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return [];
    }

    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await FeedModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          FeedModel sub = FeedModel.fromJson(x);
          try {
            batch.insert(tableName, sub.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          } catch (e) {
            print("Failed to save because ${e.toString()}");
          }
        }

        try {
          await batch.commit(continueOnError: true);
        } catch (e) {
          print("Failed to commit transaction because ${e.toString()}");
        }
      });
    }

    return data;
  }

  static Future<List<FeedModel>> getLocalData({String where = "1"}) async {
    List<FeedModel> data = [];
    if (!(await FeedModel.initTable())) {
      print("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' feedID DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(FeedModel.fromJson(maps[i]));
    });

    return data;
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    if (feedID.isEmpty) {
      feedID = Utils.generateUniqueId(); // Set unique ID if not provided
    }

    try {
      await db.insert(tableName, toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("Feed saved with ID: $feedID");
    } catch (e) {
      print("Failed to save feed because ${e.toString()}");
    }
  }

  static deleteAll() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.delete(tableName);
    } catch (e) {
      print("Failed to delete all feeds because ${e.toString()}");
    }
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.delete(tableName, where: 'feedID = ?', whereArgs: [feedID]);
    } catch (e) {
      print("Failed to delete feed because ${e.toString()}");
    }
  }

  static Future<bool> initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Database is not open");
      return false;
    }

    String sql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  feedID TEXT PRIMARY KEY,
  feedName TEXT,
  quantity TEXT,
  date TEXT,
  farmID TEXT,
  isSynced INTEGER DEFAULT 0
)''';

    try {
      await db.execute(sql);
      print('Feed table created successfully or already exists.');
      return true;
    } catch (e) {
      print('Failed to create feed table because ${e.toString()}');
      return false;
    }
  }
}
