# Fitness Network

Fitness Network is a Flutter-based mobile application designed to help users track their fitness progress, manage workout routines, and log exercise data. The app integrates with Supabase for backend services, including user authentication and data storage.

## Features

- **User Authentication**
- **Exercise Logging**
- **Workout Routine Management**
- **Calendar View for Workout Logs**
- **Profile Management**
- **Settings Page**

## Project Structure
.
├── .dart_tool/
├── .flutter-plugins
├── .flutter-plugins-dependencies
├── .gitignore
├── .idea/
├── .metadata
├── .vscode/
├── analysis_options.yaml
├── android/
├── build/
├── fitness_network.iml
├── ios/
├── lib/
│ ├── add_exercise_page.dart
│ ├── calendar_log_page.dart
│ ├── day_page.dart
│ ├── exercise_list_page.dart
│ ├── home_page.dart
│ ├── login_page.dart
│ ├── main_page.dart
│ ├── profile_page.dart
│ ├── settings_page.dart
│ └── workouts_page.dart
├── linux/
├── macos/
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── test/
├── web/
└── windows/


## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Supabase account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fitness_network.git
2. Navigate to the project directory:
   cd fitness_network
3. Install dependencies:
   flutter pub get

Running the App
Connect a device or start an emulator.

Run the app:
    flutter run
Usage
Authentication
Users can sign up and log in using their email and password. The authentication is handled by Supabase.

Logging Exercises
Users can log their exercises, including details like weight, reps, and sets. The logs are stored in Supabase.

Managing Workout Routines
Users can create and manage their workout routines, including adding and removing exercises.

Viewing Workout Logs
Users can view their workout logs in a calendar view, making it easy to track their progress over time.

Profile Management
Users can update their profile information, including display name, email, and fitness details.

Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

License
This project is licensed under the MIT License.

Contact
For any questions or feedback, please contact yourname@example.com.