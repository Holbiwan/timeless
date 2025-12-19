import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Direct email sending test
  try {
    final mailDoc = await FirebaseFirestore.instance.collection("mail").add({
      "to": ["bryanomane@gmail.com"],
      "message": {
        "subject": "🧪 Test Email - SMTP Configuration",
        "html": """
          <h2>Email Configuration Test</h2>
          <p>If you receive this email, the SMTP configuration is working correctly!</p>
          <hr>
          <small>Test sent from Timeless app</small>
        """,
        "text": "Email configuration test - If you receive this email, the SMTP configuration is working correctly!",
      },
    });
    
    print('✅ Test email added to queue: ${mailDoc.id}');
    print('📧 Check your mailbox in a few minutes...');
    
  } catch (e) {
    print('❌ Error during test: $e');
  }
}