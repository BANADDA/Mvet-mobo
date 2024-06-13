import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart'; // Utility class for common operations like database access

class FieldUserModel {
  static String tableName = 'users';
  static String endpoint = 'users';
  int userID = 0;
  String name = "";
  String phoneNumber = "";
  int roleID = 0;
  int districtID = 0;
  String districtName = "";
  String roleName = "";
  int reportCount = 0;

  FieldUserModel({
    this.userID = 0,
    this.name = "",
    this.phoneNumber = "",
    this.roleID = 0,
    this.districtID = 0,
    this.districtName = "",
    this.roleName = "",
    this.reportCount = 0,
  });

  static FieldUserModel fromJson(dynamic m) {
    FieldUserModel obj = new FieldUserModel();
    if (m == null) {
      return obj;
    }
    return FieldUserModel(
      userID: Utils.int_parse(m['userID']),
      name: Utils.to_str(m['name'], ''),
      phoneNumber: Utils.to_str(m['phoneNumber'], ''),
      roleID: Utils.int_parse(m['roleID']),
      districtID: Utils.int_parse(m['districtID']),
      districtName: Utils.to_str(m['districtName'], ''),
      roleName: Utils.to_str(m['roleName'], ''),
      reportCount: Utils.int_parse(m['reportCount']) ??
          0, // Default to 0 if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'phoneNumber': phoneNumber,
      'roleID': roleID,
      'districtID': districtID,
      'districtName': districtName,
      'roleName': roleName,
      'reportCount': reportCount,
    };
  }

  static Future<FieldUserModel> getItemById(int id) async {
    FieldUserModel item = FieldUserModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'userID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = FieldUserModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch user: ${e.toString()}');
    }
    return item;
  }

  static Future<int> farmer_count() async {
    try {
      // Fetch all users
      List<FieldUserModel> items = await get_items();
      // Filter users where roleID is 6 and count them
      int count = items.where((user) => user.roleID == 6).length;
      print("User count with roleID 6: $count");
      return count;
    } catch (e) {
      print("Error counting users: ${e.toString()}");
      return 0;
    }
  }

  static Future<List<FieldUserModel>> get_items({String where = '1'}) async {
    List<FieldUserModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await FieldUserModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      FieldUserModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<FieldUserModel>> getOnlineItems() async {
    List<FieldUserModel> data = [];

    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;

    RespondModel resp =
        RespondModel(await Utils.http_get('${FieldUserModel.endpoint}', {}));
    print("Reports response: ${resp.data}");

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
        await FieldUserModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          FieldUserModel sub = FieldUserModel.fromJson(x);
          try {
            batch.insert(tableName, sub.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          } catch (e) {
            print("faied to save becaus ${e.toString()}");
          }
        }

        try {
          await batch.commit(continueOnError: true);
        } catch (e) {
          print("faied to save to commit BRECASE == ${e.toString()}");
        }
      });
    }

    return data;
  }

  static Future<List<FieldUserModel>> getLocalData({String where = "1"}) async {
    List<FieldUserModel> data = [];
    if (!(await FieldUserModel.initTable())) {
      print("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' userID DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(FieldUserModel.fromJson(maps[i]));
    });

    return data;
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.insert(tableName, toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Failed to save user because ${e.toString()}");
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
      print("Failed to delete all users because ${e.toString()}");
    }
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.delete(tableName, where: 'userID = ?', whereArgs: [userID]);
    } catch (e) {
      print("Failed to delete user because ${e.toString()}");
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
  userID INTEGER PRIMARY KEY,
  name TEXT,
  phoneNumber TEXT,
  roleID INTEGER,
  districtID INTEGER,
  districtName TEXT,
  roleName TEXT,
  reportCount INTEGER
)''';

    try {
      await db.execute(sql);
      print('User table created successfully or already exists.');
      return true;
    } catch (e) {
      print('Failed to create user table because ${e.toString()}');
      return false;
    }
  }
}
