// lib/service/notification_service.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService extends GetxController {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Observable list of notifications
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }
  
  /// Add a new notification when user applies to a job
  Future<void> addApplicationNotification({
    required String jobTitle,
    required String companyName,
    required String jobId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final notificationData = {
        'uid': user.uid,
        'type': 'application_sent',
        'title': 'Application Sent',
        'body': 'Your application for "$jobTitle" at $companyName has been submitted successfully.',
        'timestamp': FieldValue.serverTimestamp(),
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'isRead': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Save to Firestore
      await _firestore.collection('notifications').add(notificationData);
      
      // Add to local list immediately for UI update
      final localNotif = {
        ...notificationData,
        'timestamp': Timestamp.now(),
        'timeAgo': 'Just now',
      };
      
      notifications.insert(0, localNotif);
      
    } catch (e) {
      print('Error adding notification: $e');
    }
  }
  
  /// Load user's notifications from Firestore
  Future<void> loadNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final query = await _firestore
          .collection('notifications')
          .where('uid', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final notifList = query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'timeAgo': _getTimeAgo(data['createdAt'] ?? 0),
        };
      }).toList();
      
      notifications.value = notifList;
      
    } catch (e) {
      print('Error loading notifications: $e');
      // Fallback to demo notifications if Firestore fails
      _loadDemoNotifications();
    }
  }
  
  /// Fallback demo notifications for testing
  void _loadDemoNotifications() {
    notifications.value = [
      {
        'type': 'application_sent',
        'title': 'Application Sent',
        'body': 'Your application for "UI Designer" has been sent.',
        'timeAgo': '2m ago',
        'isRead': false,
      },
      {
        'type': 'match',
        'title': 'New Match',
        'body': 'Timeless found 3 new jobs matching your profile.',
        'timeAgo': '10m ago',
        'isRead': false,
      },
      {
        'type': 'interview',
        'title': 'Interview Request',
        'body': 'Recruiter proposed an interview for next week.',
        'timeAgo': 'Yesterday',
        'isRead': false,
      },
    ];
  }
  
  /// Helper to calculate time ago
  String _getTimeAgo(int timestamp) {
    if (timestamp == 0) return 'Just now';
    
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
          
      // Update local list
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['isRead'] = true;
        notifications.refresh();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final query = await _firestore
          .collection('notifications')
          .where('uid', isEqualTo: user.uid)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      notifications.clear();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}