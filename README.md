# Music — Offline Audio Studio

<p align="center">
  <img src="assets/applogo.png" alt="Music App Logo" width="128" height="128" style="border-radius: 28px;" />
</p>

<p align="center">
  A sleek, high-performance, and feature-rich offline music player built with Flutter, GetX, and native Android audio integrations. Designed for speed, audio fidelity, and seamless offline library management.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Platform Android" />
  <img src="https://img.shields.io/badge/State_Management-GetX-8A2BE2" alt="GetX" />
  <img src="https://img.shields.io/badge/Audio_Engine-just__audio-FF6F00" alt="just_audio" />
  <img src="https://img.shields.io/badge/Background-audio__service-00ACC1" alt="audio_service" />
  <img src="https://img.shields.io/badge/Storage-Hive-F8A51D" alt="Hive" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</p>

---

## ⚡ Key Features

### 🚀 Instant-Launch & Stale-While-Revalidate Engine
- **Sub-3ms Startup**: Utilizes an ultra-low latency Hive key-value cache to instantly load your song library upon app launch without freezing on a splash screen.
- **Background MediaStore Synchronization**: Android MediaStore is queried asynchronously in the background, updating library additions or deletions seamlessly without blocking UI interaction.
- **Snappy Branded Splash**: 300ms native animated entrance with instant audio permission checks and graceful error handling.

### 🎧 Production Background Audio & Native Media Notification
- **Single Source of Truth**: Powered by `audio_service`, `just_audio`, and `audio_session` through a unified `MusicAudioHandler`.
- **System Media Notification**: Android native media notification (`MediaSessionCompat`) with live album artwork, interactive seek bar, play/pause, next/previous track, and lock-screen controls.
- **Advanced Notification Custom Actions**: Support for toggling **Shuffle** and cycling **Repeat Modes** (Repeat Off, Repeat All, Repeat One) directly from Android notification controls.
- **Audio Focus & Interruption Management**: Automatically pauses playback when headphones or Bluetooth devices disconnect (audio becoming noisy) and smoothly handles incoming calls and audio focus changes.
- **Full Media Volume Alignment**: Pure native audio routing without artificial volume ducking or clipping.

### 🔄 Reliable Session Persistence & Playback Restoration
- **Exact Last Track Restoration**: Remembers the exact song previously played, validated against available device storage.
- **Precise Duration & Seek Position**: Restores the seek bar position and duration across app restarts without resetting to zero.
- **First-Time User Idle State**: First-time launches start completely idle (`currentSong == null`, no default song 0 selected, progress slider at zero).
- **Graceful Library Changes**: If a previously played track is deleted or moved outside the app, the session safely resets to idle rather than falling back to song index 0.
- **Safe Restored State**: Reopened apps restore queue and track state in a paused condition, preventing unexpected autoplay.

### 📦 Multi-Select, Native Sharing & Safe Deletion
- **Instant Reactive Multi-Selection**: Long-press any song tile or tap "Select" in the 3-dot popup menu for zero-delay multi-selection mode.
- **Native File Sharing**: Direct integration with Android's `FileProvider` (`androidx.core.content.FileProvider`) allows sharing single or multiple audio files simultaneously via Bluetooth, Nearby Share, WhatsApp, Telegram, or email.
- **Double-Layer Safety Deletion**: Delete single or batch tracks directly from physical storage and Android MediaStore with confirmation warning dialogs preventing accidental file loss.

