import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SessionStorage {
  final SharedPreferences _prefs;

  SessionStorage(this._prefs);

  static Future<SessionStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionStorage(prefs);
  }

  String? getToken() => _prefs.getString(AppConstants.tokenKey);

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getRefreshToken() => _prefs.getString(AppConstants.refreshTokenKey);

  Future<void> saveRefreshToken(String refreshToken) async {
    await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  String? getUserId() => _prefs.getString(AppConstants.userIdKey);

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(AppConstants.userIdKey, userId);
  }

  String? getUserEmail() => _prefs.getString(AppConstants.userEmailKey);

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(AppConstants.userEmailKey, email);
  }

  String? getUserName() => _prefs.getString(AppConstants.userNameKey);

  Future<void> saveUserName(String name) async {
    await _prefs.setString(AppConstants.userNameKey, name);
  }

  bool isPerfilCompletado() => _prefs.getBool(AppConstants.perfilCompletadoKey) ?? false;

  Future<void> setPerfilCompletado(bool value) async {
    await _prefs.setBool(AppConstants.perfilCompletadoKey, value);
  }

  bool hasSession() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  String? getCachedPerfilJson() => _prefs.getString(AppConstants.cachedPerfilKey);

  Future<void> saveCachedPerfilJson(String jsonStr) async {
    await _prefs.setString(AppConstants.cachedPerfilKey, jsonStr);
  }

  String? getCachedRegistrosJson() => _prefs.getString(AppConstants.cachedRegistrosKey);

  Future<void> saveCachedRegistrosJson(String jsonStr) async {
    await _prefs.setString(AppConstants.cachedRegistrosKey, jsonStr);
  }

  String? getSyncQueueJson() => _prefs.getString(AppConstants.syncQueueKey);

  Future<void> saveSyncQueueJson(String jsonStr) async {
    await _prefs.setString(AppConstants.syncQueueKey, jsonStr);
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userIdKey);
    await _prefs.remove(AppConstants.userEmailKey);
    await _prefs.remove(AppConstants.userNameKey);
    await _prefs.remove(AppConstants.perfilCompletadoKey);
    await _prefs.remove(AppConstants.cachedPerfilKey);
    await _prefs.remove(AppConstants.cachedRegistrosKey);
    await _prefs.remove(AppConstants.syncQueueKey);
  }

  String getCustomBaseUrl() => AppConstants.apiBaseUrl;

  String getThemeMode() {
    return _prefs.getString('app_theme_mode') ?? 'system';
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString('app_theme_mode', mode);
  }
}
