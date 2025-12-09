// lib/service/email_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Send email using Firebase Extensions
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
    Map<String, dynamic>? templateData,
  }) async {
    try {
      // Method 1: Firebase Extensions (Trigger Email)
      final mailDoc = await _db.collection("mail").add({
        "to": [to],
        "message": {
          "subject": subject,
          "html": htmlBody,
          "text": textBody ?? _stripHtml(htmlBody),
        },
        "template": templateData != null
            ? {
                "name": "custom",
                "data": templateData,
              }
            : null,
      });

      print('✅ Email queued for sending: ${mailDoc.id}');
      print(' To: $to');
      print(' Subject: $subject');

      // Log email attempt
      await _logEmailAttempt(to, subject, mailDoc.id);

      return true;
    } catch (e) {
      print('❌ Email sending failed: $e');

      // Fallback: Try alternative method
      return await _sendEmailFallback(to, subject, htmlBody, textBody);
    }
  }

  // Fallback method using EmailJS or similar service
  static Future<bool> _sendEmailFallback(
      String to, String subject, String htmlBody, String? textBody) async {
    try {
      // Store email in pending queue for manual processing
      await _db.collection("pendingEmails").add({
        "to": to,
        "subject": subject,
        "htmlBody": htmlBody,
        "textBody": textBody,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
        "retryCount": 0,
      });

      print('⚠️ Email stored in pending queue for manual processing');

      return true;
    } catch (e) {
      print('❌ Fallback email storage failed: $e');
      return false;
    }
  }

  // Log email sending attempts
  static Future<void> _logEmailAttempt(
      String to, String subject, String mailDocId) async {
    try {
      await _db.collection("emailLogs").add({
        "to": to,
        "subject": subject,
        "mailDocId": mailDocId,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "queued",
      });
    } catch (e) {
      print('❌ Email logging failed: $e');
    }
  }

  // Strip HTML tags for text version
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  // Send welcome email with verification
  static Future<bool> sendWelcomeEmail(String email, String fullName) async {
    final subject = " Welcome to Timeless - Please verify your email";
    final htmlBody = _generateWelcomeEmailHTML(email, fullName);

    return await sendEmail(
      to: email,
      subject: subject,
      htmlBody: htmlBody,
      templateData: {
        "userName": fullName,
        "userEmail": email,
        "appName": "Timeless",
      },
    );
  }

  // Send application confirmation email
  static Future<bool> sendApplicationConfirmation({
    required String email,
    required String userName,
    required String jobTitle,
    required String companyName,
    required String salary,
    required String location,
    required String jobType,
  }) async {
    final subject = "✅ Candidature confirmée - $jobTitle chez $companyName";
    final htmlBody = _generateApplicationConfirmationHTML(
      userName: userName,
      jobTitle: jobTitle,
      companyName: companyName,
      salary: salary,
      location: location,
      jobType: jobType,
    );

    return await sendEmail(
      to: email,
      subject: subject,
      htmlBody: htmlBody,
      templateData: {
        "userName": userName,
        "jobTitle": jobTitle,
        "companyName": companyName,
        "salary": salary,
        "location": location,
        "jobType": jobType,
      },
    );
  }

  static String _generateWelcomeEmailHTML(String email, String fullName) {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Timeless</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
        .content { padding: 40px 30px; }
        .verification-box { background: #f8f9fa; padding: 25px; border-radius: 10px; margin: 25px 0; border-left: 4px solid #667eea; text-align: center; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 30px 20px; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1> Welcome to Timeless!</h1>
            <p>Your professional journey starts here</p>
        </div>
        <div class="content">
            <h2>Hello $fullName,</h2>
            <p>Welcome to Timeless! We're excited to have you join our community. Your account has been created successfully.</p>
            <div class="verification-box">
                <h3> Email Verification Required</h3>
                <p><strong>We've sent a verification link to:</strong></p>
                <p style="color: #667eea; font-weight: 600;">$email</p>
                <p>Please check your inbox and click the verification link to activate your account.</p>
            </div>
            <p>If you don't see the verification email, please check your spam folder.</p>
        </div>
        <div class="footer">
            <h3>The Timeless Team </h3>
            <p> support@timeless.app |  www.timeless.app</p>
        </div>
    </div>
</body>
</html>
    """;
  }

  static String _generateApplicationConfirmationHTML({
    required String userName,
    required String jobTitle,
    required String companyName,
    required String salary,
    required String location,
    required String jobType,
  }) {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Candidature confirmée</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-align: center; padding: 30px 20px; }
        .content { padding: 30px; }
        .thank-you-box { background: #e8f5e8; padding: 20px; border-radius: 10px; margin: 20px 0; border: 1px solid #28a745; text-align: center; }
        .job-details { background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #28a745; }
        .detail-row { display: flex; justify-content: space-between; margin: 8px 0; }
        .next-steps { background: #fff3cd; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #ffc107; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 20px; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✅ Candidature envoyée !</h1>
            <p>Votre candidature a été reçue avec succès</p>
        </div>
        <div class="content">
            <h2>Bonjour $userName,</h2>
            
            <div class="thank-you-box">
                <h3>🙏 Merci pour votre candidature !</h3>
                <p>Nous vous remercions d'avoir postulé à cette offre. Votre candidature est maintenant entre les mains de l'équipe de recrutement.</p>
            </div>
            
            <p>Excellente nouvelle ! Votre candidature a été soumise avec succès.</p>
            
            <div class="job-details">
                <h3>📋 Détails de votre candidature</h3>
                <div class="detail-row">
                    <span><strong>Poste :</strong></span>
                    <span>$jobTitle</span>
                </div>
                <div class="detail-row">
                    <span><strong>Entreprise :</strong></span>
                    <span>$companyName</span>
                </div>
                <div class="detail-row">
                    <span><strong>Localisation :</strong></span>
                    <span>$location</span>
                </div>
                <div class="detail-row">
                    <span><strong>Type de contrat :</strong></span>
                    <span>$jobType</span>
                </div>
                <div class="detail-row">
                    <span><strong>Salaire :</strong></span>
                    <span>$salary</span>
                </div>
            </div>
            
            <div class="next-steps">
                <h3>📞 Prochaines étapes</h3>
                <p>L'équipe de recrutement va examiner votre candidature et vous contacter prochainement si votre profil correspond à leurs attentes.</p>
                <p><strong>Nous vous souhaitons bonne chance !</strong></p>
            </div>
            
            <p>Si vous avez des questions, n'hésitez pas à nous contacter.</p>
        </div>
        <div class="footer">
            <h3>L'équipe Timeless 💼</h3>
            <p>📧 support@timeless.app</p>
            <p><em>Merci de nous faire confiance pour votre recherche d'emploi</em></p>
        </div>
    </div>
</body>
</html>
    """;
  }
}
