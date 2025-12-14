import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DemoDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Catégories d'emplois IT
  static const List<String> jobCategories = [
    'Développement',
    'Data Science',
    'DevOps',
    'Cybersécurité',
    'Cloud',
    'Mobile',
    'IA & Machine Learning',
    'Management IT'
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

  // Entreprises IT de démo
  static const List<Map<String, dynamic>> demoCompanies = [
    {
      'name': 'TechCorp Solutions',
      'logo': 'techcorp_logo.png',
      'description': 'Leader français en développement logiciel et solutions IT innovantes.',
      'siret': '12345678901234',
      'ape': '6201Z',
      'location': 'Paris, France',
      'website': 'https://techcorp-solutions.fr',
      'employees': '50-200',
      'founded': 2015,
    },
    {
      'name': 'DataFlow Analytics',
      'logo': 'dataflow_logo.png', 
      'description': 'Spécialiste en analyse de données et intelligence artificielle.',
      'siret': '98765432109876',
      'ape': '6202A',
      'location': 'Lyon, France',
      'website': 'https://dataflow-analytics.fr',
      'employees': '10-50',
      'founded': 2018,
    },
    {
      'name': 'CyberGuard Security',
      'logo': 'cyberguard_logo.png',
      'description': 'Entreprise de cybersécurité protégeant les infrastructures critiques.',
      'siret': '11122233344556',
      'ape': '6202B',
      'location': 'Marseille, France',
      'website': 'https://cyberguard-security.fr',
      'employees': '20-100',
      'founded': 2020,
    },
    {
      'name': 'CloudMaster Services',
      'logo': 'cloudmaster_logo.png',
      'description': 'Expert en migration et gestion d\'infrastructures cloud.',
      'siret': '66677788899001',
      'ape': '6203Z',
      'location': 'Toulouse, France',
      'website': 'https://cloudmaster-services.fr',
      'employees': '30-150',
      'founded': 2017,
    },
    {
      'name': 'InnovaTech Startup',
      'logo': 'innovatech_logo.png',
      'description': 'Startup innovante développant des solutions IoT et mobiles.',
      'siret': '55544433322111',
      'ape': '6209Z',
      'location': 'Nantes, France',
      'website': 'https://innovatech-startup.fr',
      'employees': '5-25',
      'founded': 2021,
    },
    {
      'name': 'DigitalPro Consulting',
      'logo': 'digitalpro_logo.png',
      'description': 'Cabinet de conseil spécialisé en transformation digitale.',
      'siret': '99988877766555',
      'ape': '6202A',
      'location': 'Bordeaux, France',
      'website': 'https://digitalpro-consulting.fr',
      'employees': '15-75',
      'founded': 2016,
    }
  ];

  // Créer les employeurs de démo
  static Future<void> createDemoEmployers() async {
    try {
      if (kDebugMode) print('🏢 Création des employeurs de démo...');

      final batch = _firestore.batch();

      for (int i = 0; i < demoCompanies.length; i++) {
        final company = demoCompanies[i];
        final employerId = 'demo_employer_${i + 1}';

        // Données employeur
        final employerData = {
          'Email': 'demo${i + 1}@${company['name']!.toLowerCase().replaceAll(' ', '')}.fr',
          'CompanyName': company['name'],
          'SIRET': company['siret'],
          'APE': company['ape'],
          'location': company['location'],
          'description': company['description'],
          'website': company['website'],
          'employees': company['employees'],
          'founded': company['founded'],
          'TotalPost': 0,
          'company': true,
          'CreatedAt': FieldValue.serverTimestamp(),
          'DemoAccount': true,
          'isActive': true,
        };

        final employerRef = _firestore
            .collection('Auth')
            .doc('Manager')
            .collection('register')
            .doc(employerId);

        batch.set(employerRef, employerData);

        // Informations détaillées de l'entreprise
        final companyDetailRef = employerRef.collection('company').doc();
        final companyDetailData = {
          'name': company['name'],
          'website': company['website'],
          'location': company['location'],
          'description': company['description'],
          'employees': company['employees'],
          'founded': company['founded'],
          'logo': company['logo'],
          'CreatedAt': FieldValue.serverTimestamp(),
        };

        batch.set(companyDetailRef, companyDetailData);
      }

      await batch.commit();
      if (kDebugMode) print('✅ ${demoCompanies.length} employeurs de démo créés !');

    } catch (e) {
      if (kDebugMode) print('❌ Erreur création employeurs de démo: $e');
      rethrow;
    }
  }

  // Générer des annonces IT de démo
  static Future<void> generateDemoJobs() async {
    try {
      if (kDebugMode) print('🚀 Génération des annonces de démo...');

      final batch = _firestore.batch();
      
      // Positions par catégorie IT
      final Map<String, List<String>> positionsByCategory = {
        'Développement': [
          'Développeur Full Stack Senior', 'Développeur Frontend React', 'Développeur Backend Node.js', 
          'Développeur PHP/Symfony', 'Ingénieur Logiciel', 'Architecte Solution'
        ],
        'Data Science': [
          'Data Scientist', 'Data Analyst', 'Ingénieur Big Data',
          'Machine Learning Engineer', 'Data Engineer', 'Business Intelligence Analyst'
        ],
        'DevOps': [
          'DevOps Engineer', 'Site Reliability Engineer', 'Platform Engineer',
          'Infrastructure Engineer', 'Build & Release Engineer', 'Automation Engineer'
        ],
        'Cybersécurité': [
          'Ingénieur Cybersécurité', 'Security Analyst', 'Penetration Tester',
          'CISO', 'Security Operations Center Analyst', 'Incident Response Specialist'
        ],
        'Cloud': [
          'Architecte Cloud', 'Cloud Engineer AWS', 'Cloud Engineer Azure',
          'Solutions Architect', 'Cloud Infrastructure Manager', 'Cloud DevOps Engineer'
        ],
        'Mobile': [
          'Développeur Mobile Flutter', 'Développeur iOS Swift', 'Développeur Android Kotlin',
          'Mobile App Architect', 'React Native Developer', 'Xamarin Developer'
        ],
        'IA & Machine Learning': [
          'AI Research Engineer', 'Deep Learning Engineer', 'NLP Engineer',
          'Computer Vision Engineer', 'MLOps Engineer', 'Prompt Engineer'
        ],
        'Management IT': [
          'CTO', 'VP Engineering', 'Team Lead Technique',
          'Product Manager', 'Chef de Projet IT', 'Scrum Master'
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
              'description': _generateJobDescription(position, company['name']!),
              'createdAt': FieldValue.serverTimestamp(),
              'isActive': true,
              'BookMarkUserList': <String>[],
              'applicants': (jobCount % 5) + 1, // Entre 1 et 5 candidatures
              'deviceToken': 'demo_device_token',
              // Champs pour les filtres
              'salaryRange': _getSalaryRange(salary),
              'keywords': _generateKeywords(position, category),
              'employerId': 'demo_employer_${(jobCount % demoCompanies.length) + 1}',
              'SIRET': company['siret'],
              'APE': company['ape'],
              'benefits': _generateBenefits(),
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
      'Développement': {
        'Débutant': 42000, 'Intermédiaire': 55000, 'Confirmé': 70000, 'Expert': 90000
      },
      'Data Science': {
        'Débutant': 45000, 'Intermédiaire': 58000, 'Confirmé': 75000, 'Expert': 95000
      },
      'DevOps': {
        'Débutant': 48000, 'Intermédiaire': 62000, 'Confirmé': 78000, 'Expert': 100000
      },
      'Cybersécurité': {
        'Débutant': 50000, 'Intermédiaire': 65000, 'Confirmé': 80000, 'Expert': 110000
      },
      'Cloud': {
        'Débutant': 52000, 'Intermédiaire': 68000, 'Confirmé': 85000, 'Expert': 120000
      },
      'Mobile': {
        'Débutant': 40000, 'Intermédiaire': 52000, 'Confirmé': 68000, 'Expert': 85000
      },
      'IA & Machine Learning': {
        'Débutant': 55000, 'Intermédiaire': 72000, 'Confirmé': 90000, 'Expert': 130000
      },
      'Management IT': {
        'Débutant': 65000, 'Intermédiaire': 85000, 'Confirmé': 110000, 'Expert': 150000
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
      'Développement': [
        'Maîtrise des langages de programmation (JavaScript, Python, Java)',
        'Expérience avec les frameworks modernes (React, Angular, Vue.js)',
        'Connaissance des bases de données (SQL, NoSQL)',
        'Pratique des méthodologies agiles (Scrum, Kanban)',
        'Maîtrise de Git et des outils DevOps'
      ],
      'Data Science': [
        'Python/R et librairies data (Pandas, NumPy, Scikit-learn)',
        'Machine Learning et Deep Learning',
        'Visualisation de données (Tableau, PowerBI, Matplotlib)',
        'Connaissance des bases de données et SQL',
        'Statistiques et mathématiques appliquées'
      ],
      'DevOps': [
        'Containerisation (Docker, Kubernetes)',
        'Cloud Computing (AWS, Azure, GCP)',
        'Infrastructure as Code (Terraform, Ansible)',
        'CI/CD pipelines (Jenkins, GitLab CI)',
        'Monitoring et logging (Prometheus, ELK Stack)'
      ],
      'Cybersécurité': [
        'Sécurité réseau et systèmes',
        'Outils SIEM (Splunk, QRadar)',
        'Tests de pénétration et audit sécurité',
        'Scripting (Python, PowerShell)',
        'Certifications sécurité (CISSP, CEH) appréciées'
      ],
      'Cloud': [
        'Expertise des plateformes cloud (AWS, Azure, GCP)',
        'Architecture et migration cloud',
        'Services cloud natifs et microservices',
        'Sécurité cloud et governance',
        'Optimisation des coûts cloud'
      ],
      'Mobile': [
        'Développement natif ou cross-platform',
        'UI/UX mobile et Material Design',
        'Intégration d\'APIs REST et GraphQL',
        'Tests automatisés et déploiement mobile',
        'Performance et optimisation mobile'
      ],
      'IA & Machine Learning': [
        'Deep Learning frameworks (TensorFlow, PyTorch)',
        'NLP et Computer Vision',
        'MLOps et déploiement de modèles',
        'Big Data et data engineering',
        'Recherche et veille technologique IA'
      ],
      'Management IT': [
        'Leadership technique et gestion d\'équipe',
        'Vision produit et stratégie technique',
        'Méthodologies agiles et lean',
        'Budget et gestion de projets IT',
        'Communication avec les stakeholders'
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
      'Développement': ['fullstack', 'frontend', 'backend', 'web', 'api', 'javascript'],
      'Data Science': ['data', 'analytics', 'machine learning', 'ai', 'python', 'sql'],
      'DevOps': ['cloud', 'kubernetes', 'docker', 'ci/cd', 'automation', 'infrastructure'],
      'Cybersécurité': ['security', 'pentest', 'siem', 'vulnerability', 'compliance'],
      'Cloud': ['aws', 'azure', 'gcp', 'migration', 'scalability', 'architecture'],
      'Mobile': ['flutter', 'react native', 'ios', 'android', 'app development'],
      'IA & Machine Learning': ['artificial intelligence', 'neural networks', 'nlp', 'computer vision'],
      'Management IT': ['leadership', 'strategy', 'agile', 'scrum', 'product management'],
    };

    return [
      ...positionKeywords,
      ...categoryKeywords,
      ...additionalKeywords[category] ?? []
    ];
  }

  static List<String> _generateBenefits() {
    final allBenefits = [
      'Télétravail hybride possible',
      'Mutuelle premium',
      'Tickets restaurant',
      '13ème mois',
      'RTT et congés flexibles',
      'Formation continue',
      'Certification professionnelle financée',
      'Prime de performance',
      'Stock-options',
      'Équipement haut de gamme',
      'Team building réguliers',
      'Participation aux bénéfices',
      'Vélo de fonction',
      'Salle de sport',
      'Conciergerie d\'entreprise'
    ];
    
    // Retourner 4-6 avantages aléatoires
    final shuffled = List<String>.from(allBenefits)..shuffle();
    return shuffled.take(5).toList();
  }

  // Générer des annonces d'emploi en anglais
  static Future<void> generateEnglishJobs() async {
    try {
      if (kDebugMode) print('🌍 Génération des annonces en anglais...');

      final batch = _firestore.batch();
      
      final englishJobs = [
        {
          "companyName": "DataMaster Strasbourg",
          "title": "Big Data Engineer",
          "description": "DataMaster Strasbourg is seeking an experienced Big Data Engineer to join our team. You will be responsible for designing, implementing, and maintaining large-scale data processing systems using cutting-edge technologies like Hadoop, Spark, and Kafka.",
          "requirements": [
            "Master's degree in Computer Science, Data Science, or a related field.",
            "5+ years of experience in big data technologies.",
            "Proficiency in Java, Scala, or Python.",
            "Experience with distributed computing frameworks (Hadoop, Spark).",
            "Knowledge of streaming technologies (Kafka, Storm).",
            "Experience with cloud platforms (AWS, Azure, GCP)."
          ],
          "location": "Strasbourg, France",
          "jobType": "CDI",
          "experienceLevel": "Confirmé",
          "salary": "75000",
          "salaryMax": "95000",
          "skills": ["Hadoop", "Spark", "Kafka", "Java", "Scala", "AWS"],
          "category": "Data Science",
          "industry": "Big Data"
        },
        {
          "companyName": "ShieldIT Nice",
          "title": "Penetration Tester",
          "description": "ShieldIT Nice is looking for a skilled Penetration Tester to join our team. You will be responsible for conducting penetration tests on our systems and applications to identify and exploit vulnerabilities, and for providing recommendations for remediation.",
          "requirements": [
            "Bachelor's degree in Computer Science or a related field.",
            "Proven experience as a Penetration Tester or similar role.",
            "Strong knowledge of penetration testing methodologies and tools.",
            "Excellent understanding of web application and network security.",
            "Relevant certifications (e.g., OSCP, CEH) are a plus."
          ],
          "location": "Nice, France",
          "jobType": "CDI",
          "experienceLevel": "Intermédiaire",
          "salary": "55000",
          "salaryMax": "75000",
          "skills": ["Penetration Testing", "Web Application Security", "Network Security", "OSCP", "CEH"],
          "category": "Cybersécurité",
          "industry": "Cybersecurity"
        },
        {
          "companyName": "UserFirst Rennes",
          "title": "Product Designer (UX/UI)",
          "description": "UserFirst Rennes is seeking a talented Product Designer to join our team. You will be responsible for the entire product design process, from user research and ideation to final UI design and prototyping. You will work closely with our product and engineering teams to create intuitive and engaging user experiences.",
          "requirements": [
            "Proven experience as a Product Designer, UX/UI Designer, or similar role.",
            "Strong portfolio of design projects.",
            "Proficiency in design and prototyping tools (e.g., Figma, Sketch).",
            "Excellent understanding of user-centered design principles and methodologies.",
            "Good communication and teamwork skills."
          ],
          "location": "Rennes, France",
          "jobType": "CDI",
          "experienceLevel": "Intermédiaire",
          "salary": "50000",
          "salaryMax": "65000",
          "skills": ["Product Design", "UX Design", "UI Design", "Figma", "User Research"],
          "category": "Développement",
          "industry": "Technology"
        },
        {
          "companyName": "AI-Driven Grenoble",
          "title": "Machine Learning Engineer",
          "description": "AI-Driven Grenoble is looking for a skilled Machine Learning Engineer to join our team. You will be responsible for designing, building, and deploying machine learning models to solve complex business problems. You will work closely with our data scientists and software engineers to bring our AI solutions to life.",
          "requirements": [
            "Master's or PhD in Computer Science or a related field.",
            "Proven experience as a Machine Learning Engineer or similar role.",
            "Strong programming skills in Python.",
            "Experience with machine learning frameworks (e.g., TensorFlow, PyTorch).",
            "Experience with deploying machine learning models in production."
          ],
          "location": "Grenoble, France",
          "jobType": "CDI",
          "experienceLevel": "Confirmé",
          "salary": "70000",
          "salaryMax": "90000",
          "skills": ["Machine Learning", "Python", "TensorFlow", "PyTorch", "MLOps"],
          "category": "IA & Machine Learning",
          "industry": "Artificial Intelligence"
        }
      ];

      for (int i = 0; i < englishJobs.length; i++) {
        final job = englishJobs[i];
        final company = demoCompanies[i % demoCompanies.length];
        
        final jobData = {
          'Position': job['title'],
          'CompanyName': job['companyName'],
          'CompanyLogo': company['logo'],
          'CompanyDescription': 'International company operating in ${job['location']}',
          'category': job['category'],
          'type': job['jobType'],
          'location': job['location'],
          'salary': job['salary'],
          'salaryMax': job['salaryMax'],
          'experienceLevel': job['experienceLevel'],
          'RequirementsList': job['requirements'],
          'description': job['description'],
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'BookMarkUserList': <String>[],
          'applicants': 0,
          'deviceToken': 'demo_device_token',
          'salaryRange': _getSalaryRange(job['salary']! as String),
          'keywords': [
            ...(job['title']! as String).toLowerCase().split(' '),
            ...(job['skills']! as List<dynamic>).map((s) => (s as String).toLowerCase()),
            'english',
            'international'
          ],
          'employerId': 'demo_employer_${(i % demoCompanies.length) + 1}',
          'SIRET': company['siret'],
          'APE': company['ape'],
          'skills': job['skills'],
          'industry': job['industry'],
          'benefits': [
            'Remote work options',
            'Health insurance',
            'Professional development',
            'Flexible hours',
            'International environment'
          ],
        };

        final docRef = _firestore.collection('allPost').doc();
        batch.set(docRef, jobData);
      }

      await batch.commit();
      if (kDebugMode) print('✅ ${englishJobs.length} annonces en anglais créées !');

    } catch (e) {
      if (kDebugMode) print('❌ Erreur création annonces anglaises: $e');
      rethrow;
    }
  }

  // Créer des candidatures fictives
  static Future<void> createDemoApplications() async {
    try {
      if (kDebugMode) print('📋 Création des candidatures de démo...');

      final batch = _firestore.batch();
      final candidateNames = [
        'Marie Dubois',
        'Thomas Martin',
        'Sophie Laurent',
        'Pierre Durand',
        'Camille Petit',
        'Antoine Moreau',
        'Julie Simon',
        'Nicolas Bernard',
        'Clara Rousseau',
        'Maxime Leroy'
      ];

      // Récupérer quelques annonces pour créer des candidatures
      final jobsSnapshot = await _firestore
          .collection('allPost')
          .where('CompanyName', whereIn: demoCompanies.map((c) => c['name']).toList())
          .limit(15)
          .get();

      for (int i = 0; i < jobsSnapshot.docs.length && i < candidateNames.length; i++) {
        final job = jobsSnapshot.docs[i];
        final candidateName = candidateNames[i];
        final email = candidateName.toLowerCase().replaceAll(' ', '.') + '@email.com';

        final applicationData = {
          'applicantName': candidateName,
          'applicantEmail': email,
          'jobId': job.id,
          'position': job.data()['Position'],
          'company': job.data()['CompanyName'],
          'employerId': job.data()['employerId'] ?? 'demo_employer_1',
          'appliedAt': FieldValue.serverTimestamp(),
          'status': ['En attente', 'En cours', 'Acceptée', 'Refusée'][i % 4],
          'cvUrl': 'https://example.com/cv/${candidateName.toLowerCase().replaceAll(' ', '-')}.pdf',
          'coverLetter': 'Madame, Monsieur,\n\nJe suis très intéressé(e) par le poste de ${job.data()['Position']} au sein de ${job.data()['CompanyName']}. Mon expérience et mes compétences correspondent parfaitement aux exigences décrites dans votre annonce...',
          'experience': ['1-2 ans', '3-5 ans', '5+ ans'][i % 3],
          'currentSalary': ((int.tryParse(job.data()['salary'] ?? '45000') ?? 45000) * 0.9).round().toString(),
          'expectedSalary': job.data()['salary'],
          'availability': 'Immédiate',
          'location': job.data()['location'],
        };

        final docRef = _firestore.collection('applications').doc();
        batch.set(docRef, applicationData);
      }

      await batch.commit();
      if (kDebugMode) print('✅ ${candidateNames.length} candidatures de démo créées !');

    } catch (e) {
      if (kDebugMode) print('❌ Erreur création candidatures de démo: $e');
      rethrow;
    }
  }

  // Méthode principale pour créer toutes les données de démo
  static Future<void> createAllDemoData() async {
    try {
      if (kDebugMode) print('🚀 Initialisation complète des données de démo...');
      
      await createDemoEmployers();
      await generateDemoJobs();
      await generateEnglishJobs();
      await createDemoApplications();
      
      if (kDebugMode) print('✅ Toutes les données de démo ont été créées avec succès !');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de la création des données de démo: $e');
      rethrow;
    }
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