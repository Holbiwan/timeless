import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';

class JobPreferencesScreen extends StatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  State<JobPreferencesScreen> createState() => _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends State<JobPreferencesScreen> {
  String selectedExperience = '';
  List<String> selectedSkills = [];
  List<String> selectedJobTypes = [];
  List<String> selectedIndustries = [];
  List<String> selectedCompanyTypes = [];
  String selectedWorkLocation = '';
  double minSalary = 30000;
  double maxSalary = 100000;
  double maxCommute = 20;

  // Predefined options
  final List<String> experienceLevels = ['Entry Level', 'Junior', 'Mid-Level', 'Senior', 'Lead', 'Executive'];
  final List<String> availableSkills = [
    'Flutter', 'Dart', 'React', 'Angular', 'Vue.js', 'JavaScript', 'TypeScript',
    'Python', 'Java', 'C#', 'Node.js', 'PHP', 'Ruby', 'Swift', 'Kotlin',
    'Firebase', 'AWS', 'Docker', 'Kubernetes', 'MongoDB', 'PostgreSQL', 'MySQL',
    'UI/UX Design', 'Figma', 'Adobe XD', 'Photoshop', 'Illustrator',
    'Project Management', 'Agile', 'Scrum', 'Marketing', 'Sales', 'UX'
  ];
  final List<String> jobTypeOptions = ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship'];
  final List<String> industryOptions = [
    'Technology', 'UX', 'Healthcare', 'Education', 'Retail', 'Manufacturing',
    'Marketing', 'Design', 'Consulting', 'Media', 'Non-profit', 'Government'
  ];
  final List<String> companyTypeOptions = ['Startup', 'Small Company', 'Medium Company', 'Large Enterprise', 'Non-profit', 'Government'];
  final List<String> workLocationOptions = ['On-site', 'Remote', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    selectedExperience = PreferencesService.getString(PrefKeys.experienceLevel);
    selectedWorkLocation = PreferencesService.getString(PrefKeys.workLocationPreference);
    minSalary = double.tryParse(PreferencesService.getString(PrefKeys.salaryRangeMin)) ?? 30000;
    maxSalary = double.tryParse(PreferencesService.getString(PrefKeys.salaryRangeMax)) ?? 100000;
    maxCommute = double.tryParse(PreferencesService.getString(PrefKeys.maxCommuteDistance)) ?? 20;
    
    // Load JSON arrays
    final skillsJson = PreferencesService.getString(PrefKeys.skillsList);
    if (skillsJson.isNotEmpty) {
      try {
        selectedSkills = List<String>.from(jsonDecode(skillsJson));
      } catch (e) {
        selectedSkills = [];
      }
    }
    
    final jobTypesJson = PreferencesService.getString(PrefKeys.jobTypes);
    if (jobTypesJson.isNotEmpty) {
      try {
        selectedJobTypes = List<String>.from(jsonDecode(jobTypesJson));
      } catch (e) {
        selectedJobTypes = [];
      }
    }
    
    final industriesJson = PreferencesService.getString(PrefKeys.industryPreferences);
    if (industriesJson.isNotEmpty) {
      try {
        selectedIndustries = List<String>.from(jsonDecode(industriesJson));
      } catch (e) {
        selectedIndustries = [];
      }
    }
    
    final companyTypesJson = PreferencesService.getString(PrefKeys.companyTypes);
    if (companyTypesJson.isNotEmpty) {
      try {
        selectedCompanyTypes = List<String>.from(jsonDecode(companyTypesJson));
      } catch (e) {
        selectedCompanyTypes = [];
      }
    }
  }

  Future<void> _savePreferences() async {
    print(' Starting to save preferences...');
    
    // Validation des données avant sauvegarde
    if (selectedExperience.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: '⚠️ Missing Information',
        message: 'Please select your experience level.',
      );
      return;
    }
    
