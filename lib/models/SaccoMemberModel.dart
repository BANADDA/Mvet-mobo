import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';
import 'RespondModel.dart';

class SaccoMemberModel {
  static String end_point = "sacco-members";
  static String tableName = "sacco_members_2";
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
  String sacco_text = "";
  String cycle_id = "";
  String position_id = "";
  String district_id = "";
  String parish_id = "";
  String village_id = "";
  String share_price = "";
  String sacco_join_status = "";
  String id_front = "";
  String id_back = "";
  String status = "";
  String balance = "";
  String SAVING = "";
  String SHARE = "";
  String LOAN = "";
  String LOAN_BALANCE = "";
  String LOAN_COUNT = "";
  String LOAN_INTEREST = "";
  String LOAN_REPAYMENT = "";
  String FEE = "";
  String WITHDRAWAL = "";
  String CYCLE_PROFIT = "";
  String share_out_share_price = "";
  String share_out_amount = "";
  String register = "";
  String pwd = "";

  bool hasLoan = false;

  static fromJson(dynamic m) {
    SaccoMemberModel obj = new SaccoMemberModel();
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
    obj.district_id = Utils.to_str(m['district_id'], '');
    obj.parish_id = Utils.to_str(m['parish_id'], '');
    obj.village_id = Utils.to_str(m['village_id'], '');
    obj.sacco_text = Utils.to_str(m['sacco_text'], '');
    obj.cycle_id = Utils.to_str(m['cycle_id'], '');
    obj.share_price = Utils.to_str(m['share_price'], '');
    obj.sacco_join_status = Utils.to_str(m['sacco_join_status'], '');
    obj.id_front = Utils.to_str(m['id_front'], '');
    obj.id_back = Utils.to_str(m['id_back'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.pwd = Utils.to_str(m['pwd'], '');
    obj.share_out_share_price = Utils.to_str(m['share_out_share_price'], '');
    obj.share_out_amount = Utils.to_str(m['share_out_amount'], '');
    obj.register = Utils.to_str(m['register'], '');

    obj.balance = Utils.to_str(m['balance'], '');
    obj.SAVING = Utils.to_str(m['SAVING'], '');
    obj.SHARE = Utils.to_str(m['SHARE'], '');
    obj.LOAN = Utils.to_str(m['LOAN'], '');
    obj.LOAN_COUNT = Utils.to_str(m['LOAN_COUNT'], '');
    obj.LOAN_BALANCE = Utils.to_str(m['LOAN_BALANCE'], '');
    obj.LOAN_REPAYMENT = Utils.to_str(m['LOAN_REPAYMENT'], '');
    obj.LOAN_INTEREST = Utils.to_str(m['LOAN_INTEREST'], '');
    obj.FEE = Utils.to_str(m['FEE'], '');
    obj.WITHDRAWAL = Utils.to_str(m['WITHDRAWAL'], '');
    obj.CYCLE_PROFIT = Utils.to_str(m['CYCLE_PROFIT'], '');

    if (Utils.int_parse(obj.LOAN_BALANCE) != 0) {
      obj.hasLoan = true;
    }

    return obj;
  }

  static Future<List<SaccoMemberModel>> getLocalData(
      {String where = "1"}) async {
    List<SaccoMemberModel> data = [];
    if (!(await SaccoMemberModel.initTable())) {
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
      data.add(SaccoMemberModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<SaccoMemberModel>> get_items({String where = '1'}) async {
    // Modify the where clause to exclude members with user type 'admin'
    String modifiedWhere = '$where AND user_type != "Admin"';

    List<SaccoMemberModel> data = await getLocalData(where: modifiedWhere);
    if (data.isEmpty) {
      await SaccoMemberModel.getOnlineItems();
      data = await getLocalData(where: modifiedWhere);
    } else {
      SaccoMemberModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<SaccoMemberModel>> get_admin({String where = '1'}) async {
    // Modify the where clause to exclude members with user type 'admin'
    String modifiedWhere = '$where AND user_type == "Admin"';

    List<SaccoMemberModel> data = await getLocalData(where: modifiedWhere);
    print('Data: ${data.first.name}');
    if (data.isEmpty) {
      await SaccoMemberModel.getOnlineItems();
      data = await getLocalData(where: modifiedWhere);
    } else {
      SaccoMemberModel.getOnlineItems();
    }
    return data;
  }

  static Future<SaccoMemberModel?> getAdminMemberDetailsForCycle(
      String cycleId) async {
    // Fetch all members with admin user type for the given cycle id
    List<SaccoMemberModel> adminMembers =
        await SaccoMemberModel.get_admin(where: 'cycle_id = "$cycleId"');

    // Return the first admin member found (if any)
    return adminMembers.isNotEmpty ? adminMembers.first : null;
  }

  static Future<List<SaccoMemberModel>> getUsersWithAdminType() async {
    List<SaccoMemberModel> adminUsers = [];

    List<SaccoMemberModel> allUsers = await SaccoMemberModel.getLocalData();
    if (allUsers.isEmpty) {
      await SaccoMemberModel.getOnlineItems();
      allUsers = await getLocalData();
      for (var user in allUsers) {
        if (user.user_type == 'Admin') {
          adminUsers.add(user);
        }
      }
    } else {
      for (var user in allUsers) {
        if (user.user_type == 'Admin') {
          adminUsers.add(user);
        }
      }
      SaccoMemberModel.getOnlineItems();
    }
    return adminUsers;
  }

  static Future<List<SaccoMemberModel>>
      getMembersWithNonZeroLoanBalance() async {
    List<SaccoMemberModel> membersWithNonZeroLoanBalance = [];

    List<SaccoMemberModel> allMembers = await getLocalData();

    for (var member in allMembers) {
      if (double.parse(member.LOAN_BALANCE) != 0) {
        membersWithNonZeroLoanBalance.add(member);
      }
    }

    return membersWithNonZeroLoanBalance;
  }

  static Future<List<SaccoMemberModel>> getOnlineItems() async {
    List<SaccoMemberModel> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get('${SaccoMemberModel.end_point}', {}));

    print('Response: ${resp.data}');

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
        await SaccoMemberModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          SaccoMemberModel sub = SaccoMemberModel.fromJson(x);
          // print('Data inserted: $x');
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
      'pwd': pwd,
      'share_out_share_price': share_out_share_price,
      'share_out_amount': share_out_amount,
      'intro': intro,
      'sacco_id': sacco_id,
      'position_id': position_id,
      'district_id': district_id,
      'parish_id': parish_id,
      'village_id': village_id,
      'sacco_text': sacco_text,
      'cycle_id': cycle_id,
      'share_price': share_price,
      'sacco_join_status': sacco_join_status,
      'id_front': id_front,
      'id_back': id_back,
      'status': status,
      'balance': balance,
      'SAVING': SAVING,
      'SHARE': SHARE,
      'LOAN': LOAN,
      'LOAN_COUNT': LOAN_COUNT,
      'LOAN_BALANCE': LOAN_BALANCE,
      'LOAN_REPAYMENT': LOAN_REPAYMENT,
      'LOAN_INTEREST': LOAN_INTEREST,
      'FEE': FEE,
      'WITHDRAWAL': WITHDRAWAL,
      'CYCLE_PROFIT': CYCLE_PROFIT,
      'register': register,
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
        ",pwd TEXT"
        ",share_out_share_price TEXT"
        ",share_out_amount TEXT"
        ",intro TEXT"
        ",sacco_id TEXT"
        ",position_id TEXT"
        ",district_id TEXT"
        ",parish_id TEXT"
        ",village_id TEXT"
        ",cycle_id TEXT"
        ",share_price TEXT"
        ",sacco_text TEXT"
        ",sacco_join_status TEXT"
        ",id_front TEXT"
        ",id_back TEXT"
        ",status TEXT"
        ",balance TEXT"
        ",SAVING TEXT"
        ",SHARE TEXT"
        ",LOAN TEXT"
        ",LOAN_COUNT TEXT"
        ",LOAN_BALANCE TEXT"
        ",LOAN_REPAYMENT TEXT"
        ",LOAN_INTEREST TEXT"
        ",FEE TEXT"
        ",WITHDRAWAL TEXT"
        ",CYCLE_PROFIT TEXT"
        ",register TEXT"
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
    if (!(await SaccoMemberModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(SaccoMemberModel.tableName);
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

  static Future<Map<String, String>> getUserSummaryForCycle(
      int memberId) async {
    Map<String, String> summary = {
      'totalSavings': '0',
      'totalShares': '0',
    };

    // int? cycleId = await CycleModel.getActiveCycleID();
    // print('Cycle Id: $cycleId');

    // Calculate total savings and shares for the given cycle and member
    List<SaccoMemberModel> memberData = await getLocalData(
      where: ' id = "$memberId"',
    );

    print('Member data: ${memberData.first.balance}');
    print('Member data: ${memberData.first.SHARE}');

    if (memberData.isNotEmpty) {
      String totalSavings = '0';
      String totalShares = '0';

      summary['totalSavings'] = totalSavings.toString();

      totalShares = memberData.first.SHARE;
      totalSavings = memberData.first.balance;
      print('Total Shares test: $totalShares');
      summary['totalShares'] = totalShares.toString();
      summary['totalSavings'] = totalSavings.toString();
      print('Summary: ${summary['totalShares']}');
      print('Total Shares: $totalShares');
    }

    return summary;
  }

  static Future<String> getUserNameById(String userId) async {
    List<SaccoMemberModel> allMembers = await SaccoMemberModel.getLocalData();

    // Find the member with the matching user_id
    SaccoMemberModel? user = allMembers.firstWhereOrNull(
      (member) => member.id.toString() == userId,
    );

    return user?.name ?? '';
  }
}
