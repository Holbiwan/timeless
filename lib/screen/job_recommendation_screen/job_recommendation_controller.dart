import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class JobRecommendationController extends GetxController
    implements GetxService {
  TextEditingController searchController = TextEditingController();
  
  // Documents Firestore
  List<QueryDocumentSnapshot> documents = [];
  
  // Recherche
  RxString searchText = ''.obs;
  
  // Filtres observables
  RxString selectedCategory = 'Tous'.obs;
  RxString selectedJobType = 'Tous'.obs;
  RxString selectedLocation = 'Toutes'.obs;
  RxString selectedSalaryRange = 'Tous'.obs;
  RxString selectedExperienceLevel = 'Tous'.obs;
  
  // Options de filtres
  final List<String> categories = [
    'Tous',
    'Technologie',
    'Marketing',
    'Finance', 
    'Design',
    'Ressources Humaines',
    'Vente',
    'Support Client',
    'Management'
  ];

  final List<String> jobTypes = [
    'Tous',
    'CDI',
    'CDD', 
    'Stage',
    'Freelance',
    'Temps partiel'
  ];

  final List<String> locations = [
    'Toutes',
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Bordeaux',
    'Lille'
  ];

  final List<String> salaryRanges = [
    'Tous',
    '< 35K',
    '35K-50K',
    '50K-70K',
    '70K-90K',
    '90K+'
  ];

  final List<String> experienceLevels = [
    'Tous',
    'Débutant',
    'Intermédiaire', 
    'Confirmé',
    'Expert'
  ];

  // Legacy code pour compatibilité
  RxList jobTypesSaved = [].obs;

  onTapSave(index) {
    if (index >= 0 && index < jobTypesSaved.length) {
      jobTypesSaved[index] = !jobTypesSaved[index];
    }
  }

  RxInt selectedJobs2 = 0.obs;
  
  final List<String> jobs2 = [
    'All Jobs',
    'UX/UI', 
    'Data',
    'Security'
  ];

  onTapJobs2(int index) {
    selectedJobs2.value = index;
    update();
  }

  // Mettre à jour le texte de recherche
  void updateSearchText(String text) {
    searchText.value = text;
    update(['search']);
  }

  // Mettre à jour les filtres
  void updateCategory(String category) {
    selectedCategory.value = category;
    update(['search']);
    if (kDebugMode) print('Catégorie sélectionnée: $category');
  }

  void updateJobType(String jobType) {
    selectedJobType.value = jobType;
    update(['search']);
    if (kDebugMode) print('Type de poste sélectionné: $jobType');
  }

  void updateLocation(String location) {
    selectedLocation.value = location;
    update(['search']);
    if (kDebugMode) print('Localisation sélectionnée: $location');
  }

  void updateSalaryRange(String salaryRange) {
    selectedSalaryRange.value = salaryRange;
    update(['search']);
    if (kDebugMode) print('Salaire sélectionné: $salaryRange');
  }

  void updateExperienceLevel(String experienceLevel) {
    selectedExperienceLevel.value = experienceLevel;
    update(['search']);
    if (kDebugMode) print('Niveau d\'expérience sélectionné: $experienceLevel');
  }

  // Réinitialiser tous les filtres
  void clearAllFilters() {
    selectedCategory.value = 'Tous';
    selectedJobType.value = 'Tous';
    selectedLocation.value = 'Toutes';
    selectedSalaryRange.value = 'Tous';
    selectedExperienceLevel.value = 'Tous';
    searchText.value = '';
    searchController.clear();
    update(['search']);
    if (kDebugMode) print('Tous les filtres réinitialisés');
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
               keywords.any((keyword) => keyword.toString().toLowerCase().contains(query));
      }).toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != 'Tous' && selectedCategory.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['category'] == selectedCategory.value;
      }).toList();
    }

    // Filtre par type de poste
    if (selectedJobType.value != 'Tous' && selectedJobType.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['type'] == selectedJobType.value;
      }).toList();
    }

    // Filtre par localisation
    if (selectedLocation.value != 'Toutes' && selectedLocation.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['location'] == selectedLocation.value;
      }).toList();
    }

    // Filtre par salaire
    if (selectedSalaryRange.value != 'Tous' && selectedSalaryRange.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['salaryRange'] == selectedSalaryRange.value;
      }).toList();
    }

    // Filtre par niveau d'expérience
    if (selectedExperienceLevel.value != 'Tous' && selectedExperienceLevel.value.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['experienceLevel'] == selectedExperienceLevel.value;
      }).toList();
    }

    return filteredDocs;
  }

  // Obtenir le nombre de résultats après filtrage
  int getFilteredResultsCount() {
    return getFilteredDocuments().length;
  }

  // Vérifier si des filtres sont actifs
  bool hasActiveFilters() {
    return selectedCategory.value != 'Tous' ||
           selectedJobType.value != 'Tous' ||
           selectedLocation.value != 'Toutes' ||
           selectedSalaryRange.value != 'Tous' ||
           selectedExperienceLevel.value != 'Tous' ||
           searchText.value.isNotEmpty;
  }
}
