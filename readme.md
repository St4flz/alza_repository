# Alza+

Bienvenido al repositorio de la aplicación **Alza+**. Este es un proyecto desarrollado con el framework Flutter.

## Requisitos Previos

Antes de clonar y ejecutar este proyecto, asegúrate de tener instalados los siguientes componentes en tu sistema:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (Recomendado versión estable más reciente).
2. [Dart SDK](https://dart.dev/get-dart) (Viene incluido con Flutter).
3. Un emulador configurado (Android / iOS) o un dispositivo físico conectado en modo desarrollador (USB debugging activo).
4. Un IDE de tu preferencia, como [VS Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio), con las extensiones de Flutter y Dart instaladas.

## Instrucciones para correr en local

Sigue estos pasos para arrancar el proyecto en tu entorno local:

1. **Clonar el repositorio:**
   Si aún no lo has hecho, clona este repositorio y entra a la carpeta:
   ```bash
   git clone <url_de_tu_repositorio>
   cd alza
   ```

2. **Descargar las dependencias:**
   Ejecuta el siguiente comando para descargar todos los paquetes necesarios (`flutter_svg`, `google_fonts`, etc.):
   ```bash
   flutter pub get
   ```

3. **Verificar el entorno:**
   Asegúrate de que no haya problemas con tu instalación de Flutter y que detecte tu emulador o dispositivo conectado:
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación:**
   Inicia tu emulador o conecta tu teléfono y ejecuta la aplicación usando el comando:
   ```bash
   flutter run
   ```
   *(Si tienes múltiples dispositivos conectados, Flutter te pedirá que elijas uno, o puedes usar `flutter run -d <device_id>`)*.

## Arquitectura Propuesta del Proyecto

El proyecto sigue una arquitectura modular y organizada por características (**Feature-First Architecture**), estructurada bajo el directorio `/lib` de la siguiente manera:

### Estructura de Carpetas Principal (`/lib`)

```text
lib/
├── app/          # Levantamiento e inicialización de la aplicación (estilos, rutas, etc.)
├── core/         # Infraestructura base (clientes HTTP, persistencia, helpers de bajo nivel)
├── shared/       # Elementos compartidos utilizados por más de 2 features
└── features/     # Funcionalidades del negocio divididas por módulos
```

* **`app/`** (Levantamiento de la aplicación): Capa responsable del arranque e inicialización global. Aquí se definen la configuración de enrutamiento (`app_router.dart`), la inicialización de estado global en `app.dart` y los tokens de diseño (`style/`).
* **`core/`** (Infraestructura): Centraliza la lógica técnica de bajo nivel. Incluye la configuración del cliente de red (Dio), integraciones directas con servicios externos (Supabase), interceptores, y manejo global de excepciones.
* **`shared/`** (Componentes compartidos): Alberga widgets de interfaz, modelos o utilidades de negocio que sean consumidos activamente por **más de dos features**. Ayuda a evitar la duplicación de código redundante.
* **`features/`** (Módulos de negocio): Contiene las características específicas de la aplicación, como la autenticación (`auth`) o el tablero principal (`home`).

---

### Estructura Interna de un Feature (`/lib/features/<nombre_feature>/`)

Cada módulo o feature dentro de `/lib/features/` implementa una división interna estricta y estandarizada:

```text
features/mi_feature/
├── hooks/        # Funciones de lógica y utilidades específicas para este feature
├── models/       # Modelos de datos y mapeadores del feature
├── providers/    # Gestores de estado e intermediarios
├── services/     # Llamados y lógica de integración externa
└── views/        # Capa visual (pantallas y widgets internos de la vista)
```

1. **`hooks/`** (Utilidades locales): *No son hooks de React*. Son funciones, extensiones o utilidades específicas y exclusivas de este feature (actúan como un `utils` local).
2. **`models/`** (Modelado de datos): Clases de Dart, entidades, y métodos de serialización (`fromJson`, `toJson`) asociados a la característica.
3. **`providers/`** (Gestión de estado): Clases intermediarias que controlan y exponen el estado del feature a las vistas (por ejemplo, implementaciones de `ChangeNotifier` o controladores de estados).
4. **`services/`** (Conexión externa): Capa de servicios que se conecta con el exterior usando las herramientas e infraestructura estandarizadas provistas por `core`.
5. **`views/`** (Interfaz de usuario): El diseño visual de la característica, organizada generalmente en:
   * **`screens/`**: Pantallas principales o de flujo completo que corresponden directamente a rutas.
   * **`components/`**: Widgets específicos que componen la interfaz del feature.

---
Para más ayuda o dudas sobre el framework, consulta la [Documentación Oficial de Flutter](https://docs.flutter.dev/).
