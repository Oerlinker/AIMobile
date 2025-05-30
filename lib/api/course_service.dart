import 'api_client.dart';

/// Servicio para manejar las operaciones relacionadas con cursos
class CourseService {
  final ApiClient _apiClient;

  CourseService(this._apiClient);

  /// Obtiene la lista de todos los cursos disponibles
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _apiClient.get('cursos/');

      // Convertir la respuesta a una lista de mapas
      final List<dynamic> coursesList = response.data;
      return coursesList.map((course) => course as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener cursos: $e');
      // En caso de error, devolver una lista vacía
      return [];
    }
  }

  /// Obtiene los detalles de un curso específico por su ID
  Future<Map<String, dynamic>?> getCourseById(int courseId) async {
    try {
      final response = await _apiClient.get('cursos/$courseId/');
      return response.data;
    } catch (e) {
      print('Error al obtener el curso con ID $courseId: $e');
      return null;
    }
  }
}
