import 'package:intl/intl.dart';
import 'package:marcci/main.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:marcci/utils/Utils.dart';
import 'package:sqflite/sqflite.dart';

class SampleModel {
  static String tableName = 'samples';
  static String endpoint = 'samples';
  int sampleID;
  String sampleUUID;
  String sampleType;
  String sampleDate;
  String result;
  bool isSynced;
  String reportID;
  String status;

  SampleModel({
    this.sampleID = 0,
    this.sampleUUID = '',
    this.sampleType = '',
    this.sampleDate = '',
    this.result = '',
    this.isSynced = false,
    this.reportID = '',
    this.status = '',
  });

  static SampleModel fromJson(dynamic m) {
    if (m == null) {
      return SampleModel();
    }
    return SampleModel(
      sampleID: m['sampleID'] ?? 0, // Ensure sampleID is not null
      sampleUUID: Utils.to_str(m['sampleUUID'], ''),
      sampleType: Utils.to_str(m['sampleType'], ''),
      sampleDate: Utils.to_str(m['sampleDate'], ''),
      result: Utils.to_str(m['result'], ''),
      isSynced: m['isSynced'] == 1,
      reportID: Utils.to_str(m['reportID'], ''),
      status: Utils.to_str(m['status'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sampleID': sampleID, // Include sampleID in toJson method
      'sampleUUID': sampleUUID ?? '',
      'sampleType': sampleType ?? '',
      'sampleDate': sampleDate.isEmpty ? null : sampleDate,
      'result': result ?? '',
      'isSynced': isSynced ? 1 : 0,
      'reportID': reportID ?? '',
      'status': status ?? '',
      'registeredBy': 0,
    };
  }

  static Future<void> syncLocalDataToServer() async {
    try {
      Database db = await Utils.getDb();
      List<Map<String, dynamic>> unsyncedSamples = await db.query(
        tableName,
        where: 'isSynced = 0',
      );

      int syncedCount = 0;
      for (var sample in unsyncedSamples) {
        SampleModel data = SampleModel.fromJson(sample);
        bool success = await SyncSampleToServer(data);
        if (success) {
          await db.update(
            tableName,
            {'isSynced': 1},
            where: 'sampleID = ?',
            whereArgs: [data.sampleID],
          );
          syncedCount++;
        }
      }

      if (syncedCount > 0) {
        await showNotification("Sync Complete",
            "$syncedCount records have been successfully synced.");
      }
    } catch (e) {
      print("Sync error: $e");
    }
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'sampleID',
      'sampleUUID',
      'sampleType',
      'sampleDate',
      'result',
      'isSynced',
      'reportID',
      'status',
      'registeredBy'
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

  Future<void> _fetchLoggedInUser() async {}

  static Future<void> saveLocally(SampleModel sample) async {
    try {
      LoggedInUserModel ul = await LoggedInUserModel.getLoggedInUser();
      print("Saving locally");
      Database db = await Utils.getDb();
      await ensureTableColumns(db);

      final Map<String, dynamic> data = sample.toJson();

      // Set default values for status and creationDate
      data['status'] = 'pending';
      data['sampleDate'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      data['registeredBy'] = ul.id;

      print("sample data to insert: $data");

      // Remove sampleID to allow auto-increment
      data.remove('sampleID');

      // Check if the sample already exists
      List<Map> existingSamples = await db.query(
        tableName,
        where: 'sampleUUID = ?',
        whereArgs: [data['sampleUUID']],
      );

      if (existingSamples.isNotEmpty) {
        print("Sample already exists with UUID: ${data['sampleUUID']}");
        return;
      }

      print("Inserting sample into the database...");
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Sample insert failed or sample already exists.");
        return;
      }
      print("Data inserted successfully with sampleID: $id.");
    } catch (e) {
      print("Local save error: $e");
      Utils.toast("An error occurred while saving the report data.");
    }
  }

  // static Future<void> saveLocally(SampleModel sample) async {
  //   try {
  //     Database db = await Utils.getDb();
  //     await ensureTableColumns(db);
  //     final Map<String, dynamic> data = sample.toJson();
  //     LoggedInUserModel ul = LoggedInUserModel();
  //     data['registeredBy'] = ul.id;

  //     await db.insert(tableName, data);
  //   } catch (e) {
  //     print("Local save error: $e");
  //     Utils.toast("An error occurred while saving the sample data.");
  //   }
  // }

  static Future<bool> SyncSampleToServer(SampleModel sampleData) async {
    try {
      Map<String, dynamic> sample = sampleData.toJson();
      sample.remove('isSynced');

      RespondModel response =
          RespondModel(await Utils.http_post(SampleModel.endpoint, sample));

      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing sample to server: $e');
      return false;
    }
  }

  static Future<SampleModel> getItemById(int id) async {
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'sampleID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return SampleModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch sample: $e');
    }
    return SampleModel();
  }

  static Future<int> sampleCount() async {
    try {
      List<SampleModel> items = await getItems();
      return items.length;
    } catch (e) {
      print("Failed to count samples: $e");
      return 0;
    }
  }

  static Future<int> sample_count() async {
    try {
      List<SampleModel> items = await getItems();
      print("Reports count: ${items.length}");
      return items.length;
    } catch (e) {
      print("Error counting reports: ${e.toString()}");
      return 0;
    }
  }

  static Future<List<SampleModel>> getItems({String where = '1'}) async {
    List<SampleModel> data = await getLocalData(where: where);
    print("Fetching samples: ${data.length}");
    if (data.isEmpty) {
      await SampleModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      SampleModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<SampleModel>> getOnlineItems() async {
    List<SampleModel> data = [];
    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;
    RespondModel resp =
        RespondModel(await Utils.http_get('${SampleModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await SampleModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          SampleModel sub = SampleModel.fromJson(x);
          try {
            batch.insert(tableName, sub.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          } catch (e) {
            print("Batch insert error: $e");
          }
        }
        try {
          await batch.commit(continueOnError: true);
        } catch (e) {
          print("Batch commit error: $e");
        }
      });
    }
    return data;
  }

  static Future<List<SampleModel>> getLocalData({String where = "1"}) async {
    List<SampleModel> data = [];
    if (!(await SampleModel.initTable())) {
      return [];
    }
    try {
      Database db = await Utils.getDb();
      List<Map> maps = await db.query(tableName, where: where);
      if (maps.isNotEmpty) {
        for (var x in maps) {
          data.add(SampleModel.fromJson(x));
        }
      }
    } catch (e) {
      print("Local data fetch error: $e");
    }
    return data;
  }

  static Future<void> updateItem(SampleModel item) async {
    try {
      Database db = await Utils.getDb();
      await db.update(tableName, item.toJson(),
          where: 'sampleID = ?', whereArgs: [item.sampleID]);
    } catch (e) {
      print('Failed to update sample: $e');
    }
  }

  static Future<bool> initTable() async {
    try {
      Database db = await Utils.getDb();
      await db.execute('''
      CREATE TABLE IF NOT EXISTS samples (
        sampleID INTEGER PRIMARY KEY AUTOINCREMENT,
        sampleUUID TEXT,
        sampleType TEXT,
        sampleDate TEXT,
        result TEXT,
        isSynced INTEGER,
        reportID TEXT,
        status TEXT,
        registeredBy INTEGER
      )
    ''');
      return true;
    } catch (e) {
      print("Table init error: $e");
      return false;
    }
  }

  static Future<void> deleteAll() async {
    try {
      Database db = await Utils.getDb();
      await db.execute('DELETE FROM $tableName');
    } catch (e) {
      print("Delete all error: $e");
    }
  }
}
