import 'package:marcci/main.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/Utils.dart';

class AnimalFormModel {
  static String tableName = 'animals';
  static String endpoint = 'animals';
  String animalID;
  String tagNumber;
  String animalName;
  String reportID;
  int age;
  String breed;
  String sex;
  String vaccinationStatus;
  String dewormingStatus;
  String previousIllness;
  String bodyPosture;
  double bodyScore;
  String temperament;
  double rectalTemperature;
  String heartSounds;
  int heartRate;
  String lungSounds;
  int respiratoryRate;
  String stockingDate;
  String cattleSource;
  String clinicalSymptoms;
  String tentativeDiagnosis;
  String otherSuspectedDisease;
  String supportiveTreatment;
  String prognosis;
  bool isSynced;

  AnimalFormModel({
    this.animalID = '',
    this.tagNumber = '',
    this.animalName = '',
    this.age = 0,
    this.breed = '',
    this.sex = '',
    this.reportID = '',
    this.vaccinationStatus = '',
    this.dewormingStatus = '',
    this.previousIllness = '',
    this.bodyPosture = '',
    this.bodyScore = 0.0,
    this.temperament = '',
    this.rectalTemperature = 0.0,
    this.heartSounds = '',
    this.heartRate = 0,
    this.lungSounds = '',
    this.respiratoryRate = 0,
    this.stockingDate = '',
    this.cattleSource = '',
    this.clinicalSymptoms = '',
    this.tentativeDiagnosis = '',
    this.otherSuspectedDisease = '',
    this.supportiveTreatment = '',
    this.prognosis = '',
    this.isSynced = false,
  });