    if (selectedSkills.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: '⚠️ Missing Information',
        message: 'Please select at least one skill.',
      );
      return;
    }
    
    try {
      // Afficher un indicateur de chargement
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving preferences...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      await PreferencesService.setValue(PrefKeys.experienceLevel, selectedExperience);
      await PreferencesService.setValue(PrefKeys.workLocationPreference, selectedWorkLocation);
      await PreferencesService.setValue(PrefKeys.salaryRangeMin, minSalary.toString());
      await PreferencesService.setValue(PrefKeys.salaryRangeMax, maxSalary.toString());
      await PreferencesService.setValue(PrefKeys.maxCommuteDistance, maxCommute.toString());
      
      // Save JSON arrays
      await PreferencesService.setValue(PrefKeys.skillsList, jsonEncode(selectedSkills));
      await PreferencesService.setValue(PrefKeys.jobTypes, jsonEncode(selectedJobTypes));
      await PreferencesService.setValue(PrefKeys.industryPreferences, jsonEncode(selectedIndustries));
      await PreferencesService.setValue(PrefKeys.companyTypes, jsonEncode(selectedCompanyTypes));
      
      // Marquer que les préférences ont été configurées
      await PreferencesService.setValue(PrefKeys.jobPreferencesCompleted, true.toString());
      
      // Fermer le dialog de chargement
      Get.back();
      
      print('✅ All preferences saved successfully!');
      print('Experience: $selectedExperience');
      print('Skills: $selectedSkills');
      print('Job Types: $selectedJobTypes');
      print('Salary: $minSalary - $maxSalary');
      
      AppTheme.showStandardSnackBar(
        title: '✅ Preferences Saved Successfully!',
        message: 'Your job matching preferences have been updated! Redirecting to job recommendations...',
        isSuccess: true,
      );
      
      // Attendre un peu pour que l'utilisateur voit le message de succès
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Rediriger vers l'écran de recommandations de jobs
      Get.back(); // Fermer l'écran des préférences
      Get.to(() => const JobRecommendationScreen()); // Aller vers l'écran de matching
      
    } catch (e) {
      // Fermer le dialog de chargement si ouvert
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      print('❌ Error saving preferences: $e');
      AppTheme.showStandardSnackBar(
        title: '❌ Save Failed',
        message: 'Failed to save preferences. Please try again.\nError: ${e.toString()}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: const Text('Job Preferences'),
        backgroundColor: ColorRes.backgroundColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF000647), width: 2.0),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              print(' AppBar Save button pressed!');
              await _savePreferences();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF000647), width: 2.0),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 40,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Help us understand you better!',
                    style: appTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorRes.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'These preferences help our algorithm find jobs that match your needs and career goals.',
                    textAlign: TextAlign.center,
                    style: appTextStyle(
                      fontSize: 12,
                      color: ColorRes.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Experience Level
            _buildDropdownSection(
              title: ' Experience Level',
              subtitle: 'What level describes you best?',
              value: selectedExperience,
              items: experienceLevels,
              onChanged: (value) => setState(() => selectedExperience = value),
            ),
            
            // Skills
            _buildMultiSelectSection(
              title: ' Your Skills',
              subtitle: 'Select your technical and professional skills',
              selectedItems: selectedSkills,
              availableItems: availableSkills,
              onChanged: (items) => setState(() => selectedSkills = items),
            ),
            
            // Job Types
            _buildMultiSelectSection(
              title: ' Job Types',
              subtitle: 'What type of work are you looking for?',
              selectedItems: selectedJobTypes,
              availableItems: jobTypeOptions,
              onChanged: (items) => setState(() => selectedJobTypes = items),
            ),
            
            // Work Location
            _buildDropdownSection(
              title: ' Work Location Preference',
              subtitle: 'How do you prefer to work?',
              value: selectedWorkLocation,
              items: workLocationOptions,
              onChanged: (value) => setState(() => selectedWorkLocation = value),
            ),
            
            // Salary Range
            _buildSalarySection(),
            
            // Industries
            _buildMultiSelectSection(
              title: ' Preferred Industries',
              subtitle: 'Which industries interest you?',
              selectedItems: selectedIndustries,
              availableItems: industryOptions,
              onChanged: (items) => setState(() => selectedIndustries = items),
            ),
            
            // Company Types
            _buildMultiSelectSection(
              title: ' Company Types',
              subtitle: 'What size companies do you prefer?',
              selectedItems: selectedCompanyTypes,
              availableItems: companyTypeOptions,
              onChanged: (items) => setState(() => selectedCompanyTypes = items),
            ),
            
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  print(' Bottom Save button pressed!');
                  await _savePreferences();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Preferences & Improve Matching',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subtitle, style: appTextStyle(fontSize: 12, color: ColorRes.grey)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorRes.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.isEmpty ? null : value,
                hint: const Text('Select...'),
                isExpanded: true,
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSection({
    required String title,
    required String subtitle,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Function(List<String>) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subtitle, style: appTextStyle(fontSize: 12, color: ColorRes.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableItems.map((item) {
              final isSelected = selectedItems.contains(item);
              return GestureDetector(
                onTap: () {
                  List<String> newList = List.from(selectedItems);
                  if (isSelected) {
                    newList.remove(item);
                  } else {
                    newList.add(item);
                  }
                  onChanged(newList);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF000647), width: 2.0),
                  ),
                  child: Text(
                    item,
                    style: appTextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(' Salary Range', style: appTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('What is your expected salary range?', style: appTextStyle(fontSize: 12, color: ColorRes.grey)),
          const SizedBox(height: 15),
          Row(
            children: [
              Text('\$${minSalary.toInt()}', style: appTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('\$${maxSalary.toInt()}', style: appTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          RangeSlider(
            values: RangeValues(minSalary, maxSalary),
            min: 20000,
            max: 200000,
            divisions: 18,
            activeColor: const Color(0xFF000647),
            onChanged: (values) {
              setState(() {
                minSalary = values.start;
                maxSalary = values.end;
              });
            },
          ),
        ],
      ),
    );
  }
}