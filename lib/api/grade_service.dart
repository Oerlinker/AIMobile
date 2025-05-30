import 'dart:convert';
import '../models/grade.dart';
import '../models/period.dart';
import 'api_client.dart';

/// Servicio para manejar las operaciones relacionadas con calificaciones
class GradeService {
  final ApiClient _apiClient;

  GradeService(this._apiClient);

  /// Obtiene todos los períodos académicos disponibles
  Future<List<Period>> getPeriods() async {
    try {
      final response = await _apiClient.get('notas/periodos/');

      // Convertir la respuesta a una lista de objetos Period
      final List<dynamic> periodsList = response.data;
      return periodsList.map((period) => Period.fromJson(period)).toList();
    } catch (e) {
      print('Error al obtener períodos: $e');
      return [];
    }
  }

  /// Obtiene las calificaciones según los filtros especificados
  ///
  /// Los filtros son opcionales y pueden incluir: estudiante, materia, periodo, curso
  Future<List<Grade>> getGrades({
    int? studentId,
    int? subjectId,
    int? periodId,
    int? courseId,
  }) async {
    try {
      // Construir los parámetros de consulta
      final Map<String, dynamic> queryParams = {};
      if (studentId != null) queryParams['estudiante'] = studentId;
      if (subjectId != null) queryParams['materia'] = subjectId;
      if (periodId != null) queryParams['periodo'] = periodId;
      if (courseId != null) queryParams['curso'] = courseId;

      final response = await _apiClient.get(
        'notas/calificaciones/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Convertir la respuesta a una lista de objetos Grade
      final List<dynamic> gradesList = response.data;
      return gradesList.map((grade) => Grade.fromJson(grade)).toList();
    } catch (e) {
      print('Error al obtener calificaciones: $e');
      return [];
    }
  }

  /// Obtiene el detalle de una calificación específica por su ID
  Future<Grade?> getGradeById(int gradeId) async {
    try {
      final response = await _apiClient.get('notas/calificaciones/$gradeId/');
      return Grade.fromJson(response.data);
    } catch (e) {
      print('Error al obtener detalle de calificación: $e');
      return null;
    }
  }

  /// Crea una nueva calificación (solo para profesores)
  Future<Grade?> createGrade(Grade grade) async {
    try {
      final response = await _apiClient.post(
        'notas/calificaciones/',
        data: grade.toJson(),
      );

      if (response.statusCode == 201) {
        return Grade.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error al crear calificación: $e');
      return null;
    }
  }

  /// Actualiza una calificación existente (solo para profesores)
  Future<Grade?> updateGrade(Grade grade) async {
    try {
      if (grade.id == null) {
        throw Exception('No se puede actualizar una calificación sin ID');
      }

      final response = await _apiClient.put(
        'notas/calificaciones/${grade.id}/',
        data: grade.toJson(),
      );

      if (response.statusCode == 200) {
        return Grade.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error al actualizar calificación: $e');
      return null;
    }
  }

  /// Elimina una calificación (solo para profesores)
  Future<bool> deleteGrade(int gradeId) async {
    try {
      final response = await _apiClient.delete('notas/calificaciones/$gradeId/');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar calificación: $e');
      return false;
    }
  }

  /// Realiza la autoevaluación del estudiante (solo para el estudiante asociado)
  Future<bool> submitSelfEvaluation(int gradeId, double serScore, double decidirScore) async {
    try {
      final response = await _apiClient.post(
        'notas/calificaciones/$gradeId/autoevaluacion/',
        data: {
          'autoevaluacion_ser': serScore,
          'autoevaluacion_decidir': decidirScore,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al enviar autoevaluación: $e');
      return false;
    }
  }

  /// Obtiene estadísticas del estudiante
  Future<Map<String, dynamic>?> getStudentStatistics(int studentId) async {
    try {
      final response = await _apiClient.get(
        'notas/calificaciones/estadisticas_estudiante/',
        queryParameters: {'estudiante': studentId},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener estadísticas del estudiante: $e');
      return null;
    }
  }

  /// Obtiene estadísticas de una materia (solo para profesores y administrativos)
  Future<Map<String, dynamic>?> getSubjectStatistics({
    required int subjectId,
    int? periodId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'materia': subjectId};
      if (periodId != null) queryParams['periodo'] = periodId;

      final response = await _apiClient.get(
        'notas/calificaciones/estadisticas_materia/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener estadísticas de la materia: $e');
      return null;
    }
  }

  /// Obtiene reporte trimestral (solo para profesores y administrativos)
  Future<Map<String, dynamic>?> getTermReport({
    required int courseId,
    required int periodId,
  }) async {
    try {
      final response = await _apiClient.get(
        'notas/calificaciones/reporte_trimestral/',
        queryParameters: {
          'curso': courseId,
          'periodo': periodId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener reporte trimestral: $e');
      return null;
    }
  }
}
