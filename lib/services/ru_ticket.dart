import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart' as html;

class UFRGSRuTickets {
  static const String _baseUrl = 'https://www1.ufrgs.br/sistemas/portal';

  final Dio _dio;
  final CookieJar _cookieJar;
  var isLogged = false;

  UFRGSRuTickets()
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
    return isLogged;
  }

  /// Clears cookies (logout)
  Future<void> logout() async {
    await _cookieJar.deleteAll();
    isLogged = false;
  }

  Future<Map<String, int>> fetchTicketCounts() async {
    final response = await _dio.get('https://www1.ufrgs.br/RU/tru/');

    if (response.statusCode != 200) {
      throw Exception('Failed to load RU page');
    }

    final document = html.parse(response.data);

    final Map<String, int> result = {};

    final elements = document.querySelectorAll('#yw0 tr td:first-child');

    for (final element in elements) {
      final text = element.text.trim();

      if (text.isEmpty) continue;

      result[text] = (result[text] ?? 0) + 1;
    }

    return result;
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

    // 2. Fetch RU tickets page
    final response = await _dio.get('https://www1.ufrgs.br/RU/tru/');

    if (response.statusCode != 200) {
      throw Exception('Failed to load RU tickets page');
    }

    // 3. Parse HTML
    final document = html.parse(response.data);

    final Map<String, int> result = {};

    final elements = document.querySelectorAll('#yw0 tr td:first-child');

    for (final element in elements) {
      final text = element.text.trim();

      if (text.isEmpty) continue;

      result[text] = (result[text] ?? 0) + 1;
    }

    return result;
  }
}
