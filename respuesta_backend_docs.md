# Documentación para la Integración con Flutter
## Aula Inteligente

Este documento proporciona la información necesaria para desarrollar una aplicación móvil en Flutter que se conecte con el backend de Aula Inteligente.

## Información General del Backend

- **Tecnología**: Django Rest Framework
- **Base de datos**: PostgreSQL
- **Autenticación**: JWT (JSON Web Tokens)
- **URL Base API**: `https://backendaisi2-production.up.railway.app/api/`
- **Machine Learning**: Modelos de predicción académica basados en Random Forest

## Sistema de Autenticación

El sistema utiliza JSON Web Tokens (JWT) para la autenticación de usuarios.

### Endpoints de Autenticación:

- **Iniciar Sesión**: `POST /api/usuarios/login/`
  - **Payload**: `{"username": "usuario", "password": "contraseña"}`
  - **Respuesta**:
    ```json
    {
      "access": "token_jwt_aquí",
      "refresh": "refresh_token_aquí",
      "user": {
        "id": 1,
        "username": "usuario",
        "email": "usuario@ejemplo.com",
        "first_name": "Nombre",
        "last_name": "Apellido",
        "role": "PROFESOR|ESTUDIANTE|ADMINISTRATIVO",
        "curso": null,
        "curso_detail": null
      }
    }
    ```

- **Renovar Token**: `POST /api/usuarios/login/refresh/`
  - **Payload**: `{"refresh": "refresh_token_aquí"}`
  - **Respuesta**: `{"access": "nuevo_token_jwt_aquí"}`

- **Registrar Usuario**: `POST /api/usuarios/registro/`
  - **Payload**:
    ```json
    {
      "username": "nuevo_usuario",
      "email": "email@ejemplo.com",
      "first_name": "Nombre",
      "last_name": "Apellido",
      "role": "ESTUDIANTE",
      "curso": 1,
      "password": "contraseña",
      "password2": "contraseña"
    }
    ```
  - **Notas**: El campo `curso` es opcional y solo aplicable para estudiantes.

- **Ver Perfil de Usuario**: `GET /api/usuarios/perfil/`
  - **Headers**: `Authorization: Bearer token_jwt_aquí`

- **Actualizar Perfil**: `PUT /api/usuarios/perfil/`
  - **Headers**: `Authorization: Bearer token_jwt_aquí`
  - **Payload**: Campos parciales a actualizar

## Modelos Principales

### 1. Usuario (User)

Extiende el modelo de usuario de Django con roles específicos para el sistema educativo.

```python
{
  "id": integer,
  "username": string,
  "email": string,
  "first_name": string,
  "last_name": string,
  "role": "PROFESOR" | "ESTUDIANTE" | "ADMINISTRATIVO",
  "curso": integer (id del curso, solo para estudiantes),
  "curso_detail": object (detalles del curso)
}
```

### 2. Curso

Representa un grupo o nivel educativo al que pertenecen los estudiantes.

```python
{
  "id": integer,
  "nombre": string,
  "nivel": "PRIMARIA" | "SECUNDARIA",
  "materias": array[integer] (ids de materias)
}
```

### 3. Materia

Representa una asignatura académica.

```python
{
  "id": integer,
  "nombre": string,
  "codigo": string,
  "descripcion": string,
  "creditos": integer,
  "profesor": integer (id del profesor)
}
```

### 4. Nota

Calificaciones de los estudiantes organizadas por el modelo de evaluación ser-saber-hacer-decidir.

```python
{
  "id": integer,
  "estudiante": integer,
  "materia": integer,
  "periodo": integer,
  "ser_puntaje": decimal (0-10),
  "saber_puntaje": decimal (0-35),
  "hacer_puntaje": decimal (0-35),
  "decidir_puntaje": decimal (0-10),
  "autoevaluacion_ser": decimal (0-5),
  "autoevaluacion_decidir": decimal (0-5),
  "fecha_registro": datetime,
  "ultima_modificacion": datetime,
  "comentario": string
}
```

### 5. Periodo

División temporal del año académico.

```python
{
  "id": integer,
  "nombre": string,
  "trimestre": "PRIMERO" | "SEGUNDO" | "TERCERO",
  "año_academico": string (formato: "AAAA-AAAA"),
  "fecha_inicio": date,
  "fecha_fin": date
}
```

### 6. Predicción

Predicciones del rendimiento académico basadas en modelos de machine learning.

