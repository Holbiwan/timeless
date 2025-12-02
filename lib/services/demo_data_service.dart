import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DemoDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Catégories d'emplois
  static const List<String> jobCategories = [
    'Technologie',
    'Marketing',
    'Finance', 
    'Design',
    'Ressources Humaines',
    'Vente',
    'Support Client',
    'Management'
  ];

  // Types de contrat
  static const List<String> jobTypes = [
    'CDI',
    'CDD', 
    'Stage',
    'Freelance',
    'Temps partiel'
  ];

  // Niveaux d'expérience
  static const List<String> experienceLevels = [
    'Débutant',
    'Intermédiaire', 
    'Confirmé',
    'Expert'
  ];

  // Villes
  static const List<String> cities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Bordeaux',
    'Lille'
  ];

  // Entreprises de démo
  static const List<Map<String, dynamic>> demoCompanies = [
    {
      'name': 'TechInnovate',
      'logo': 'tech_innovate_logo.png',
      'description': 'Startup innovante en intelligence artificielle'
    },
    {
      'name': 'DigitalSolutions',
      'logo': 'digital_solutions_logo.png', 
      'description': 'Agence de transformation digitale'
    },
    {
      'name': 'CreativeStudio',
      'logo': 'creative_studio_logo.png',
      'description': 'Studio de création graphique et web'
    },
    {
      'name': 'FinanceExpert',
      'logo': 'finance_expert_logo.png',
      'description': 'Cabinet de conseil en finance'
    },
    {
      'name': 'MarketPro',
      'logo': 'market_pro_logo.png',
      'description': 'Agence de marketing digital'
    }
  ];

  // Générer des annonces de démo
  static Future<void> generateDemoJobs() async {
    try {
      if (kDebugMode) print('🚀 Génération des annonces de démo...');

      final batch = _firestore.batch();
      
      // Positions par catégorie
      final Map<String, List<String>> positionsByCategory = {
        'Technologie': [
          'Développeur Flutter', 'Développeur React', 'Data Scientist', 
          'DevOps Engineer', 'Architecte Solution', 'Ingénieur iOS'
        ],
        'Marketing': [
          'Responsable Marketing Digital', 'Community Manager', 'SEO Specialist',
          'Marketing Manager', 'Content Creator', 'Growth Hacker'
        ],
        'Design': [
          'UI/UX Designer', 'Graphiste', 'Product Designer',
          'Motion Designer', 'Directeur Artistique', 'Web Designer'
        ],
        'Finance': [
          'Analyst Financier', 'Contrôleur de Gestion', 'Comptable',
          'CFO', 'Audit Manager', 'Risk Analyst'
        ],
        'Ressources Humaines': [
          'Responsable RH', 'Recruteur', 'HR Business Partner',
          'Chargé de Formation', 'Gestionnaire Paie', 'DRH'
        ],
        'Vente': [
          'Commercial BtoB', 'Account Manager', 'Sales Representative',
          'Business Developer', 'Key Account Manager', 'Directeur Commercial'
        ],
        'Support Client': [
          'Customer Success Manager', 'Support Technique', 'Service Client',
          'Account Manager', 'Technical Support', 'Customer Care'
        ],
        'Management': [
          'Chef de Projet', 'Product Manager', 'Team Lead',
          'Directeur Général', 'Operations Manager', 'Program Manager'
        ]
      };

      int jobCount = 0;
      
      // Créer des annonces pour chaque catégorie
      for (String category in jobCategories) {
        final positions = positionsByCategory[category] ?? ['Poste Générique'];
        
        for (String position in positions) {
          for (int i = 0; i < 3; i++) { // 3 annonces par position
            final company = demoCompanies[jobCount % demoCompanies.length];
            final jobType = jobTypes[jobCount % jobTypes.length];
            final city = cities[jobCount % cities.length];
            final experienceLevel = experienceLevels[jobCount % experienceLevels.length];
            
            final salary = _generateSalary(category, experienceLevel);
            final requirements = _generateRequirements(category, position, experienceLevel);
            
            final jobData = {
              'Position': position,
              'CompanyName': company['name'],
              'CompanyLogo': company['logo'],
              'CompanyDescription': company['description'],
              'category': category,
              'type': jobType,
              'location': city,
              'salary': salary,
              'experienceLevel': experienceLevel,
              'RequirementsList': requirements,
              'description': _generateJobDescription(position, company['name']),
              'createdAt': FieldValue.serverTimestamp(),
              'isActive': true,
              'BookMarkUserList': <String>[],
              'applicants': 0,
              'deviceToken': 'demo_device_token',
              // Champs pour les filtres
              'salaryRange': _getSalaryRange(salary),
              'keywords': _generateKeywords(position, category),
            };

            final docRef = _firestore.collection('allPost').doc();
            batch.set(docRef, jobData);
            
            jobCount++;
          }
        }
      }

      await batch.commit();
      if (kDebugMode) print('✅ $jobCount annonces de démo créées avec succès !');

    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de la génération des annonces : $e');
      rethrow;
    }
  }

  static String _generateSalary(String category, String experienceLevel) {
    final Map<String, Map<String, int>> salaryRanges = {
      'Technologie': {
        'Débutant': 45000, 'Intermédiaire': 55000, 'Confirmé': 70000, 'Expert': 90000
      },
      'Marketing': {
        'Débutant': 35000, 'Intermédiaire': 45000, 'Confirmé': 60000, 'Expert': 80000
      },
      'Design': {
        'Débutant': 35000, 'Intermédiaire': 45000, 'Confirmé': 60000, 'Expert': 75000
      },
      'Finance': {
        'Débutant': 40000, 'Intermédiaire': 50000, 'Confirmé': 65000, 'Expert': 85000
      },
      'Ressources Humaines': {
        'Débutant': 35000, 'Intermédiaire': 45000, 'Confirmé': 60000, 'Expert': 80000
      },
      'Vente': {
        'Débutant': 30000, 'Intermédiaire': 40000, 'Confirmé': 55000, 'Expert': 75000
      },
      'Support Client': {
        'Débutant': 28000, 'Intermédiaire': 35000, 'Confirmé': 45000, 'Expert': 60000
      },
      'Management': {
        'Débutant': 50000, 'Intermédiaire': 65000, 'Confirmé': 80000, 'Expert': 120000
      }
    };

    final baseSalary = salaryRanges[category]?[experienceLevel] ?? 40000;
    return baseSalary.toString();
  }

  static String _getSalaryRange(String salary) {
    final sal = int.tryParse(salary) ?? 40000;
    if (sal < 35000) return '< 35K';
    if (sal < 50000) return '35K-50K';
    if (sal < 70000) return '50K-70K';
    if (sal < 90000) return '70K-90K';
    return '90K+';
  }

  static List<String> _generateRequirements(String category, String position, String experienceLevel) {
    final Map<String, List<String>> categoryRequirements = {
      'Technologie': [
        'Maîtrise des langages de programmation',
        'Expérience avec les frameworks modernes',
        'Connaissance des bonnes pratiques de développement',
        'Capacité à travailler en équipe agile',
        'Anglais technique requis'
      ],
      'Marketing': [
        'Expérience en marketing digital',
        'Maîtrise des réseaux sociaux',
        'Connaissance des outils d\'analyse',
        'Créativité et sens de l\'innovation',
        'Excellente communication'
      ],
      'Design': [
        'Maîtrise des outils Adobe Creative Suite',
        'Expérience en design UI/UX',
        'Sens artistique développé',
        'Portfolio démontrant vos compétences',
        'Capacité à travailler avec les développeurs'
      ],
      'Finance': [
        'Formation en finance ou comptabilité',
        'Maîtrise d\'Excel et outils financiers',
        'Rigueur et attention aux détails',
        'Connaissance de la réglementation',
        'Esprit d\'analyse'
      ]
    };

    final baseRequirements = categoryRequirements[category] ?? [
      'Formation supérieure requise',
      'Expérience professionnelle souhaitée',
      'Autonomie et prise d\'initiative',
      'Travail en équipe',
      'Français courant'
    ];

    // Ajouter des requirements selon le niveau
    final experienceRequirement = {
      'Débutant': '0-2 ans d\'expérience',
      'Intermédiaire': '2-5 ans d\'expérience', 
      'Confirmé': '5-10 ans d\'expérience',
      'Expert': '10+ ans d\'expérience'
    };

    return [experienceRequirement[experienceLevel]!, ...baseRequirements];
  }

  static String _generateJobDescription(String position, String companyName) {
    return '''$companyName recherche un(e) $position pour rejoindre notre équipe dynamique.

Vous serez en charge de missions variées et stimulantes dans un environnement de travail moderne et bienveillant.

Nous offrons :
• Un salaire compétitif
• Télétravail possible
• Formation continue
• Avantages sociaux
• Évolution de carrière

Rejoignez-nous pour contribuer au succès de nos projets innovants !''';
  }

  static List<String> _generateKeywords(String position, String category) {
    final positionKeywords = position.toLowerCase().split(' ');
    final categoryKeywords = [category.toLowerCase()];
    
    final Map<String, List<String>> additionalKeywords = {
      'Technologie': ['tech', 'développement', 'software', 'code', 'programmation'],
      'Marketing': ['digital', 'communication', 'brand', 'campaign', 'social media'],
      'Design': ['créatif', 'graphique', 'interface', 'visuel', 'artistic'],
      'Finance': ['comptabilité', 'audit', 'budget', 'analyse', 'fiscalité'],
    };

    return [
      ...positionKeywords,
      ...categoryKeywords,
      ...additionalKeywords[category] ?? []
    ];
  }

  // Créer un utilisateur de démo
  static Future<void> createDemoUser({
    required String email,
    required String password,
    required String fullName,
    String userType = 'candidate'
  }) async {
    try {
      if (kDebugMode) print('👤 Création utilisateur de démo: $email');

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final String userId = userCredential.user!.uid;

      // Données utilisateur
      final userData = {
        'fullName': fullName,
        'email': email,
        'userType': userType, // 'candidate' ou 'employer' 
        'isProfileComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'phoneNumber': '+33 6 12 34 56 78',
        'city': cities[0],
        'country': 'France',
        'state': 'Île-de-France',
        'occupation': 'Développeur',
        'deviceToken': 'demo_device_token_$userId',
      };

      await _firestore.collection('users').doc(userId).set(userData);

      if (kDebugMode) print('✅ Utilisateur de démo créé: $fullName');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur création utilisateur de démo: $e');
      rethrow;
    }
  }

  // Nettoyer les données de démo
  static Future<void> cleanDemoData() async {
    try {
      if (kDebugMode) print('🧹 Nettoyage des données de démo...');

      final batch = _firestore.batch();
      
      // Supprimer les annonces de démo
      final jobsQuery = await _firestore
          .collection('allPost')
          .where('CompanyName', whereIn: demoCompanies.map((c) => c['name']).toList())
          .get();

      for (final doc in jobsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      if (kDebugMode) print('✅ Données de démo nettoyées');

    } catch (e) {
      if (kDebugMode) print('❌ Erreur nettoyage des données: $e');
    }
  }

  // Vérifier si les données de démo existent
  static Future<bool> demoDataExists() async {
    try {
      final snapshot = await _firestore
          .collection('allPost')
          .where('CompanyName', isEqualTo: demoCompanies.first['name'])
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}