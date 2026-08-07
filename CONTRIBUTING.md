# Contributing to Habit Circle

Welcome! This guide covers how we work together on this repo. It's written for
people who are new to GitHub — if anything is unclear, ask.

## The big picture

- `main` is always the "good" version of the app. We never commit directly to it.
- All work happens on a **branch**, then gets merged into `main` through a
  **pull request (PR)** that a teammate reviews.

## One-time setup

1. Install Xcode from the Mac App Store.
2. Clone the repo and open `HabitCircle.xcodeproj` (see the README).
3. Make sure you can build and run in the Simulator before changing anything.

## Day-to-day workflow

1. **Get the latest `main`:**
   ```bash
   git checkout main
   git pull
   ```
2. **Create a branch** for your task. Use a short, descriptive name:
   ```bash
   git checkout -b feature/progress-ring-animation
   # or: fix/back-button-crash
   ```
3. **Make your changes** in Xcode. Build and test in the Simulator.
4. **Commit** in small, meaningful chunks:
   ```bash
   git add -A
   git commit -m "Add spring animation to progress ring"
   ```
5. **Push** your branch:
   ```bash
   git push -u origin feature/progress-ring-animation
   ```
6. **Open a Pull Request** on GitHub (it will suggest your pushed branch).
   Fill in the template describing what changed and how you tested it.
7. A teammate reviews it. Once approved and CI passes, **squash-merge** into `main`.
8. Delete the branch after merging (GitHub offers a button).

## Branch naming

- `feature/...` — new functionality
- `fix/...` — bug fixes
- `chore/...` — tooling, docs, cleanup

## Commit messages

- Write in the imperative mood: "Add", "Fix", "Refactor" — not "Added"/"Fixing".
- Keep the first line under ~72 characters; add detail in the body if needed.

## Code style

- Match the existing SwiftUI patterns and the `DesignSystem` (colors, typography,
  layout constants) instead of hardcoding values.
- Don't commit build output, `xcuserdata`, or `.DS_Store` (the `.gitignore`
  handles this).

## What not to commit

- Secrets, API keys, or credentials — ever. If we add a backend later, keys go in
  ignored config files or CI secrets, never in the repo.
