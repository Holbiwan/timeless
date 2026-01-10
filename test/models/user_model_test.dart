import 'package:flutter_test/flutter_test.dart';
import 'package:timeless/models/user_model_unified.dart';

void main() {
  group('UserModel - Tests basiques', () {

    // Test 1 : Vérifier qu'on peut créer un utilisateur
    test('Création d\'un utilisateur', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        firstName: 'Jean',
        lastName: 'Dupont',
        fullName: 'Jean Dupont',
        title: 'Développeur',
        bio: 'Passionné de développement',
        experience: 'junior',
        city: 'Paris',
        savedJobs: [],
        appliedJobs: [],
        provider: 'email',
        role: 'user',
        profileCompleted: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Vérifications
      expect(user.firstName, 'Jean');
      expect(user.lastName, 'Dupont');
      expect(user.email, 'test@example.com');
    });

    // Test 2 : Vérifier l'affichage du nom complet
    test('Affichage du nom complet', () {
      final user = UserModel(
        uid: 'user456',
        email: 'marie@example.com',
        firstName: 'Marie',
        lastName: 'Martin',
        fullName: 'Marie Martin',
        title: 'Designer',
        bio: '',
        experience: 'mid',
        city: 'Lyon',
        savedJobs: [],
        appliedJobs: [],
        provider: 'email',
        role: 'user',
        profileCompleted: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.displayName, 'Marie Martin');
    });

    // Test 3 : Vérifier la gestion des jobs sauvegardés
    test('Gestion des jobs sauvegardés', () {
      final user = UserModel(
        uid: 'user789',
        email: 'paul@example.com',
        firstName: 'Paul',
        lastName: 'Bernard',
        fullName: 'Paul Bernard',
        title: 'Product Manager',
        bio: '',
        experience: 'senior',
        city: 'Marseille',
        savedJobs: ['job1', 'job2', 'job3'],
        appliedJobs: ['job1'],
        provider: 'email',
        role: 'user',
        profileCompleted: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Vérifier qu'on a bien 3 jobs sauvegardés
      expect(user.savedJobs.length, 3);
      expect(user.savedJobs.contains('job1'), true);
    });
  });
}
