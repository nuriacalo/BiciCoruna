# BiciCoruña

Aplicación móvil para consultar en tiempo real la disponibilidad de bicicletas en las estaciones del sistema de bicicletas públicas de A Coruña.

## 📱 Descripción

BiciCoruña es una aplicación Flutter que permite a los usuarios visualizar todas las estaciones de bicicletas públicas de A Coruña, consultar la disponibilidad de bicicletas en tiempo real y obtener información detallada de cada estación.

### Características principales

- 🚲 **Listado de estaciones**: Visualiza todas las estaciones disponibles en A Coruña
- 🔍 **Búsqueda**: Encuentra estaciones por nombre
- 📊 **Información en tiempo real**: Consulta bicis disponibles, plazas libres y estado de cada estación
- 🗺️ **Detalles de estación**: Dirección, capacidad, coordenadas geográficas y más
- 🔄 **Actualización automática**: Refresca los datos con pull-to-refresh
- 🎨 **Interfaz moderna**: Diseño Material 3 con tema personalizado

## 🏗️ Arquitectura

El proyecto sigue el patrón **MVVM (Model-View-ViewModel)** con la siguiente estructura:

```
lib/
├── model/              # Modelos de datos
│   ├── station.dart    # Modelo de estación
│   └── bike.dart       # Modelo de bicicleta
├── view/               # Vistas de la aplicación
│   ├── station_details_view.dart
│   └── StationSearchDelegate.dart
├── viewmodel/          # Lógica de negocio
│   └── stationViewModel.dart
├── widgets/            # Componentes reutilizables
│   ├── station_card.dart
│   ├── loading_view.dart
│   └── error_view.dart
└── main.dart          # Punto de entrada
```

## 🔌 API

La aplicación consume la API pública de GBFS (General Bikeshare Feed Specification) de A Coruña:

- **Base URL**: `https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl`
- **Endpoints utilizados**:
  - `/station_information`: Información estática de las estaciones
  - `/station_status`: Estado en tiempo real de las estaciones

## 🛠️ Tecnologías

- **Flutter** 3.9.2+
- **Dart**
- **Paquetes principales**:
  - `http`: ^1.6.0 - Para peticiones HTTP
  - `intl`: ^0.20.2 - Para formateo de fechas y localización
  - `cupertino_icons`: ^1.0.8 - Iconos iOS

## 🚀 Instalación

### Requisitos previos

- Flutter SDK 3.9.2 o superior
- Dart SDK
- Android Studio / Xcode (según plataforma objetivo)

### Pasos

1. **Clonar el repositorio**:
   ```bash
   git clone <url-del-repositorio>
   cd BiciCoruna
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## 📱 Plataformas soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 Tema y diseño

La aplicación utiliza Material Design 3 con una paleta de colores personalizada:

- **Color primario**: Azul (#1E88E5)
- **Color secundario**: Azul claro (#64B5F6)
- **Superficie**: Blanco / Gris claro (#F5F5F5)

## 📸 Funcionalidades

### Pantalla principal
- Lista de todas las estaciones
- Tarjetas con información resumida
- Indicadores visuales de disponibilidad
- Botón de búsqueda y actualización

### Detalles de estación
- Nombre y dirección completa
- Código postal y coordenadas
- Capacidad total
- Bicis disponibles y deshabilitadas
- Estado de la estación (activa/inactiva)
- Información sobre alquiler y devolución

### Búsqueda
- Búsqueda en tiempo real por nombre
- Navegación directa a detalles de estación

## 🔄 Estado y manejo de errores

La aplicación incluye:

- **Loading states**: Indicadores de carga mientras se obtienen datos
- **Error handling**: Manejo robusto de errores de red con mensajes descriptivos
- **Empty states**: Vista cuando no hay estaciones disponibles
- **Retry mechanism**: Opción de reintentar en caso de error

## 👨‍💻 Desarrollo

### Comandos útiles

```bash
# Ejecutar en modo debug
flutter run

# Ejecutar tests
flutter test

# Construir para producción (Android)
flutter build apk --release

# Construir para producción (iOS)
flutter build ios --release

# Analizar código
flutter analyze
```

## 📄 Licencia

Proyecto educativo para el módulo de Desarrollo de Interfaces.
