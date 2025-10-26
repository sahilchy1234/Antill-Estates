import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antill_estates/services/firebase_notification_service.dart';
import 'package:antill_estates/services/user_notification_service.dart';

class NotificationDebugView extends StatefulWidget {
  const NotificationDebugView({Key? key}) : super(key: key);

  @override
  State<NotificationDebugView> createState() => _NotificationDebugViewState();
}

class _NotificationDebugViewState extends State<NotificationDebugView> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();
  final UserNotificationService _userService = UserNotificationService();
  
  String _fcmToken = 'Loading...';
  String _userStatus = 'Loading...';
  String _permissionStatus = 'Loading...';
  List<String> _logs = [];
  
  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
    _startNotificationMonitoring();
  }

  Future<void> _loadDebugInfo() async {
    try {
      // Get FCM Token
      final token = await _messaging.getToken();
      setState(() {
        _fcmToken = token ?? 'No token found';
      });

      // Get permission status
      final permission = await _notificationService.getNotificationPermissionStatus();
      setState(() {
        _permissionStatus = permission ? 'Granted' : 'Denied';
      });

      // Get user status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isRegistered = await _userService.isUserRegisteredForNotifications();
        setState(() {
          _userStatus = isRegistered ? 'Registered' : 'Not Registered';
        });
      } else {
        setState(() {
          _userStatus = 'Not Authenticated';
        });
      }

      _addLog('Debug info loaded successfully');
    } catch (e) {
      _addLog('Error loading debug info: $e');
    }
  }

  void _startNotificationMonitoring() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addLog('📱 FOREGROUND: ${message.notification?.title}');
      _addLog('   Data: ${message.data}');
    });

    // Listen for notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addLog('🎯 TAPPED: ${message.notification?.title}');
      _addLog('   Data: ${message.data}');
    });

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((String token) {
      _addLog('🔄 Token refreshed: ${token.substring(0, 20)}...');
      setState(() {
        _fcmToken = token;
      });
    });

    _addLog('Notification monitoring started');
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toLocal().toString().substring(11, 19);
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _refreshDebugInfo() async {
    _addLog('Refreshing debug info...');
    await _loadDebugInfo();
  }

  Future<void> _forceRegisterUser() async {
    _addLog('Force registering user...');
    try {
      await _userService.registerUserForNotifications();
      _addLog('User registration completed');
      await _loadDebugInfo();
    } catch (e) {
      _addLog('Registration error: $e');
    }
  }

  Future<void> _testLocalNotification() async {
    _addLog('Testing local notification...');
    try {
      await _notificationService.clearAllNotifications();
      _addLog('Local notification test completed');
    } catch (e) {
      _addLog('Local notification error: $e');
    }
  }

  Future<void> _clearLogs() async {
    setState(() {
      _logs.clear();
    });
    _addLog('Logs cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Notification Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards
            _buildStatusCard('📱 FCM Token', _fcmToken),
            _buildStatusCard('👤 User Status', _userStatus),
            _buildStatusCard('🔔 Permission', _permissionStatus),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshDebugInfo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                ElevatedButton.icon(
                  onPressed: _forceRegisterUser,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register User'),
                ),
                ElevatedButton.icon(
                  onPressed: _testLocalNotification,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Test Local'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Logs'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Testing Instructions:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Make sure this app is running'),
                    const Text('2. Go to: http://localhost:8000/test_flutter_connection.html'),
                    const Text('3. Send test notifications from the web tool'),
                    const Text('4. Watch this log for incoming messages'),
                    const Text('5. Check device notification tray'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logs
            Text(
              '📋 Debug Logs:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: value.contains('No') || value.contains('Denied') || value.contains('Not')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
