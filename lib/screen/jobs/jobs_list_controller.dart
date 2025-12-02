import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/services/job_service.dart';

class JobsListController extends GetxController {
  // Controllers
  final searchController = TextEditingController();
  final locationController = TextEditingController();

  // Observable variables
  final jobs = <JobOfferModel>[].obs;
  final isLoading = false.obs;
  final searchTerm = ''.obs;
  final location = ''.obs;
  final selectedJobTypes = <JobType>[].obs;
  final selectedExperienceLevels = <ExperienceLevel>[].obs;
  final activeFilters = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Charger immédiatement les données factices au démarrage
    jobs.value = _getMockJobs();
    loadJobs();
  }

  @override
  void onClose() {
    searchController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // Getters
  bool get hasActiveFilters => activeFilters.isNotEmpty;

  // Search and filter methods
  void updateSearchTerm(String term) {
    searchTerm.value = term;
  }

  void updateLocation(String loc) {
    location.value = loc;
  }

  void clearSearch() {
    searchController.clear();
    searchTerm.value = '';
    locationController.clear();
    location.value = '';
    searchJobs();
  }

  void addFilter(dynamic filter) {
    if (filter is JobType) {
      if (!selectedJobTypes.contains(filter)) {
        selectedJobTypes.add(filter);
        activeFilters.add(_getJobTypeLabel(filter));
      }
    } else if (filter is ExperienceLevel) {
      if (!selectedExperienceLevels.contains(filter)) {
        selectedExperienceLevels.add(filter);
        activeFilters.add(_getExperienceLevelLabel(filter));
      }
    }
  }

  void removeFilter(String filterLabel) {
    activeFilters.remove(filterLabel);
    
    // Remove from specific filter lists
    selectedJobTypes.removeWhere((type) => _getJobTypeLabel(type) == filterLabel);
    selectedExperienceLevels.removeWhere((level) => _getExperienceLevelLabel(level) == filterLabel);
    
    // Refresh results
    searchJobs();
  }

  bool isFilterSelected(dynamic filter) {
    if (filter is JobType) {
      return selectedJobTypes.contains(filter);
    } else if (filter is ExperienceLevel) {
      return selectedExperienceLevels.contains(filter);
    }
    return false;
  }

  void clearAllFilters() {
    selectedJobTypes.clear();
    selectedExperienceLevels.clear();
    activeFilters.clear();
    searchJobs();
  }

  void applyFilters() {
    searchJobs();
  }

  // Data loading
  Future<void> loadJobs() async {
    try {
      isLoading.value = true;
      final jobsList = await JobService.getAllJobOffers(limit: 50);
      jobs.value = jobsList;
      
      // Si pas de jobs trouvés, utiliser des données factices
      if (jobsList.isEmpty) {
        jobs.value = _getMockJobs();
      }
    } catch (e) {
      // En cas d'erreur, utiliser des données factices
      jobs.value = _getMockJobs();
      Get.snackbar(
        'Mode démo',
        'Chargement des offres d\'exemple',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Données factices pour les tests
  List<JobOfferModel> _getMockJobs() {
    return [
      JobOfferModel(
        id: '1',
        employerId: 'emp1',
        companyName: 'TechCorp',
        title: 'Développeur Flutter',
        description: 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe. Vous travaillerez sur des applications mobiles innovantes.',
        requirements: ['Flutter', 'Dart', 'Firebase'],
        location: 'Paris, Île-de-France',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 45000,
        salaryMax: 55000,
        skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
        industry: 'Développement Mobile',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        isActive: true,
      ),
      JobOfferModel(
        id: '2',
        employerId: 'emp2',
        companyName: 'DesignStudio',
        title: 'UI/UX Designer',
        description: 'Créez des interfaces utilisateur modernes et intuitives. Nous recherchons quelqu\'un de créatif avec une bonne expérience en design.',
        requirements: ['Figma', 'Adobe XD', 'Sketch'],
        location: 'Lyon, Auvergne-Rhône-Alpes',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.junior,
        salaryMin: 40000,
        salaryMax: 50000,
        skills: ['Figma', 'Adobe XD', 'Prototypage', 'UI Design'],
        industry: 'Design & Créativité',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        isActive: true,
      ),
      JobOfferModel(
        id: '3',
        employerId: 'emp3',
        companyName: 'DataFlow',
        title: 'Data Scientist',
        description: 'Analysez des données complexes et créez des modèles prédictifs pour aider notre entreprise à prendre de meilleures décisions.',
        requirements: ['Python', 'R', 'Machine Learning'],
        location: 'Télétravail',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.senior,
        salaryMin: 50000,
        salaryMax: 65000,
        skills: ['Python', 'R', 'SQL', 'Machine Learning'],
        industry: 'Science des Données',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        isActive: true,
      ),
      JobOfferModel(
        id: '4',
        employerId: 'emp4',
        companyName: 'StartupXYZ',
        title: 'Product Manager',
        description: 'Gérez le cycle de vie des produits digitaux de la conception à la mise sur le marché. Expérience en gestion de produit requise.',
        requirements: ['Gestion produit', 'Agile', 'Analytics'],
        location: 'Marseille, Provence-Alpes-Côte d\'Azur',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 55000,
        salaryMax: 70000,
        skills: ['Product Management', 'Agile', 'Scrum', 'Analytics'],
        industry: 'Product Management',
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
        isActive: true,
      ),
      JobOfferModel(
        id: '5',
        employerId: 'emp5',
        companyName: 'CloudTech',
        title: 'DevOps Engineer',
        description: 'Automatisez les déploiements et gérez l\'infrastructure cloud. Expérience avec AWS ou Azure requise.',
        requirements: ['AWS', 'Docker', 'Kubernetes'],
        location: 'Toulouse, Occitanie',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.senior,
        salaryMin: 48000,
        salaryMax: 62000,
        skills: ['AWS', 'Docker', 'Kubernetes', 'CI/CD'],
        industry: 'Cloud & Infrastructure',
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        isActive: true,
      ),
      JobOfferModel(
        id: '6',
        employerId: 'emp6',
        companyName: 'MediaCorp',
        title: 'Chef de Projet Digital',
        description: 'Dirigez des projets digitaux innovants dans le secteur des médias. Coordonnez les équipes techniques et créatives.',
        requirements: ['Gestion projet', 'Digital', 'Médias'],
        location: 'Bordeaux, Nouvelle-Aquitaine',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 42000,
        salaryMax: 52000,
        skills: ['Project Management', 'Digital Strategy', 'Communication'],
        industry: 'Médias & Communication',
        createdAt: DateTime.now().subtract(Duration(hours: 18)),
        isActive: true,
      ),
      JobOfferModel(
        id: '7',
        employerId: 'emp7',
        companyName: 'EcoTech',
        title: 'Ingénieur Environnemental',
        description: 'Développez des solutions technologiques pour réduire l\'impact environnemental. Passion pour l\'écologie requise.',
        requirements: ['Environnement', 'Ingénierie', 'Durabilité'],
        location: 'Nantes, Pays de la Loire',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.junior,
        salaryMin: 38000,
        salaryMax: 45000,
        skills: ['Environnement', 'Analyse', 'Solutions durables'],
        industry: 'Environnement & Écologie',
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        isActive: true,
      ),
      JobOfferModel(
        id: '8',
        employerId: 'emp8',
        companyName: 'FinanceFirst',
        title: 'Analyste Financier',
        description: 'Analysez les marchés financiers et conseillez nos clients sur leurs investissements. Formation en finance requise.',
        requirements: ['Finance', 'Analyse', 'Excel'],
        location: 'Lille, Hauts-de-France',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.entry,
        salaryMin: 35000,
        salaryMax: 42000,
        skills: ['Analyse financière', 'Excel', 'Reporting'],
        industry: 'Finance & Banque',
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
        isActive: true,
      ),
      JobOfferModel(
        id: '9',
        employerId: 'emp9',
        companyName: 'HealthTech',
        title: 'Développeur FullStack',
        description: 'Développez des applications web pour le secteur de la santé. Respect des normes RGPD et sécurité des données crucial.',
        requirements: ['React', 'Node.js', 'Sécurité'],
        location: 'Strasbourg, Grand Est',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 44000,
        salaryMax: 54000,
        skills: ['React', 'Node.js', 'RGPD', 'Sécurité'],
        industry: 'Santé & Médical',
        createdAt: DateTime.now().subtract(Duration(hours: 10)),
        isActive: true,
      ),
      JobOfferModel(
        id: '10',
        employerId: 'emp10',
        companyName: 'EduPlatform',
        title: 'Concepteur Pédagogique',
        description: 'Créez du contenu éducatif digital pour nos plateformes e-learning. Expérience en pédagogie numérique appréciée.',
        requirements: ['Pédagogie', 'E-learning', 'Créativité'],
        location: 'Rennes, Bretagne',
        jobType: JobType.partTime,
        experienceLevel: ExperienceLevel.junior,
        salaryMin: 28000,
        salaryMax: 35000,
        skills: ['Pédagogie numérique', 'Conception', 'E-learning'],
        industry: 'Éducation & Formation',
        createdAt: DateTime.now().subtract(Duration(hours: 14)),
        isActive: true,
      ),
      JobOfferModel(
        id: '11',
        employerId: 'emp11',
        companyName: 'RetailInnovate',
        title: 'Responsable E-commerce',
        description: 'Gérez notre boutique en ligne et développez les ventes digitales. Expérience en marketing digital requise.',
        requirements: ['E-commerce', 'Marketing', 'Analytics'],
        location: 'Nice, Provence-Alpes-Côte d\'Azur',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 40000,
        salaryMax: 48000,
        skills: ['E-commerce', 'SEO', 'Google Analytics', 'Marketing'],
        industry: 'Commerce & Retail',
        createdAt: DateTime.now().subtract(Duration(hours: 20)),
        isActive: true,
      ),
      JobOfferModel(
        id: '12',
        employerId: 'emp12',
        companyName: 'ArtisanCraft',
        title: 'Artisan Menuisier',
        description: 'Rejoignez notre équipe d\'artisans pour créer des meubles sur mesure. Passion pour le travail du bois essentielle.',
        requirements: ['Menuiserie', 'Artisanat', 'Précision'],
        location: 'Annecy, Auvergne-Rhône-Alpes',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 32000,
        salaryMax: 38000,
        skills: ['Menuiserie', 'Travail du bois', 'Artisanat'],
        industry: 'Artisanat & Métiers d\'Art',
        createdAt: DateTime.now().subtract(Duration(hours: 16)),
        isActive: true,
      ),
      JobOfferModel(
        id: '13',
        employerId: 'emp13',
        companyName: 'SportAcademy',
        title: 'Coach Sportif',
        description: 'Encadrez des séances de sport individuelles et collectives. Diplôme BPJEPS ou équivalent requis.',
        requirements: ['BPJEPS', 'Sport', 'Pédagogie'],
        location: 'Montpellier, Occitanie',
        jobType: JobType.partTime,
        experienceLevel: ExperienceLevel.entry,
        salaryMin: 22000,
        salaryMax: 28000,
        skills: ['Coaching sportif', 'Pédagogie', 'Motivation'],
        industry: 'Sport & Loisirs',
        createdAt: DateTime.now().subtract(Duration(hours: 22)),
        isActive: true,
      ),
      JobOfferModel(
        id: '14',
        employerId: 'emp14',
        companyName: 'LegalTech',
        title: 'Juriste en Droit du Numérique',
        description: 'Conseillez nos clients sur les questions juridiques liées au numérique. Master en droit requis.',
        requirements: ['Droit', 'RGPD', 'Numérique'],
        location: 'Rouen, Normandie',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.senior,
        salaryMin: 45000,
        salaryMax: 55000,
        skills: ['Droit numérique', 'RGPD', 'Conseil juridique'],
        industry: 'Juridique & Droit',
        createdAt: DateTime.now().subtract(Duration(hours: 26)),
        isActive: true,
      ),
      JobOfferModel(
        id: '15',
        employerId: 'emp15',
        companyName: 'AgriTech',
        title: 'Ingénieur Agronome',
        description: 'Développez des solutions agricoles durables et innovantes. Connaissance en agriculture moderne requise.',
        requirements: ['Agronomie', 'Agriculture', 'Innovation'],
        location: 'Poitiers, Nouvelle-Aquitaine',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        salaryMin: 38000,
        salaryMax: 45000,
        skills: ['Agronomie', 'Agriculture durable', 'Innovation'],
        industry: 'Agriculture & Agroalimentaire',
        createdAt: DateTime.now().subtract(Duration(hours: 30)),
        isActive: true,
      ),
    ];
  }

  Future<void> searchJobs() async {
    try {
      isLoading.value = true;
      
      JobType? jobTypeFilter = selectedJobTypes.isNotEmpty ? selectedJobTypes.first : null;
      ExperienceLevel? experienceFilter = selectedExperienceLevels.isNotEmpty ? selectedExperienceLevels.first : null;
      
      final jobsList = await JobService.getAllJobOffers(
        limit: 100,
        searchTerm: searchTerm.value.isNotEmpty ? searchTerm.value : null,
        location: location.value.isNotEmpty ? location.value : null,
        jobType: jobTypeFilter,
        experienceLevel: experienceFilter,
      );
      
      jobs.value = jobsList;
      
      // Si pas de jobs trouvés, utiliser des données factices filtrées
      if (jobsList.isEmpty) {
        jobs.value = _getFilteredMockJobs(jobTypeFilter, experienceFilter);
      }
    } catch (e) {
      // En cas d'erreur, utiliser des données factices filtrées
      jobs.value = _getFilteredMockJobs(
        selectedJobTypes.isNotEmpty ? selectedJobTypes.first : null,
        selectedExperienceLevels.isNotEmpty ? selectedExperienceLevels.first : null,
      );
      Get.snackbar(
        'Mode démo',
        'Recherche dans les offres d\'exemple',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Données factices filtrées
  List<JobOfferModel> _getFilteredMockJobs(JobType? jobType, ExperienceLevel? experienceLevel) {
    List<JobOfferModel> mockJobs = _getMockJobs();
    
    // Filtrer par terme de recherche
    if (searchTerm.value.isNotEmpty) {
      mockJobs = mockJobs.where((job) =>
        job.title.toLowerCase().contains(searchTerm.value.toLowerCase()) ||
        job.description.toLowerCase().contains(searchTerm.value.toLowerCase()) ||
        job.companyName.toLowerCase().contains(searchTerm.value.toLowerCase())
      ).toList();
    }
    
    // Filtrer par localisation
    if (location.value.isNotEmpty) {
      mockJobs = mockJobs.where((job) =>
        job.location.toLowerCase().contains(location.value.toLowerCase())
      ).toList();
    }
    
    // Filtrer par type de job
    if (jobType != null) {
      mockJobs = mockJobs.where((job) => job.jobType == jobType).toList();
    }
    
    // Filtrer par niveau d'expérience
    if (experienceLevel != null) {
      mockJobs = mockJobs.where((job) => job.experienceLevel == experienceLevel).toList();
    }
    
    return mockJobs;
  }

  Future<void> refreshJobs() async {
    await searchJobs();
  }

  // Helper methods
  String _getJobTypeLabel(JobType type) {
    switch (type) {
      case JobType.fullTime:
        return 'Temps plein';
      case JobType.partTime:
        return 'Temps partiel';
      case JobType.contract:
        return 'Contrat';
      case JobType.internship:
        return 'Stage';
      case JobType.freelance:
        return 'Freelance';
    }
  }

  String _getExperienceLevelLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.entry:
        return 'Débutant';
      case ExperienceLevel.junior:
        return 'Junior';
      case ExperienceLevel.mid:
        return 'Confirmé';
      case ExperienceLevel.senior:
        return 'Senior';
      case ExperienceLevel.lead:
        return 'Lead';
      case ExperienceLevel.executive:
        return 'Direction';
    }
  }

  // Bookmark functionality (future implementation)
  void toggleBookmark(String jobId) {
    // TODO: Implement bookmark functionality
    Get.snackbar(
      'Favoris',
      'Fonctionnalité en cours de développement',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}