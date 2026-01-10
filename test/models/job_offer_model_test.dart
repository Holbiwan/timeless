import 'package:flutter_test/flutter_test.dart';
import 'package:timeless/models/job_offer_model.dart';

void main() {
  group('JobOfferModel - Tests basiques', () {

    // Test 1 : Vérifier qu'on peut créer une offre d'emploi
    test('Création d\'une offre d\'emploi', () {
      final job = JobOfferModel(
        id: 'job123',
        employerId: 'employer456',
        companyName: 'Google',
        title: 'Développeur Flutter',
        description: 'Nous recherchons un développeur Flutter',
        requirements: ['Flutter', 'Dart'],
        location: 'Paris',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.junior,
        skills: ['Flutter', 'Dart'],
        industry: 'Technologie',
        createdAt: DateTime(2024, 1, 1),
      );

      // Vérifications
      expect(job.title, 'Développeur Flutter');
      expect(job.companyName, 'Google');
      expect(job.location, 'Paris');
    });

    // Test 2 : Vérifier l'affichage du type de contrat
    test('Affichage du type de contrat', () {
      final jobFullTime = JobOfferModel(
        id: 'job1',
        employerId: 'emp1',
        companyName: 'Company A',
        title: 'Dev',
        description: 'Description',
        requirements: [],
        location: 'Paris',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.junior,
        skills: [],
        industry: 'Tech',
        createdAt: DateTime.now(),
      );

      expect(jobFullTime.jobTypeDisplay, 'Full-time');
    });

    // Test 3 : Vérifier l'affichage du salaire
    test('Affichage du salaire', () {
      final jobWithSalary = JobOfferModel(
        id: 'job2',
        employerId: 'emp1',
        companyName: 'Company B',
        title: 'Dev Senior',
        description: 'Description',
        requirements: [],
        location: 'Lyon',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.senior,
        salaryMin: 40000,
        salaryMax: 50000,
        skills: [],
        industry: 'Tech',
        createdAt: DateTime.now(),
      );

      expect(jobWithSalary.salaryDisplay, '40000€ - 50000€');
    });

    // Test 4 : Vérifier la modification d'une offre avec copyWith
    test('Modification d\'une offre avec copyWith', () {
      final job = JobOfferModel(
        id: 'job3',
        employerId: 'emp1',
        companyName: 'Startup',
        title: 'Dev Mobile',
        description: 'Description',
        requirements: [],
        location: 'Remote',
        jobType: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        skills: [],
        industry: 'Tech',
        createdAt: DateTime.now(),
      );

      // On modifie le titre
      final updatedJob = job.copyWith(title: 'Lead Mobile Developer');

      expect(updatedJob.title, 'Lead Mobile Developer');
      expect(updatedJob.companyName, 'Startup'); // Les autres valeurs restent identiques
    });
  });
}
