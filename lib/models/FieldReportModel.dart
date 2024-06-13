import 'package:intl/intl.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class ReportModel {
  static String tableName = 'reports';
  static String endpoint = 'reports';
  int reportID = 0;
  String report_id = '';
  String farmID;
  String content = '';
  String surveyType = '';
  String season = '';
  String diseaseType = '';
  String bioSecurityMeasures;
  String feedingMechanisms;
  String otherBioSecurityMeasures = '';
  String otherFeedingMechanisms = '';
  int submittedByID = 0;
  String submitterName = '';
  String creationDate;
  String submissionDate;
  String status = '';

  ReportModel({
    this.reportID = 0,
    this.report_id = '',
    this.farmID = '',
    this.content = '',
    this.surveyType = '',
    this.season = '',
    this.diseaseType = '',
    this.bioSecurityMeasures = '',
    this.feedingMechanisms = '',
    this.otherBioSecurityMeasures = '',
    this.otherFeedingMechanisms = '',
    this.submittedByID = 0,
    this.submitterName = '',
    this.creationDate = '',
    this.submissionDate = '',
    this.status = '',
  });

  // Method to fetch reports filtered by farm ID
  static Future<List<ReportModel>> getReportsByFarmId(String farmId) async {
    List<ReportModel> allReports = await get_items();
    // Filter the reports by farm ID
    return allReports.where((report) => report.farmID == farmId).toList();
  }

  static Future<ReportModel> getItemById(String reportId) async {
    ReportModel item = ReportModel();
    try {
      List<ReportModel> items = await ReportModel.get_items();
      // Filter to get the report with the specified report_id
      item = items.firstWhere((report) => report.report_id == reportId,
          orElse: () => ReportModel());
    } catch (e) {
      item = ReportModel();
    }
    return item;
  }

  static ReportModel fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportID: Utils.int_parse(json['reportID']),
      report_id: Utils.to_str(json['report_id'], ''),
      farmID: Utils.to_str(json['farmID'], ''),
      content: Utils.to_str(json['content'], ''),
      surveyType: Utils.to_str(json['surveyType'], ''),
      season: Utils.to_str(json['season'], ''),
      diseaseType: Utils.to_str(json['diseaseType'], ''),
      bioSecurityMeasures: Utils.to_str(json['bioSecurityMeasures'], ''),
      feedingMechanisms: Utils.to_str(json['feedingMechanisms'], ''),
      otherBioSecurityMeasures:
          Utils.to_str(json['otherBioSecurityMeasures'], ''),
      otherFeedingMechanisms: Utils.to_str(json['otherFeedingMechanisms'], ''),
      submittedByID: Utils.int_parse(json['submittedByID']),
      submitterName: Utils.to_str(json['submitterName'], ''),
      creationDate: Utils.to_str(json['creationDate'], ''),
      submissionDate: Utils.to_str(json['submissionDate'], ''),
      status: Utils.to_str(json['status'], ''),
    );
  }

  static Future<List<ReportModel>> getLocalData({String where = "1"}) async {
    List<ReportModel> data = [];
    if (!(await ReportModel.initTable())) {
      print("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map<String, dynamic>> maps =
        (await db.query(tableName, where: where, orderBy: 'reportID DESC'))
            .cast<Map<String, dynamic>>(); // Casting to the correct type

    if (maps.isEmpty) {
      return data;
    }
    data = maps.map((map) => ReportModel.fromJson(map)).toList();

    return data;
  }

  static Future<int> report_count() async {
    try {
      List<ReportModel> items = await get_items();
      print("Reports count: ${items.length}");
      return items.length;
    } catch (e) {
      print("Error counting reports: ${e.toString()}");
      return 0;
    }
  }

  static Future<List<ReportModel>> get_items({String where = '1'}) async {
    print("Getting report data...");
    List<ReportModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await ReportModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      ReportModel.getOnlineItems();
      data = await getLocalData(where: where);
    }
    return data;
  }

  static Future<List<ReportModel>> getOnlineItems() async {
    List<ReportModel> data = [];

    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;

    RespondModel resp = RespondModel(
        await Utils.http_get('${ReportModel.endpoint}' + '/${user_id}', {}));
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
        await ReportModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          ReportModel sub = ReportModel.fromJson(x);
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
          print("Failed to save to commit because ${e.toString()}");
        }
      });
    }

    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      'reportID': reportID == 0
          ? null
          : reportID, // Ensure reportID is set to null for auto-increment
      'report_id': report_id,
      'farmID': farmID,
      'content': content,
      'surveyType': surveyType,
      'season': season,
      'diseaseType': diseaseType,
      'bioSecurityMeasures': bioSecurityMeasures,
      'feedingMechanisms': feedingMechanisms,
      'otherBioSecurityMeasures': otherBioSecurityMeasures,
      'otherFeedingMechanisms': otherFeedingMechanisms,
      'submittedByID': submittedByID,
      'submitterName': submitterName,
      'creationDate': creationDate,
      'submissionDate': submissionDate,
      'status': status,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'reportID',
      'report_id',
      'farmID',
      'content',
      'surveyType',
      'season',
      'diseaseType',
      'bioSecurityMeasures',
      'feedingMechanisms',
      'otherBioSecurityMeasures',
      'otherFeedingMechanisms',
      'submittedByID',
      'submitterName',
      'creationDate',
      'submissionDate',
      'status'
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

  static Future<void> saveLocally(ReportModel report) async {
    try {
      print("Saving locally");
      Database db = await Utils.getDb();
      await ensureTableColumns(db);

      final Map<String, dynamic> data = report.toJson();

      // Set default values for status and creationDate
      data['status'] = 'pending';
      data['creationDate'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      LoggedInUserModel ul = await LoggedInUserModel.getLoggedInUser();
      data['submittedByID'] = ul.id;
      data['submitterName'] = ul.name;

      print("Report data to insert: $data");

      print("Inserting report into the database...");
      int id = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (id == 0) {
        print("Report already exists with id: $id");
        return;
      }
      print("Data inserted successfully with reportID: $id.");
    } catch (e) {
      print("Local save error: $e");
      Utils.toast("An error occurred while saving the report data.");
    }
  }

  static Future<bool> SyncreportToServer(ReportModel reportData) async {
    try {
      Map<String, dynamic> report = reportData.toJson();
      report.remove('isSynced');

      RespondModel response =
          RespondModel(await Utils.http_post(ReportModel.endpoint, report));

      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error syncing report to server: $e');
      return false;
    }
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    try {
      await db.insert(
        tableName,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Failed to save report because ${e.toString()}");
    }
  }

  static Future<bool> initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = """
    CREATE TABLE IF NOT EXISTS $tableName (
        reportID INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id TEXT UNIQUE,
        farmID TEXT,
        content TEXT,
        surveyType TEXT,
        season TEXT,
        diseaseType TEXT,
        bioSecurityMeasures TEXT,
        feedingMechanisms TEXT,
        otherBioSecurityMeasures TEXT,
        otherFeedingMechanisms TEXT,
        submittedByID INTEGER,
        submitterName TEXT,
        creationDate TEXT,
        submissionDate TEXT,
        status TEXT
    );
    """;

    try {
      await db.execute(sql);
      return true;
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');
      return false;
    }
  }

  static deleteAll() async {
    if (!(await ReportModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(ReportModel.tableName);
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      print("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(tableName, where: 'id = $reportID');
    } catch (e) {
      print("Failed to save student because ${e.toString()}");
    }
  }
}
