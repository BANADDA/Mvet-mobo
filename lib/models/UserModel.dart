import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';
import 'RespondModel.dart';

class UserModel {
  static String end_point_1 = "sacco-members";
  static String tableName = "users";
  int id = 0;
  String username = "";
  String password = "";
  String first_name = "";
  String last_name = "";
  String reg_date = "";
  String last_seen = "";
  String email = "";
  String approved = "";
  String profile_photo = "";
  String user_type = "";
  String sex = "";
  String reg_number = "";
  String country = "";
  String occupation = "";
  String profile_photo_large = "";
  String phone_number = "";
  String location_lat = "";
  String location_long = "";
  String facebook = "";
  String twitter = "";
  String whatsapp = "";
  String linkedin = "";
  String website = "";
  String other_link = "";
  String cv = "";
  String language = "";
  String about = "";
  String address = "";
  String created_at = "";
  String updated_at = "";
  String remember_token = "";
  String avatar = "";
  String name = "";
  String campus_id = "";
  String campus_text = "";
  String complete_profile = "";
  String title = "";
  String dob = "";
  String intro = "";
  String sacco_id = "";
  String position_id = "";
  String sacco_text = "";
  String sacco_join_status = "";
  String id_front = "";
  String id_back = "";
  String status = "";
  String balance = "";

  static Future<UserModel> getItemById(String id) async {
    UserModel item = UserModel();
    try {
      List<UserModel> items = await UserModel.get_items(where: "id = $id");
      if (items.isNotEmpty) {
        item = items.first;
      }
    } catch (E) {
      item = UserModel();
    }
    return item;
  }

