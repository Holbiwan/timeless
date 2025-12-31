import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _jobApplicationAlerts = true;
  bool _marketingEmails = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final String employerId = PreferencesService.getString(PrefKeys.employerId);
      final String currentUserId = PreferencesService.getString(PrefKeys.userId);
      final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;

      final doc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(actualEmployerId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final notificationSettings = data['notificationSettings'] as Map<String, dynamic>?;
        
        if (notificationSettings != null) {
          setState(() {
            _emailNotifications = notificationSettings['emailNotifications'] ?? true;
            _pushNotifications = notificationSettings['pushNotifications'] ?? true;
            _jobApplicationAlerts = notificationSettings['jobApplicationAlerts'] ?? true;
            _marketingEmails = notificationSettings['marketingEmails'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> _saveNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String employerId = PreferencesService.getString(PrefKeys.employerId);
      final String currentUserId = PreferencesService.getString(PrefKeys.userId);
      final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;

      final notificationSettings = {
        'emailNotifications': _emailNotifications,
        'pushNotifications': _pushNotifications,
        'jobApplicationAlerts': _jobApplicationAlerts,
        'marketingEmails': _marketingEmails,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('employers')
          .doc(actualEmployerId)
          .update({
        'notificationSettings': notificationSettings,
      });

      Get.snackbar(
        'Success',
        'Notification settings updated successfully!',
        backgroundColor: const Color(0xFF000647),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update settings: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000647),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveNotificationSettings,
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manage your notification preferences to stay updated about your job postings and applications.',
                      style: GoogleFonts.inter(
                        color: Colors.blue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Communication Preferences',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard([
              _buildNotificationTile(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                icon: Icons.email,
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildNotificationTile(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on your device',
                icon: Icons.notifications,
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            Text(
              'Job-Related Alerts',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard([
              _buildNotificationTile(
                title: 'New Applications',
                subtitle: 'Get notified when someone applies to your jobs',
                icon: Icons.work,
                value: _jobApplicationAlerts,
                onChanged: (value) {
                  setState(() {
                    _jobApplicationAlerts = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            Text(
              'Marketing',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard([
              _buildNotificationTile(
                title: 'Marketing Emails',
                subtitle: 'Receive updates about new features and tips',
                icon: Icons.campaign,
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() {
                    _marketingEmails = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000647),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Settings',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF000647),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF000647),
      ),
    );
  }
}