```python
{
  "id": integer,
  "estudiante": integer,
  "materia": integer,
  "valor_numerico": decimal (0-100),
  "nivel_rendimiento": "BAJO" | "MEDIO" | "ALTO",
  "fecha_prediccion": datetime,
  "promedio_notas": decimal,
  "porcentaje_asistencia": decimal,
  "promedio_participaciones": decimal,
  "confianza": integer (0-100)
}
```

### 7. Notificación

Notificaciones para usuarios sobre eventos importantes del sistema.

```python
{
  "id": integer,
  "usuario": integer (id del usuario),
  "titulo": string,
  "mensaje": string,
  "tipo": "INFO" | "ALERTA" | "PREDICCION" | "RECORDATORIO" | "SISTEMA",
  "estado": "NO_LEIDA" | "LEIDA" | "ARCHIVADA",
  "fecha_creacion": datetime,
  "fecha_lectura": datetime (null si no se ha leído),
  "url_accion": string (URL opcional para acción específica)
}
```

### 8. Dashboard

Componentes visuales y estadísticas consolidadas del sistema.

```python
{
  "estadisticas_generales": {
    "total_estudiantes": integer,
    "total_profesores": integer,
    "total_cursos": integer,
    "total_materias": integer,
    "promedio_asistencia": decimal,
    "promedio_rendimiento": decimal
  },
  "rendimiento_por_curso": [
    {
      "curso_id": integer,
      "nombre": string,
      "promedio": decimal,
      "estudiantes": integer
    }
  ],
  "estadisticas_estudiante": {
    "estudiante_id": integer,
    "nombre": string,
    "promedios": {
      "ser": decimal,
      "saber": decimal,
      "hacer": decimal,
      "decidir": decimal,
      "autoevaluacion_ser": decimal,
      "autoevaluacion_decidir": decimal
    },
    "asistencia": decimal,
    "participaciones": decimal,
    "predicciones": {
      "total": integer,
      "alto": integer,
      "medio": integer,
      "bajo": integer
    }
  }
}
```

## Endpoints Principales

### Usuarios

- **Listar Usuarios**: `GET /api/usuarios/lista/`
  - **Filtros**: `?rol=ESTUDIANTE&curso=1&materia=2`
  - **Permisos**: Solo profesores y administrativos

- **Listar Estudiantes**: `GET /api/usuarios/estudiantes/`
  - **Filtros**: `?curso=1`
  - **Permisos**: Solo profesores y administrativos

- **Actualizar Usuario (Admin)**: `PUT /api/usuarios/actualizar/{user_id}/`
  - **Permisos**: Solo administrativos

- **Eliminar Usuario**: `DELETE /api/usuarios/{user_id}/`
  - **Permisos**: Solo administrativos

### Materias

- **Listar Materias**: `GET /api/materias/`
- **Detalle de Materia**: `GET /api/materias/{id}/`
- **Crear Materia**: `POST /api/materias/`
  - **Permisos**: Solo administrativos
- **Actualizar Materia**: `PUT /api/materias/{id}/`
  - **Permisos**: Solo administrativos
- **Eliminar Materia**: `DELETE /api/materias/{id}/`
  - **Permisos**: Solo administrativos

### Cursos

- **Listar Cursos**: `GET /api/cursos/`
- **Detalle de Curso**: `GET /api/cursos/{id}/`
- **Crear Curso**: `POST /api/cursos/`
  - **Permisos**: Solo administrativos
- **Actualizar Curso**: `PUT /api/cursos/{id}/`
  - **Permisos**: Solo administrativos
- **Eliminar Curso**: `DELETE /api/cursos/{id}/`
  - **Permisos**: Solo administrativos

### Notas

- **Listar Periodos**: `GET /api/notas/periodos/`
- **Listar Notas**: `GET /api/notas/calificaciones/`
  - **Filtros**: `?estudiante=1&materia=2&periodo=3&curso=4`
  - **Comportamiento**:
    - Los estudiantes solo ven sus propias notas
    - Los profesores ven las notas de sus materias
    - Los administrativos ven todas las notas
- **Detalle de Nota**: `GET /api/notas/calificaciones/{id}/`
- **Crear Nota**: `POST /api/notas/calificaciones/`
  - **Permisos**: Solo profesores
- **Actualizar Nota**: `PUT /api/notas/calificaciones/{id}/`
  - **Permisos**: Solo profesores
- **Eliminar Nota**: `DELETE /api/notas/calificaciones/{id}/`
  - **Permisos**: Solo profesores