  static fromJson(dynamic m) {
    UserModel obj = new UserModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.username = Utils.to_str(m['username'], '');
    obj.password = Utils.to_str(m['password'], '');
    obj.first_name = Utils.to_str(m['first_name'], '');
    obj.last_name = Utils.to_str(m['last_name'], '');
    obj.reg_date = Utils.to_str(m['reg_date'], '');
    obj.last_seen = Utils.to_str(m['last_seen'], '');
    obj.email = Utils.to_str(m['email'], '');
    obj.approved = Utils.to_str(m['approved'], '');
    obj.profile_photo = Utils.to_str(m['profile_photo'], '');
    obj.user_type = Utils.to_str(m['user_type'], '');
    obj.sex = Utils.to_str(m['sex'], '');
    obj.reg_number = Utils.to_str(m['reg_number'], '');
    obj.country = Utils.to_str(m['country'], '');
    obj.occupation = Utils.to_str(m['occupation'], '');
    obj.profile_photo_large = Utils.to_str(m['profile_photo_large'], '');
    obj.phone_number = Utils.to_str(m['phone_number'], '');
    obj.location_lat = Utils.to_str(m['location_lat'], '');
    obj.location_long = Utils.to_str(m['location_long'], '');
    obj.facebook = Utils.to_str(m['facebook'], '');
    obj.twitter = Utils.to_str(m['twitter'], '');
    obj.whatsapp = Utils.to_str(m['whatsapp'], '');
    obj.linkedin = Utils.to_str(m['linkedin'], '');
    obj.website = Utils.to_str(m['website'], '');
    obj.other_link = Utils.to_str(m['other_link'], '');
    obj.cv = Utils.to_str(m['cv'], '');
    obj.language = Utils.to_str(m['language'], '');
    obj.about = Utils.to_str(m['about'], '');
    obj.address = Utils.to_str(m['address'], '');
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.remember_token = Utils.to_str(m['remember_token'], '');
    obj.avatar = Utils.to_str(m['avatar'], '');
    obj.name = Utils.to_str(m['name'], '');
    obj.campus_id = Utils.to_str(m['campus_id'], '');
    obj.campus_text = Utils.to_str(m['campus_text'], '');
    obj.complete_profile = Utils.to_str(m['complete_profile'], '');
    obj.title = Utils.to_str(m['title'], '');
    obj.dob = Utils.to_str(m['dob'], '');
    obj.intro = Utils.to_str(m['intro'], '');
    obj.sacco_id = Utils.to_str(m['sacco_id'], '');
    obj.position_id = Utils.to_str(m['position_id'], '');
    obj.sacco_text = Utils.to_str(m['sacco_text'], '');
    obj.sacco_join_status = Utils.to_str(m['sacco_join_status'], '');
    obj.id_front = Utils.to_str(m['id_front'], '');
    obj.id_back = Utils.to_str(m['id_back'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.balance = Utils.to_str(m['balance'], '');

    return obj;
  }

  static Future<List<UserModel>> getLocalData({String where = "1"}) async {
    List<UserModel> data = [];
    if (!(await UserModel.initTable())) {
      Utils.toast("Failed to init dynamic store.");
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
      data.add(UserModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<UserModel>> get_items({String where = '1'}) async {
    List<UserModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await UserModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      UserModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<UserModel>> getOnlineItems() async {
    List<UserModel> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get('${UserModel.end_point_1}', {}));

    if (resp.code != 1) {
      return [];
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return [];
    }

    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await UserModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          UserModel sub = UserModel.fromJson(x);
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

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.insert(
        tableName,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }

  toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'first_name': first_name,
      'last_name': last_name,
      'reg_date': reg_date,
      'last_seen': last_seen,
      'email': email,
      'approved': approved,
      'profile_photo': profile_photo,
      'user_type': user_type,
      'sex': sex,
      'reg_number': reg_number,
      'country': country,
      'occupation': occupation,
      'profile_photo_large': profile_photo_large,
      'phone_number': phone_number,
      'location_lat': location_lat,
      'location_long': location_long,
      'facebook': facebook,
      'twitter': twitter,
      'whatsapp': whatsapp,
      'linkedin': linkedin,
      'website': website,
      'other_link': other_link,
      'cv': cv,
      'language': language,
      'about': about,
      'address': address,
      'created_at': created_at,
      'updated_at': updated_at,
      'remember_token': remember_token,
      'avatar': avatar,
      'name': name,
      'campus_id': campus_id,
      'campus_text': campus_text,
      'complete_profile': complete_profile,
      'title': title,
      'dob': dob,
      'intro': intro,
      'sacco_id': sacco_id,
      'position_id': position_id,
      'sacco_text': sacco_text,
      'sacco_join_status': sacco_join_status,
      'id_front': id_front,
      'id_back': id_back,
      'status': status,
      'balance': balance,
    };
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = " CREATE TABLE IF NOT EXISTS "
        "$tableName ("
        "id INTEGER PRIMARY KEY"
        ",username TEXT"
        ",password TEXT"
        ",first_name TEXT"
        ",last_name TEXT"
        ",reg_date TEXT"
        ",last_seen TEXT"
        ",email TEXT"
        ",approved TEXT"
        ",profile_photo TEXT"
        ",user_type TEXT"
        ",sex TEXT"
        ",reg_number TEXT"
        ",country TEXT"
        ",occupation TEXT"
        ",profile_photo_large TEXT"
        ",phone_number TEXT"
        ",location_lat TEXT"
        ",location_long TEXT"
        ",facebook TEXT"
        ",twitter TEXT"
        ",whatsapp TEXT"
        ",linkedin TEXT"
        ",website TEXT"
        ",other_link TEXT"
        ",cv TEXT"
        ",language TEXT"
        ",about TEXT"
        ",address TEXT"
        ",created_at TEXT"
        ",updated_at TEXT"
        ",remember_token TEXT"
        ",avatar TEXT"
        ",name TEXT"
        ",campus_id TEXT"
        ",campus_text TEXT"
        ",complete_profile TEXT"
        ",title TEXT"
        ",dob TEXT"
        ",intro TEXT"
        ",sacco_id TEXT"
        ",position_id TEXT"
        ",sacco_text TEXT"
        ",sacco_join_status TEXT"
        ",id_front TEXT"
        ",id_back TEXT"
        ",status TEXT"
        ",balance TEXT"
        ")";

    try {
      //await db.execute("DROP TABLE ${tableName}");
      await db.execute(sql);
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');

      return false;
    }

    return true;
  }

  static deleteAll() async {
    if (!(await UserModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(UserModel.tableName);
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(tableName, where: 'id = $id');
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }
}
