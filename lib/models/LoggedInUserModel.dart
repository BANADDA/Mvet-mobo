import 'package:marcci/utils/AppConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class LoggedInUserModel {
  static String end_point = "logged_in_user";
  int id = 0;
  String username = "";
  String phone_number = "";
  String name = "";
  String avatar = "";
  String remember_token = "";
  String created_at = "";
  String updated_at = "";
  String district_id = "";
  String district_name = "";
  String sex = "";
  String role_id = "";
  String role_name = "";
  bool isAdmin = false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone_number': phone_number,
      'name': name,
      'avatar': avatar,
      'remember_token': remember_token,
      'created_at': created_at,
      'updated_at': updated_at,
      'district_id': district_id,
      'district_name': district_name,
      'sex': sex,
      'role_id': role_id,
      'role_name': role_name,
    };
  }

  static LoggedInUserModel fromJson(dynamic m) {
    LoggedInUserModel obj = new LoggedInUserModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['userID']);
    obj.username = Utils.to_str(m['name'], '');
    obj.phone_number = Utils.to_str(m['phoneNumber'], '');
    obj.name = Utils.to_str(m['name'], '');
    obj.avatar = Utils.to_str(m['avatar'], '');
    if (obj.avatar.contains('http')) {
      obj.avatar = "${AppConfig.MAIN_SITE_URL}/${obj.avatar}";
    }
    obj.remember_token = Utils.to_str(m['token'], '');
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.district_id = Utils.to_str(m['districtID'], '');
    obj.district_name = Utils.to_str(m['districtName'], '');
    obj.role_id = Utils.to_str(m['roleID'], '');
    obj.role_name = Utils.to_str(m['roleName'], '');
    obj.sex = Utils.to_str(m['sex'], '');

    return obj;
  }

  String s(dynamic m) {
    return Utils.to_str(m, '');
  }

  static deleteAllItems() async {}

  static Future<LoggedInUserModel> getLoggedInUser() async {
    LoggedInUserModel item = new LoggedInUserModel();

    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      print("Database is not open.");
      return item;
    }

    if (!await initTable()) {
      print("Failed to initialize table.");
      return item;
    }

    List<Map<String, dynamic>> maps =
        await db.query(LoggedInUserModel.end_point);
    if (maps.isNotEmpty) {
      // print("Raw database data: ${maps.first}");

      // Accessing fields directly from the map
      item.id = maps.first['id'];
      item.username = maps.first['username'];
      item.phone_number = maps.first['phone_number'];
      item.name = maps.first['name'];
      item.avatar = maps.first['avatar'];
      item.remember_token = maps.first['remember_token'];
      item.created_at = maps.first['created_at'];
      item.updated_at = maps.first['updated_at'];
      item.district_id = maps.first['district_id'];
      item.district_name = maps.first['district_name'];
      item.sex = maps.first['sex'];
      item.role_id = maps.first['role_id'];
      item.role_name = maps.first['role_name'];

      // Ensure that the token is retrieved and printed properly
      // print("Fetched user with token: ${item.remember_token}");
      // print("Fetched user with id: ${item.id}");
    } else {
      print("No user found in the database.");
    }

    return item;
  }

  static Future<String> get_token() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic localToken = prefs.getString('token');
    if (localToken == null || localToken.toString().length < 6) {
      LoggedInUserModel lu = await LoggedInUserModel.getLoggedInUser();
      localToken = lu.remember_token;
      await prefs.setString('token', localToken);
    }

    return localToken;
  }

  Future<bool> save() async {
    bool isSuccess = false;
    Database db = await openDatabase(AppConfig.DATABASE_PATH);

    if (!db.isOpen) {
      print("Database is not open.");
      return false;
    }

    if (!(await initTable())) {
      print("Failed to initialize the table.");
      return false;
    }

    try {
      // Delete any existing logged-in user record
      await db.delete(LoggedInUserModel.end_point);

      // Insert the new logged-in user record
      int id = await db.insert(
        LoggedInUserModel.end_point,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', remember_token);
      print("User saved successfully with ID: $id");
      isSuccess = true;
    } catch (e) {
      print("Failed to save user: ${e.toString()}");
      isSuccess = false;
    }

    return isSuccess;
  }

  Future<String> getUserTypeName() async {
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return 'Unknown User Type';
    }

    final List<Map<String, dynamic>> maps = await db
        .query(LoggedInUserModel.end_point, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Utils.to_str(maps[0]['user_type_name'], 'Unknown User Type');
    } else {
      return 'Unknown User Type';
    }
  }

  static Future<bool> initTable() async {
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return false;
    }

    String sql =
        "CREATE TABLE IF NOT EXISTS ${LoggedInUserModel.end_point} (id INTEGER PRIMARY KEY, username TEXT, phone_number TEXT, name TEXT, avatar TEXT, remember_token TEXT, created_at TEXT, updated_at TEXT, district_id TEXT, district_name TEXT, sex TEXT, role_id TEXT, role_name TEXT)";
    try {
      await db.execute(sql);
    } catch (e) {
      print('Failed to create table because ${e.toString()}');
      return false;
    }

    return true;
  }
}
