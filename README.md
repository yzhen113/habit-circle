# Habit Circle

A native iOS app for building habits together in small circles. Members share a
habit, complete it daily (optionally with photo verification), track group
progress, and cheer each other on in a group chat.

> Status: SwiftUI prototype running on **mock data**. No backend yet.

## Requirements

- macOS with **Xcode 16** or newer
- **iOS 17.0+** deployment target
- Swift 5.0

No third-party dependencies or package manager setup — it builds straight from Xcode.

## Getting started

1. Clone the repo:
   ```bash
   git clone <repo-url>
   cd "habit circle"
   ```
2. Open the project in Xcode:
   ```bash
   open HabitCircle.xcodeproj
   ```
3. Select the **HabitCircle** scheme and an iPhone simulator (e.g. iPhone 17).
4. Press **Run** (⌘R).

You do **not** need a paid Apple Developer account to run in the Simulator.
To run on your own physical device, sign in with a free Apple ID under
*Xcode → Settings → Accounts* and select your team in the target's
*Signing & Capabilities* tab (device builds from a free account expire after 7 days).

## Project structure

```
HabitCircle/
  App/            App entry point and root tab view
  Features/       Screens grouped by feature
    Home/         Daily task list + day paging
    Discover/     Browse/search circles
    Detail/       Habit detail: weekday strip, progress ring, photo history
    Chat/         Circle group chat
  Components/     Reusable views (cards, bubbles, tab bar, pickers)
  DesignSystem/   Colors, typography, layout constants
  Models/         Data models and view models (mock-backed for now)
  Assets.xcassets Images, app icon, colors
  Resources/      Design references
```

Architecture: SwiftUI with lightweight `ObservableObject` view models per feature.
Data is currently seeded from in-memory samples in the view models.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branching and pull-request workflow.

## Roadmap (high level)

- [ ] Replace mock data with a backend (auth, persistence, storage)
- [ ] Real photo verification uploads
- [ ] Live group chat
- [ ] Push notifications for reminders