- **Autoevaluación**: `POST /api/notas/calificaciones/{id}/autoevaluacion/`
  - **Payload**:
    ```json
    {
      "autoevaluacion_ser": 4.5,
      "autoevaluacion_decidir": 4.0
    }
    ```
  - **Permisos**: Solo el estudiante asociado a la nota
- **Estadísticas del Estudiante**: `GET /api/notas/calificaciones/estadisticas_estudiante/`
  - **Filtros**: `?estudiante=1`
  - **Permisos**: Profesores, administrativos y el propio estudiante
- **Estadísticas de Materia**: `GET /api/notas/calificaciones/estadisticas_materia/`
  - **Filtros**: `?materia=1&periodo=2`
  - **Permisos**: Profesores y administrativos
- **Reporte Trimestral**: `GET /api/notas/calificaciones/reporte_trimestral/`
  - **Filtros**: `?curso=1&periodo=2`
  - **Permisos**: Profesores y administrativos

### Participaciones

- **Listar Participaciones**: `GET /api/participaciones/`
  - **Filtros**: `?estudiante=1&materia=2&fecha_inicio=2024-01-01&fecha_fin=2024-05-31&tipo=VOLUNTARIA&curso=1&fecha=2024-05-15`
- **Detalle de Participación**: `GET /api/participaciones/{id}/`
- **Crear Participación**: `POST /api/participaciones/`
  - **Payload**:
    ```json
    {
      "estudiante": 1,
      "materia": 2,
      "fecha": "2024-05-15",
      "tipo": "VOLUNTARIA",
      "descripcion": "Participación en clase",
      "valor": 8
    }
    ```
  - **Permisos**: Solo profesores
- **Actualizar Participación**: `PUT /api/participaciones/{id}/`
  - **Permisos**: Solo profesores
- **Eliminar Participación**: `DELETE /api/participaciones/{id}/`
  - **Permisos**: Solo profesores
- **Estadísticas de Participación**: `GET /api/participaciones/estadisticas_participacion/`
  - **Filtros**: `?estudiante=1&materia=2`

### Asistencias

- **Listar Asistencias**: `GET /api/asistencias/`
  - **Filtros**: `?estudiante=1&materia=2&fecha_inicio=2024-01-01&fecha_fin=2024-05-31&presente=true&curso=1&fecha=2024-05-15`
- **Detalle de Asistencia**: `GET /api/asistencias/{id}/`
- **Crear Asistencia**: `POST /api/asistencias/`
  - **Permisos**: Solo profesores
- **Actualizar Asistencia**: `PUT /api/asistencias/{id}/`
  - **Permisos**: Solo profesores
- **Eliminar Asistencia**: `DELETE /api/asistencias/{id}/`
  - **Permisos**: Solo profesores

### Predicciones

- **Listar Predicciones**: `GET /api/predicciones/`
  - **Filtros**: `?estudiante=1&materia=2&curso=1`
  - **Comportamiento**:
    - Los estudiantes solo ven sus propias predicciones
    - Los profesores ven las predicciones de sus materias
    - Los administrativos ven todas las predicciones

- **Detalle de Predicción**: `GET /api/predicciones/{id}/`

- **Generar Predicción**: `POST /api/predicciones/generar_prediccion/`
  - **Payload**:
    ```json
    {
      "estudiante": 1,
      "materia": 2
    }
    ```
  - **Permisos**: Profesores y administrativos

- **Generar Predicción ML**: `POST /api/predicciones/generar_prediccion_ml/`
  - **Payload**:
    ```json
    {
      "estudiante": 1,
      "materia": 2
    }
    ```
  - **Permisos**: Profesores y administrativos
  - **Descripción**: Utiliza el modelo de machine learning más avanzado para generar predicciones

- **Estudiantes en Riesgo**: `GET /api/predicciones/estudiantes_en_riesgo/`
  - **Filtros**: `?curso=1&materia=2`
  - **Descripción**: Obtiene una lista de estudiantes con predicciones por debajo del umbral de rendimiento aceptable
  - **Permisos**: Profesores y administrativos

- **Recomendaciones**: `GET /api/predicciones/{id}/recomendaciones/`
  - **Descripción**: Obtiene recomendaciones generadas automáticamente basadas en el rendimiento y las predicciones
  - **Permisos**: Profesores, administrativos y el estudiante asociado a la predicción

