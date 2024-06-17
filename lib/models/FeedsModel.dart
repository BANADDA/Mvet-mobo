import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class FeedsModel {
  static String tableName = 'feeds';
  static String endpoint = 'feeds';
  String id;
  String farmID;
  String animal;
  String name;
  double quantity;
  String unit;
  String date;
  bool isSynced;

  FeedsModel({
    this.id = '',
    this.farmID = '',
    this.animal = '',
    this.name = '',
    this.quantity = 0.0,
    this.unit = '',
    this.date = '',
    this.isSynced = false,
  });

  static FeedsModel fromJson(dynamic m) {
    if (m == null) {
      return FeedsModel();
    }
    return FeedsModel(
      id: Utils.to_str(m['id'], ''),
      farmID: Utils.to_str(m['farmID'], ''),
      animal: Utils.to_str(m['animal'], ''),
      name: Utils.to_str(m['name'], ''),
      quantity: Utils.to_double(m['quantity'], 0.0),
      unit: Utils.to_str(m['unit'], ''),
      date: Utils.to_str(m['date'], ''),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? Utils.generateUniqueId() : id,
      'farmID': farmID,
      'animal': animal,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'date': date,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'farmID',
      'animal',
      'name',
      'quantity',
      'unit',
      'date',
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

  static Future<void> saveLocally(FeedsModel feed) async {
    print("Saving feed: $feed");
    try {
      await initTable();
      Database db = await Utils.getDb();
      await ensureTableColumns(db);
      final Map<String, dynamic> data = feed.toJson();
      // data['registeredBy'] = (await LoggedInUserModel.getLoggedInUser()).id;
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Feed already exists");
        return;
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("An error occurred while saving locally: $e");
      Utils.toast(
          "An error occurred while saving the feed data."); // Providing user feedback
    }
  }

  static Future<bool> syncToServer(FeedsModel feedData) async {
    try {
      Map<String, dynamic> feed = feedData.toJson();
      feed.remove('isSynced');
      RespondModel response =
          RespondModel(await Utils.http_post(FeedsModel.endpoint, feed));
      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing feed to server: $e');
      return false;
    }
  }

  static Future<FeedsModel> getItemById(String id) async {
    FeedsModel item = FeedsModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = FeedsModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch feed: ${e.toString()}');
    }
    return item;
  }

  static Future<List<FeedsModel>> get_items({String where = '1'}) async {
    print('Fetching local data with condition: $where');
    List<FeedsModel> data = await getLocalData(where: where);
    print('Local data fetched: ${data.length} items');
    if (data.isEmpty) {
      print('Local data is empty, fetching online data');
      await FeedsModel.getOnlineItems();
      data = await getLocalData(where: where);
      print('Data fetched from online: ${data.length} items');
    } else {
      print('Local data is available, fetching online data in background');
      FeedsModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<FeedsModel>> getOnlineItems() async {
    List<FeedsModel> data = [];
    RespondModel resp =
        RespondModel(await Utils.http_get('${FeedsModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await FeedsModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          FeedsModel sub = FeedsModel.fromJson(x);
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

  static Future<List<FeedsModel>> getLocalData({String where = "1"}) async {
    List<FeedsModel> data = [];
    if (!(await FeedsModel.initTable())) {
      return data;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }
    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' id DESC ');
    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(FeedsModel.fromJson(maps[i]));
    });
    return data;
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return;
    }
    if (id.isEmpty) {
      id = Utils.generateUniqueId();
    }
    try {
      await db.insert(tableName, toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Failed to save feed because ${e.toString()}");
    }
  }

  static deleteAll() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
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
      return;
    }
    try {
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Failed to delete feed because ${e.toString()}");
    }
  }

  static Future<bool> initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    String sql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  id TEXT PRIMARY KEY,
  farmID TEXT,
  animal TEXT,
  name TEXT,
  quantity REAL,
  unit TEXT,
  date TEXT,
  isSynced INTEGER DEFAULT 0
)''';
    try {
      await db.execute(sql);
      return true;
    } catch (e) {
      print('Failed to create feeds table because ${e.toString()}');
      return false;
    }
  }
}
