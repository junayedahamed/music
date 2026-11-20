# Flutter Music Player Upgrade — Android Media Notification & Background Playback

## 1. Project Overview

I have an existing Flutter music player application.

My current technology stack:

- Flutter and Dart
- GetX for state management and dependency injection
- just_audio for audio playback
- Local device music files
- Custom music player UI
- Reactive playback controls using GetX observables
- Custom theme support (Light/Dark mode)

I want to upgrade the existing music player by implementing a production-quality Android media notification system with background playback.

**IMPORTANT: This is an upgrade to an existing application, NOT a new project.**

Do not rebuild the application from scratch. Do not unnecessarily replace existing packages, controllers, models, UI components, or business logic.

Your first responsibility is to understand the existing implementation and then integrate the new functionality without breaking existing features.

---

# 2. Primary Objectives

Implement a complete Android media notification and background playback system using:

1. `just_audio` — existing audio playback engine.
2. `audio_service` — background audio service and media notification management.
3. `audio_session` — audio focus and interruption management.

Do not introduce `just_audio_background` alongside `audio_service`.

The application must maintain a single source of truth for audio playback.

There must never be two independent AudioPlayer instances controlling the same music queue.

## 3. Mandatory Development Rules

Before making any changes:

1. Inspect the complete project structure.
2. Identify the existing MusicController.
3. Identify where the AudioPlayer instance is created.
4. Inspect the SongModel and its local file path and artwork properties.
5. Understand how local music scanning works.
6. Understand existing playlist and queue management.
7. Inspect previous/next song functionality.
8. Inspect repeat and shuffle implementation.
9. Inspect playback speed management.
10. Inspect GetX dependency injection and controller lifecycle.
11. Inspect the existing PlayerView and its reactive observables.
12. Inspect AndroidManifest.xml, MainActivity, Gradle configuration, and minimum SDK.

Do not assume class names, variable names, or model properties.

Use the actual project implementation.

If essential information is missing, ask me questions before implementing the affected functionality.

Do not make destructive changes without explaining them.

## 4. Architecture Requirements

Preserve the existing GetX architecture.

Recommended responsibility separation:

### MusicAudioHandler

Create a new service:

`lib/src/services/music_audio_handler.dart`

Responsibilities:

- Extend BaseAudioHandler.
- Integrate with the existing just_audio engine.
- Manage background playback.
- Publish media metadata.
- Publish playback state.
- Handle notification playback commands.
- Handle seeking.
- Handle previous/next.
- Handle repeat and shuffle custom actions.
- Synchronize the Android notification with actual playback.
- Manage queue information.
- Handle playback completion and errors.

### MusicController

Keep the existing GetX controller.

Responsibilities:

- Manage reactive UI state.
- Expose existing playback methods.
- Communicate with MusicAudioHandler.
- Subscribe to audio playback streams.
- Update existing Rx variables.
- Manage playback speed.
- Manage favorites.
- Manage existing playlist functionality.
- Keep existing methods compatible wherever possible.

Do not create a second AudioPlayer inside MusicController.

The AudioHandler should own or receive the single shared AudioPlayer instance.

### PlayerView

Preserve the existing custom player UI.

Do not redesign the player screen unless a change is technically necessary.

Keep existing:

- Album artwork.
- Song title.
- Artist name.
- Playback slider.
- Current duration.
- Total duration.
- Play/pause button.
- Previous/next buttons.
- Repeat button.
- Shuffle button.
- Playback speed selector.
- Favorite functionality.
- Theme integration.

All UI controls must remain synchronized with notification controls.

## 5. Package Integration

Use the following packages:

- `just_audio`
- `audio_service`
- `audio_session`

Check the existing package versions and compatibility before upgrading anything.

Use the latest mutually compatible stable versions at implementation time.

Avoid unnecessary dependency upgrades.

Do not downgrade Flutter or Dart.

Do not introduce deprecated APIs.

Use official package documentation:

- https://pub.dev/packages/just_audio
- https://pub.dev/packages/audio_service
- https://pub.dev/packages/audio_session

