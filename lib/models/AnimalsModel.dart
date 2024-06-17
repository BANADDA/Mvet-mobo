import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class AnimalsModel {
  static String tableName = 'animals';
  static String endpoint = 'animals';
  String id;
  String farmID;
  String animal;
  double quantity;
  String date;
  bool isSynced;

  AnimalsModel({
    this.id = '',
    this.farmID = '',
    this.animal = '',
    this.quantity = 0.0,
    this.date = '',
    this.isSynced = false,
  });

  static AnimalsModel fromJson(dynamic m) {
    if (m == null) {
      return AnimalsModel();
    }
    return AnimalsModel(
      id: Utils.to_str(m['id'], ''),
      farmID: Utils.to_str(m['farmID'], ''),
      animal: Utils.to_str(m['animal'], ''),
      quantity: Utils.to_double(m['quantity'], 0.0),
      date: Utils.to_str(m['date'], ''),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? Utils.generateUniqueId() : id,
      'farmID': farmID,
      'animal': animal,
      'quantity': quantity,
      'date': date,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'farmID',
      'animal',
      'quantity',
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

  static Future<void> saveLocally(AnimalsModel animal) async {
    try {
      await initTable();
      Database db = await Utils.getDb();
      await ensureTableColumns(db);
      final Map<String, dynamic> data = animal.toJson();
      data['registeredBy'] = (await LoggedInUserModel.getLoggedInUser()).id;
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Animal data already exists");
        return;
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("An error occurred while saving locally: $e");
      Utils.toast(
          "An error occurred while saving the animal data."); // Providing user feedback
    }
  }

  static Future<bool> syncToServer(AnimalsModel animalData) async {
    try {
      Map<String, dynamic> animal = animalData.toJson();
      animal.remove('isSynced');
      RespondModel response =
          RespondModel(await Utils.http_post(AnimalsModel.endpoint, animal));
      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing animal data to server: $e');
      return false;
    }
  }

  static Future<AnimalsModel> getItemById(String id) async {
    AnimalsModel item = AnimalsModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = AnimalsModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch animal data: ${e.toString()}');
    }
    return item;
  }

  static Future<List<AnimalsModel>> get_items({String where = '1'}) async {
    List<AnimalsModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await AnimalsModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      AnimalsModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<AnimalsModel>> getOnlineItems() async {
    List<AnimalsModel> data = [];
    RespondModel resp =
        RespondModel(await Utils.http_get('${AnimalsModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await AnimalsModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          AnimalsModel sub = AnimalsModel.fromJson(x);
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

  static Future<List<AnimalsModel>> getLocalData({String where = "1"}) async {
    List<AnimalsModel> data = [];
    if (!(await AnimalsModel.initTable())) {
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
      data.add(AnimalsModel.fromJson(maps[i]));
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
      print("Failed to save animal data because ${e.toString()}");
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
      print("Failed to delete all animal data because ${e.toString()}");
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
      print("Failed to delete animal data because ${e.toString()}");
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
  quantity REAL,
  date TEXT,
  isSynced INTEGER DEFAULT 0
)''';
    try {
      await db.execute(sql);
      return true;
    } catch (e) {
      print('Failed to create animals table because ${e.toString()}');
      return false;
    }
  }
}
