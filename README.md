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

## Estructura del Proyecto

Hemos implementado una arquitectura base escalable:

* **`/lib/views`**: Contiene las pantallas principales (como la vista inicial `splash_view.dart`).
* **`/lib/components`**: Contiene widgets reusables (como el fondo dinámico `animated_background.dart`).
* **`/lib/global`**: Contiene estados globales sencillos o configuraciones generales.
* **`/lib/theme`**: Contiene el sistema de tokens de diseño (`app_colors.dart` y `app_fonts.dart`).
* **`/assets`**: Carpeta donde se almacenan recursos multimedia como imágenes (`logo.svg`) y fuentes locales (`VerdanaPro`).

---
Para más ayuda o dudas sobre el framework, consulta la [Documentación Oficial de Flutter](https://docs.flutter.dev/).
