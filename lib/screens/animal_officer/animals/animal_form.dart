import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/AnimalFormModel.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/SampleModel.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/utils/dimensions.dart';
import 'package:marcci/widgets/appbar.dart';

class AnimalInfoFormScreen extends StatefulWidget {
  final String reportId;
  final FarmModel selectedFarm;
  final int formNumber;
  final VoidCallback onFormAdded;

  AnimalInfoFormScreen({
    required this.reportId,
    required this.selectedFarm,
    required this.formNumber,
    required this.onFormAdded,
  });

  @override
  _AnimalInfoFormScreenState createState() => _AnimalInfoFormScreenState();
}

class _AnimalInfoFormScreenState extends State<AnimalInfoFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Map<String, dynamic>> vaccineEntries = [];
  List<Map<String, dynamic>> dewormingEntries = [];
  List<Map<String, dynamic>> illnessEntries = [];

  Map<String, String> imagePaths = {};
  Map<String, String> symptomImages = {};

  bool isSubmitting = false;
  String report_id = '';

  @override
  void initState() {
    super.initState();
    report_id = widget.reportId;
    print("Report Id for animal form: $report_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FxAppBar(
          titleText: "Animal Form",
          onSettings: () {
            Get.to(() => AppSettings());
          },
          onBack: () {
            Navigator.pop(context);
          },
        ),
        body: Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  buildDetailsContainer(context),
                  SizedBox(height: 20),
                  buildBreedContainer(context),
                  SizedBox(height: 20),
                  buildVaccinationContainer(context),
                  SizedBox(height: 20),
                  buildDewormingContainer(context),
                  SizedBox(height: 20),
                  buildIllnessContainer(context),
                  SizedBox(height: 20),
                  buildBodyPostureAndTemperamentContainer(context),
                  SizedBox(height: 20),
                  buildTemperatureAndSoundContainer(context),
                  SizedBox(height: 20),
                  buildStockingContainer(context),
                  SizedBox(height: 20),
                  buildClinicalSymptomsContainer(context),
                  SizedBox(height: 20),
                  buildAnimalPhotoContainer(context),
                  SizedBox(height: 20),
                  buildTentativeDiagnosisContainer(context),
                  SizedBox(height: 20),
                  buildSampleAttachmentContainer(context),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: handleSubmit,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 4, 64, 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20))),
                  SizedBox(
                    height: 35,
                  )
                ],
              ),
            ),
          ),
          if (isSubmitting)
            Container(
              color: Colors.black45,
              child: const Center(
                child: SpinKitCircle(color: Colors.white, size: 50.0),
              ),
            )
        ]));
  }

  void handleSubmit() async {
    print("Handling form submission");

    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => isSubmitting = true);
      var formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      try {
        // Reassign the form data fields to the correct column names
        formData['animalID'] = ''; // Generate a unique ID if needed
        formData['tagNumber'] = formData['tag_number'];
        formData['animalName'] = formData['animal_name'];
        formData['reportID'] = report_id;
        formData['age'] = int.parse(formData['age']);
        formData['breed'] = formData['breed'];
        formData['sex'] = formData['sex'];
        formData['vaccinationStatus'] = formData['vaccination_status'];
        formData['dewormingStatus'] = formData['deworming_status'];
        formData['previousIllness'] = formData['previous_illness'];
        formData['bodyPosture'] = formData['body_posture'];
        formData['bodyScore'] = double.parse(formData['body_score'].toString());
        formData['temperament'] = formData['temperament'];
        formData['rectalTemperature'] =
            double.parse(formData['rectal_temperature'] ?? '0.0');
        formData['heartSounds'] = formData['heart_sounds'];
        formData['heartRate'] = int.parse(formData['heart_rate'] ?? '0');
        formData['lungSounds'] = formData['lung_sounds'];
        formData['respiratoryRate'] =
            int.parse(formData['respiratory_rate'] ?? '0');
        formData['stockingDate'] = formData['stocking_date'] != null
            ? DateFormat('yyyy-MM-dd').format(formData['stocking_date'])
            : '';
        formData['cattleSource'] = formData['cattle_source'];
        formData['clinicalSymptoms'] = formData['clinical_symptoms'];
        formData['tentativeDiagnosis'] = formData['tentative_diagnosis'];
        formData['otherSuspectedDisease'] = formData['other_suspected_disease'];
        formData['supportiveTreatment'] = formData['supportive_treatment'];
        formData['prognosis'] = formData['prognosis'];
        formData['isSynced'] = false;

        if (imagePaths.isNotEmpty) {
          formData['imagePaths'] = imagePaths;
        }

        if (symptomImages.isNotEmpty) {
          formData['symptomImages'] = symptomImages;
        }

        print('Form Data with Images: $formData');

        // Save animal form locally
        AnimalFormModel animalForm = AnimalFormModel.fromJson(formData);
        await AnimalFormModel.saveLocally(animalForm);

        // Only handle samples if they are provided
        if (samples.isNotEmpty) {
          List<Map<String, dynamic>> sampleMaps = samples.map((sample) {
            return {
              'sampleType': sample['sampleType'],
              'reportID': report_id,
              'sampleUUID': sample['sampleID'],
            };
          }).toList();

          for (var sampleData in sampleMaps) {
            SampleModel sample = SampleModel.fromJson(sampleData);
            await SampleModel.saveLocally(sample);
          }

          print('Samples: $sampleMaps');
        }

        _showSnackBar("Success! Animal form created successfully.",
            Color.fromARGB(255, 3, 68, 5));
        widget.onFormAdded(); // Call the callback function
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar("An error occurred.", Color.fromARGB(255, 91, 4, 4));
        print(e);
      } finally {
        setState(() => isSubmitting = false);
      }
    } else {
      print('Validation failed');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      margin: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
    ));
  }

  void _showSampleBottomSheet(BuildContext context) {
    List<String> tempSamples = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Clinical Samples",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select sample type...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: [
                      'Whole Blood',
                      'Serum',
                      'Nasal Swab',
                      'Oral Swab',
                      'Probang',
                      'Hoof Sample',
                      'Fecal Sample'
                    ]
                        .map((String value) => DropdownMenuItem<String>(
                            value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          String districtName =
                              widget.selectedFarm.districtName;
                          String farmId = widget.selectedFarm.farmID;
                          String timestamp =
                              DateFormat('ddMMyyyy').format(DateTime.now());
                          String animalId =
                              widget.formNumber.toString().padLeft(2, '0');
                          String sampleType = getSampleTypeAbbreviation(value);

                          String sampleId =
                              "$districtName-$timestamp-$farmId-$animalId-$sampleType";

                          // Check if the sample ID is already in the list
                          if (!tempSamples.contains(sampleId)) {
                            tempSamples.add(sampleId);
                            samples.add({
                              'sampleType': value,
                              'sampleID': sampleId,
                            });
                          }
                        });
                      }
                    },
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tempSamples.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(tempSamples[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setModalState(() {
                              samples.removeWhere((sample) =>
                                  sample['sampleID'] == tempSamples[index]);
                              tempSamples.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Avoid adding tempSamples to samples again
                            Navigator.pop(context);
                          });
                        },
                        child: Text('Submit Samples'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 4, 64, 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> samples = [];

  Widget buildSampleAttachmentContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        color: Color.fromARGB(255, 241, 248, 242),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Clinical Sample",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showSampleBottomSheet(context),
              icon: Icon(Icons.attach_file, size: 20),
              label: Text("Attach Sample"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 4, 64, 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: const Color.fromARGB(255, 2, 12, 2),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: samples.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.white60,
                  child: ListTile(
                    title: Text(samples[index]['sampleID']),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: const Color.fromARGB(255, 126, 12, 4),
                      ),
                      onPressed: () => setState(() => samples.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTentativeDiagnosisContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Diagnosis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderTextField(
            name: 'tentative_diagnosis',
            decoration: InputDecoration(
              labelText: 'Tentative diagnosis',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'other_suspected_disease',
            decoration: InputDecoration(
              labelText: 'Any other suspected disease (this is optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'supportive_treatment',
            decoration: InputDecoration(
              labelText: 'Supportive treatment',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          FormBuilderRadioGroup(
            name: 'prognosis',
            decoration: InputDecoration(
              labelText: 'Prognosis',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            options: [
              FormBuilderFieldOption(value: 'Good', child: Text('Good')),
              FormBuilderFieldOption(value: 'Guarded', child: Text('Guarded')),
              FormBuilderFieldOption(value: 'Grave', child: Text('Grave')),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAnimalPhotoContainer(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.all(10),
          color: Color.fromARGB(255, 241, 248, 242),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Capture animal body posture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildPhotoRegion(context, 'Front', Icons.camera_front,
                      'assets/images/front_placeholder.jpg'),
                  buildPhotoRegion(context, 'Rear', Icons.camera_rear,
                      'assets/images/rear_placeholder.jpg'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildPhotoRegion(context, 'Right', Icons.camera,
                      'assets/images/right_placeholder.jpg'),
                  buildPhotoRegion(context, 'Left', Icons.camera,
                      'assets/images/left_placeholder.jpg'),
                ],
              ),
            ],
          ),
        ));
  }

  Widget buildPhotoRegion(
      BuildContext context, String region, IconData icon, String imagePath) {
    return Expanded(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);

              if (pickedFile != null) {
                setState(() {
                  imagePaths[region] = pickedFile.path;
                  print('Image for $region captured: ${imagePaths[region]}');
                });
              }
            },
            child: Container(
              width: 160,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: imagePaths[region] != null
                      ? FileImage(File(imagePaths[region]!)) as ImageProvider
                      : AssetImage(imagePath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);

              if (pickedFile != null) {
                setState(() {
                  imagePaths[region] = pickedFile.path;
                  print('Image for $region captured: ${imagePaths[region]}');
                });
              }
            },
            icon: Icon(icon),
            label: Text(region),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 3, 55, 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClinicalSymptomsContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Clinical Signs and Symptoms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderCheckboxGroup(
            name: 'clinical_symptoms',
            decoration: InputDecoration(
              labelText: 'Select the signs and symptoms',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            options: [
              FormBuilderFieldOption(
                  value: 'frothing', child: Text('Frothing')),
              FormBuilderFieldOption(
                  value: 'ulcerations', child: Text('Ulcerations')),
              FormBuilderFieldOption(
                  value: 'shivering', child: Text('Shivering')),
              FormBuilderFieldOption(
                  value: 'abortion', child: Text('Abortion')),
              FormBuilderFieldOption(
                  value: 'vesicles_hooves',
                  child: Text('Vesicles on the hooves')),
              FormBuilderFieldOption(
                  value: 'vesicles_mouth',
                  child: Text('Vesicles on the mouth')),
              FormBuilderFieldOption(
                  value: 'vesicles_udder',
                  child: Text('Vesicles on the udder')),
              FormBuilderFieldOption(
                  value: 'skin_lesions', child: Text('Skin Lesions')),
              FormBuilderFieldOption(
                  value: 'none', child: Text('None of these')),
              FormBuilderFieldOption(value: 'other', child: Text('Others')),
            ],
            onChanged: (List<dynamic>? values) {
              setState(() {
                if (values!.contains('none')) {
                  symptomImages.clear();
                } else {
                  values.remove('none');
                  Map<String, String> updatedSymptomImages = {};
                  for (var value in values) {
                    if (symptomImages.containsKey(value)) {
                      updatedSymptomImages[value] = symptomImages[value] ?? '';
                    } else {
                      updatedSymptomImages[value] = '';
                    }
                  }
                  symptomImages = updatedSymptomImages;
                }
              });
            },
          ),
          SizedBox(height: 20),
          buildSymptomImageGrid(),
        ],
      ),
    );
  }

  Widget buildSymptomImageGrid() {
    List<Widget> rows = [];
    List<String> keys = symptomImages.keys.toList();

    for (int i = 0; i < keys.length; i += 2) {
      List<Widget> children = [];

      children.add(Expanded(child: buildSymptomCaptureOption(keys[i])));
      if (i + 1 < keys.length) {
        children.add(Expanded(child: buildSymptomCaptureOption(keys[i + 1])));
      } else {
        children.add(Expanded(child: Container()));
      }

      rows.add(Row(children: children));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Capture selected symptom area on animal's body",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          Column(children: rows),
        ],
      ),
    );
  }

  Widget buildSymptomCaptureOption(String symptom) {
    return Column(
      children: [
        Text(symptom),
        GestureDetector(
          onTap: () => captureImageForSymptom(symptom),
          child: Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: symptomImages[symptom]!.isNotEmpty
                ? Image.file(File(symptomImages[symptom]!), fit: BoxFit.fill)
                : Container(width: 100, height: 100, color: Colors.grey[300]),
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => captureImageForSymptom(symptom),
          icon: Icon(Icons.camera_enhance),
          label: Text("Capture Image"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 3, 55, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void captureImageForSymptom(String symptom) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        symptomImages[symptom] = pickedFile.path;
        print('Image for $symptom captured: ${symptomImages[symptom]}');
      });
    }
  }

  List<DropdownMenuItem<String>> getYearDropdownItems() {
    var currentYear = DateTime.now().year;
    var startYear = currentYear - 10;
    List<DropdownMenuItem<String>> items = [];
    for (var year = startYear; year <= currentYear; year++) {
      items.add(DropdownMenuItem(
          value: year.toString(), child: Text(year.toString())));
    }
    return items;
  }

  Widget buildStockingContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Stocking",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderDateTimePicker(
            name: 'stocking_date',
            decoration: InputDecoration(
              labelText: 'When did you bring in new animal?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            initialEntryMode: DatePickerEntryMode.calendar,
            inputType: InputType.date,
            format: DateFormat('yyyy-MM-dd'),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            // validator: FormBuilderValidators.required(),
            initialValue: DateTime.now(),
          ),
          SizedBox(height: 20),
          FormBuilderRadioGroup(
            name: 'cattle_source',
            decoration: InputDecoration(
              labelText: 'Where did you get the animal from?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(
                  value: 'farm', child: Text('From the farm')),
              FormBuilderFieldOption(
                  value: 'market', child: Text('From the market')),
              FormBuilderFieldOption(
                  value: 'both', child: Text('From both the farm and market')),
              FormBuilderFieldOption(value: 'other', child: Text('Other')),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTemperatureAndSoundContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Temperature and Sound",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderTextField(
            name: 'rectal_temperature',
            decoration: InputDecoration(
              labelText: 'Rectal temperature (in degrees Celsius)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.thermostat_outlined),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(),
              // FormBuilderValidators.required(),
            ]),
          ),
          SizedBox(height: 20),
          FormBuilderRadioGroup(
            name: 'heart_sounds',
            decoration: InputDecoration(
              labelText: 'Heart Sounds',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            options: [
              FormBuilderFieldOption(value: 'Normal', child: Text('Normal')),
              FormBuilderFieldOption(
                  value: 'Irregular', child: Text('Irregular')),
            ],
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'heart_rate',
            decoration: InputDecoration(
              labelText: 'Heart beats per minute',
              hintText: 'This is optional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.favorite_border),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          FormBuilderRadioGroup(
            name: 'lung_sounds',
            decoration: InputDecoration(
              labelText: 'Lung Sounds',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            options: [
              FormBuilderFieldOption(value: 'Normal', child: Text('Normal')),
              FormBuilderFieldOption(
                  value: 'Labored Breath', child: Text('Labored Breath')),
              FormBuilderFieldOption(
                  value: 'Wheezing', child: Text('Wheezing')),
            ],
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'respiratory_rate',
            decoration: InputDecoration(
              labelText: 'Respiratory rate per minute',
              hintText: 'This is optional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.air),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget buildBodyPostureAndTemperamentContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Body Posture and Temperament",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderCheckboxGroup(
            name: 'body_posture',
            decoration: InputDecoration(
              labelText: 'Body Posture',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            options: [
              FormBuilderFieldOption(
                  value: 'Unable to stand', child: Text('Unable to stand')),
              FormBuilderFieldOption(value: 'Limping', child: Text('Limping')),
              FormBuilderFieldOption(
                  value: 'Recumbent', child: Text('Recumbent')),
              FormBuilderFieldOption(
                  value: 'None of these', child: Text('None of these')),
              FormBuilderFieldOption(value: 'Others', child: Text('Others')),
            ],
          ),
          SizedBox(height: 20),
          Text("Body Score (From 1 to 5)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          FormBuilderSlider(
            name: 'body_score',
            min: 1.0,
            max: 5.0,
            initialValue: 3.0,
            divisions: 4,
            displayValues: DisplayValues.current,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          FormBuilderRadioGroup(
            name: 'temperament',
            decoration: InputDecoration(
              labelText: 'Temperament',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(value: 'Alert', child: Text('Alert')),
              FormBuilderFieldOption(value: 'Docile', child: Text('Docile')),
              FormBuilderFieldOption(
                  value: 'Aggressive', child: Text('Aggressive')),
              FormBuilderFieldOption(value: 'Other', child: Text('Other')),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailsContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Animal details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderRadioGroup(
            name: 'sex',
            decoration: InputDecoration(
              labelText: 'Sex',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
              prefixIcon: Icon(Icons.pets), // Sex icon
            ),
            options: [
              FormBuilderFieldOption(value: 'Male', child: Text('Male')),
              FormBuilderFieldOption(value: 'Female', child: Text('Female')),
            ],
            // validator: FormBuilderValidators.required(),
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'tag_number',
            decoration: InputDecoration(
              labelText: 'Tag Number',
              hintText: 'Enter tag number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon: Icon(Icons.tag), // Tag icon
            ),
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'animal_name',
            decoration: InputDecoration(
              labelText: 'Animal Name',
              hintText: 'This is optional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon: Icon(Icons.edit_attributes), // Name icon
            ),
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'age',
            decoration: InputDecoration(
              labelText: 'Age',
              hintText: 'Enter age in months',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon: Icon(Icons.calendar_today), // Age icon
            ),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
              FormBuilderValidators.max(120),
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildIllnessEntry(Map<String, dynamic> entry) {
    int index = illnessEntries.indexOf(entry);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Illness infomation",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          setState(() => illnessEntries.removeAt(index)),
                    )
                  ],
                ),
                Divider(
                  color: Color.fromARGB(255, 76, 76, 76),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'illness_$index',
                  decoration: InputDecoration(
                    labelText: 'What was the animal suffering from?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialValue: entry['illness'],
                  onChanged: (val) => entry['illness'] = val,
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'treatment_$index',
                  decoration: InputDecoration(
                    labelText: 'What was the treatment given?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialValue: entry['treatment'],
                  onChanged: (val) => entry['treatment'] = val,
                ),
                SizedBox(height: 20),
              ],
            )));
  }

  Widget buildIllnessContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Previous Illness",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderRadioGroup<String>(
            name: 'previous_illness',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(value: 'No', child: Text('No')),
              FormBuilderFieldOption(value: 'Yes', child: Text('Yes')),
            ],
            onChanged: (val) {
              setState(() {
                if (val == 'No') {
                  illnessEntries.clear();
                }
              });
            },
          ),
          if (_formKey.currentState?.fields['previous_illness']?.value == 'Yes')
            Column(
              children: [
                ...illnessEntries
                    .map((entry) => buildIllnessEntry(entry))
                    .toList(),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Add Illness"),
                  onPressed: () {
                    setState(() {
                      illnessEntries.add({'illness': '', 'treatment': ''});
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildDewormingEntry(Map<String, dynamic> entry) {
    int index = dewormingEntries.indexOf(entry);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Deworming status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          setState(() => dewormingEntries.removeAt(index)),
                    )
                  ],
                ),
                Divider(
                  color: Color.fromARGB(255, 76, 76, 76),
                ),
                SizedBox(height: 10),
                FormBuilderDateTimePicker(
                  name: 'deworming_date_$index',
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialValue: entry['date'],
                  onChanged: (val) => entry['date'] = val,
                  decoration: InputDecoration(
                    labelText: 'When was the deworming carried out?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.date_range,
                        color: Color.fromARGB(255, 4, 112, 8)),
                  ),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                    name: 'dewormer_type_$index',
                    initialValue: entry['type'],
                    onChanged: (val) => entry['type'] = val,
                    decoration: InputDecoration(
                        labelText: 'What dewormer was used?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(
                          Icons.medical_services,
                          color: Color.fromARGB(255, 4, 112, 8),
                        ))),
                SizedBox(height: 20),
              ],
            )));
  }

  Widget buildDewormingContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Deworming Status",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderRadioGroup<String>(
            name: 'deworming_status',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(
                  value: 'Not Dewormed', child: Text('Not Dewormed')),
              FormBuilderFieldOption(
                  value: 'Dewormed', child: Text('Dewormed')),
            ],
            onChanged: (val) {
              setState(() {
                if (val == 'Not Dewormed') {
                  dewormingEntries.clear();
                }
              });
            },
          ),
          ...dewormingEntries
              .map((entry) => buildDewormingEntry(entry))
              .toList(),
          if (_formKey.currentState?.fields['deworming_status']?.value ==
              'Dewormed')
            Column(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Add Dewormer"),
                  onPressed: () {
                    setState(() {
                      dewormingEntries.add({'date': null, 'type': null});
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildVaccineEntry(Map<String, dynamic> entry) {
    int index = vaccineEntries.indexOf(entry);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Vaccination status",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () =>
                      setState(() => vaccineEntries.removeAt(index)),
                )
              ],
            ),
            Divider(
              color: Color.fromARGB(255, 76, 76, 76),
            ),
            SizedBox(height: 10),
            FormBuilderDateTimePicker(
              name: 'vaccination_date_$index',
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialValue: entry['date'],
              onChanged: (val) => entry['date'] = val,
              decoration: InputDecoration(
                labelText: 'When was the vaccination carried out?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(Icons.calendar_today,
                    color: Color.fromARGB(255, 4, 112, 8)),
              ),
            ),
            SizedBox(height: 15),
            FormBuilderTextField(
              name: 'vaccine_type_$index',
              initialValue: entry['type'],
              onChanged: (val) => entry['type'] = val,
              decoration: InputDecoration(
                labelText: 'What vaccine was used?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(
                  Icons.medical_services,
                  color: Color.fromARGB(255, 4, 112, 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVaccinationContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Vaccination Status",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderRadioGroup<String>(
            name: 'vaccination_status',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(
                  value: 'Not Vaccinated', child: Text('Not Vaccinated')),
              FormBuilderFieldOption(
                  value: 'Vaccinated', child: Text('Vaccinated')),
            ],
            onChanged: (val) {
              setState(() {
                if (val == 'Not Vaccinated') {
                  vaccineEntries.clear();
                }
              });
            },
          ),
          ...vaccineEntries.map((entry) => buildVaccineEntry(entry)).toList(),
          if (_formKey.currentState?.fields['vaccination_status']?.value ==
              'Vaccinated')
            Column(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Add Vaccine"),
                  onPressed: () {
                    setState(() {
                      vaccineEntries.add({'date': null, 'type': null});
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildBreedContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color.fromARGB(255, 241, 248, 242),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Animal breed",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          FormBuilderRadioGroup(
            name: 'breed',
            decoration: InputDecoration(
              labelText: 'Breed',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            options: [
              FormBuilderFieldOption(value: 'Ankole', child: Text('Ankole')),
              FormBuilderFieldOption(value: 'Ganda', child: Text('Ganda')),
              FormBuilderFieldOption(value: 'Nyor', child: Text('Nyor')),
              FormBuilderFieldOption(value: 'Boran', child: Text('Boran')),
              FormBuilderFieldOption(value: 'Nosga', child: Text('Nosga')),
              FormBuilderFieldOption(value: 'Others', child: Text('Others')),
            ],
            // validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  String getSampleTypeAbbreviation(String sampleType) {
    switch (sampleType) {
      case 'Whole Blood':
        return 'WB';
      case 'Serum':
        return 'SM';
      case 'Nasal Swab':
        return 'NS';
      case 'Oral Swab':
        return 'OS';
      case 'Probang':
        return 'PB';
      case 'Hoof Sample':
        return 'HS';
      case 'Fecal Sample':
        return 'FS';
      default:
        return 'OT'; // Other
    }
  }

  String getSampleTypeFromAbbreviation(String abbreviation) {
    switch (abbreviation) {
      case 'WB':
        return 'Whole Blood';
      case 'SM':
        return 'Serum';
      case 'NS':
        return 'Nasal Swab';
      case 'OS':
        return 'Oral Swab';
      case 'PB':
        return 'Probang';
      case 'HS':
        return 'Hoof Sample';
      case 'FS':
        return 'Fecal Sample';
      default:
        return 'Other';
    }
  }
}