- **Notificaciones de Predicciones**: `GET /api/predicciones/notificaciones/`
  - **Descripción**: Obtiene notificaciones relevantes sobre predicciones según el rol del usuario
  - **Permisos**: Todos los usuarios autenticados

### Notificaciones

- **Listar Notificaciones**: `GET /api/notificaciones/`
  - **Filtros**: `?estado=NO_LEIDA&tipo=ALERTA`
  - **Descripción**: Cada usuario solo ve sus propias notificaciones

- **Detalle de Notificación**: `GET /api/notificaciones/{id}/`

- **Crear Notificación**: `POST /api/notificaciones/`
  - **Payload**:
    ```json
    {
      "usuario": 1,
      "titulo": "Título de la notificación",
      "mensaje": "Contenido detallado",
      "tipo": "ALERTA",
      "url_accion": "/ruta/para/accion"
    }
    ```

- **Actualizar Notificación**: `PUT /api/notificaciones/{id}/`

- **Eliminar Notificación**: `DELETE /api/notificaciones/{id}/`

- **Marcar como Leída**: `POST /api/notificaciones/{id}/marcar_como_leida/`
  - **Descripción**: Marca una notificación específica como leída

- **Archivar Notificación**: `POST /api/notificaciones/{id}/archivar/`
  - **Descripción**: Archiva una notificación específica

- **Marcar Todas como Leídas**: `POST /api/notificaciones/marcar_todas_como_leidas/`
  - **Descripción**: Marca todas las notificaciones no leídas como leídas

- **Contador de No Leídas**: `GET /api/notificaciones/no_leidas_count/`
  - **Descripción**: Devuelve el número de notificaciones no leídas

### Dashboard

- **Estadísticas Generales**: `GET /api/dashboard/estadisticas/`
  - **Descripción**: Proporciona estadísticas generales según el rol del usuario
  - **Permisos**: Todos los usuarios autenticados

- **Dashboard Estudiante**: `GET /api/dashboard/estudiante/{estudiante_id}/`
  - **Descripción**: Obtiene estadísticas detalladas de un estudiante específico
  - **Permisos**: Profesores, administrativos, y el propio estudiante

- **Dashboard Estudiante (Propio)**: `GET /api/dashboard/estudiante/`
  - **Descripción**: Obtiene estadísticas del estudiante autenticado
  - **Permisos**: Estudiantes

- **Comparativo de Rendimiento**: `GET /api/dashboard/comparativo/`
  - **Filtros**: `?curso=1&materia=2&periodo=3`
  - **Descripción**: Compara el rendimiento entre diferentes cursos o materias
  - **Permisos**: Profesores y administrativos

## Recomendaciones para la Implementación en Flutter

### 1. Paquetes Recomendados

- **http** o **dio**: Para realizar peticiones HTTP
- **flutter_secure_storage**: Para almacenar tokens de forma segura
- **provider** o **flutter_bloc**: Para manejo de estado
- **json_serializable** o **freezed**: Para serialización de modelos
- **flutter_form_builder**: Para gestión de formularios

### 2. Estructura Sugerida para el Proyecto Flutter

```
lib/
├── api/
│   ├── api_client.dart       # Cliente HTTP base
│   ├── auth_service.dart     # Servicio de autenticación
│   ├── user_service.dart     # Servicio de usuarios
│   ├── course_service.dart   # Servicio de cursos
│   ├── subject_service.dart  # Servicio de materias
│   ├── grade_service.dart    # Servicio de notas
│   ├── prediction_service.dart # Servicio de predicciones
│   ├── notification_service.dart # Servicio de notificaciones
│   ├── dashboard_service.dart # Servicio de dashboard
│   └── ...
├── models/
│   ├── user.dart             # Modelo de usuario
│   ├── course.dart           # Modelo de curso
│   ├── subject.dart          # Modelo de materia
│   ├── grade.dart            # Modelo de nota
│   ├── prediction.dart       # Modelo de predicción
│   ├── notification.dart     # Modelo de notificación
│   ├── dashboard.dart        # Modelo de dashboard
│   └── ...
├── providers/
│   ├── auth_provider.dart    # Gestión de estado de autenticación
│   ├── prediction_provider.dart # Gestión de estado de predicciones
│   ├── notification_provider.dart # Gestión de estado de notificaciones  
│   ├── dashboard_provider.dart # Gestión de estado de dashboard
│   └── ...
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── predictions/
│   │   ├── predictions_screen.dart
│   │   └── recommendations_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── dashboard/
│   │   ├── general_dashboard_screen.dart
│   │   ├── student_dashboard_screen.dart
│   │   └── comparative_dashboard_screen.dart
│   └── ...
├── widgets/
│   └── ...
└── main.dart
```

