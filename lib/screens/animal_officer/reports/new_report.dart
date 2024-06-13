import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:marcci/models/AnimalFormModel.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/screens/animal_officer/animals/animal_form.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:marcci/widgets/fadepageroute%20copy.dart';
import 'package:marcci/widgets/farm_picker.dart';

class CreateReportScreen extends StatefulWidget {
  final String reportId;
  final VoidCallback onFormAdded;

  CreateReportScreen({required this.reportId, required this.onFormAdded});

  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ValueNotifier<bool> _showOtherFieldNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showOtherFeedingNotifier = ValueNotifier(false);
  FarmModel? selectedFarm;
  String report_id = '';
  bool isFarmSelected = false; // Flag to check if a farm has been selected
  int animalFormCounter = 0; // Counter for animal forms
  List<AnimalFormModel> animalForms = [];

  @override
  void initState() {
    super.initState();
    report_id = widget.reportId;
    print("Report Id: $report_id");
  }

  Future<void> fetchAnimalForms() async {
    List<AnimalFormModel> forms = await AnimalFormModel.getItems();
    List<AnimalFormModel> filteredForms =
        forms.where((form) => form.reportID == report_id).toList();
    print("Filtered animal forms count: ${filteredForms.length}");
    setState(() {
      animalForms = filteredForms;
    });
  }

  Future<void> _saveReport() async {
    LoggedInUserModel ul = await LoggedInUserModel.getLoggedInUser();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final formData = _formKey.currentState!.value;

      // Print all the form data to the console for debugging
      print("User ID: ${ul.id}");
      print("User Name: ${ul.name}");
      print("Farm ID: ${selectedFarm!.farmID}");
      print("Survey Type: ${formData['survey_type']}");
      print("Season: ${formData['season']}");
      print("Disease Type: ${formData['disease_type']}");
      print("Bio-Security Measures: ${formData['bio_security_measures']}");
      print("Feeding Mechanisms: ${formData['feeding_mechanisms']}");
      print(
          "Other Bio-Security Measures: ${formData['other_bio_security_measures']}");
      print(
          "Other Feeding Mechanisms: ${formData['other_feeding_mechanisms']}");
      print("Content: ${formData['user_text']}");

      // Assuming you have a method to save the report
      ReportModel newReport = ReportModel(
          report_id: report_id,
          submittedByID: ul.id,
          submitterName: ul.name,
          farmID: selectedFarm!.farmID,
          surveyType: formData['survey_type'],
          season: formData['season'],
          diseaseType: formData['disease_type'],
          bioSecurityMeasures:
              (formData['bio_security_measures'] as List<String>)
                  .join(', '), // Convert List to String
          feedingMechanisms:
              (formData['feeding_mechanisms'] as List<String>).join(', '),
          content: formData['user_text']);

      print("New report: ${newReport}");

      // Save the new report

      await ReportModel.saveLocally(newReport);
      widget.onFormAdded();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _showOtherFieldNotifier.dispose();
    _showOtherFeedingNotifier.dispose();
    super.dispose();
  }

