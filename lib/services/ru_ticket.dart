import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';

class TicketCountsResponse {
  const TicketCountsResponse({
    required this.ticketCounts,
    required this.isFromCache,
    this.refreshFailed = false,
  });

  final Map<String, int> ticketCounts;
  final bool isFromCache;
  final bool refreshFailed;
}

class RUTicketService {
  static const String _baseUrl = 'https://www1.ufrgs.br/sistemas/portal';
  static const String _ticketsCachePrefix = 'ru_tickets_cache_';

  static final RUTicketService _instance = RUTicketService._internal();

  factory RUTicketService() {
    return _instance;
  }

  final Dio _dio;
  final CookieJar _cookieJar;
  var isLogged = false;
  String? _loggedUser;

  RUTicketService._internal()
    : _cookieJar = CookieJar(),
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          followRedirects: false, // IMPORTANT: keep 302 visible
          validateStatus: (status) => status != null && status < 500,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      ) {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Returns true if credentials are valid (302 Found)
  Future<bool> login({required String usuario, required String senha}) async {
    const loginPath = '/login';

    // Ensure we are logged out before attempting a new login
    await logout();

    // Step 1: initialize session cookies
    await _dio.get(loginPath);

    // Step 2: submit credentials
    final response = await _dio.post(
      loginPath,
      data: FormData.fromMap({
        'Var1': '',
        'Var2': '',
        'usuario': usuario,
        'senha': senha,
        'login': '',
      }),
    );

    isLogged = response.statusCode == 302;
    if (isLogged) {
      _loggedUser = usuario;
    }
    return isLogged;
  }

  /// Clears cookies (logout)
  Future<void> logout() async {
    await _cookieJar.deleteAll();
    isLogged = false;
    _loggedUser = null;
  }

  Future<Map<String, int>> fetchTicketCounts() async {
    return _fetchTicketCountsFromApi();
  }

  Future<Map<String, int>> _fetchTicketCountsFromApi() async {
    final response = await _dio.get('https://www1.ufrgs.br/RU/tru/');

    if (response.statusCode != 200) {
      throw Exception('Failed to load RU page');
    }

    // Search for the URL pattern in the response
    final responseData = response.data.toString();
    final urlPattern = RegExp(
      r"window\.open\('(/RU/tru/tiquete/impressao\?usuario=[^']+&tipo=N)'",
    );
    final match = urlPattern.firstMatch(responseData);

    if (match == null) {
      // If we are on the RU page but can't find the print link, 
      // it most likely means there are no tickets available.
      if (responseData.contains('RU') || responseData.contains('Tiquete')) {
        return {};
      }
      throw Exception('Could not find ticket URL in response');
    }

    final ticketUrl = match.group(1);

    // Fetch the actual ticket data
    final ticketResponse = await _dio.get('https://www1.ufrgs.br$ticketUrl');

    if (ticketResponse.statusCode != 200) {
      throw Exception('Failed to load ticket data');
    }

    final document = html.parse(ticketResponse.data);

    final Map<String, int> result = {};

    final rows = document.querySelectorAll('#yw0 tr');

    for (final row in rows) {
      final data = row.querySelectorAll('td');
      
      // 1. Safety Check: Ensure the row actually has the columns you expect
      if (data.length < 5) continue;

      // 2. Cleanup: Use trim() to remove hidden newlines or spaces from the HTML
      final ticketNumber = data[0].text.trim();
      final statusText = data[4].text.trim();
      
      // 3. Logic: Check availability
      final isAvailable = statusText == 'Dispon�vel';

      if (ticketNumber.isEmpty || !isAvailable) continue;

      // 4. Update Result
      result[ticketNumber] = (result[ticketNumber] ?? 0) + 1;
    }

    return result;
  }

  Stream<TicketCountsResponse> getTicketCountsWithCache({
    required String usuario,
    required String senha,
  }) async* {
    final cached = await _readCachedTicketCounts(usuario);

    if (cached != null && cached.isNotEmpty) {
      yield TicketCountsResponse(ticketCounts: cached, isFromCache: true);
    }

    try {
      // Ensure we are logged in with the correct user
      if (!isLogged || _loggedUser != usuario) {
        await login(usuario: usuario, senha: senha);
        if (!isLogged) {
          throw Exception('Invalid credentials');
        }
      }

      final fresh = await _fetchTicketCountsFromApi();
      print(fresh);
      await _saveCachedTicketCounts(usuario, fresh);

      // Always yield the fresh data to ensure the UI is up to date and cache is overwritten
      yield TicketCountsResponse(ticketCounts: fresh, isFromCache: false);
    } catch (e) {
      if (cached == null || cached.isEmpty) {
        rethrow;
      }

      yield TicketCountsResponse(
        ticketCounts: cached,
        isFromCache: true,
        refreshFailed: true,
      );
    }
  }

  Future<Map<String, int>> loginAndFetchTicketCounts({
    required String usuario,
    required String senha,
  }) async {
    // 1. Login
    if (!isLogged) {
      await login(usuario: usuario, senha: senha);

      if (!isLogged) {
        throw Exception('Invalid credentials');
      }
    }

    return _fetchTicketCountsFromApi();
  }

  Future<void> _saveCachedTicketCounts(
    String usuario,
    Map<String, int> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_ticketsCachePrefix$usuario', jsonEncode(data));
  }

  Future<Map<String, int>?> _readCachedTicketCounts(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_ticketsCachePrefix$usuario');
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final parsed = <String, int>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is int) {
          parsed[entry.key.toString()] = value;
        } else if (value is num) {
          parsed[entry.key.toString()] = value.toInt();
        }
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
