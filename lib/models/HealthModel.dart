import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class HealthModel {
  static String tableName = 'health';
  static String endpoint = 'health';
  String id;
  String farmID;
  String animal;
  String symptoms;
  String status;
  String date;
  bool isSynced;

  HealthModel({
    this.id = '',
    this.farmID = '',
    this.animal = '',
    this.symptoms = '',
    this.status = '',
    this.date = '',
    this.isSynced = false,
  });

  static HealthModel fromJson(dynamic m) {
    if (m == null) {
      return HealthModel();
    }
    return HealthModel(
      id: Utils.to_str(m['id'], ''),
      farmID: Utils.to_str(m['farmID'], ''),
      animal: Utils.to_str(m['animal'], ''),
      symptoms: Utils.to_str(m['symptoms'], ''),
      status: Utils.to_str(m['status'], ''),
      date: Utils.to_str(m['date'], ''),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? Utils.generateUniqueId() : id,
      'farmID': farmID,
      'animal': animal,
      'symptoms': symptoms,
      'status': status,
      'date': date,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'farmID',
      'animal',
      'symptoms',
      'status',
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

  static Future<void> saveLocally(HealthModel health) async {
    try {
      await initTable();
      Database db = await Utils.getDb();
      await ensureTableColumns(db);
      final Map<String, dynamic> data = health.toJson();
      data['registeredBy'] = (await LoggedInUserModel.getLoggedInUser()).id;
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Health data already exists");
        return;
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("An error occurred while saving locally: $e");
      Utils.toast(
          "An error occurred while saving the health data."); // Providing user feedback
    }
  }

  static Future<bool> syncToServer(HealthModel healthData) async {
    try {
      Map<String, dynamic> health = healthData.toJson();
      health.remove('isSynced');
      RespondModel response =
          RespondModel(await Utils.http_post(HealthModel.endpoint, health));
      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing health data to server: $e');
      return false;
    }
  }

  static Future<HealthModel> getItemById(String id) async {
    HealthModel item = HealthModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = HealthModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch health data: ${e.toString()}');
    }
    return item;
  }

  static Future<List<HealthModel>> get_items({String where = '1'}) async {
    List<HealthModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await HealthModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      HealthModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<HealthModel>> getOnlineItems() async {
    List<HealthModel> data = [];
    RespondModel resp =
        RespondModel(await Utils.http_get('${HealthModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await HealthModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          HealthModel sub = HealthModel.fromJson(x);
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

  static Future<List<HealthModel>> getLocalData({String where = "1"}) async {
    List<HealthModel> data = [];
    if (!(await HealthModel.initTable())) {
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
      data.add(HealthModel.fromJson(maps[i]));
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
      print("Failed to save health data because ${e.toString()}");
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
      print("Failed to delete all health data because ${e.toString()}");
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
      print("Failed to delete health data because ${e.toString()}");
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
  symptoms TEXT,
  status TEXT,
  date TEXT,
  isSynced INTEGER DEFAULT 0
)''';
    try {
      await db.execute(sql);
      return true;
    } catch (e) {
      print('Failed to create health table because ${e.toString()}');
      return false;
    }
  }
}
