// Catégories communes pour les offres d'emploi utilisées dans toute l'application
class JobCategories {
  static const List<String> allCategories = [
    'Data',
    'UX/UI',
    'Security',
    'Frontend',
    'Backend',
    'Mobile',
    'DevOps',
    'AI/ML',
    'Product',
    'Marketing',
    'QA/Testing',
    'Sales',
    'Finance',
    'HR',
    'Operations'
  ];

  // Catégories avec "All" pour les filtres côté candidat
  static const List<String> candidateCategories = [
    'All',
    ...allCategories
  ];

  // Types de contrats communs (pour affichage dans les dropdowns)
  static const List<String> jobTypesDisplay = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance',
    'Temporary'
  ];

  // Types de contrats normalisés (pour sauvegarde et filtres)
  static const List<String> jobTypes = [
    'full-time',
    'part-time',
    'contract',
    'internship',
    'freelance',
    'temporary'
  ];

  // Types de contrats avec "All" pour affichage aux candidats
  static const List<String> candidateJobTypesDisplay = [
    'All',
    ...jobTypesDisplay
  ];

  // Types de contrats avec "All" pour les filtres côté candidat (valeurs internes)
  static const List<String> candidateJobTypes = [
    'All',
    ...jobTypes
  ];

  // Mapping des types d'affichage vers les types normalisés
  static const Map<String, String> jobTypeMapping = {
    'Full-time': 'full-time',
    'Part-time': 'part-time',
    'Contract': 'contract',
    'Internship': 'internship',
    'Freelance': 'freelance',
    'Temporary': 'temporary'
  };

  // Mapping de correspondances pour les catégories (pour les données legacy)
  static const Map<String, List<String>> categoryMappings = {
    'UX/UI': ['UX/UI', 'UX', 'UI'],
    'AI/ML': ['AI/ML', 'AI', 'ML', 'Machine Learning'],
    'DevOps': ['DevOps', 'Dev Ops'],
    'QA/Testing': ['QA/Testing', 'QA', 'Testing', 'Quality Assurance'],
  };

  // Vérifier si une catégorie de document correspond à une catégorie sélectionnée
  static bool categoryMatches(String selectedCategory, String docCategory) {
    if (selectedCategory == 'All') return true;
    if (selectedCategory == docCategory) return true;
    
    // Vérifier les mappings spéciaux
    if (categoryMappings.containsKey(selectedCategory)) {
      return categoryMappings[selectedCategory]!.contains(docCategory);
    }
    
    return false;
  }

  // Normaliser une catégorie avant sauvegarde (pour éviter les variants)
  static String normalizeCategory(String category) {
    // Nettoyer les espaces et standardiser la casse
    final cleaned = category.trim();
    
    // Mappings de normalisation pour les variants courants
    const normalizationMap = {
      'ux': 'UX/UI',
      'ui': 'UX/UI', 
      'ux/ui': 'UX/UI',
      'ai': 'AI/ML',
      'ml': 'AI/ML',
      'machine learning': 'AI/ML',
      'dev ops': 'DevOps',
      'devops': 'DevOps',
      'qa': 'QA/Testing',
      'testing': 'QA/Testing',
      'quality assurance': 'QA/Testing',
    };
    
    final lowerCleaned = cleaned.toLowerCase();
    return normalizationMap[lowerCleaned] ?? cleaned;
  }

  // Normaliser un type de job pour la compatibilité avec JobOfferModel._parseJobTypeFromString
  static String normalizeJobType(String jobType) {
    final cleaned = jobType.trim();
    // Utiliser le mapping si disponible, sinon convertir en minuscules
    return jobTypeMapping[cleaned] ?? cleaned.toLowerCase();
  }

  // Convertir un type d'affichage en valeur interne pour les filtres
  static String jobTypeDisplayToInternal(String displayType) {
    if (displayType == 'All') return 'All';
    return jobTypeMapping[displayType] ?? displayType.toLowerCase();
  }

  // Convertir une valeur interne en type d'affichage
  static String jobTypeInternalToDisplay(String internalType) {
    if (internalType == 'All') return 'All';
    for (final entry in jobTypeMapping.entries) {
      if (entry.value == internalType) return entry.key;
    }
    // Fallback: capitaliser la première lettre
    return internalType.isNotEmpty 
        ? '${internalType[0].toUpperCase()}${internalType.substring(1)}'
        : internalType;
  }
}