## 6. Android Media Notification Requirements

Implement an Android native media notification using audio_service.

The notification should display:

### Song Information

- Current song title.
- Artist name.
- Album name when available.
- Album artwork.
- Playback status.

### Playback Controls

- Previous song.
- Play.
- Pause.
- Next song.
- Seek backward and forward where supported.
- Seek bar.
- Current playback position.
- Total duration.

### Advanced Controls

- Repeat Off.
- Repeat All.
- Repeat One.
- Shuffle On/Off.

Use AudioHandler custom actions for repeat and shuffle where supported.

Ensure the notification's custom actions update the actual AudioPlayer state.

Do not implement fake buttons that only change their displayed state.

### Android Notification Design

Use the native Android media notification.

Requirements:

- Display correct album artwork.
- Display the current song metadata.
- Update play/pause state immediately.
- Update metadata when the song changes.
- Show playback progress.
- Support expanded media controls.
- Support lock-screen media controls.
- Support Bluetooth and headset media buttons where supported.
- Keep notification state synchronized with actual playback.

IMPORTANT:

Android controls the final media notification layout.

Do not attempt to create a completely custom Flutter notification UI inside Android's native media notification.

Use supported MediaControl, MediaAction, PlaybackState, MediaItem, and customAction APIs.

Do not assume that Android will display every custom action in every notification layout.

## 7. Local Music Metadata Integration

The application plays music from local device storage.

Use the existing SongModel and local music scanning implementation.

Do not introduce another music scanning system unless the current implementation cannot supply required metadata.

Map existing song properties to AudioService MediaItem:

- id: stable song identifier or local file path.
- title: song title.
- artist: artist name.
- album: album name.
- duration: song duration.
- artUri: local artwork file URI when available.

Example:

MediaItem(
id: song.path,
title: song.title,
artist: song.artist,
album: song.album,
duration: song.duration,
artUri: artworkPath != null
? Uri.file(artworkPath)
: null,
)

Adapt this example to the actual SongModel.

Handle:

- Missing artwork.
- Invalid metadata.
- Empty artist names.
- Missing album names.
- Unknown song duration.
- Deleted local music files.
- Invalid file paths.

Artwork should remain accessible to Android while the notification is active.

Provide a fallback artwork strategy.

Do not use temporary artwork paths that disappear while playback is active.

## 8. Background Playback

Music must continue playing when:

- The user minimizes the application.
- The user navigates to another screen.
- The device screen is locked.
- The notification is expanded.
- The user switches between applications.

Handle Android foreground service requirements correctly.

Implement proper AudioService initialization before runApp().

Initialize the audio service only once.

Do not initialize a new service every time PlayerView opens.

The audio service must survive normal Flutter screen navigation.

Do not dispose of the shared AudioPlayer when PlayerView is closed.

Implement proper cleanup when the audio service is permanently stopped.

## 9. Android Configuration

Inspect and update AndroidManifest.xml.

Add the necessary permissions where applicable:

- WAKE_LOCK
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_MEDIA_PLAYBACK

Register the audio_service Android service according to the official package documentation.

Configure:

- android:foregroundServiceType="mediaPlayback"
- android:exported
- MediaBrowserService intent filter
- Correct tools namespace if required.

Check the existing MainActivity.

If required, integrate AudioServiceActivity without removing existing native functionality.

Check Android Gradle configuration and minimum SDK compatibility.

Do not blindly replace the existing AndroidManifest.xml.

Ensure compatibility with current Android foreground-service requirements, including Android 14 and newer.

Do not request unnecessary notification permissions.

Check whether POST_NOTIFICATIONS is required for the targeted Android version and implement the appropriate runtime permission flow.

The media session and foreground media playback requirements must be configured independently of ordinary notification permission assumptions.

## 10. Playback State Synchronization

This is one of the most important requirements.

The Android notification and Flutter UI must always represent the same playback state.

Synchronize:

