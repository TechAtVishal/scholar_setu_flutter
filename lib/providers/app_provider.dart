import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';
import '../models/application_model.dart';

class AppProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserProfileModel _profile = UserProfileModel();
  Map<String, Map<String, dynamic>> _documents = {};
  List<ApplicationModel> _applications = [];
  List<Map<String, dynamic>> _offlineQueue = [];
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  UserProfileModel get profile => _profile;
  Map<String, Map<String, dynamic>> get documents => _documents;
  List<ApplicationModel> get applications => _applications;
  List<Map<String, dynamic>> get offlineQueue => _offlineQueue;
  List<Map<String, dynamic>> get notifications => _notifications;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  List<ApplicationModel> get pendingApplications =>
      _applications.where((a) => a.status != 'disbursed' && a.status != 'rejected').toList();

  int get unreadNotifications => _notifications.where((n) => n['read'] != true).length;

  AppProvider() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        _user = jsonDecode(userJson) as Map<String, dynamic>;
        _isAuthenticated = true;
      }
      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        _profile = UserProfileModel.fromJson(jsonDecode(profileJson));
      }
      final docsJson = prefs.getString('documents');
      if (docsJson != null) {
        final raw = jsonDecode(docsJson) as Map<String, dynamic>;
        _documents = raw.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
      }
      final appsJson = prefs.getString('applications');
      if (appsJson != null) {
        final list = jsonDecode(appsJson) as List;
        _applications = list.map((e) => ApplicationModel.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> login(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    _user = userData;
    _isAuthenticated = true;
    await prefs.setString('user', jsonEncode(userData));
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('profile');
    await prefs.remove('documents');
    await prefs.remove('applications');
    _user = null;
    _isAuthenticated = false;
    _profile = UserProfileModel();
    _documents = {};
    _applications = [];
    notifyListeners();
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> addDocument(String type, Map<String, dynamic> data) async {
    _documents[type] = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('documents', jsonEncode(_documents));
    notifyListeners();
  }

  Future<ApplicationModel> addApplication({
    required String schemeId,
    required String schemeName,
    required Map<String, dynamic> formData,
    bool offline = false,
  }) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final applicationId = 'SS-${schemeId.toUpperCase().substring(0, 4)}-${now.year}-${(100000 + (now.millisecondsSinceEpoch % 900000)).toString()}';
    final app = ApplicationModel(
      id: uuid.v4(),
      applicationId: applicationId,
      schemeId: schemeId,
      schemeName: schemeName,
      status: offline ? 'draft' : 'submitted',
      submittedAt: now,
      formData: formData,
      timeline: [
        ApplicationTimeline(
          status: offline ? 'draft' : 'submitted',
          label: offline ? 'Saved as Draft' : 'Application Submitted',
          date: now,
          note: offline
              ? 'Will be submitted when internet is available'
              : 'Your application has been submitted to NSP portal',
          done: true,
        ),
      ],
    );
    _applications.add(app);
    if (offline) {
      _offlineQueue.add({'type': 'application', 'id': app.id, 'time': now.toIso8601String()});
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('applications', jsonEncode(_applications.map((a) => a.toJson()).toList()));
    notifyListeners();
    return app;
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, {'id': DateTime.now().millisecondsSinceEpoch.toString(), ...notification, 'read': false, 'time': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n['id'] == id);
    if (idx >= 0) {
      _notifications[idx] = {..._notifications[idx], 'read': true};
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
