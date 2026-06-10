## **1\. Ficha Técnica del Proyecto**

* **Flutter Version:** 3.41.9 (Channel Stable)
* **Dart Version:** 3.11.5
* **Plataformas Target:** iOS, Android (Base de código única)
* **Gestión de Dependencias:** `pub.dev`
  --------------------------

  ## **2\. Estructura de Carpetas (Clean Architecture)**

Para proyectos de nivel profesional, se recomienda organizar por **Features** (funcionalidades) para evitar que la carpeta `lib` se vuelva inmanejable.

Plaintext

* lib/
* ├── core/                        \# Utilidades globales y configuración
* │   ├── network/                 \# Cliente API (Dio), Interceptores
* │   ├── theme/                   \# Estilos, colores y fuentes
* │   ├── errors/                  \# Manejo de excepciones personalizadas
* │   └── utils/                   \# Extensiones y funciones auxiliares
* ├── features/                    \# Funcionalidades del negocio
* │   ├── auth/                    \# Ejemplo: Módulo de Autenticación
* │   │   ├── data/                \# Implementación de Repositorios y DTOs
* │   │   ├── domain/              \# Entidades y Casos de Uso (Lógica pura)
* │   │   └── presentation/        \# Widgets, Screens y State Management
* │   └── profile/                 \# Ejemplo: Módulo de Perfil
* ├── shared/                      \# Componentes reutilizables en toda la app
* │   ├── widgets/                 \# Botones, Inputs, Cards genéricos
* │   └── models/                  \# Modelos de datos compartidos
* ├── main.dart                    \# Punto de entrada de la aplicación
* └── app.dart                     \# Configuración de MaterialApp/CupertinoApp
  ---

  ## **3\. Conexión con el Backend (Networking)**

Para conectar con un backend de forma eficiente y limpia, la recomendación estándar es usar **Dio**. Permite manejar interceptores (útiles para enviar tokens JWT automáticamente) y configuración global de timeouts.

### **Recomendación de implementación:**

1. **Crear un cliente base:** Configura la URL de tu API y los headers en `core/network`.
2. **Manejo de Modelos:** No uses `Map<String, dynamic>` directamente. Usa herramientas como `json_serializable` para convertir tus JSON en objetos Dart de forma segura.
   -------------------------------------------------------------------------------------------------------------------------

   ## **4\. Componentes y UI: "Smart vs. Dumb Widgets"**

Para mantener el frontend "limpio", divide tus archivos según su responsabilidad:

* **Pages (Smart):** Son los componentes que se conectan con el gestor de estado (Bloc, Riverpod o Provider). Se encargan de disparar acciones y escuchar cambios.
* **Components/Widgets (Dumb):** Son puramente visuales. Reciben datos por el constructor y notifican interacciones mediante callbacks (`onPressed`, `onChanged`).

**Tip de Limpieza:** Si un Widget tiene más de 60 líneas de código, es momento de extraer partes de su `build` a un nuevo archivo en la carpeta `shared/widgets`.

---

## **5\. Integración de Plugins (Hardware y Funciones Nativas)**

Para acceder a funciones como la cámara o el almacenamiento en iOS y Android, no es necesario escribir código nativo (Swift/Kotlin). Usamos plugins de **pub.dev**.

### **Plugins Esenciales Recomendados:**

1. **Cámara y Galería:**

    * `camera`: Para control total de la lente.
    * `image_picker`: Para una selección rápida de fotos/videos de la galería.
2. **Permisos:**

    * `permission_handler`: Indispensable para solicitar acceso a cámara, ubicación o notificaciones de forma limpia.
3. **Almacenamiento Local:**

    * `flutter_secure_storage`: Para guardar tokens de sesión de forma encriptada.

   ### **Ejemplo de flujo para la Cámara:**

Para que funcione en ambas plataformas, debes añadir los permisos en los archivos de configuración nativa:

* **Android:** `AndroidManifest.xml`
* **iOS:** `Info.plist` (añadiendo las llaves `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription`).
  ----------------------------------

  ## **6\. Reglas de Oro para "Código Limpio" en Dart**
* **Tipado Estricto:** Evita el uso de `dynamic`. Define siempre el tipo de dato para aprovechar el análisis estático de Dart.
* **Records para Retornos Múltiples:** Usa la nueva sintaxis de Dart para devolver éxito y error simultáneamente:
* Dart
* (User? user, String? error) getUserData() { ... }
*
*
* **Separación de Responsabilidades:** Un servicio de API solo debe hacer la petición. La lógica de qué hacer con los datos va en el **Domain Layer** (Casos de uso).
* **Inmutabilidad:** Usa `final` siempre que sea posible para tus variables y estados.
  -------------------------------------------------------------------------

  ## **7\. Preparación Cross-Platform (iOS & Android)**

Aunque Flutter es "escribe una vez, corre en todos lados", hay detalles para que el código sea de alta calidad en ambos:

1. **Uso de `SafeArea`:** Para evitar que el contenido choque con el "notch" o la barra de navegación de los teléfonos modernos.
2. **Adaptive Widgets:** Usa `Switch.adaptive` o `Slider.adaptive` para que el componente cambie su apariencia automáticamente entre el estilo Material (Android) y Cupertino (iOS).
3. **App Icons:** Utiliza el paquete `flutter_launcher_icons` para generar automáticamente todos los tamaños de iconos necesarios para ambas tiendas.