- isPlaying
- current song
- current queue index
- playback position
- buffered position
- duration
- processing state
- playback speed
- repeat mode
- shuffle mode
- previous/next availability

Use appropriate just_audio streams.

Examples include:

- playerStateStream
- playbackEventStream
- positionStream
- durationStream
- currentIndexStream
- sequenceStateStream
- shuffleModeEnabledStream
- loopModeStream

Avoid unnecessary subscriptions.

Store StreamSubscriptions and cancel them appropriately.

Avoid excessive Rx updates that cause unnecessary widget rebuilds.

Use GetX observables consistently.

Do not use setState unnecessarily.

## 11. Notification Action Implementation

Implement the following actions:

### Play

Start the existing AudioPlayer.

### Pause

Pause the existing AudioPlayer.

### Previous

Navigate to the previous song in the existing queue.

Respect existing previous-song logic.

### Next

Navigate to the next song in the existing queue.

Respect existing next-song logic.

### Seek

Update the existing AudioPlayer position.

Ensure the Flutter progress slider receives the updated position.

### Repeat

Support three states:

1. Off
2. All
3. One

Keep just_audio LoopMode and the notification's repeat state synchronized.

### Shuffle

Toggle the existing just_audio shuffle functionality.

Preserve the existing queue behavior.

### Playback Speed

Keep playback speed synchronized with the existing player.

Playback speed does not need to be exposed as a notification action unless a suitable supported implementation is available.

## 12. Queue Management

Integrate the existing local music playlist with AudioService.

Use:

- QueueHandler
- Queue state
- MediaItem
- Queue update notifications

Requirements:

- Update notification metadata when the current song changes.
- Maintain the correct current queue index.
- Previous and next must use the existing playlist.
- Queue changes must update AudioService.
- Repeat All must repeat the queue.
- Repeat One must repeat the current song.
- Shuffle must use just_audio's existing shuffle functionality.
- Preserve the user's existing queue and playlist behavior.

Avoid maintaining two unrelated queues.

The AudioService queue should accurately represent the playback engine's current sequence.

## 13. Audio Session Management

Integrate audio_session.

Handle:

- Audio focus.
- Phone call interruptions.
- Other applications requesting audio focus.
- Headphone disconnection.
- Bluetooth audio interruptions.
- Audio becoming noisy events.

When headphones are disconnected, pause playback where appropriate.

Handle audio focus interruptions safely.

Do not allow unexpected duplicate playback after interruptions.

## 14. GetX Dependency Injection

Use GetX dependency management correctly.

The AudioHandler should be initialized once and shared.

Register it using an appropriate GetX dependency strategy.

For example:

- Permanent dependency for the audio service.
- Shared dependency for MusicController.
- Proper lifecycle handling for screen-specific controllers.

Avoid creating duplicate MusicController instances.

Avoid repeated Get.put calls that create multiple playback managers.

Do not destroy the shared AudioPlayer when navigating away from PlayerView.

## 15. Performance and Memory Management

Follow production-level Flutter practices.

Requirements:

- Avoid memory leaks.
- Cancel stream subscriptions.
- Dispose resources correctly.
- Avoid duplicate stream listeners.
- Avoid unnecessary rebuilds.
- Avoid unnecessary artwork decoding.
- Handle large local music queues efficiently.
- Avoid repeatedly rebuilding MediaItem objects when metadata has not changed.
- Avoid blocking the main isolate with expensive metadata processing.
- Handle player errors without crashing the application.

Keep the architecture scalable and maintainable.

## 16. Error Handling

Handle the following situations:

- Audio file not found.
- Unsupported audio format.
- Corrupted music file.
- Invalid metadata.
- Artwork unavailable.
- Playback failure.
- Queue becoming empty.
- Previous/next unavailable.
- Audio service initialization failure.
- Audio focus interruption.
- Service termination.
- Device reboot where applicable.

Display user-friendly errors.

Do not expose unnecessary internal exceptions to the user.

## 17. Testing Requirements

Do not consider the task complete until the following scenarios are tested.