### 3. Flujo de Autenticación

1. El usuario ingresa credenciales en la pantalla de login
2. La aplicación hace una petición a `/api/usuarios/login/`
3. Almacenar tokens (access y refresh) de forma segura
4. Incluir el token de acceso en todas las solicitudes posteriores
5. Implementar renovación automática del token usando el refresh token
6. Cerrar sesión limpiando los tokens almacenados

### 4. Manejo de Errores

- Implementar interceptores para manejar errores HTTP 401 (no autorizado)
- Mostrar mensajes de error amigables basados en las respuestas del servidor
- Implementar reintentos automáticos para problemas de conectividad

### 5. Offline First (Opcionaln no tomar en cuenta)

- Considerar implementar almacenamiento local con SQLite o Hive
- Sincronizar datos cuando la conexión esté disponible

## Sistema de Predicción Académica (Machine Learning)

### Descripción del Sistema

El backend incluye un componente avanzado de predicción basado en modelos de machine learning (Random Forest Regressor) que analiza varios factores para predecir el rendimiento académico de los estudiantes y genera recomendaciones automáticamente.

### Factores que influyen en las predicciones:

1. **Asistencia**: Porcentaje de asistencia a clases
2. **Participaciones**: Cantidad y calidad de participaciones en clase
3. **Notas anteriores**: Historial de calificaciones en la materia y en materias relacionadas
4. **Factores contextuales**: Desempeño general del estudiante y en el curso

### Modelos disponibles:

- **Modelo general**: Para predicciones globales del rendimiento
- **Modelos por materia**: Modelos específicos entrenados para cada materia (del 1 al 15)

### Niveles de riesgo:

- **BAJO**: El estudiante tiene alta probabilidad de obtener buenas calificaciones
- **MEDIO**: El estudiante podría enfrentar dificultades si no mejora
- **ALTO**: El estudiante necesita intervención inmediata para evitar reprobar

### Implementación en Flutter

Para integrar el sistema de predicciones en la aplicación Flutter, se recomienda:

1. **Crear un servicio dedicado para predicciones**:

```dart
class PredictionService {
  final ApiClient _apiClient;
  
  PredictionService(this._apiClient);
  
  Future<List<dynamic>> getMyPredictions() async {
    try {
      // Los estudiantes solo ven sus propias predicciones gracias al filtrado automático
      final response = await _apiClient.get('predicciones/');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener predicciones: $e');
    }
  }
  
  Future<Map<String, dynamic>> getRecommendations(int predictionId) async {
    try {
      final response = await _apiClient.get('predicciones/$predictionId/recomendaciones/');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener recomendaciones: $e');
    }
  }
  
  Future<Map<String, dynamic>> generatePrediction(int studentId, int subjectId) async {
    try {
      final response = await _apiClient.post('predicciones/generar_prediccion/', data: {
        'estudiante': studentId,
        'materia': subjectId
      });
      return response.data;
    } catch (e) {
      throw Exception('Error al generar predicción: $e');
    }
  }
  
  Future<Map<String, dynamic>> generateMLPrediction(int studentId, int subjectId) async {
    try {
      final response = await _apiClient.post('predicciones/generar_prediccion_ml/', data: {
        'estudiante': studentId,
        'materia': subjectId
      });
      return response.data;
    } catch (e) {
      throw Exception('Error al generar predicción ML: $e');
    }
  }
  
  Future<List<dynamic>> getStudentsAtRisk({int? courseId, int? subjectId}) async {
    try {
      Map<String, dynamic>? queryParams;
      
      if (courseId != null || subjectId != null) {
        queryParams = {};
        if (courseId != null) queryParams['curso'] = courseId;
        if (subjectId != null) queryParams['materia'] = subjectId;
      }
      
      final response = await _apiClient.get(
        'predicciones/estudiantes_en_riesgo/',
        queryParameters: queryParams
      );
      return response.data['estudiantes'];
    } catch (e) {
      throw Exception('Error al obtener estudiantes en riesgo: $e');
    }
  }
  
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiClient.get('predicciones/notificaciones/');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener notificaciones de predicciones: $e');
    }
  }
}
```

2. **Servicio de Notificaciones**:

