# 🚨 PreAlertateClima - Aplicación de Alerta Temprana de Catástrofes Naturales

**PreAlertateClima** es una aplicación móvil nativa para Android desarrollada en Kotlin que proporciona herramientas de emergencia, alerta temprana en tiempo real mediante Firebase, mapas interactivos, comandos por voz y guías de acción ante desastres naturales.

---

## 📁 Estructura del Proyecto

```text
MyApplication/
├── app/
│   ├── build.gradle.kts
│   ├── google-services.json
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── java/com/example/PreAlertateClima/
│           │   ├── core/utils/
│           │   │   ├── DisasterActivity.kt          # Escuchador global en tiempo real de Firestore
│           │   │   └── NavegacionExt.kt            # Extensiones de navegación entre Activities
│           │   ├── domain/model/
│           │   │   ├── Emergency.kt                 # Modelo de datos de números de emergencia
│           │   │   └── ChatMessage.kt               # Modelo de datos de mensajes de chat
│           │   ├── presentation/
│           │   │   ├── home/
│           │   │   │   └── MainActivity.kt          # Pantalla principal (Inicio, Clima y Emergencias)
│           │   │   ├── location/
│           │   │   │   └── MapActivity.kt           # Pantalla "¿Dónde estoy?" (Mapa, Geocoder y Firestore)
│           │   │   ├── navegacion/
│           │   │   │   ├── PantalladerActivity.kt   # Pantalla de Herramientas, Batería y Voz
│           │   │   │   └── VoiceActivity.kt         # Pantalla propia de Grabadora de Voz (Micrófono)
│           │   │   ├── media/
│           │   │   │   └── CameraActivity.kt        # Cámara (Video frontal/selfie y fotos por voz)
│           │   │   ├── asistencia/
│           │   │   │   ├── ChatAsistenciaActivity.kt # Chat con asistente en tiempo real
│           │   │   │   └── ChatAdapter.kt           # Adaptador de RecyclerView para Chat
│           │   │   ├── guide/
│           │   │   │   └── GuiaCatastrofesActivity.kt # Guía educativa con imágenes y videos locales
│           │   │   ├── desastre/
│           │   │   │   └── DesastreAlertaActivity.kt # Pantalla propia de Alerta por Desastre Natural
│           │   │   ├── alertapanico/
│           │   │   │   └── PanicoAlertaActivity.kt  # Pantalla propia de Simulación de Pánico Manual
│           │   │   └── bateria/
│           │   │       └── BatteryAdapter.kt        # Adaptador de RecyclerView para Batería
│           └── res/
│               ├── drawable/                        # Infografías e imágenes del proyecto
│               │   ├── huracan_guia.png
│               │   ├── terremoto_guia.png
│               │   └── tsunami_guia.png
│               ├── raw/                             # Videos locales y alarma en alta calidad
│               │   ├── alarma_alerta.mp4
│               │   ├── huracan_video.mp4
│               │   ├── terremoto_video.mp4
│               │   └── tsunami_video.mp4
│               └── layout/                          # Diseños XML de pantallas e items
│                   ├── pantalla_inicio.xml
│                   ├── activity_map.xml
│                   ├── pantallader.xml
│                   ├── activity_camera.xml
│                   ├── activity_voice.xml
│                   ├── activity_chat_asistencia.xml
│                   ├── activity_guia_catastrofes.xml
│                   ├── activity_desastre_alerta.xml
│                   ├── activity_panico_alerta.xml
│                   ├── item_battery.xml
│                   ├── item_emergency.xml
│                   ├── item_chat_user.xml
│                   └── item_chat_representative.xml
└── build.gradle.kts
```

---

## 🚀 Funcionalidades Principales

### 1. 🏠 Pantalla Principal e Inicio (`MainActivity`)
- **Widget del Clima**: Carga dinámica mediante `WebView` alimentada por API/Widget.
- **Números de Emergencia**: Conexión e hidratación en tiempo real desde Firebase Firestore (`Emergencias`). Incluye 4 instituciones predeterminadas (Policía 101, Bomberos 100, Ambulancia SAME 107, Defensa Civil 103).
- **Llamadas Directas**: Inicia el servicio telefónico del dispositivo (`Intent.ACTION_DIAL`).
- **Header con Linterna**: Botón de linterna superior con indicador visual de estado (**Rojo cuando está apagada** / **Verde cuando está encendida**). Apagado automático en ciclo de vida.

### 2. 📍 Localización y Mapa (`MapActivity`)
- **Ubicación en Tiempo Real**: Visualización de mapa mediante OpenStreetMap.
- **Dirección en Grande**: Formateo y visualización clara de la dirección física procesada con `Geocoder`.
- **Registro de Siniestro**: Guardado de coordenadas actuales y referencias en la colección `LocacionesSiniestros` de Firestore.
- **Manejo de Errores**: Notificación visual inmediata en pantalla si el servicio de GPS se encuentra desactivado.