### Basic Playback

- Start music from PlayerView.
- Confirm notification appears.
- Pause from notification.
- Resume from notification.
- Play another song.
- Confirm title and artwork update.

### Navigation

- Next from notification.
- Previous from notification.
- Navigate through the existing playlist.
- Verify queue index synchronization.

### Advanced Controls

- Seek from notification.
- Seek from PlayerView.
- Repeat Off.
- Repeat All.
- Repeat One.
- Shuffle On.
- Shuffle Off.
- Change playback speed.

### Background Playback

- Minimize application.
- Lock device.
- Open another application.
- Navigate between Flutter screens.
- Disconnect headphones.
- Reconnect audio devices.

### Android Testing

Test on relevant Android versions, particularly Android 13, 14, and newer where available.

Check:

- Notification behavior.
- Foreground service behavior.
- Lock-screen controls.
- Media session integration.
- Notification permission behavior.
- App lifecycle behavior.

## 18. Code Quality Requirements

Follow these development standards:

- Clean and modular code.
- Single Responsibility Principle.
- Reusable services.
- Strong typing.
- Null safety.
- Meaningful naming.
- No unnecessary dependencies.
- No deprecated Flutter APIs.
- No duplicate business logic.
- No duplicate AudioPlayer instances.
- No unnecessary setState.
- Proper resource disposal.
- Production-ready error handling.

Do not place all audio logic inside main.dart.

Do not place all notification logic inside MusicController.

Keep AudioHandler, GetX controller, and UI responsibilities separated.

## 19. Implementation Workflow

Follow this exact sequence.

### Phase 1: Existing System Audit

Inspect all relevant existing files.

Produce a brief report containing:

- Current architecture.
- Existing AudioPlayer initialization.
- Existing queue implementation.
- Existing repeat/shuffle implementation.
- Existing GetX dependencies.
- Existing Android configuration.
- Files that need modification.
- Files that need creation.

Do not modify anything during the initial audit.

### Phase 2: Implementation Plan

Explain:

- How the existing AudioPlayer will be integrated.
- How AudioService will communicate with GetX.
- How the existing queue will be synchronized.
- How notification controls will work.
- Which Android configurations need modification.

Wait for my approval before making large architectural changes.

### Phase 3: Implementation

Implement the feature incrementally.

For every modified file:

- Explain why it needs modification.
- Preserve unrelated functionality.
- Show complete updated code when appropriate.
- Avoid partial snippets that leave the project uncompilable.

### Phase 4: Validation

Run:

- flutter pub get
- flutter analyze
- flutter test, where applicable
- Android debug build.

Resolve errors introduced by your changes.

Do not claim the implementation is complete if it has not been built and tested.

### Phase 5: Final Report

Provide:

- Packages added.
- Files created.
- Files modified.
- Android configuration changes.
- Implemented notification features.
- Remaining limitations.
- Testing results.
- Any manual setup still required.

---

# 20. Non-Negotiable Instructions

1. Do not rewrite the existing music player.
2. Do not replace GetX.
3. Do not replace just_audio.
4. Do not introduce a second AudioPlayer.
5. Do not introduce just_audio_background alongside audio_service.
6. Do not remove existing playback functionality.
7. Do not break local music scanning.
8. Do not break favorites.
9. Do not break existing playlist management.
10. Do not break the current custom PlayerView UI.
11. Do not introduce deprecated APIs.
12. Do not blindly modify Android configuration.
13. Do not guess existing model properties or controller methods.
14. Do not use fake notification actions.
15. Do not claim successful builds without actual validation.

**Final Goal:**

Upgrade my existing Flutter music player into a production-quality Android music player with persistent background playback, a native expanded media notification, album artwork, play/pause, previous/next, seek bar, repeat modes, shuffle, lock-screen controls, and synchronized GetX state.

Preserve the existing architecture and functionality while adding this system in a clean, modular, scalable, and maintainable way.

Start with Phase 1: inspect my existing project. Do not modify code until the audit and implementation plan are ready.
