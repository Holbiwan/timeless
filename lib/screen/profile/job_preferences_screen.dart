import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';

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
    'Project Management', 'Agile', 'Scrum', 'Marketing', 'Sales', 'Finance'
  ];
  final List<String> jobTypeOptions = ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship'];
  final List<String> industryOptions = [
    'Technology', 'Finance', 'Healthcare', 'Education', 'Retail', 'Manufacturing',
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
    selectedExperience = PrefService.getString(PrefKeys.experienceLevel);
    selectedWorkLocation = PrefService.getString(PrefKeys.workLocationPreference);
    minSalary = double.tryParse(PrefService.getString(PrefKeys.salaryRangeMin)) ?? 30000;
    maxSalary = double.tryParse(PrefService.getString(PrefKeys.salaryRangeMax)) ?? 100000;
    maxCommute = double.tryParse(PrefService.getString(PrefKeys.maxCommuteDistance)) ?? 20;
    
    // Load JSON arrays
    final skillsJson = PrefService.getString(PrefKeys.skillsList);
    if (skillsJson.isNotEmpty) {
      try {
        selectedSkills = List<String>.from(jsonDecode(skillsJson));
      } catch (e) {
        selectedSkills = [];
      }
    }
    
    final jobTypesJson = PrefService.getString(PrefKeys.jobTypes);
    if (jobTypesJson.isNotEmpty) {
      try {
        selectedJobTypes = List<String>.from(jsonDecode(jobTypesJson));
      } catch (e) {
        selectedJobTypes = [];
      }
    }
    
    final industriesJson = PrefService.getString(PrefKeys.industryPreferences);
    if (industriesJson.isNotEmpty) {
      try {
        selectedIndustries = List<String>.from(jsonDecode(industriesJson));
      } catch (e) {
        selectedIndustries = [];
      }
    }
    
    final companyTypesJson = PrefService.getString(PrefKeys.companyTypes);
    if (companyTypesJson.isNotEmpty) {
      try {
        selectedCompanyTypes = List<String>.from(jsonDecode(companyTypesJson));
      } catch (e) {
        selectedCompanyTypes = [];
      }
    }
  }

  Future<void> _savePreferences() async {
    print('🚀 Starting to save preferences...');
    
    try {
      await PrefService.setValue(PrefKeys.experienceLevel, selectedExperience);
      await PrefService.setValue(PrefKeys.workLocationPreference, selectedWorkLocation);
      await PrefService.setValue(PrefKeys.salaryRangeMin, minSalary.toString());
      await PrefService.setValue(PrefKeys.salaryRangeMax, maxSalary.toString());
      await PrefService.setValue(PrefKeys.maxCommuteDistance, maxCommute.toString());
      
      // Save JSON arrays
      await PrefService.setValue(PrefKeys.skillsList, jsonEncode(selectedSkills));
      await PrefService.setValue(PrefKeys.jobTypes, jsonEncode(selectedJobTypes));
      await PrefService.setValue(PrefKeys.industryPreferences, jsonEncode(selectedIndustries));
      await PrefService.setValue(PrefKeys.companyTypes, jsonEncode(selectedCompanyTypes));
      
      print('✅ All preferences saved successfully!');
      print('Experience: $selectedExperience');
      print('Skills: $selectedSkills');
      print('Job Types: $selectedJobTypes');
      print('Salary: $minSalary - $maxSalary');
      
      Get.snackbar(
        '✅ Preferences Saved',
        'Your job matching preferences have been updated! This will help us find better job matches for you.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      Get.back();
    } catch (e) {
      print('❌ Error saving preferences: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to save preferences: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
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
        actions: [
          TextButton(
            onPressed: () async {
              print('🔵 AppBar Save button pressed!');
              await _savePreferences();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 40,
                    color: Colors.blue,
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
              title: '🎯 Experience Level',
              subtitle: 'What level describes you best?',
              value: selectedExperience,
              items: experienceLevels,
              onChanged: (value) => setState(() => selectedExperience = value),
            ),
            
            // Skills
            _buildMultiSelectSection(
              title: '💡 Your Skills',
              subtitle: 'Select your technical and professional skills',
              selectedItems: selectedSkills,
              availableItems: availableSkills,
              onChanged: (items) => setState(() => selectedSkills = items),
            ),
            
            // Job Types
            _buildMultiSelectSection(
              title: '💼 Job Types',
              subtitle: 'What type of work are you looking for?',
              selectedItems: selectedJobTypes,
              availableItems: jobTypeOptions,
              onChanged: (items) => setState(() => selectedJobTypes = items),
            ),
            
            // Work Location
            _buildDropdownSection(
              title: '📍 Work Location Preference',
              subtitle: 'How do you prefer to work?',
              value: selectedWorkLocation,
              items: workLocationOptions,
              onChanged: (value) => setState(() => selectedWorkLocation = value),
            ),
            
            // Salary Range
            _buildSalarySection(),
            
            // Industries
            _buildMultiSelectSection(
              title: '🏢 Preferred Industries',
              subtitle: 'Which industries interest you?',
              selectedItems: selectedIndustries,
              availableItems: industryOptions,
              onChanged: (items) => setState(() => selectedIndustries = items),
            ),
            
            // Company Types
            _buildMultiSelectSection(
              title: '🚀 Company Types',
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
                  print('🔵 Bottom Save button pressed!');
                  await _savePreferences();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Preferences & Improve Matching',
                  style: TextStyle(
                    color: Colors.white,
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
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    item,
                    style: appTextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.blue,
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
          Text('💰 Salary Range', style: appTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            activeColor: Colors.blue,
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