  void _attachAnimalForm() async {
    if (isFarmSelected) {
      setState(() {
        animalFormCounter++; // Increment the counter
      });

      await Navigator.push(
        context,
        FadePageRoute(
          route: (_) => AnimalInfoFormScreen(
            reportId: report_id,
            selectedFarm: selectedFarm!,
            formNumber: animalFormCounter, // Pass the counter value
            onFormAdded: fetchAnimalForms, // Pass the callback function
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a farm first.'),
        backgroundColor: Color.fromARGB(255, 113, 10, 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: FxAppBar(
        titleText: "New Field Report",
        onSettings: () {
          Get.to(() => AppSettings());
        },
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select farm to survey",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'user_text',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Select Farm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon:
                            Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'Farm selection is required',
                      ),
                      onTap: () async {
                        selectedFarm = await Get.to(() => FarmsPickerScreen());
                        if (selectedFarm != null) {
                          setState(() {
                            _formKey.currentState!.patchValue({
                              'user_text':
                                  "${selectedFarm!.farmName} - ${selectedFarm!.farmerPhone}",
                            });
                            isFarmSelected = true; // Farm has been selected
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select type of survey carried out",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderRadioGroup(
                      name: 'survey_type',
                      decoration: InputDecoration(
                        labelText: 'Type of Survey',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'Outbreak Response',
                            child: Text('Outbreak Response')),
                        FormBuilderFieldOption(
                            value: 'Passive', child: Text('Passive')),
                        FormBuilderFieldOption(
                            value: 'Cross-sectional',
                            child: Text('Cross-sectional')),
                      ],
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select current season",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderRadioGroup(
                      name: 'season',
                      decoration: InputDecoration(
                        labelText: 'Select Season',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'Dry', child: Text('Dry season')),
                        FormBuilderFieldOption(
                            value: 'Rain', child: Text('Rain season')),
                      ],
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("What kind of disease is this survey targeting?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderRadioGroup(
                      name: 'disease_type',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'African Swine Fever',
                            child: Text('African Swine Fever')),
                        FormBuilderFieldOption(
                            value: 'Foot-and-Mouth Disease',
                            child: Text('Foot-and-Mouth Disease')),
                        FormBuilderFieldOption(
                            value: 'Both', child: Text('Both')),
                      ],
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bio-Security Measures",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderCheckboxGroup(
                      name: 'bio_security_measures',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'Bio-security Aware',
                            child: Text('Farm-workers are bio-security aware')),
                        FormBuilderFieldOption(
                            value: 'Double Fencing',
                            child: Text('Double Fencing')),
                        FormBuilderFieldOption(
                            value: 'Single Fencing',
                            child: Text('Single Fencing')),
                        FormBuilderFieldOption(
                            value: 'Protective Footwear',
                            child: Text('Protective footwear')),
                        FormBuilderFieldOption(
                            value: 'Foot Bath', child: Text('Foot Bath')),
                        FormBuilderFieldOption(
                            value: 'Isolation of Animals',
                            child: Text('Isolation of incoming animals')),
                        FormBuilderFieldOption(
                            value: 'Artificial Insemination',
                            child: Text('Artificial insemination')),
                        FormBuilderFieldOption(
                            value: 'On-farm Bull', child: Text('On-farm bull')),
                        FormBuilderFieldOption(
                            value: 'Separate Entry and Exit',
                            child: Text('Separate entry and exit points')),
                        FormBuilderFieldOption(
                            value: 'None', child: Text('None')),
                        FormBuilderFieldOption(
                            value: 'Others', child: Text('Others')),
                      ],
                      orientation: OptionsOrientation.vertical,
                      onChanged: (values) {
                        _showOtherFieldNotifier.value =
                            values?.contains('Others') ?? false;
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showOtherFieldNotifier,
                      builder: (context, showOtherField, child) {
                        if (showOtherField) {
                          return Column(
                            children: [
                              SizedBox(height: 10),
                              FormBuilderTextField(
                                name: 'other_bio_security_measures',
                                decoration: InputDecoration(
                                  labelText: 'Please specify other measures',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.required(
                                  errorText:
                                      "Please specify the other bio-security measures.",
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Animal Feeding Mechanisms",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    FormBuilderCheckboxGroup(
                      name: 'feeding_mechanisms',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'Fodder on farm',
                            child: Text('Fodder on farm')),
                        FormBuilderFieldOption(
                            value: 'Fodder from outside',
                            child: Text('Fodder from outside the farm')),
                        FormBuilderFieldOption(
                            value: 'Personal leftovers',
                            child: Text('Personal Leftovers')),
                        FormBuilderFieldOption(
                            value: 'Leftovers from outside',
                            child: Text('Leftovers from outside')),
                        FormBuilderFieldOption(
                            value: 'Same drinking point',
                            child:
                                Text('Same drinking point with other animals')),
                        FormBuilderFieldOption(
                            value: 'On-farm drinking point',
                            child: Text('On-farm drinking point')),
                        FormBuilderFieldOption(
                            value: 'Communal grazing',
                            child: Text('Communal grazing')),
                        FormBuilderFieldOption(
                            value: 'Others', child: Text('Others')),
                      ],
                      orientation: OptionsOrientation.vertical,
                      onChanged: (values) {
                        _showOtherFeedingNotifier.value =
                            values?.contains('Others') ?? false;
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showOtherFeedingNotifier,
                      builder: (context, showOtherField, child) {
                        if (showOtherField) {
                          return Column(
                            children: [
                              SizedBox(height: 10),
                              FormBuilderTextField(
                                name: 'other_feeding_mechanisms',
                                decoration: InputDecoration(
                                  labelText: 'Please specify other mechanisms',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.required(
                                  errorText:
                                      "Please specify the other feeding mechanisms.",
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Color.fromARGB(255, 246, 253, 246)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: Image.asset(
                                      'assets/images/animal.png',
                                      fit: BoxFit.contain,
                                      height: 150,
                                      width: 150,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Attach Animal Form",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.attach_file,
                                          color: Colors.white),
                                      label: Text("Attach Form"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Theme.of(context)
                                            .primaryColor, // Text color
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 18),
                                      ),
                                      onPressed: _attachAnimalForm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: animalForms.length,
                              itemBuilder: (context, index) {
                                final animalForm = animalForms[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                        "Animal Form ${animalForm.animalID}"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Tag Number: ${animalForm.sex}\nAnimal Name: ${animalForm.age}"),
                                        Text(
                                            "Tag Number: ${animalForm.breed}\nAnimal Name: ${animalForm.age}"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ))),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _saveReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 78, 3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.0098,
                        horizontal: screenWidth * 0.15, // Responsive padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(3.0), // Rounded top-left corner
                          topRight:
                              Radius.circular(3.0), // Rounded top-right corner
                          bottomLeft: Radius.circular(
                              3.0), // No rounding on bottom-left corner
                          bottomRight: Radius.circular(
                              3.0), // No rounding on bottom-right corner
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FxText(
                          'Submit',
                          color: Colors.white,
                          fontSize:
                              screenHeight * 0.025, // Responsive font size
                          fontWeight: 800,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
