import 'dart:convert';

import 'package:marcci/utils/AppConfig.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';
import 'RespondModel.dart';

class ManifestModel {
  static String end_point = "manifest";
  static String table_name = "manifest_1";
  int id = 1;
  String data = "";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
    };
  }

  static ManifestModel fromJson(dynamic m) {
    ManifestModel obj = new ManifestModel();
    if (m == null) {
      return obj;
    }

    obj.id = 1;
    obj.data = Utils.to_str(m['data'], '');

    return obj;
  }

  String s(dynamic m) {
    return Utils.to_str(m, '');
  }

  static deleteAllItems() async {}

  static Future<ManifestModel> getItems({String where = '1'}) async {
    List<ManifestModel> items = await ManifestModel.getLocalData(where);
    ManifestModel.getOnlineData();

    if (items.isEmpty) {
      await ManifestModel.getOnlineData();
      items = await ManifestModel.getLocalData(where);
    }
    if (items.isEmpty) {
      return ManifestModel();
    }
    ManifestModel man = items[0];
    if (man.data.length > 2) {
      dynamic _json = json.decode(man.data);
      if (_json is Map) {
        man.balance = Utils.to_str(_json['balance'], '0.00');
      }
      try {
        if (_json['sacco'] != null) {}
      } catch (e) {
        Utils.log("Failed to parse sacco because ${e.toString()}");
      }
    }

    return items[0];
  }

  String balance = "0.00";

  static Future<void> getOnlineData() async {
    if (!(await Utils.is_connected())) {
      return;
    }

    RespondModel resp =
        RespondModel(await Utils.http_get('${ManifestModel.end_point}', {}));

    if (resp.code != 1) {
      return;
    }

    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await db.transaction((txn) async {
      try {
        await txn.insert(
          ManifestModel.table_name,
          {
            'id': 1,
            'data': resp.data.toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        Utils.toast("Failed to save student because ${e.toString()}");
      }
    });

    return;
  }

  static Future<List<ManifestModel>> getLocalData(String where) async {
    List<ManifestModel> data = [];
    if (!(await ManifestModel.initTable())) {
      Utils.toast("Failed to init students store.");
      return data;
    }
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(ManifestModel.table_name, where: where);

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(ManifestModel.fromJson(maps[i]));
    });
    return data;
  }

  Future<bool> save() async {
    bool isSuccess = false;
    if (!(await initTable())) {
      return false;
    }
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return false;
    }

    try {
      await db.insert(
        ManifestModel.table_name,
        {
          'id': 1,
          'data': toJson().toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      isSuccess = true;
    } catch (e) {
      Utils.toast("Failed because ${e.toString()}");
      isSuccess = false;
    }

    return isSuccess;
  }

  static Future<bool> initTable() async {
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return false;
    }

    String sql =
        "CREATE TABLE IF NOT EXISTS ${ManifestModel.table_name} (id INTEGER PRIMARY KEY, data TEXT)";
    try {
      await db.execute(sql);
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');
      return false;
    }

    return true;
  }
}
