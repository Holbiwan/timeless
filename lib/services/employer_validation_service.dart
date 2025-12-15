// lib/services/employer_validation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmployerValidationService {
  static const String _baseUrl = 'https://api.insee.fr/entreprises/sirene/V3';

  // Données fictives cohérentes pour les tests
  static const Map<String, Map<String, dynamic>> _fakeCompanies = {
    '12345678901234': {
      'siret': '12345678901234',
      'denomination': 'TechCorp Solutions',
      'activitePrincipaleUniteLegale': '6201Z',
      'activitePrincipaleLibelle': 'Programmation informatique',
      'adresse': '123 Avenue des Champs-Élysées 75008 Paris',
      'secteur': 'Informatique',
      'effectif': '50-99',
      'created': '2020-03-15',
    },
    '98765432109876': {
      'siret': '98765432109876',
      'denomination': 'DataFlow Analytics',
      'activitePrincipaleUniteLegale': '6202A',
      'activitePrincipaleLibelle':
          'Conseil en systèmes et logiciels informatiques',
      'adresse': '45 Rue de la République 69002 Lyon',
      'secteur': 'Conseil en informatique',
      'effectif': '20-49',
      'created': '2019-07-22',
    },
    '11223344556677': {
      'siret': '11223344556677',
      'denomination': 'SecurNet Technologies',
      'activitePrincipaleUniteLegale': '6209Z',
      'activitePrincipaleLibelle': 'Autres activités informatiques',
      'adresse': '78 Boulevard Saint-Germain 75006 Paris',
      'secteur': 'Cybersécurité',
      'effectif': '10-19',
      'created': '2021-11-10',
    },
    '99887766554433': {
      'siret': '99887766554433',
      'denomination': 'UX Design Studio',
      'activitePrincipaleUniteLegale': '7410Z',
      'activitePrincipaleLibelle': 'Activités spécialisées de design',
      'adresse': '12 Rue de Rivoli 75001 Paris',
      'secteur': 'Design UX/UI',
      'effectif': '5-9',
      'created': '2022-01-08',
    },
    '55667788990011': {
      'siret': '55667788990011',
      'denomination': 'CloudDataWorks',
      'activitePrincipaleUniteLegale': '6201Z',
      'activitePrincipaleLibelle': 'Programmation informatique',
      'adresse': '15 Croisette 06400 Cannes',
      'secteur': 'Data Engineering',
      'effectif': '30-49',
      'created': '2021-05-20',
    }
  };

  static const Map<String, String> _apeLibelles = {
    '6201Z': 'Programmation informatique',
    '6202A': 'Conseil en systèmes et logiciels informatiques',
    '6202B': 'Tierce maintenance de systèmes et d\'applications informatiques',
    '6203Z': 'Gestion d\'installations informatiques',
    '6209Z': 'Autres activités informatiques',
    '7410Z': 'Activités spécialisées de design',
    '7021Z': 'Conseil en relations publiques et communication',
    '6311Z': 'Traitement de données, hébergement et activités connexes',
    '6312Z': 'Portails Internet',
    '7112B': 'Ingénierie, études techniques',
  };

  // Valide un code SIRET et récupère les informations de l'entreprise
  static Future<Map<String, dynamic>?> validateSiret(String siret) async {
    // Nettoyage du SIRET
    final cleanSiret = siret.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanSiret.length != 14) {
      throw ArgumentError('Le SIRET doit contenir exactement 14 chiffres');
    }

    try {
      // Tentative d'appel à l'API INSEE réelle
      final response = await http.get(
        Uri.parse('$_baseUrl/siret/$cleanSiret'),
        headers: {
          'Accept': 'application/json',
          // Note: Pour une vraie app, il faudrait un token API INSEE
          // 'Authorization': 'Bearer YOUR_INSEE_API_TOKEN'
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseInseeResponse(data);
      } else if (response.statusCode == 404) {
        throw Exception('SIRET non trouvé dans la base INSEE');
      } else {
        // Fallback sur les données fictives
        return _getFakeCompanyData(cleanSiret);
      }
    } catch (e) {
      if (kDebugMode) print('Erreur API INSEE: $e');
      // Fallback sur les données fictives pour le développement
      return _getFakeCompanyData(cleanSiret);
    }
  }

  // Valide un code APE
  static bool validateApeCode(String apeCode) {
    final apeRegex = RegExp(r'^[0-9]{4}[A-Z]$');
    return apeRegex.hasMatch(apeCode.trim().toUpperCase());
  }

  // Récupère le libellé d'un code APE
  static String getApeLibelle(String apeCode) {
    return _apeLibelles[apeCode.trim().toUpperCase()] ??
        'Activité non répertoriée';
  }

  // Valide la cohérence SIRET/APE
  static Future<bool> validateSiretApeConsistency(
      String siret, String apeCode) async {
    try {
      final companyInfo = await validateSiret(siret);
      if (companyInfo == null) return false;

      final companySiretApe = companyInfo['activitePrincipaleUniteLegale'];
      return companySiretApe == apeCode.trim().toUpperCase();
    } catch (e) {
      if (kDebugMode) print('Erreur validation cohérence SIRET/APE: $e');
      return false;
    }
  }

  // Parse la réponse de l'API INSEE
  static Map<String, dynamic> _parseInseeResponse(Map<String, dynamic> data) {
    final etablissement = data['etablissement'];
    final uniteLegale = etablissement['uniteLegale'];

    return {
      'siret': etablissement['siret'],
      'denomination': uniteLegale['denominationUniteLegale'] ??
          '${uniteLegale['prenomUsuelUniteLegale'] ?? ''} ${uniteLegale['nomUniteLegale'] ?? ''}',
      'activitePrincipaleUniteLegale':
          uniteLegale['activitePrincipaleUniteLegale'],
      'activitePrincipaleLibelle':
          getApeLibelle(uniteLegale['activitePrincipaleUniteLegale']),
      'adresse': '${etablissement['adresseEtablissement']['numeroVoieEtablissement'] ?? ''} '
          '${etablissement['adresseEtablissement']['typeVoieEtablissement'] ?? ''} '
          '${etablissement['adresseEtablissement']['libelleVoieEtablissement'] ?? ''} '
          '${etablissement['adresseEtablissement']['codePostalEtablissement'] ?? ''} '
          '${etablissement['adresseEtablissement']['libelleCommuneEtablissement'] ?? ''}',
      'secteur':
          _getSecteurFromApe(uniteLegale['activitePrincipaleUniteLegale']),
      'effectif':
          etablissement['trancheEffectifsEtablissement'] ?? 'Non renseigné',
      'created': DateTime.now().toIso8601String().split('T')[0],
    };
  }

  // Récupère les données fictives pour le développement/test
  static Map<String, dynamic>? _getFakeCompanyData(String siret) {
    if (_fakeCompanies.containsKey(siret)) {
      if (kDebugMode)
        print('Utilisation des données fictives pour SIRET: $siret');
      return Map<String, dynamic>.from(_fakeCompanies[siret]!);
    }
    throw Exception('SIRET non trouvé (simulation)');
  }

  // Détermine le secteur d'activité à partir du code APE
  static String _getSecteurFromApe(String apeCode) {
    if (apeCode.startsWith('62') || apeCode.startsWith('63')) {
      return 'Informatique';
    } else if (apeCode.startsWith('74')) {
      return 'Services professionnels';
    } else if (apeCode.startsWith('70')) {
      return 'Conseil';
    }
    return 'Autre';
  }

  // Génère des données fictives cohérentes pour les tests
  static Map<String, dynamic> generateFakeEmployerData({
    required String siret,
    required String companyName,
    required String email,
  }) {
    final apeCode =
        _fakeCompanies[siret]?['activitePrincipaleUniteLegale'] ?? '6201Z';

    return {
      'email': email,
      'companyName': companyName,
      'siretCode': siret,
      'apeCode': apeCode,
      'companyInfo': _fakeCompanies[siret] ??
          {
            'siret': siret,
            'denomination': companyName,
            'activitePrincipaleUniteLegale': apeCode,
            'activitePrincipaleLibelle': getApeLibelle(apeCode),
            'secteur': _getSecteurFromApe(apeCode),
          },
      'isVerified': true,
      'createdAt': DateTime.now(),
      'lastLoginAt': DateTime.now(),
      'accountType': 'employer',
      'status': 'active',
    };
  }

  // Liste des SIRET fictifs disponibles pour les tests
  static List<String> getAvailableFakeSirets() {
    return _fakeCompanies.keys.toList();
  }

  // Informations détaillées sur les entreprises fictives
  static List<Map<String, dynamic>> getFakeCompaniesDetails() {
    return _fakeCompanies.values.toList();
  }
}