### 🎨 Modern Adaptive UI & Full-Bleed Launcher Icons
- **Edge-to-Edge Adaptive Icons**: Fully compliant with Android Adaptive Icon standards (`mipmap-anydpi-v26`) ensuring edge-to-edge coverage with **zero white padding or borders** across all Android launchers (Samsung One UI, Pixel Launcher, MIUI/HyperOS, OxygenOS).
- **Fast Alphabet Indexer (A–Z)**: Smooth vertical drag scrollbar for rapid jumping through thousands of songs alphabetically.
- **Custom 60fps Canvas Visualizers**: Handcrafted vinyl groove rotation painter and animated soundwave equalizer with zero heavy third-party JSON/Lottie overhead.
- **Full Dark / Light Theming**: High-contrast dark mode and clean light mode powered by reactive GetX controllers.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | Cross-platform UI toolkit |
| **Language** | [Dart](https://dart.dev) | High-performance compiled client language |
| **State Management** | [GetX](https://pub.dev/packages/get) | Reactive state management, dependency injection, and micro-navigation |
| **Audio Engine** | [just_audio](https://pub.dev/packages/just_audio) | Core audio streaming, playback controls, and buffer streaming |
| **Background Service** | [audio_service](https://pub.dev/packages/audio_service) | Android MediaSession, foreground service, and media notification controls |
| **Audio Focus** | [audio_session](https://pub.dev/packages/audio_session) | Audio focus management, headphone unplug (becoming noisy) detection |
| **Media Querying** | [on_audio_query](https://pub.dev/packages/on_audio_query) | Android MediaStore audio indexing and ID3 tag retrieval |
| **Persistence Cache** | [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter) | Ultra-fast local NoSQL database for session and song cache |
| **Native Integration** | Android Kotlin (`MethodChannel`) | Scoped storage deletion, MediaScanner indexing, and FileProvider sharing |

---

## 🏗️ Clean Modular Codebase ($\le 250$ Lines/File)

In compliance with strict production and performance guidelines, every single Dart file in `lib/` is strictly under 250 lines of code, decoupled into dedicated coordinators and services:

- **`MusicAudioHandler`**: Owns the single `AudioPlayer` instance, manages playback state, MediaItems, and notification actions.
- **`AudioSessionManager`**: Encapsulates audio focus configuration and noisy headphone disconnection callbacks.
- **`AudioSessionRestorer`**: Safely validates and restores persisted playback sessions without race conditions.
- **`PlayerSessionCoordinator`**: Coordinates Hive session saves and debounce logic.
- **`PlayerActionCoordinator`**: Handles auxiliary player actions (loop cycling, shuffle toggles, speed selection, seeking).
- **`PlayerListenerBinder`**: Binds audio player stream events to GetX observables safely.
- **`HomeSelectionController`**: Manages batch selection state with immediate UI reactivity.
- **`QueueNavHelper`**: Pure utility for calculating safe circular previous/next queue indices.

---

## 🔄 Recent Updates & Changelog

- **Upgraded to `audio_service` + `audio_session`**: Complete background playback overhaul replacing `just_audio_background` with native Android `MediaSessionCompat` and foreground media service (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`).
- **Notification Custom Controls**: Added Android media notification actions for toggling shuffle and cycling loop modes (Off, All, One) with direct player state synchronization.
- **Session Persistence & Playback Restoration**: 
  - Restores exact last-played track and seek position.
  - Implemented clean idle start for first-time users (`currentSong == null`).
  - Added device library validation to handle deleted files gracefully without defaulting to song index 0.
- **Zero-Latency Multi-Select**: Fixed reactive subscription in song list items so tapping "Select" in the 3-dot popup menu immediately selects the item and reveals selection checkboxes.
- **Audio Interruption & Disconnect Protection**: Configured `audio_session` to automatically pause playback on headphone unplug or Bluetooth disconnect.
- **Refactored Architecture**: Split controllers and services so that 100% of Dart files adhere to the $\le 250$ lines per file maintainability standard.
- **Native File Sharing & Deletion**: Added platform channel methods in `MainActivity.kt` for sending multiple file URIs via `ACTION_SEND_MULTIPLE` and invoking Android `MediaScannerConnection` + `ContentResolver` to purge deleted audio files cleanly.
- **Full-Bleed Adaptive Icons**: Added `mipmap-anydpi-v26` adaptive icon manifests eliminating the default Android white background plates.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>=3.6.0`)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator running Android 7.0 (API 24) or higher

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AbabilX/music.git
   cd music
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on a connected Android device**:
   ```bash
   flutter run
   ```

4. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```

---

## 📂 Project Structure

```text
music/
├── android/                   # Native Android host project
│   └── app/src/main/
│       ├── AndroidManifest.xml # Permissions, FileProvider & AudioService declarations
│       ├── kotlin/.../        # Native Kotlin implementation (sharing, deletion)
│       └── res/               # Adaptive icons, mipmap densities, and XML drawables
├── assets/                    # Static brand assets (applogo.png)
├── lib/
│   ├── main.dart              # AudioService & Hive initialization
│   ├── app.dart               # GetMaterialApp configuration & theme registry
│   └── src/
│       ├── controller/        # Decoupled GetX business logic (<250 lines/file)
│       │   ├── audio_controller.dart          # Main PlayerController facade
│       │   ├── player_action_coordinator.dart # Seek, loop, shuffle, speed actions
│       │   ├── player_session_coordinator.dart# Session save orchestration
│       │   ├── player_listener_binder.dart    # Stream listener bindings
│       │   ├── home_selection_controller.dart # Batch multi-select state
│       │   └── theme_controller.dart          # Reactive dark/light mode controller
│       ├── services/          # Audio playback & native background services
│       │   ├── music_audio_handler.dart       # BaseAudioHandler for media notification
│       │   ├── audio_session_manager.dart     # Headphone unplug & focus management
│       │   ├── audio_session_restorer.dart    # Session recovery & validation
│       │   ├── audio_cache_service.dart       # Hive session & song caching
│       │   └── queue_nav_helper.dart          # Queue navigation calculations
│       └── view/              # UI screens & modular widgets (<250 lines/file)
│           ├── home/          # Home view, favorites, playlists, search & sorting
│           ├── music tile/    # Reusable song tile with instant multi-select & 3-dot menu
│           ├── player view/   # Fullscreen audio visualizer & studio player
│           └── welcome_splash_screen/ # Fast native animated splash screen
├── test/                      # Unit & integration tests
│   └── session_persistence_test.dart
└── pubspec.yaml               # Flutter package dependencies and configuration
```

---

## 🤝 Contribution Guidelines

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

### Workflow

1. **Fork the Project**.
2. **Create your Feature Branch**:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your Changes**:
   ```bash
   git commit -m 'feat: Add AmazingFeature'
   ```
4. **Follow Flutter & Dart Conventions**:
   - Ensure clean code and formatting:
     ```bash
     dart format lib/
     flutter analyze lib/
     ```
   - Keep all `.dart` files $\le 250$ lines.
   - Use GetX reactive state management (avoid application-level `setState`).
   - Test your changes on both dark and light modes.
5. **Push to the Branch**:
   ```bash
   git push origin feature/AmazingFeature
   ```
6. **Open a Pull Request**.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

**Crafted with ❤️ by [Team AbabilX](https://github.com/AbabilX)**
