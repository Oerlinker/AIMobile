import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cliente HTTP para comunicarse con la API del backend
///
/// Esta clase maneja todas las peticiones HTTP, incluyendo la autenticación
/// y renovación automática de tokens JWT.
class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Constructor que configura las opciones base del cliente HTTP
  ApiClient() {
    _dio.options.baseUrl = 'https://backendaisi2-production.up.railway.app/api/';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Configuración de interceptores para manejar autenticación y errores
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Añadir token a las peticiones
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Si el error es 401 (no autorizado), intentar renovar el token
        if (error.response?.statusCode == 401) {
          // Token expirado, intentar renovarlo
          if (await _refreshToken()) {
            // Reintentar la petición original
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Intenta renovar el token de acceso usando el refresh token
  ///
  /// Retorna true si se renovó correctamente, false en caso contrario
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        'usuarios/login/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {}), // Sin el token de autorización
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: 'access_token',
          value: response.data['access'],
        );
        return true;
      }
      return false;
    } catch (e) {
      // Error al refrescar token, usuario debe volver a iniciar sesión
      await _secureStorage.deleteAll();
      return false;
    }
  }

  /// Reintenta una petición fallida con el nuevo token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Métodos públicos para realizar peticiones HTTP

  /// Realiza una petición GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// Realiza una petición POST
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// Realiza una petición PUT
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  /// Realiza una petición DELETE
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
