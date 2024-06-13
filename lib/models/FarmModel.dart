import 'dart:convert';

import 'package:marcci/main.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class FarmModel {
  static String tableName = 'farms';
  static String endpoint = 'farms';
  String farmID;
  String farmName = '';
  String latitude = '';
  String longitude = '';
  List<String> farmPhotos;
  String farmProfile = '';
  String districtID = '';
  String ownerName = '';
  String registeredBy = '';
  String farmerName = '';
  String farmerID = ''; // Added farmerID
  String farmerDOB = '';
  String farmerPhone = '';
  String villageName = '';
  String parishName = '';
  String subcountyName = '';
  String districtName = '';
  String animalsData = '';
  String managementSystemsData = '';
  bool isSynced = false;

  FarmModel({
    this.farmID = '',
    this.farmName = '',
    this.latitude = '',
    this.longitude = '',
    this.farmProfile = '',
    this.districtID = '',
    this.ownerName = '',
    this.registeredBy = '',
    this.farmerName = '',
    this.farmerID = '',
    this.farmerDOB = '',
    this.farmerPhone = '',
    this.villageName = '',
    this.parishName = '',
    this.subcountyName = '',
    this.districtName = '',
    this.animalsData = '',
    this.managementSystemsData = '',
    this.farmPhotos = const [],
    this.isSynced = false,
  });

  static FarmModel fromJson(dynamic m) {
    if (m == null) {
      return FarmModel();
    }
    return FarmModel(
      farmID: Utils.to_str(m['farmID'], ''),
      farmName: Utils.to_str(m['farmName'], ''),
      latitude: Utils.to_str(m['latitude'], ''),
      longitude: Utils.to_str(m['longitude'], ''),
      farmProfile: Utils.to_str(m['farmProfile'], ''),
      districtID: Utils.to_str(m['districtID'], ''),
      ownerName: Utils.to_str(m['ownerName'], ''),
      registeredBy: Utils.to_str(m['registeredBy'], ''),
      farmerName: Utils.to_str(m['farmerName'], ''),
      farmerID: Utils.to_str(m['farmerID'], ''),
      farmerDOB: Utils.to_str(m['farmerDOB'], ''),
      farmerPhone: Utils.to_str(m['farmerPhone'], ''),
      villageName: Utils.to_str(m['villageName'], ''),
      parishName: Utils.to_str(m['parishName'], ''),
      subcountyName: Utils.to_str(m['subcountyName'], ''),
      districtName: Utils.to_str(m['districtName'], ''),
      animalsData: Utils.to_str(m['animalsData'], ''),
      managementSystemsData: Utils.to_str(m['managementSystemsData'], ''),
      farmPhotos:
          List<String>.from(json.decode(Utils.to_str(m['farmPhotos'], '[]'))),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmID': farmID.isEmpty ? Utils.generateUniqueId() : farmID,
      'farmName': farmName,
      'latitude': latitude,
      'longitude': longitude,
      'farmProfile': farmProfile,
      'districtID': districtID,
      'ownerName': ownerName,
      'registeredBy': registeredBy,
      'farmerName': farmerName,
      'farmerID': farmerID,
      'farmerDOB': farmerDOB,
      'farmerPhone': farmerPhone,
      'villageName': villageName,
      'parishName': parishName,
      'subcountyName': subcountyName,
      'districtName': districtName,
      'animalsData': animalsData,
      'managementSystemsData': managementSystemsData,
      'farmPhotos': json.encode(farmPhotos),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<List<String>> getDistinctSubcounties() async {
    Database db = await Utils.getDb();
    var result = await db.query(tableName, columns: ['DISTINCT subcountyName']);
    return result.map((e) => e['subcountyName'] as String).toList();
  }

  static Future<List<String>> getDistinctParishes(String subcountyName) async {
    Database db = await Utils.getDb();
    var result = await db.query(tableName,
        columns: ['DISTINCT parishName'],
        where: 'subcountyName = ?',
        whereArgs: [subcountyName]);
    return result.map((e) => e['parishName'] as String).toList();
  }

  static Future<List<String>> getDistinctVillages(String parishName) async {
    Database db = await Utils.getDb();
    var result = await db.query(tableName,
        columns: ['DISTINCT villageName'],
        where: 'parishName = ?',
        whereArgs: [parishName]);
    return result.map((e) => e['villageName'] as String).toList();
  }

  static Future<void> syncLocalDataToServer() async {
    // Get database instance
    final Database db = await Utils.getDb();
    print("Database instance obtained.");

    // Query the database for all members with 'is_synced' set to 0
    final List<Map<String, dynamic>> unsyncedFarms = await db.query(
      tableName,
      where: 'is_synced = 0',
    );
    print("Fetched unsynced farm count: ${unsyncedFarms.length}");

    // Initialize count of successfully synced members
    int syncedCount = 0;

    // Iterate over each unsynced member
    for (var farm in unsyncedFarms) {
      // print("Attempting to sync member with ID: ${memberData['id']}");
      FarmModel data = FarmModel.fromJson(farm);
      print("JSON payload being sent: ${farm}");

      // Try syncing each member to the server
      bool success = await SyncFarmToServer(data);
      if (success) {
        print("Farm with ID: ${data.farmID} synced successfully.");
        // Update the 'is_synced' status in the database
        await db.update(
          tableName,
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [data.farmID],
        );
        syncedCount++;
      } else {
        print("Failed to sync farm with ID: ${data.farmID}");
      }
    }

    // If any members were synced, show a notification
    if (syncedCount > 0) {
      print("$syncedCount members have been successfully synced.");
      await showNotification("Sync Complete",
          "$syncedCount records have been successfully synced.");
    } else {
      print("No members were synced in this run.");
    }
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'farmName',
      'latitude',
      'longitude',
      'farmPhotos',
      'farmProfile',
      'districtID',
      'ownerName',
      'registeredBy',
      'farmerName',
      'farmerID', // Added farmerID
      'farmerDOB',
      'farmerPhone',
      'villageName',
      'parishName',
      'subcountyName',
      'districtName',
      'animalsData',
      'managementSystemsData',
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

  // Save local data
  static Future<void> saveLocally(FarmModel farm) async {
    try {
      print("Getting database instance...");
      await initTable();
      print("Saving locally");
      Database db = await Utils.getDb();
      await ensureTableColumns(db);

      print("Converting farm model to JSON...");
      final Map<String, dynamic> data = farm.toJson();

      LoggedInUserModel ul = LoggedInUserModel();

      // Set the registeredBy field
      data['registeredBy'] = ul.id;

      // Set the farmerID if the user role is 'farmer'
      // if (ul.role_name.toLowerCase() == 'farmer') {
      //   data['farmerID'] = ul.id;
      // }

      print("Farm data to insert: $data");

      print("Inserting data into the database...");
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (id == 0) {
        print("Farm already exists");
        return;
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("An error occurred while saving locally: $e");
      Utils.toast(
          "An error occurred while saving the farm data."); // Providing user feedback
    }
  }

  static Future<bool> SyncFarmToServer(FarmModel farmData) async {
    try {
      Map<String, dynamic> farm = farmData.toJson();
      farm.remove('is_synced');

      print("JSON payload being sent: ${farm}");

      RespondModel response =
          RespondModel(await Utils.http_post(FarmModel.endpoint, farm));

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
      print('Error syncing member to server: $e');
      return false;
    }
  }

  static Future<FarmModel> getItemById(String id) async {
    FarmModel item = FarmModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'farmID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = FarmModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch farm: ${e.toString()}');
    }
    return item;
  }

  static Future<int> farm_count() async {
    try {
      List<FarmModel> items = await get_items();
      print("Reports count: ${items.length}");
      return items.length;
    } catch (e) {
      print("Error counting reports: ${e.toString()}");
      return 0;
    }
  }

  static Future<FarmModel?> getFirstFarmByFarmerId(String farmerID) async {
    List<FarmModel> allFarms = await get_items();
    try {
      return allFarms.firstWhere((farm) => farm.farmerID == farmerID);
    } catch (e) {
      return null;
    }
  }

  static Future<List<FarmModel>> get_items({String where = '1'}) async {
    List<FarmModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await FarmModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      FarmModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<FarmModel>> getOnlineItems() async {
    List<FarmModel> data = [];

    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;

    RespondModel resp =
        RespondModel(await Utils.http_get('${FarmModel.endpoint}', {}));
    print("Farms response: ${resp.data}");

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
        await FarmModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          FarmModel sub = FarmModel.fromJson(x);
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

  static Future<List<FarmModel>> getLocalData({String where = "1"}) async {
    List<FarmModel> data = [];
    if (!(await FarmModel.initTable())) {
      print("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' farmID DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(FarmModel.fromJson(maps[i]));
    });

    return data;
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    // Check if it's a new entry and needs an ID
    if (farmID.isEmpty) {
      farmID = Utils.generateUniqueId(); // Set unique ID if not provided
    }

    try {
      await db.insert(tableName, toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("Farm saved with ID: $farmID");
    } catch (e) {
      print("Failed to save farm because ${e.toString()}");
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
      print("Failed to delete all farms because ${e.toString()}");
    }
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.delete(tableName, where: 'farmID = ?', whereArgs: [farmID]);
    } catch (e) {
      print("Failed to delete farm because ${e.toString()}");
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
  farmID TEXT PRIMARY KEY,
  farmName TEXT,
  latitude TEXT,
  longitude TEXT,
  farmPhotos TEXT,
  farmProfile TEXT,
  districtID TEXT,
  ownerName TEXT,
  registeredBy TEXT,
  farmerName TEXT,
  farmerID TEXT,
  farmerDOB TEXT,
  farmerPhone TEXT,
  villageName TEXT,
  parishName TEXT,
  subcountyName TEXT,
  districtName TEXT,
  animalsData TEXT,
  managementSystemsData TEXT,
  isSynced INTEGER DEFAULT 0
)''';

    try {
      await db.execute(sql);
      print('Farm table created successfully or already exists.');
      return true;
    } catch (e) {
      print('Failed to create farm table because ${e.toString()}');
      return false;
    }
  }
}
