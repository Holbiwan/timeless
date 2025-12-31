import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/date_sort_filter.dart';

class JobRecommendationController extends GetxController
    implements GetxService {
  TextEditingController searchController = TextEditingController();

  // Documents Firestore
  List<QueryDocumentSnapshot> documents = [];

  // Recherche
  RxString searchText = ''.obs;

  // Filtres observables
  RxString selectedCategory = 'All'.obs;
  RxString selectedJobType = 'All'.obs;
  RxString selectedLocation = 'All'.obs;
  RxString selectedSalaryRange = 'All'.obs;
  RxString selectedExperienceLevel = 'All'.obs;

  // Date sorting
  Rx<DateSortOption> selectedDateSort = DateSortOption.newest.obs;

  // Options de filtres (Digital/Informatique uniquement)
  final List<String> categories = [
    'All', 
    'Development', 
    'UX/UI', 
    'Data', 
    'Security', 
    'DevOps', 
    'Digital Marketing', 
    'QA/Testing'
  ];

  final List<String> jobTypes = [
    'All',
    'CDI',
    'CDD',
    'Internship',
    'Freelance',
    'Intérim'
  ];

  final List<String> locations = [
    'All',
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Bordeaux',
    'Lille',
    'Cannes'
  ];

  final List<String> salaryRanges = [
    'All',
    '< 35K',
    '35K-50K',
    '50K-70K',
    '70K-90K',
    '90K+'
  ];

  final List<String> experienceLevels = [
    'All',
    'Entry-level',
    'Intermediate',
    'Experienced',
    'Expert'
  ];

  // Legacy code pour compatibilité
  RxList jobTypesSaved = [].obs;

  onTapSave(index) {
    if (index >= 0 && index < jobTypesSaved.length) {
      jobTypesSaved[index] = !jobTypesSaved[index];
    }
  }


  // Mettre à jour le texte de recherche
  void updateSearchText(String text) {
    searchText.value = text;
    update(['search']);
  }

  // Mettre à jour les filtres
  void updateCategory(String category) {
    selectedCategory.value = category;
    update();
    update(['search']);
    if (kDebugMode) print('Selected category: $category');
  }

  void updateJobType(String jobType) {
    selectedJobType.value = jobType;
    update(['search']);
    if (kDebugMode) print('Selected job type: $jobType');
  }

  void updateLocation(String location) {
    selectedLocation.value = location;
    update(['search']);
    if (kDebugMode) print('Selected location: $location');
  }

  void updateSalaryRange(String salaryRange) {
    selectedSalaryRange.value = salaryRange;
    update(['search']);
    if (kDebugMode) print('Selected salary range: $salaryRange');
  }

  void updateExperienceLevel(String experienceLevel) {
    selectedExperienceLevel.value = experienceLevel;
    update(['search']);
    if (kDebugMode) print('Selected experience level: $experienceLevel');
  }

  // Update date sorting
  void updateDateSort(DateSortOption sortOption) {
    selectedDateSort.value = sortOption;
    update(['search']);
    DateSortHelper.showSortingFeedback(sortOption);
    if (kDebugMode) print('Selected date sort: ${sortOption.label}');
  }

  // Réinitialiser tous les filtres
  void clearAllFilters() {
    selectedCategory.value = 'All';
    selectedJobType.value = 'All';
    selectedLocation.value = 'All';
    selectedSalaryRange.value = 'All';
    selectedExperienceLevel.value = 'All';
    selectedDateSort.value = DateSortOption.newest;
    searchText.value = '';
    searchController.clear();
    update(['search']);
    if (kDebugMode) print('All filters reset');
  }

  // Appliquer les filtres aux documents
  List<QueryDocumentSnapshot> getFilteredDocuments() {
    List<QueryDocumentSnapshot> filteredDocs = List.from(documents);

    // Filtre par recherche textuelle
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final position = (data['Position'] ?? '').toString().toLowerCase();
        final company = (data['CompanyName'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();
        final keywords = data['keywords'] as List<dynamic>? ?? [];

        return position.contains(query) ||
            company.contains(query) ||
            category.contains(query) ||
            keywords.any(
                (keyword) => keyword.toString().toLowerCase().contains(query));
      }).toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != 'All' && selectedCategory.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final docCategory = data['category']?.toString() ?? '';
        // Correspondance entre UX/UI et UX pour les données Firestore
        if (selectedCategory.value == 'UX/UI') {
          return docCategory == 'UX' ||
              docCategory == 'UI' ||
              docCategory == 'UX/UI';
        }
        return docCategory == selectedCategory.value;
      }).toList();
    }

    // Filtre par type de poste
    if (selectedJobType.value != 'All' && selectedJobType.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['jobType'] == selectedJobType.value;
      }).toList();
    }

    // Filtre par localisation
    if (selectedLocation.value != 'All' && selectedLocation.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final docLocation = data['location']?.toString() ?? '';
        // Vérifier si la ville sélectionnée est incluse dans la localisation
        return docLocation
            .toLowerCase()
            .contains(selectedLocation.value.toLowerCase());
      }).toList();
    }

    // Filtre par salaire
    if (selectedSalaryRange.value != 'All' &&
        selectedSalaryRange.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final salary = data['salary']?.toString() ?? '';

        if (salary.isEmpty || salary == '0') return false;

        // Extraire le salaire minimum de la chaîne (ex: "60000-75000" -> 60000)
        int? minSalary;
        if (salary.contains('-')) {
          minSalary = int.tryParse(salary.split('-')[0]);
        } else {
          minSalary = int.tryParse(salary);
        }

        if (minSalary == null) return false;

        // Filtrer selon la tranche sélectionnée
        switch (selectedSalaryRange.value) {
          case '< 35K':
            return minSalary < 35000;
          case '35K-50K':
            return minSalary >= 35000 && minSalary < 50000;
          case '50K-70K':
            return minSalary >= 50000 && minSalary < 70000;
          case '70K-90K':
            return minSalary >= 70000 && minSalary < 90000;
          case '90K+':
            return minSalary >= 90000;
          default:
            return true;
        }
      }).toList();
    }

    // Filtre par niveau d'expérience
    if (selectedExperienceLevel.value != 'All' &&
        selectedExperienceLevel.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['experienceLevel'] == selectedExperienceLevel.value;
      }).toList();
    }

    // Apply date sorting
    filteredDocs = DateSortHelper.sortDocuments<QueryDocumentSnapshot>(
      filteredDocs,
      selectedDateSort.value,
      'createdAt',
      getTimestamp: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['createdAt'] ?? data['timestamp'] ?? data['dateCreated'];
      },
    );

    return filteredDocs;
  }

  // Obtenir le nombre de résultats après filtrage
  int getFilteredResultsCount() {
    return getFilteredDocuments().length;
  }

  // Vérifier si des filtres sont actifs
  bool hasActiveFilters() {
    return selectedCategory.value != 'All' ||
        selectedJobType.value != 'All' ||
        selectedLocation.value != 'All' ||
        selectedSalaryRange.value != 'All' ||
        selectedExperienceLevel.value != 'All' ||
        searchText.value.isNotEmpty ||
        selectedDateSort.value != DateSortOption.newest;
  }
}