```dart
class NotificationService {
  final ApiClient _apiClient;
  
  NotificationService(this._apiClient);
  
  Future<List<dynamic>> getNotifications({String? estado, String? tipo}) async {
    try {
      Map<String, dynamic>? queryParams;
      
      if (estado != null || tipo != null) {
        queryParams = {};
        if (estado != null) queryParams['estado'] = estado;
        if (tipo != null) queryParams['tipo'] = tipo;
      }
      
      final response = await _apiClient.get(
        'notificaciones/',
        queryParameters: queryParams
      );
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }
  
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('notificaciones/no_leidas_count/');
      return response.data['count'];
    } catch (e) {
      throw Exception('Error al obtener conteo de notificaciones: $e');
    }
  }
  
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.post('notificaciones/$notificationId/marcar_como_leida/');
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post('notificaciones/marcar_todas_como_leidas/');
    } catch (e) {
      throw Exception('Error al marcar todas las notificaciones como leídas: $e');
    }
  }
  
  Future<void> archiveNotification(int notificationId) async {
    try {
      await _apiClient.post('notificaciones/$notificationId/archivar/');
    } catch (e) {
      throw Exception('Error al archivar notificación: $e');
    }
  }
}
```

3. **Visualización de predicciones**:
  - Implementar gráficos para mostrar tendencias (usando packages como `fl_chart`)
  - Usar códigos de colores según el nivel de riesgo (rojo para alto, amarillo para medio, verde para bajo)
  - Mostrar recomendaciones personalizadas en tarjetas interactivas

4. **Notificaciones**:
  - Configurar notificaciones push cuando se generen nuevas predicciones
  - Alertar al estudiante si su nivel de riesgo cambia a "ALTO"
  - Mostrar un contador de notificaciones no leídas en la interfaz

## Sistema de Dashboard y Visualización

### Descripción del Sistema

El backend incluye un completo sistema de dashboard que proporciona visualizaciones estadísticas y análisis de datos para diferentes roles de usuario:

1. **Para Estudiantes**: Rendimiento personal, progreso en asignaturas, asistencia y predicciones
2. **Para Profesores**: Rendimiento de sus clases, estudiantes en riesgo, estadísticas de asistencia y participación
3. **Para Administrativos**: Vista global del sistema educativo, rendimiento por cursos y materias

### Implementación en Flutter

Para integrar el sistema de dashboard en tu aplicación Flutter:

1. **Crear un servicio para el dashboard**:

```dart
class DashboardService {
  final ApiClient _apiClient;
  
  DashboardService(this._apiClient);
  
  Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final response = await _apiClient.get('dashboard/estadisticas/');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas generales: $e');
    }
  }
  
  Future<Map<String, dynamic>> getStudentDashboard({int? studentId}) async {
    try {
      final String endpoint = studentId != null 
          ? 'dashboard/estudiante/$studentId/'
          : 'dashboard/estudiante/';
          
      final response = await _apiClient.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener dashboard del estudiante: $e');
    }
  }
  
  Future<Map<String, dynamic>> getComparativeData({
    int? courseId,
    int? subjectId,
    int? periodId
  }) async {
    try {
      Map<String, dynamic>? queryParams;
      
      if (courseId != null || subjectId != null || periodId != null) {
        queryParams = {};
        if (courseId != null) queryParams['curso'] = courseId;
        if (subjectId != null) queryParams['materia'] = subjectId;
        if (periodId != null) queryParams['periodo'] = periodId;
      }
      
      final response = await _apiClient.get(
        'dashboard/comparativo/',
        queryParameters: queryParams
      );
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener datos comparativos: $e');
    }
  }
}
```

2. **Visualización de datos**:
  - Utiliza gráficos de barras, líneas y circulares para mostrar estadísticas (fl_chart)
  - Implementa paneles de información con KPIs relevantes
  - Crea vistas personalizadas según el rol del usuario

## Ejemplos de Código

### Ejemplo de Configuración del Cliente HTTP

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  ApiClient() {
    _dio.options.baseUrl = 'https://backendaisi2-production.up.railway.app/api/';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
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
  
  // Métodos para realizar peticiones
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

### Ejemplo de Servicio de Autenticación

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AuthService(this._apiClient);

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.post('usuarios/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: 'access_token',
          value: response.data['access'],
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: response.data['refresh'],
        );
        await _secureStorage.write(
          key: 'user_data',
          value: response.data['user'].toString(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.read(key: 'access_token') != null;
  }
}
```

## Contacto

Para consultas adicionales o soporte técnico sobre la integración con el backend, contactar al equipo de desarrollo.
