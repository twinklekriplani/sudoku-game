# Sudoku Quest

## 1. Project Overview
Sudoku Quest is a premium, fully-featured Sudoku mobile game built with Flutter. It features a modern dark-themed UI, level-based progression, dynamic scoring based on completion time, and a persistent local leaderboard. Designed with clean architecture in mind, the game provides a seamless, responsive puzzle experience without requiring an internet connection.

## 2. Assignment Objective
This application was developed as an internship assignment for the **Flutter Developer Intern** role at **Cypher Matrix**. It demonstrates proficiency in:
- Flutter UI/UX development and responsive design
- Complex state management and game logic implementation
- Local data persistence using `SharedPreferences`
- Level progression and unlocking mechanisms
- Dynamic scoring and timer integration
- Clean, maintainable MVC architecture

## 3. Features

### Core Features
- **Player Authentication:** Simple local player name entry.
- **Home Dashboard:** Displays current player name, active level, overall progress, and total score.

### Game Features
- **9x9 Sudoku Board:** Fully functional, responsive grid.
- **Pre-filled & Editable Cells:** System cells are locked; player cells can be edited using a custom 1-9 number selector pad.
- **Move Validation:** Strict validation against standard Sudoku rules (Row, Column, 3x3 Grid). Invalid moves are visually flagged.
- **Game Controls:** Check Solution and Restart Level functionalities.
- **Timer:** Real-time completion timer tracking your solving speed.

### Progression & Scoring
- **10 Distinct Levels:** 
  - Levels 1–3: Easy
  - Levels 4–6: Medium
  - Levels 7–10: Hard
- **Unlock System:** Completing a level unlocks the next sequential level.
- **Dynamic Scoring:** 
  - Base Score = 1000
  - Under 2 minutes = +500
  - Under 5 minutes = +300
  - Under 10 minutes = +100
  - Wrong Move Penalty = -20 points per invalid entry.

### Leaderboard
- **Local Top 10:** Displays the top 10 highest-scoring game completions, noting the Player Name, Score, and Level Completed.

### Local Storage
- **Offline Persistence:** All player names, unlocked levels, cumulative scores, and leaderboard history are saved locally.

### UI/UX
- **Premium Dark Theme:** Deep blue/purple gradients, cyan accents, and glowing borders.
- **Responsive Layouts:** Adjusts seamlessly across various mobile screen sizes avoiding RenderFlex overflows.

## 4. Screens / User Flow
1. **Welcome Screen:** Enter player name to begin.
2. **Home Screen:** View dashboard statistics and access primary navigation.
3. **Level Selection:** View 10 levels (locked/unlocked states visually distinct).
4. **Sudoku Game Screen:** Play the puzzle, track time, and input numbers.
5. **Result Screen:** View detailed score breakdown (Base + Time Bonus - Penalties) upon completion.
6. **Leaderboard Screen:** View top 10 local scores.

## 5. Level System

| Levels | Difficulty | Blank Cells |
| ------ | ---------- | ----------- |
| 1–3    | Easy       | 25-35       |
| 4–6    | Medium     | 40-50       |
| 7–10   | Hard       | 53-62       |

*Progression:* Players start with Level 1 unlocked. Completing a level saves the newly unlocked level to `SharedPreferences`, granting access to the next puzzle in the sequence.

## 6. Sudoku Game Logic
- **Generation:** Puzzles are generated using a mathematically valid base 9x9 board. A deterministic hole-punching algorithm simulates the 10 distinct difficulty levels by removing specific cell counts.
- **Validation:** When a number is inputted, the `GameController` verifies it against the row, column, and 3x3 subgrid. If invalid, it highlights red and increments the wrong-move penalty counter.
- **Completion:** The user must explicitly press "Check Solution". The system verifies the board is full and correct before stopping the timer and calculating the score.

## 7. Scoring System
Final scores are calculated precisely to the assignment requirements:
- **Base Score:** 1000 points.
- **Time Bonus:** Applied once based on completion time (`<2m: 500`, `<5m: 300`, `<10m: 100`, `>=10m: 0`).
- **Penalties:** Each incorrectly placed number deducts 20 points.
- **Calculation:** `Max(0, Base + TimeBonus - Penalties)`.
- **Storage:** The final score is added to the user's `Total Score` and pushed to the `Leaderboard` immediately upon verification.

## 8. Leaderboard
- **Storage:** A JSON-encoded array stored via `SharedPreferences`.
- **Behavior:** Records `{playerName, score, level, timestamp}`.
- **Sorting:** Sorted dynamically by score (descending) and truncated to keep only the Top 10 entries locally.