  static AnimalFormModel fromJson(dynamic m) {
    if (m == null) {
      return AnimalFormModel();
    }
    return AnimalFormModel(
      animalID: Utils.to_str(m['animalID'], ''),
      tagNumber: Utils.to_str(m['tagNumber'], ''),
      animalName: Utils.to_str(m['animalName'], ''),
      age: Utils.to_int(m['age'], 0),
      breed: Utils.to_str(m['breed'], ''),
      sex: Utils.to_str(m['sex'], ''),
      reportID: Utils.to_str(m['reportID'], ''),
      vaccinationStatus: Utils.to_str(m['vaccinationStatus'], ''),
      dewormingStatus: Utils.to_str(m['dewormingStatus'], ''),
      previousIllness: Utils.to_str(m['previousIllness'], ''),
      bodyPosture: Utils.to_str(m['bodyPosture'], ''),
      bodyScore: Utils.to_double(m['bodyScore'], 0.0),
      temperament: Utils.to_str(m['temperament'], ''),
      rectalTemperature: Utils.to_double(m['rectalTemperature'], 0.0),
      heartSounds: Utils.to_str(m['heartSounds'], ''),
      heartRate: Utils.to_int(m['heartRate'], 0),
      lungSounds: Utils.to_str(m['lungSounds'], ''),
      respiratoryRate: Utils.to_int(m['respiratoryRate'], 0),
      stockingDate: Utils.to_str(m['stockingDate'], ''),
      cattleSource: Utils.to_str(m['cattleSource'], ''),
      clinicalSymptoms: Utils.to_str(m['clinicalSymptoms'], ''),
      tentativeDiagnosis: Utils.to_str(m['tentativeDiagnosis'], ''),
      otherSuspectedDisease: Utils.to_str(m['otherSuspectedDisease'], ''),
      supportiveTreatment: Utils.to_str(m['supportiveTreatment'], ''),
      prognosis: Utils.to_str(m['prognosis'], ''),
      isSynced: m['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalID': animalID.isEmpty ? Utils.generateUniqueId() : animalID,
      'tagNumber': tagNumber,
      'animalName': animalName,
      'age': age,
      'breed': breed,
      'sex': sex,
      'reportID': reportID ?? '',
      'vaccinationStatus': vaccinationStatus,
      'dewormingStatus': dewormingStatus,
      'previousIllness': previousIllness,
      'bodyPosture': bodyPosture,
      'bodyScore': bodyScore,
      'temperament': temperament,
      'rectalTemperature': rectalTemperature,
      'heartSounds': heartSounds,
      'heartRate': heartRate,
      'lungSounds': lungSounds,
      'respiratoryRate': respiratoryRate,
      'stockingDate': stockingDate,
      'cattleSource': cattleSource,
      'clinicalSymptoms': clinicalSymptoms,
      'tentativeDiagnosis': tentativeDiagnosis,
      'otherSuspectedDisease': otherSuspectedDisease,
      'supportiveTreatment': supportiveTreatment,
      'prognosis': prognosis,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static Future<void> ensureTableColumns(Database db) async {
    List<String> requiredColumns = [
      'animalID',
      'tagNumber',
      'animalName',
      'age',
      'breed',
      'sex',
      'reportID',
      'vaccinationStatus',
      'dewormingStatus',
      'previousIllness',
      'bodyPosture',
      'bodyScore',
      'temperament',
      'rectalTemperature',
      'heartSounds',
      'heartRate',
      'lungSounds',
      'respiratoryRate',
      'stockingDate',
      'cattleSource',
      'clinicalSymptoms',
      'tentativeDiagnosis',
      'otherSuspectedDisease',
      'supportiveTreatment',
      'prognosis',
      'isSynced'
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

  static Future<void> saveLocally(AnimalFormModel form) async {
    try {
      Database db = await Utils.getDb();
      await ensureTableColumns(db); // Ensure columns are present
      final Map<String, dynamic> data = form.toJson();
      LoggedInUserModel ul = LoggedInUserModel();

      await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      print("Local save error: $e");
      Utils.toast("An error occurred while saving the animal form data.");
    }
  }

  static Future<void> syncLocalDataToServer() async {
    final Database db = await Utils.getDb();
    final List<Map<String, dynamic>> unsyncedForms = await db.query(
      tableName,
      where: 'isSynced = 0',
    );
    int syncedCount = 0;
    for (var form in unsyncedForms) {
      AnimalFormModel data = AnimalFormModel.fromJson(form);
      bool success = await SyncFormToServer(data);
      if (success) {
        await db.update(
          tableName,
          {'isSynced': 1},
          where: 'animalID = ?',
          whereArgs: [data.animalID],
        );
        syncedCount++;
      }
    }
    if (syncedCount > 0) {
      await showNotification("Sync Complete",
          "$syncedCount records have been successfully synced.");
    }
  }

  static Future<bool> SyncFormToServer(AnimalFormModel formData) async {
    try {
      Map<String, dynamic> form = formData.toJson();
      form.remove('isSynced');
      RespondModel response =
          RespondModel(await Utils.http_post(AnimalFormModel.endpoint, form));
      if (response.code == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<AnimalFormModel> getItemById(int id) async {
    AnimalFormModel item = AnimalFormModel();
    try {
      Database db = await Utils.getDb();
      List<Map> maps =
          await db.query(tableName, where: 'animalID = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        item = AnimalFormModel.fromJson(maps.first);
      }
    } catch (e) {
      print('Failed to fetch animal form: ${e.toString()}');
    }
    return item;
  }

  static Future<int> formCount() async {
    try {
      List<AnimalFormModel> items = await getItems();
      return items.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<AnimalFormModel>> getItems({String where = '1'}) async {
    List<AnimalFormModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await AnimalFormModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      AnimalFormModel.getOnlineItems();
      data = await getLocalData(where: where);
    }
    return data;
  }

  static Future<List<AnimalFormModel>> getOnlineItems() async {
    List<AnimalFormModel> data = [];
    LoggedInUserModel authUser = LoggedInUserModel();
    int user_id = authUser.id;
    RespondModel resp =
        RespondModel(await Utils.http_get('${AnimalFormModel.endpoint}', {}));
    if (resp.code != 1) {
      return [];
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return [];
    }
    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await AnimalFormModel.deleteAll();
      }
      await db.transaction((txn) async {
        var batch = txn.batch();
        for (var x in resp.data) {
          AnimalFormModel sub = AnimalFormModel.fromJson(x);
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

  static Future<List<AnimalFormModel>> getLocalData(
      {String where = "1"}) async {
    List<AnimalFormModel> data = [];
    if (!(await AnimalFormModel.initTable())) {
      return [];
    }
    try {
      Database db = await Utils.getDb();
      List<Map> maps = await db.query(tableName, where: where);
      if (maps.isNotEmpty) {
        for (var x in maps) {
          data.add(AnimalFormModel.fromJson(x));
        }
      }
    } catch (e) {
      print("Local data fetch error: $e");
    }
    return data;
  }

  static Future<bool> initTable() async {
    try {
      Database db = await Utils.getDb();
      await db.execute('''
      CREATE TABLE IF NOT EXISTS animals (
        animalID TEXT PRIMARY KEY,
        tagNumber TEXT,
        animalName TEXT,
        age INTEGER,
        breed TEXT,
        sex TEXT,
        reportID TEXT,
        vaccinationStatus TEXT,
        dewormingStatus TEXT,
        previousIllness TEXT,
        bodyPosture TEXT,
        bodyScore REAL,
        temperament TEXT,
        rectalTemperature REAL,
        heartSounds TEXT,
        heartRate INTEGER,
        lungSounds TEXT,
        respiratoryRate INTEGER,
        stockingDate TEXT,
        cattleSource TEXT,
        clinicalSymptoms TEXT,
        tentativeDiagnosis TEXT,
        otherSuspectedDisease TEXT,
        supportiveTreatment TEXT,
        prognosis TEXT,
        isSynced INTEGER
      )
    ''');
      return true;
    } catch (e) {
      print("Error initializing table: $e");
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