### 3. 🛠️ Herramientas, Batería y Voz (`PantalladerActivity`)
- **RecyclerView de Batería Superior**: Ocupa el 100% de la anchura con una altura de ~100dp. Muestra porcentaje actual, tiempo estimado restante de uso y hora aproximada de agotamiento.
- **Comando por Voz Directo**: Invoca el reconocidor de voz de Google con Toast de aviso.
  - Comando `"camara"` o `"abrir camara"`: Abre la cámara.
  - Comando `"foto"` o `"tomar foto"`: Abre la cámara, captura automáticamente la fotografía y regresa a la pantalla de herramientas.

### 4. 🚨 Sistema de Alerta Temprana de Catástrofes (`DisasterActivity` / `DesastreAlertaActivity`)
- **Escuchador Global Singleton**: Escucha la colección `catastrofes` de Firebase Firestore en tiempo real desde cualquier pantalla. Ignora datos pasados al iniciar para no bloquear la navegación.
- **Pantalla Dedicada de Desastre (`DesastreAlertaActivity`)**:
  - Título: `⚠️ ¡ALERTA DE DESASTRE NATURAL! ⚠️`.
  - Efectos: Parpadeo de pantalla en colores rojo/blanco, linterna, vibración y reproducción continua de `R.raw.alarma_alerta`.
  - **Botón "📖 VER GUÍA DE CATASTROFES"**: Desactiva la alerta y abre la Guía de Catástrofes.
  - **Botón "DETENER ALERTA"**: Desactiva la alerta y regresa a la pantalla de herramientas.

### 5. 🚨 Simulación Manual de Pánico (`PanicoAlertaActivity`)
- **Pantalla Independiente de Pánico**: Activada desde el menú de herramientas.
- Título: `🚨 SIMULACIÓN DE PÁNICO 🚨`.
- Botón **"DETENER PÁNICO"** para cancelar los efectos de socorro y regresar a la pantalla de herramientas.

### 6. 📖 Guía de Acción ante Catástrofes (`GuiaCatastrofesActivity`)
- **Infografías Maximizadas**: Imágenes legibles a ancho completo desde `res/drawable` (`huracan_guia`, `terremoto_guia`, `tsunami_guia`).
- **Videos Locales**: Reproducción de archivos de video en formato MP4 desde `res/raw` (`huracan_video`, `terremoto_video`, `tsunami_video`) usando `VideoView` con controles `MediaController`.

### 7. 📷 Cámara y Videos (`CameraActivity`)
- Implementada con **Jetpack CameraX**.
- Grabación de video con cámara frontal (selfie) y trasera.
- Disparo automático de fotografías mediante comando por voz.
- Almacenamiento local e indexación en la galería del teléfono (`DCIM/PreAlertate` y `Movies/PreAlertate`).

### 8. 🎙️ Grabadora de Voz (`VoiceActivity`)
- Pantalla dedicada exclusivamente para la grabación de notas de voz con micrófono mediante `MediaRecorder` (`MPEG-4`/`AAC`).
- Inserción e indexación en la biblioteca pública del sistema (`Music/PreAlertate/`) vía `MediaStore` y `MediaScannerConnection`.

### 9. 💬 Chat de Asistencia (`ChatAsistenciaActivity`)
- Chat interactivo simulado en tiempo real sincronizado mediante Firestore (`chat_asistencia`).

---

## 🗄️ Colecciones en Firebase Firestore

| Colección | Descripción |
| :--- | :--- |
| `Emergencias` | Almacena los nombres e instituciones de emergencia con sus números telefónicos (`nombre`, `numero`). |
| `catastrofes` | Registro en tiempo real de eventos de catástrofe que disparan la alerta global (`activo`, `fechaHora`, `ubicacion`). |
| `LocacionesSiniestros` | Guarda los reportes de ubicación enviados por el usuario (`latitud`, `longitud`, `referencia`, `hora`). |
| `chat_asistencia` | Mensajes del chat entre el usuario y los representantes (`remitente`, `mensaje`, `timestamp`). |

---

## 🔑 Permisos Configurados (`AndroidManifest.xml`)

- `INTERNET`: Conexión con Firebase y APIs de mapas/clima.
- `CAMERA`: Captura de fotos y videos con CameraX.
- `RECORD_AUDIO`: Grabación de voz y comandos por micrófono.
- `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION`: Geolocalización para GPS y mapas.
- `VIBRATE`: Efecto de vibración para las alertas de emergencia.
- `WRITE_EXTERNAL_STORAGE` & `READ_EXTERNAL_STORAGE`: Guardado local de contenido multimedia.
