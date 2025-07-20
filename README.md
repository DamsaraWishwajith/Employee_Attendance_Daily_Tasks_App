# Attendify  - Employee Attendance & Tasks App

Attendify  is a Flutter-based application designed to manage employee attendance and tasks efficiently. This repository contains the source code for a cross-platform app that runs on both web and Android platforms.

## How to Run

### Prerequisites
- **Flutter SDK**: Version 3.0 or higher
- **Dart**: Included with Flutter
- **Android Studio**: For Android emulator or physical device testing
- **Web Browser**: Chrome recommended for web deployment
- **IDE**: VS Code or Android Studio with Flutter and Dart plugins installed
- **Git**: To clone the repository

### Running on Android
1. **Clone the Repository**:
   ```bash
   git clone <repository-link>
   cd Attendify 
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Connect a Device**:
   - Connect an Android device via USB with developer mode enabled or launch an emulator in Android Studio.
   - Verify device detection:
     ```bash
     flutter devices
     ```
4. **Run the App**:
   ```bash
   flutter run
   ```
   - Select the connected Android device or emulator when prompted.
5. **Build APK** (optional for distribution):
   ```bash
   flutter build apk --release
   ```
   - The APK will be located in `build/app/outputs/flutter-apk/app-release.apk`.

### Running on Web
1. **Clone the Repository** (if not already done):
   ```bash
   git clone <repository-link>
   cd Attendify 
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Enable Web Support** (if not already enabled):
   ```bash
   flutter config --enable-web
   ```
4. **Run the App**:
   ```bash
   flutter run -d chrome
   ```
   - This will open the app in the Chrome browser.
5. **Build for Web** (optional for deployment):
   ```bash
   flutter build web
   ```
   - The web build will be generated in `build/web`. Host these files on a web server for deployment.

## Tools and Packages Used
The following packages were selected for their functionality and compatibility with Flutter:

- **flutter**: Core framework for building the cross-platform UI, providing widgets like `Scaffold`, `AppBar`, and `ListView`.
- **shared_preferences**: Used for local storage of user data, attendance records, and tasks. Chosen for its simplicity and cross-platform support.
- **intl**: Handles date and time formatting (e.g., `DateFormat` for consistent date display). Selected for its robust and flexible formatting options.
- **logger**: Facilitates debugging by logging errors and events. Chosen for its detailed and customizable output.
- **Material Design**: Leveraged for UI components to ensure a consistent and modern look across platforms.

## Assumptions
- **Offline Functionality**: The app uses `shared_preferences` for data persistence, assuming no backend or network connectivity is required.
- **Single-User Focus**: Designed for individual employee use, with no multi-user support or authentication system.
- **Task Management Scope**: Tasks include fields for name, date, priority, and status, with no additional features like categories or assignees.
- **Attendance Logic**: Attendance is tracked daily with check-in/check-out times and statuses (Present, Incomplete, Absent).
- **Assets**: Assumes `assets/1.jpg` and `assets/2.jpg` are included in the project and declared in `pubspec.yaml`.
- **No Server Dependency**: All data is stored locally, making the app suitable for offline use.

## Bonus Features
- **Responsive Design**: The app adapts to different screen sizes for both web and mobile platforms.
- **Error Handling**: Comprehensive error handling with `try-catch` blocks and user notifications via `ScaffoldMessenger` for failed operations.
- **Interactive Task Dialog**: The task addition dialog includes a date picker and dropdowns for priority and status, enhancing user experience.
- **Color-Coded Status**: Attendance status is visually indicated (green for Present, red for Absent) for clarity.
- **Data Persistence**: Both tasks and attendance records persist across app sessions using `shared_preferences`.

## Total Time Taken
The development of Attendify took approximately **18 hours**, broken down as follows:
- Project setup and dependency configuration: 2 hours
- UI design and implementation: 5 hours
- Attendance and task management logic: 7 hours
- Testing and debugging: 4 hours