## 9. Local Data Persistence
Data is managed via the `shared_preferences` package.
Stored keys use a Prefix architecture (`playerName_keyName`) to isolate data, allowing multiple local users to log in on the same device without overwriting each other's progress.
Persisted items include:
- `playerName`
- `[name]_unlockedLevels`
- `[name]_totalScore`
- `leaderboard` (Shared JSON array)

## 10. State Management
**Approach:** Lightweight Native MVC using `ValueNotifier` and `ValueListenableBuilder`.
- **Why?** It ensures localized, highly performant UI rebuilds without the overhead or boilerplate of external packages like Provider or Riverpod for an application of this scope.
- **Execution:** Controllers hold business logic and `ValueNotifier` states. Views listen to these notifiers to reactively update the UI (e.g., updating a specific Sudoku cell without rebuilding the entire screen).

## 11. Project Architecture
The project strictly adheres to the **Model-View-Controller (MVC)** architectural pattern.

```text
lib/
├── controllers/       # Business logic & state notifiers (e.g., game_controller.dart)
├── models/            # Immutable data classes (e.g., score_model.dart)
├── routes/            # Centralized named route definitions
├── services/          # Abstracted data layers (StorageService, SudokuService)
├── theme/             # Global color schemes, typography, and styling
├── views/             # Flutter UI widgets and screens
└── main.dart          # App entry point
```

## 12. Technologies Used

| Technology       | Purpose                      |
| ---------------- | ---------------------------- |
| Flutter          | Mobile application framework |
| Dart             | Programming language         |
| shared_preferences| Local data persistence       |

*(Note: No unnecessary external packages were added, keeping the bundle size minimal and performant).*

## 13. Installation & Setup

### Prerequisites
- Flutter SDK (3.x+)
- Dart SDK
- Android Studio / VS Code
- Android emulator or physical device

### Installation
```bash
git clone https://github.com/yourusername/sudoku-quest.git
cd sudoku-quest
flutter pub get
flutter run
```

## 14. Build APK
To generate a release-ready APK for Android:
```bash
flutter build apk --release
```
*The generated APK can be found at: `build/app/outputs/flutter-apk/app-release.apk`*

## 15. Screenshots
*(Add your screenshots here before submission)*

| Welcome Screen | Home Screen | Level Selection | Game Screen | Leaderboard |
| -------------- | ----------- | --------------- | ----------- | ----------- |
| ![Welcome](screenshots/welcome.png) | ![Home](screenshots/home.png) | ![Levels](screenshots/levels.png) | ![Game](screenshots/game.png) | ![Leaderboard](screenshots/leaderboard.png) |

## 16. Testing Scenarios Handled
- **Persistence:** Navigating away, minimizing, or completely killing the app retains correct level unlocks and cumulative score.
- **Duplicate Prevention:** Double-tapping "Check Solution" is caught by an `isCompleted` guard, preventing duplicate leaderboard entries.
- **Responsive Layouts:** Deeply nested UI components (especially the 9x9 board) are strictly constrained using `Expanded`, `AspectRatio`, and calculated dimensions to prevent `RenderFlex` overflows on small devices.

## 17. Assignment Requirements vs Implementation

| Requirement                  | Status | Implementation |
| ---------------------------- | ------ | -------------- |
| Authentication / Player Name | ✅      | Persistent via SharedPreferences |
| Home Screen                  | ✅      | Custom glowing dark UI |
| Sudoku Board                 | ✅      | Dynamic 9x9 grid & Numpad |
| Validation                   | ✅      | Row/Col/Box validation on input |
| Timer                        | ✅      | Active stopwatch via async Timer |
| Level Progression            | ✅      | 10 distinct locked/unlocked levels |
| Scoring                      | ✅      | Exact math applied per requirements |
| Leaderboard                  | ✅      | Top 10 JSON array parsing |
| Local Persistence            | ✅      | SharedPreferences architecture |
| README                       | ✅      | Comprehensive documentation |

## 18. Assumptions & Limitations
- **Sudoku Generation:** Due to time constraints, instead of generating completely random valid Sudoku boards on the fly (which requires heavy backtracking algorithms), the app utilizes a mathematically perfect base board and applies a deterministic "hole-punching" algorithm to simulate 10 distinct, solvable puzzles matching the required difficulty criteria.
- **Offline Only:** The leaderboard is strictly local. Cloud syncing is not implemented.

## 19. Future Enhancements
- Firebase authentication & Global Cloud Leaderboard
- Dynamic randomized puzzle generation
- Sound effects and haptic feedback
- "Hint" system for difficult puzzles
- Daily Sudoku challenges

## 20. Submission Details
**Developer:** [Your Name]  
**Role:** Flutter Developer Intern  
**Company:** Cypher Matrix  
**Project:** Sudoku Quest  
**GitHub:** [GitHub Repository Link]  
**APK:** [Google Drive / APK Link]  

---
*Built with ❤️ in Flutter.*
