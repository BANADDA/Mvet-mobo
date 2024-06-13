import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class FarmerModel {
  static String tableName = 'farmers';
  static String endpoint = 'farmers';
  int farmerID;
  String phoneNumber;
  String name;
  String dateOfBirth;
  double latitude;
  double longitude;
  String gender;
  bool isPWD;
  bool isSynced;

  FarmerModel({
    this.farmerID = 0,
    this.phoneNumber = '',
    this.name = '',
    this.dateOfBirth = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.gender = '',
    this.isPWD = false,
    this.isSynced = false,
  });

  static FarmerModel fromJson(dynamic m) {
    if (m == null) {
      return FarmerModel();
    }
    return FarmerModel(
      farmerID: m['farmerID'] ?? 0,
      phoneNumber: Utils.to_str(m['phoneNumber'], ''),
      name: Utils.to_str(m['name'], ''),
      dateOfBirth: Utils.to_str(m['dateOfBirth'], ''),
      latitude: m['latitude'] ?? 0.0,
      longitude: m['longitude'] ?? 0.0,
      gender: Utils.to_str(m['gender'], ''),
      isPWD: m['isPWD'] == 1,
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'gender': gender,
      'isPWD': isPWD ? 1 : 0, // Convert boolean to integer if needed
    };
  }

  static Future<void> saveLocally(FarmerModel farmer) async {
    try {
      Database db = await Utils.getDb();
      await ensureTableColumns(db);
      final Map<String, dynamic> data = farmer.toJson();
      LoggedInUserModel ul = await LoggedInUserModel.getLoggedInUser();
      data['registeredBy'] = ul.id;

      await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Local save error: $e");
      Utils.toast("An error occurred while saving the farmer data.");
    }
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'farmerID',
      'phoneNumber',
      'name',
      'dateOfBirth',
      'latitude',
      'longitude',
      'gender',
      'isPWD',
      'isSynced',
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

  static Future<bool> syncFarmerToServer(FarmerModel farmerData) async {
    try {
      Map<String, dynamic> farmer = farmerData.toJson();
      farmer.remove('isSynced');

      RespondModel response =
          RespondModel(await Utils.http_post(FarmerModel.endpoint, farmer));

      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing farmer to server: $e');
      return false;
    }
  }

  static Future<FarmerModel> getItemById(int id) async {
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'farmerID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return FarmerModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch farmer: $e');
    }
    return FarmerModel();
  }

  static Future<int> farmerCount() async {
    try {
      List<FarmerModel> items = await getItems();
      return items.length;
    } catch (e) {
      print("Failed to count farmers: $e");
      return 0;
    }
  }

  static Future<List<FarmerModel>> getItems({String where = '1'}) async {
    List<FarmerModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await FarmerModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      FarmerModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<FarmerModel>> getOnlineItems() async {
    List<FarmerModel> data = [];
    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;
    RespondModel resp =
        RespondModel(await Utils.http_get('${FarmerModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await FarmerModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          FarmerModel sub = FarmerModel.fromJson(x);
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

  static Future<List<FarmerModel>> getLocalData({String where = "1"}) async {
    List<FarmerModel> data = [];
    if (!(await FarmerModel.initTable())) {
      return [];
    }
    try {
      Database db = await Utils.getDb();
      List<Map> maps = await db.query(tableName, where: where);
      if (maps.isNotEmpty) {
        for (var x in maps) {
          data.add(FarmerModel.fromJson(x));
        }
      }
    } catch (e) {
      print("Local data fetch error: $e");
    }
    return data;
  }

  static Future<void> updateItem(FarmerModel item) async {
    try {
      Database db = await Utils.getDb();
      await db.update(tableName, item.toJson(),
          where: 'farmerID = ?', whereArgs: [item.farmerID]);
    } catch (e) {
      print('Failed to update farmer: $e');
    }
  }

  static Future<bool> initTable() async {
    try {
      Database db = await Utils.getDb();
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          farmerID INTEGER PRIMARY KEY AUTOINCREMENT,
          phoneNumber TEXT,
          name TEXT,
          dateOfBirth TEXT,
          latitude REAL,
          longitude REAL,
          gender TEXT,
          isPWD INTEGER,
          isSynced INTEGER,
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
