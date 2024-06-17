import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class YieldsModel {
  static String tableName = 'yields';
  static String endpoint = 'yields';
  String id;
  String farmID;
  String animal;
  String yieldType;
  double quantity;
  String unit;
  String date;
  bool isSynced;

  YieldsModel({
    this.id = '',
    this.farmID = '',
    this.animal = '',
    this.yieldType = '',
    this.quantity = 0.0,
    this.unit = '',
    this.date = '',
    this.isSynced = false,
  });

  static YieldsModel fromJson(dynamic m) {
    if (m == null) {
      return YieldsModel();
    }
    return YieldsModel(
      id: Utils.to_str(m['id'], ''),
      farmID: Utils.to_str(m['farmID'], ''),
      animal: Utils.to_str(m['animal'], ''),
      yieldType: Utils.to_str(m['yieldType'], ''),
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
      'yieldType': yieldType,
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
      'yieldType',
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

  static Future<void> saveLocally(YieldsModel yieldData) async {
    try {
      await initTable();
      Database db = await Utils.getDb();
      await ensureTableColumns(db);
      final Map<String, dynamic> data = yieldData.toJson();
      data['registeredBy'] = (await LoggedInUserModel.getLoggedInUser()).id;
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Yield data already exists");
        return;
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("An error occurred while saving locally: $e");
      Utils.toast(
          "An error occurred while saving the yield data."); // Providing user feedback
    }
  }

  static Future<bool> syncToServer(YieldsModel yieldData) async {
    try {
      Map<String, dynamic> yieldMap = yieldData.toJson();
      yieldMap.remove('isSynced');
      RespondModel response =
          RespondModel(await Utils.http_post(YieldsModel.endpoint, yieldMap));
      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing yield data to server: $e');
      return false;
    }
  }

  static Future<YieldsModel> getItemById(String id) async {
    YieldsModel item = YieldsModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = YieldsModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch yield data: ${e.toString()}');
    }
    return item;
  }

  static Future<List<YieldsModel>> get_items({String where = '1'}) async {
    List<YieldsModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await YieldsModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      YieldsModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<YieldsModel>> getOnlineItems() async {
    List<YieldsModel> data = [];
    RespondModel resp =
        RespondModel(await Utils.http_get('${YieldsModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await YieldsModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          YieldsModel sub = YieldsModel.fromJson(x);
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

  static Future<List<YieldsModel>> getLocalData({String where = "1"}) async {
    List<YieldsModel> data = [];
    if (!(await YieldsModel.initTable())) {
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
      data.add(YieldsModel.fromJson(maps[i]));
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
      print("Failed to save yield data because ${e.toString()}");
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
      print("Failed to delete all yield data because ${e.toString()}");
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
      print("Failed to delete yield data because ${e.toString()}");
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
  yieldType TEXT,
  quantity REAL,
  unit TEXT,
  date TEXT,
  isSynced INTEGER DEFAULT 0
)''';
    try {
      await db.execute(sql);
      return true;
    } catch (e) {
      print('Failed to create yields table because ${e.toString()}');
      return false;
    }
  }
}
