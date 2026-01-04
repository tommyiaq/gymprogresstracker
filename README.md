# Gym Progress Tracker

A Flutter application to help users manage their workout routines, track progress, and visualize statistics.

## Purpose of the App

Gym Progress Tracker is designed to be a comprehensive fitness companion that simplifies workout management. Users can create and customize routines, log their workouts, and gain insights into their progress through detailed statistics. The app aims to provide a seamless and intuitive experience for individuals looking to stay organized and motivated in their fitness journey.

## Features

*   **Routine Management**: Create, edit, and delete custom workout routines with specific exercises, reps, variations, and weights.
*   **Flexible Scheduling**: Assign routines to specific days of the week and define time slots for workouts.
*   **Workout Tracking**: Easily play and log workouts, recording sets, reps, and weights performed.
*   **Progress Visualization**: View detailed statistics and charts to track performance over time, including daily effort and exercise-specific progress.
*   **Data Persistence**: All routines, exercises, and workout logs are saved locally on the device.
*   **Customizable Exercises**: Add and manage a master list of exercises.
*   **Notifications (Planned)**: Future support for scheduling local notifications to remind users of upcoming workouts.

## Architecture

The application follows a clear and modular architecture, separating concerns into `models`, `pages`, `services`, and `widgets` within the `lib` directory.

### Folder Structure

*   `lib/models`: Contains the data structures used throughout the application.
*   `lib/pages`: Houses the main screens/views of the application.
*   `lib/services`: Provides business logic and data management, often interacting with local storage.
*   `lib/widgets`: Contains reusable UI components.

### Models

*   `exercise.dart`: Defines the `Exercise` model, storing just the name of an exercise.
*   `routine.dart`: Represents a `Routine` with an ID, name, a list of `RoutineExercise` objects, scheduled days, time slots, last played timestamp, and notification settings.
*   `routine_exercise.dart`: Links an `Exercise` to a `Routine`, specifying `reps`, `variation`, and `weight` for that exercise within a routine.
*   `workout_log.dart`: Records details of a completed workout session, including a session ID, routine ID, start/end times, and the `RoutineExercise` performed.

### Pages

*   `main.dart`: The entry point of the application, initializing Flutter and running `MyApp`.
*   `home_widget.dart`: The main navigation hub, using a `BottomNavigationBar` to switch between `ManageRoutinesPage`, `PlayPage`, and `StatsPage`.
*   `manage_routines_page.dart`: Displays a list of all created routines, allowing users to play, edit, or delete them.
*   `edit_routine_page.dart`: A form for creating new routines or modifying existing ones, allowing users to define routine names, select exercises, specify days and time slots, and configure notification settings.
*   `play_page.dart`: Presents routines that were last played or are scheduled for the current day, enabling users to start a workout session.
*   `stats_page.dart`: Visualizes workout history through charts and graphs using `fl_chart`, allowing users to filter by time period and exercise. It also persists user preferences for stat filters.
*   `workout_page.dart`: Displays the exercises for a selected routine and allows the user to log their sets, reps, and weights during a workout session. (Inferred from navigation, but not explicitly read).

### Services

*   `exercise_service.dart`: Manages a master list of exercises, handling their loading, saving (using `shared_preferences`), and ensuring uniqueness.
*   `notification_service.dart`: (Currently commented out) Designed to handle scheduling and canceling local notifications for upcoming routines using `flutter_local_notifications` and `timezone`.
*   `routine_service.dart`: Manages the creation, retrieval, updating, and deletion of workout routines, persisting them using `shared_preferences`.
*   `workout_history_service.dart`: Stores and retrieves all completed `WorkoutLog` entries, persisting them using `shared_preferences`.

### Widgets

The application uses several custom reusable widgets to enhance the user experience and maintain a consistent UI:

*   `day_selector.dart`: Allows users to select specific days of the week.
*   `exercise_selector.dart`: Provides an interface for selecting and configuring exercises for a routine.
*   `incrementable_field.dart`: A numeric input field with increment/decrement buttons.
*   `routine_name_field.dart`: A text input field specifically for routine names.
*   `time_slot_selector.dart`: Enables users to define specific time slots for routines.

## Getting Started

To run this project:

1.  Clone the repository:
    ```bash
    git clone https://github.com/tommyiaq/gymprogresstracker.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd gymprogresstracker
    ```
3.  Get Flutter dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application:
    ```bash
    flutter run
    ```
