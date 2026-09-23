# 📘 Especificación y Guía de Implementación del Backend — PractiHoras

Este documento describe en detalle el funcionamiento actual de la aplicación móvil **PractiHoras**, su modelo de datos, la lógica de negocio, los algoritmos de cálculo y todos los requerimientos técnicos necesarios para que el equipo de backend diseñe e implemente la API RESTful / Base de Datos.

---

## 📑 Tabla de Contenidos
1. [Visión General del Proyecto](#1-visión-general-del-proyecto)
2. [Arquitectura y Flujo de la Aplicación](#2-arquitectura-y-flujo-de-la-aplicación)
3. [Modelo de Datos y Entidades](#3-modelo-de-datos-y-entidades)
4. [Lógica de Negocio y Algoritmos](#4-lógica-de-negocio-y-algoritmos)
5. [Especificación de Endpoints (API REST)](#5-especificación-de-endpoints-api-rest)
6. [Estrategia de Sincronización y Modo Offline](#6-estrategia-de-sincronización-y-modo-offline)
7. [Validaciones y Manejo de Errores](#7-validaciones-y-manejo-de-errores)
8. [Seguridad y Autenticación Recomendada](#8-seguridad-y-autenticación-recomendada)

---

## 1. Visión General del Proyecto

**PractiHoras** es una plataforma orientada a estudiantes, practicantes pre-profesionales y profesionales que necesitan llevar un control riguroso, trazable y automatizado del cumplimiento de sus horas de prácticas.

### Funcionalidades Clave:
* **Configuración del Perfil y Meta:** Registro de meta total de horas (ej. 360 hrs, 480 hrs), horas convalidadas/previas, fechas de inicio y fin de prácticas, y plantilla de horario semanal (lunes a domingo).
* **Registro Diario Inteligente:** Autocompletado rápido de horas según el horario configurado para el día seleccionado, cálculo en tiempo real de horas netas computables y registro de actividades.
* **Motor de Ritmo y Cumplimiento (Pacing Engine):** Algoritmo inteligente que analiza días hábiles restantes, horas esperadas a la fecha y clasifica el estado en *Adelantado*, *A tiempo* o *Atrasado*, sugiriendo el ritmo diario necesario.
* **Historial con Filtros:** Visualización por mes y modalidad (Presencial, Remoto, Híbrido), edición y eliminación de registros.
* **Exportación de Reportes:** Generación de archivos CSV compatibles con Excel con sumatoria acumulativa ($\sum$) y codificación UTF-8 BOM.

---

## 2. Arquitectura y Flujo de la Aplicación

Actualmente el frontend móvil está desarrollado en **Flutter (Clean Architecture + Riverpod)** y almacena la información localmente en **Hive (NoSQL local)**.

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                       │
│  (Presentación: Riverpod Providers + UI Screens / Widgets)  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                ┌──────────────▼──────────────┐
                │   Capa de Dominio & Casos   │
                │    de Uso / Reglas Negocio  │
                └──────────────┬──────────────┘
                               │
               (Objetivo Actual: Migrar a API)
                               │
                ┌──────────────▼──────────────┐
                │    BACKEND API (REST/JSON)  │
                │    Node.js / Go / Python /   │
                │        Java / C# / etc.     │
                └──────────────┬──────────────┘
                               │
                ┌──────────────▼──────────────┐
                │      Base de Datos SQL      │
                │  (PostgreSQL / MySQL / etc) │
                └─────────────────────────────┘
```

### Flujo de Usuario:
1. **Splash Screen:** Comprueba si el usuario tiene sesión activa y si ha completado su perfil inicial (`perfilCompletado == true`).
2. **Onboarding / Registro de Perfil:** Si es nuevo, solicita nombre, meta de horas, horas previas, fechas de vigencia y horario semanal.
3. **Dashboard Principal:** Muestra métricas consolidadas, tarjeta de ritmo dinámico, gráfica semanal y accesos directos.
4. **Registro de Horas:** Permite registrar la jornada indicando hora inicio, hora fin, descuento por refrigerio/almuerzo, modalidad y descripción de tareas.
5. **Historial y Ajustes:** Permite consultar registros pasados, filtrar por mes/modalidad, exportar reportes y modificar la configuración del perfil.

---

## 3. Modelo de Datos y Entidades

### 3.1. Entidad `Usuario / Perfil` (`users` / `profiles`)

| Campo | Tipo SQL Sugerido | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` / `VARCHAR(36)` (PK) | Identificador único del usuario / perfil. |
| `email` | `VARCHAR(255)` (UNIQUE) | Correo electrónico del usuario. |
| `nombre` | `VARCHAR(150)` | Nombre completo del practicante. |
| `meta_horas_total` | `DECIMAL(6,2)` | Total de horas que debe cumplir (ej. `360.00`). |
| `horas_iniciales_previas` | `DECIMAL(6,2)` | Horas ya cursadas antes de usar el sistema (ej. `40.00`). Default `0.0`. |
| `horas_minimas_semanales` | `DECIMAL(5,2)` | Límite o meta semanal (ej. `30.00`). Default `30.0`. |
| `fecha_inicio` | `DATE` | Fecha de inicio de las prácticas (ej. `2026-03-01`). |
| `fecha_fin` | `DATE` | Fecha límite o pactada de culminación (ej. `2026-06-30`). |
| `perfil_completado` | `BOOLEAN` | `true` si ya completó el onboarding inicial. |
| `created_at` | `TIMESTAMP WITH TIME ZONE` | Fecha de creación. |
| `updated_at` | `TIMESTAMP WITH TIME ZONE` | Última actualización. |

---

### 3.2. Entidad `Horario Semanal` (`weekly_schedules`)

Define la plantilla predeterminada de trabajo por cada día de la semana. Relación `1:N` con `Profile` o almacenado como tabla estructurada / JSONB.

| Campo | Tipo SQL Sugerido | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` / `BIGSERIAL` (PK) | Identificador del horario. |
| `user_id` | `UUID` (FK) | Relación con el usuario. |
| `dia_semana` | `VARCHAR(10)` | Clave del día: `'lunes'`, `'martes'`, `'miercoles'`, `'jueves'`, `'viernes'`, `'sabado'`, `'domingo'`. |
| `activo` | `BOOLEAN` | `true` si es día laboral regular; `false` si es descanso. |
| `hora_inicio` | `VARCHAR(5)` / `TIME` | Formato 24h `"08:00"`. |
| `hora_fin` | `VARCHAR(5)` / `TIME` | Formato 24h `"13:00"`. |
| `refrigerio_minutos` | `INT` | Minutos de refrigerio no computables (ej. `0` o `60`). |
| `modalidad` | `VARCHAR(20)` | `'Presencial'`, `'Remoto'` o `'Híbrido'`. |

---

### 3.3. Entidad `Registro de Hora` (`work_logs` / `registros_horas`)

Cada entrada individual de horas trabajadas por el practicante.

| Campo | Tipo SQL Sugerido | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` / `VARCHAR(36)` (PK) | Identificador único del registro. |
| `user_id` | `UUID` (FK) | Relación con el usuario propietario. |
| `fecha` | `DATE` | Fecha de la jornada (ej. `2026-09-22`). |
| `hora_inicio` | `VARCHAR(5)` / `TIME` | Hora de inicio `"08:00"`. |
| `hora_fin` | `VARCHAR(5)` / `TIME` | Hora de culminación `"13:00"`. |
| `descuento_almuerzo_minutos` | `INT` | Minutos de refrigerio descontados (default `0`). |
| `horas_computables` | `DECIMAL(5,2)` | Horas netas calculadas (ej. `5.00`). |
| `modalidad` | `VARCHAR(20)` | `'Presencial'`, `'Remoto'` o `'Híbrido'`. |
| `actividades` | `TEXT` | Descripción de tareas y entregables realizados. |
| `created_at` | `TIMESTAMP WITH TIME ZONE` | Momento de creación. |
| `updated_at` | `TIMESTAMP WITH TIME ZONE` | Momento de última modificación. |

---

## 4. Lógica de Negocio y Algoritmos

El backend puede ejecutar o validar estas reglas de negocio en los endpoints correspondientes:

### 4.1. Cálculo de Horas Netas Computables
Para un registro con `hora_inicio = "HH:mm"`, `hora_fin = "HH:mm"` y `descuento_minutos`:
1. Convertir `hora_inicio` a minutos desde medianoche: $\text{minIni} = \text{hora} \times 60 + \text{minuto}$.
2. Convertir `hora_fin` a minutos desde medianoche: $\text{minFin} = \text{hora} \times 60 + \text{minuto}$.
3. Minutos brutos: $\text{minBrutos} = \text{minFin} - \text{minIni}$.
4. Minutos netos: $\text{minNetos} = \max(0, \text{minBrutos} - \text{descuento\_minutos})$.
5. Horas computables: $\text{horasComputables} = \text{round}(\frac{\text{minNetos}}{60}, 2)$.

---

### 4.2. Algoritmo del Motor de Ritmo y Cumplimiento (Pacing Engine)

Dado un usuario con `fecha_inicio`, `fecha_fin`, `meta_horas_total`, `horas_iniciales_previas` y su lista de registros:

1. **Horas Registradas en App:**
   $$\text{horasRegistradas} = \sum \text{reg.horas\_computables}$$
2. **Horas Totales Completadas:**
   $$\text{horasTotales} = \text{horas\_iniciales\_previas} + \text{horasRegistradas}$$
3. **Horas Restantes:**
   $$\text{horasRestantes} = \max(0, \text{meta\_horas\_total} - \text{horasTotales})$$
4. **Porcentaje de Progreso:**
   $$\text{porcentaje} = \text{clamp}\left( \frac{\text{horasTotales}}{\text{meta\_horas\_total}} \times 100, 0, 100 \right)$$
5. **Cálculo de Días Hábiles:**
   * Se obtienen los días de la semana marcados como `activo == true` en el `horario_semanal` (si ninguno estuviera activo, se toma de Lunes a Viernes por defecto).
   * Se itera cada día entre `fecha_inicio` y `fecha_fin`:
     * Si el día coincide con un día laboral activo:
       * Incrementa $\text{totalDiasHabiles}$.
       * Si el día es $\le \text{fecha\_actual}$: incrementa $\text{diasHabilesTranscurridos}$.
       * Si el día es $> \text{fecha\_actual}$: incrementa $\text{diasHabilesRestantes}$.
6. **Horas Esperadas a la Fecha:**
   $$\text{horasEsperadasHoy} = \text{meta\_horas\_total} \times \left( \frac{\text{diasHabilesTranscurridos}}{\text{totalDiasHabiles}} \right)$$
7. **Diferencia de Ritmo:**
   $$\text{diferenciaHorasRitmo} = \text{horasTotales} - \text{horasEsperadasHoy}$$
8. **Ritmo Diario Sugerido (Horas/Día Restante):**
   $$\text{ritmoDiarioSugerido} = \begin{cases} \frac{\text{horasRestantes}}{\text{diasHabilesRestantes}} & \text{si } \text{diasHabilesRestantes} > 0 \\ \text{horasRestantes} & \text{en otro caso} \end{cases}$$
9. **Determinación del Estado (`estado_ritmo`):**
   * **`adelantado`:** Si $\text{horasRestantes} \le 0$ o $\text{diferenciaHorasRitmo} \ge +3.0$ horas.
   * **`a_tiempo`:** Si $-3.0 \le \text{diferenciaHorasRitmo} < +3.0$ horas.
   * **`atrasado`:** Si $\text{diferenciaHorasRitmo} < -3.0$ horas.
   * **`sin_fechas`:** Si no se configuraron `fecha_inicio` o `fecha_fin`.

---

### 4.3. Formato Oficial de Exportación CSV
El reporte CSV exportado requiere el siguiente orden cronológico ascendente y columnas:
```csv
Fecha,Hora de inicio,Hora de Fin,Resumen actividades realizada,Horas realizadas,Horas totales Sumatoria (∑)
Inicial,-,-,"Horas previas cursadas (convalidadas en ajustes)",40.00,40.00
2026-09-01,08:00,13:00,"Desarrollo del módulo de login y autenticación",5.00,45.00
2026-09-02,08:00,13:00,"Corrección de bugs en formulario y pruebas unitarias",5.00,50.00
```
> [!IMPORTANT]
> El archivo debe incluir **BOM UTF-8 (`\uFEFF`)** al inicio para garantizar compatibilidad con Microsoft Excel en caracteres en español y el símbolo $\sum$.

---

## 5. Especificación de Endpoints (API REST)

Base URL sugerida: `/api/v1`

### 5.1. Autenticación (`/auth`)

#### `POST /auth/register`
Registra un nuevo usuario en la plataforma.
* **Request Body:**
  ```json
  {
    "email": "practicante@universidad.edu.pe",
    "password": "PasswordSegura123!",
    "nombre": "Juan Pérez"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "token": "jwt_access_token_here",
    "refreshToken": "jwt_refresh_token_here",
    "user": {
      "id": "b7d18804-0985-48b6-98dc-1bb1d58c8a14",
      "email": "practicante@universidad.edu.pe",
      "nombre": "Juan Pérez",
      "perfilCompletado": false
    }
  }
  ```

#### `POST /auth/login`
Inicia sesión con credenciales.
* **Request Body:**
  ```json
  {
    "email": "practicante@universidad.edu.pe",
    "password": "PasswordSegura123!"
  }
  ```

#### `GET /auth/me`
Retorna los datos del usuario autenticado vía header `Authorization: Bearer <token>`.

---

### 5.2. Perfil y Horario Semanal (`/profile`)

#### `GET /profile`
Obtiene los datos del perfil y la configuración del horario semanal del usuario autenticado.
* **Response (200 OK):**
  ```json
  {
    "id": "b7d18804-0985-48b6-98dc-1bb1d58c8a14",
    "nombre": "Juan Pérez",
    "metaHorasTotal": 360.0,
    "horasInicialesPrevias": 0.0,
    "horasMinimasSemanales": 30.0,
    "perfilCompletado": true,
    "fechaInicio": "2026-03-01",
    "fechaFin": "2026-06-30",
    "horarioSemanal": {
      "lunes": {
        "diaSemana": "lunes",
        "activo": true,
        "horaInicio": "08:00",
        "horaFin": "13:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "martes": {
        "diaSemana": "martes",
        "activo": true,
        "horaInicio": "14:00",
        "horaFin": "19:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "miercoles": {
        "diaSemana": "miercoles",
        "activo": true,
        "horaInicio": "14:00",
        "horaFin": "19:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "jueves": {
        "diaSemana": "jueves",
        "activo": true,
        "horaInicio": "08:00",
        "horaFin": "13:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "viernes": {
        "diaSemana": "viernes",
        "activo": true,
        "horaInicio": "08:00",
        "horaFin": "13:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "sabado": {
        "diaSemana": "sabado",
        "activo": false,
        "horaInicio": "08:00",
        "horaFin": "13:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      },
      "domingo": {
        "diaSemana": "domingo",
        "activo": false,
        "horaInicio": "08:00",
        "horaFin": "13:00",
        "refrigerioMinutos": 0,
        "modalidad": "Presencial"
      }
    }
  }
  ```

#### `PUT /profile`
Actualiza la configuración general del perfil y/o el horario semanal.
* **Request Body:** Mismo formato del perfil.

---

### 5.3. Registros de Horas (`/registros`)

#### `GET /registros`
Lista todos los registros del usuario autenticado ordenados por fecha descendente.
* **Query Params opcionales:**
  * `mes`: `1` a `12` (filtrar por mes específico).
  * `anio`: `2026` (filtrar por año).
  * `modalidad`: `'Presencial' | 'Remoto' | 'Híbrido'`.
  * `desde`: `YYYY-MM-DD`.
  * `hasta`: `YYYY-MM-DD`.
* **Response (200 OK):**
  ```json
  [
    {
      "id": "e931ca8a-86c2-48ea-a311-37dca9372e9a",
      "fecha": "2026-09-22",
      "horaInicio": "08:00",
      "horaFin": "13:00",
      "descuentoAlmuerzoMinutos": 0,
      "horasComputables": 5.0,
      "modalidad": "Presencial",
      "actividades": "Implementación del módulo de reportes y testing en Flutter.",
      "createdAt": "2026-09-22T19:30:00.000Z",
      "updatedAt": "2026-09-22T19:30:00.000Z"
    }
  ]
  ```

#### `POST /registros`
Crea un nuevo registro de horas de práctica.
* **Request Body:**
  ```json
  {
    "id": "e931ca8a-86c2-48ea-a311-37dca9372e9a",
    "fecha": "2026-09-22",
    "horaInicio": "08:00",
    "horaFin": "13:00",
    "descuentoAlmuerzoMinutos": 0,
    "modalidad": "Presencial",
    "actividades": "Implementación del módulo de reportes y testing en Flutter."
  }
  ```
* **Response (201 Created):** Retorna el objeto creado con `horasComputables` calculado por el backend.

#### `PUT /registros/:id`
Actualiza un registro existente.
* **Request Body:** Mismos campos que `POST /registros`.
* **Response (200 OK):** Registro actualizado.

#### `DELETE /registros/:id`
Elimina un registro.
* **Response (204 No Content / 200 OK):**
  ```json
  { "message": "Registro eliminado con éxito" }
  ```

---

### 5.4. Métricas y Estadísticas (`/metricas/dashboard`)

#### `GET /metricas/dashboard`
Retorna las métricas calculadas en el servidor para el usuario autenticado (útil para acelerar el renderizado o validación cruzada).
* **Response (200 OK):**
  ```json
  {
    "horasTotalesCompletadas": 125.0,
    "horasPreviasCursadas": 20.0,
    "horasRegistradasEnApp": 105.0,
    "metaHorasTotal": 360.0,
    "horasRestantes": 235.0,
    "porcentajeProgreso": 34.7,
    "horasEstaSemana": 25.0,
    "horasEsteMes": 85.0,
    "totalDiasTrabajados": 21,
    "promedioHorasPorDia": 5.0,
    "horasPorDiaSemana": {
      "1": 5.0,
      "2": 5.0,
      "3": 5.0,
      "4": 5.0,
      "5": 5.0,
      "6": 0.0,
      "7": 0.0
    },
    "estadoRitmo": "adelantado",
    "diferenciaHorasRitmo": 5.5,
    "horasEsperadasHoy": 119.5,
    "ritmoDiarioSugerido": 4.8,
    "diasHabilesRestantes": 49,
    "mensajeRitmo": "🚀 Vas adelantado por 5.5 hrs. ¡Excelente ritmo!"
  }
  ```

---

## 6. Estrategia de Sincronización y Modo Offline

La aplicación móvil está diseñada con un enfoque **Offline-First**. Para garantizar una transición fluida al backend:

1. **Generación de UUIDs en el Cliente:**
   * La app móvil genera IDs en formato `UUID v4` al crear registros sin conexión. El backend debe aceptar el ID proporcionado por el cliente como clave primaria en inserciones.
2. **Campos de Auditoría:**
   * Incluir `created_at`, `updated_at` y `deleted_at` (soft deletes) para facilitar la sincronización bidireccional.
3. **Resolución de Conflictos:**
   * La regla estándar aplicada es *Last-Write-Wins (LWW)* basada en `updated_at`.
4. **Endpoint de Sincronización Batch (Recomendado):**
   * `POST /sync/batch` para enviar lotes de registros creados, modificados o eliminados localmente cuando el dispositivo recupera conexión a internet.

---

## 7. Validaciones y Manejo de Errores

El backend debe aplicar las siguientes validaciones:

1. **Horas:**
   * `hora_inicio` debe ser cronológicamente anterior a `hora_fin`.
   * El cálculo de `horas_computables` no puede ser negativo ni exceder las 24 horas por día.
2. **Modalidad:**
   * Valores estrictos permitidos: `['Presencial', 'Remoto', 'Híbrido']`.
3. **Días de la semana en horario semanal:**
   * Valores permitidos: `['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo']`.
4. **Respuestas de Error Estándar (RFC 7807):**
   ```json
   {
     "statusCode": 400,
     "error": "Bad Request",
     "message": "La hora de inicio (14:00) no puede ser posterior a la hora de fin (12:00)",
     "timestamp": "2026-09-22T19:40:00.000Z"
   }
   ```

---

## 8. Seguridad y Autenticación Recomendada

* **JWT (JSON Web Tokens):** Con expiración corta (ej. 15 a 60 minutos) y `Refresh Tokens` seguros almacenados en `flutter_secure_storage`.
* **CORS y Rate Limiting:** Habilitar cabeceras CORS adecuadas y protección contra fuerza bruta en `/auth/login`.
* **Aislamiento por Tenant / User:** Cada consulta (`SELECT`, `UPDATE`, `DELETE`) debe estar estrictamente condicionada al `user_id` del token JWT decodificado en el middleware de autenticación.
