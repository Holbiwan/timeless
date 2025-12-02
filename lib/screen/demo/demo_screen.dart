import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/services/demo_data_service.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/app_res.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _isLoading = false;
  bool _isDemoDataGenerated = false;

  @override
  void initState() {
    super.initState();
    _checkDemoDataExists();
  }

  Future<void> _checkDemoDataExists() async {
    final exists = await DemoDataService.demoDataExists();
    setState(() {
      _isDemoDataGenerated = exists;
    });
  }

  Future<void> _generateDemoData() async {
    setState(() => _isLoading = true);
    
    try {
      await DemoDataService.generateDemoJobs();
      setState(() => _isDemoDataGenerated = true);
      
      AppTheme.showStandardSnackBar(
        title: "✅ Données de démo créées",
        message: "120+ offres d'emploi générées avec succès",
      );
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur",
        message: "Impossible de créer les données de démo: $e",
        isError: true,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _cleanDemoData() async {
    setState(() => _isLoading = true);
    
    try {
      await DemoDataService.cleanDemoData();
      setState(() => _isDemoDataGenerated = false);
      
      AppTheme.showStandardSnackBar(
        title: "🧹 Données supprimées",
        message: "Toutes les données de démo ont été supprimées",
      );
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur",
        message: "Impossible de supprimer les données: $e",
        isError: true,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _createDemoUser() async {
    setState(() => _isLoading = true);
    
    try {
      await DemoDataService.createDemoUser(
        email: 'demo@timeless.com',
        password: 'demo123456',
        fullName: 'Utilisateur Démo',
        userType: 'candidate',
      );
      
      AppTheme.showStandardSnackBar(
        title: "👤 Utilisateur de démo créé",
        message: "Email: demo@timeless.com / Mot de passe: demo123456",
      );
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur",
        message: "Impossible de créer l'utilisateur: $e",
        isError: true,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _signInAsDemoUser() async {
    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'demo@timeless.com',
        password: 'demo123456',
      );
      
      AppTheme.showStandardSnackBar(
        title: "✅ Connexion réussie",
        message: "Connecté en tant qu'utilisateur de démo",
      );
      
      // Rediriger vers le dashboard après connexion
      Get.offAllNamed('/dashboard');
      
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur de connexion",
        message: "Veuillez d'abord créer l'utilisateur de démo",
        isError: true,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testJobRecommendation() async {
    if (!_isDemoDataGenerated) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Données manquantes",
        message: "Veuillez d'abord générer les données de démo",
        isError: true,
      );
      return;
    }

    Get.toNamed(AppRes.jobRecommendationScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Mode Démo Timeless',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF000647),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF000647)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚀 Démo Complète',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Testez toutes les fonctionnalités de A à Z avec des données réelles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Étapes de la démo
            Expanded(
              child: ListView(
                children: [
                  _buildDemoCard(
                    icon: Icons.data_usage,
                    title: '1. Générer les données',
                    description: 'Créer 120+ offres d\'emploi réalistes',
                    isCompleted: _isDemoDataGenerated,
                    onTap: _isDemoDataGenerated ? _cleanDemoData : _generateDemoData,
                    buttonText: _isDemoDataGenerated ? 'Supprimer les données' : 'Générer les données',
                    isDestructive: _isDemoDataGenerated,
                  ),
                  
                  _buildDemoCard(
                    icon: Icons.person_add,
                    title: '2. Créer un utilisateur de test',
                    description: 'Email: demo@timeless.com',
                    isCompleted: false,
                    onTap: _createDemoUser,
                    buttonText: 'Créer utilisateur de démo',
                  ),
                  
                  _buildDemoCard(
                    icon: Icons.login,
                    title: '3. Se connecter',
                    description: 'Connexion automatique avec les identifiants de démo',
                    isCompleted: FirebaseAuth.instance.currentUser != null,
                    onTap: _signInAsDemoUser,
                    buttonText: 'Se connecter',
                  ),
                  
                  _buildDemoCard(
                    icon: Icons.work,
                    title: '4. Tester les filtres d\'emploi',
                    description: 'Recherche et filtres en temps réel',
                    isCompleted: false,
                    onTap: _testJobRecommendation,
                    buttonText: 'Voir les offres d\'emploi',
                  ),
                ],
              ),
            ),
            
            // Statut utilisateur actuel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut actuel:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FirebaseAuth.instance.currentUser != null 
                        ? '✅ Connecté: ${FirebaseAuth.instance.currentUser!.email}'
                        : '❌ Non connecté',
                    style: TextStyle(
                      fontSize: 12,
                      color: FirebaseAuth.instance.currentUser != null 
                          ? Colors.green.shade700 
                          : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    _isDemoDataGenerated 
                        ? '✅ Données de démo disponibles'
                        : '❌ Aucune donnée de démo',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDemoDataGenerated 
                          ? Colors.green.shade700 
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    required VoidCallback onTap,
    required String buttonText,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.shade100 
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isCompleted 
                      ? Colors.green.shade700 
                      : Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive 
                    ? Colors.red.shade600 
                    : const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}