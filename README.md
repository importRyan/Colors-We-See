#  Colors We See

Simulates color blindness on your camera feed using Metal filters.

The primary objective is to explore the latest Composable Architecture beta and UGC-driven App Clip cards ahead of a larger App Clip-focused project.

[Structure](#structure) [Screenshots](#screenshots) [To Dos](#tasks) 

## Structure
Quick overview of reducer/SPM module composition of this few day old hobby project:
```
[[iOS/App Clip Targets]]
  (Thin clients instantiating AppRootScene)

[[Features Package]]
  [Root] 
  └── AppRoot
     └── Bootstrap
  Integration tests cover deferred deeplinking and sad bootstrap paths

  [Tabs]
  Composes Camera, Learn, and Photos Tabs

  [CameraTab]
  └── Camera
     ├── CameraPermissions
     └── AppClipFullAppDownload
  Integration tests hit async permissions flow, app clip upgrade prompt

  [Common]
  Analytics, feature flags, and other shared specifics

[[Clients Package]]
  └── Analytics
  └── App Clip
  └── Feature Flags
  └── Launch Environment
  └── Vision Simulation (Camera + Metal Compute)

[[ColorVision Package]]
  (Reusable GPU and CPU color blindness simulation tools)

```

## Screenshots
![ColorsWeSee](https://github.com/importRyan/Colors-We-See/assets/78187398/cb10fbad-a2a9-4000-924f-dc5e6136b2a2)

## Tasks
- [x] Setup XCC (pre-build script to populate Firebase secrets, test plans)
- [x] Remote config (version check)
- [x] Symbol stripping
- [x] App icon
- [ ] QC TestFlight
- [ ] Submit barebones 1.0
- [ ] User selected image simulation + export (PhotosTab)
- [ ] UGC sharing (snap photos, user selected images)
- [ ] Slicker CameraTab
- [ ] UGC-driven App Clip card
- [ ] Non-fatals
- [ ] App Clip code generation and export
- [ ] macOS target
- [ ] macOS ScreenCaptureKit tab
- [ ] Shortcuts
- [ ] Learn tab
- [ ] Improve barebones video interface / exposure / focus
- [ ] Metal simulation cross fade/rolling fade
- [ ] Animate camera permissions screen
- [ ] visionOS target (limited to LearnTab, PhotosTab)
- [ ] String Catalog accessor generation
