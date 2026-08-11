# TaskFlow Flutter

A working Flutter task-management app with an offline-first data layer, persistent local storage, searchable and filterable task lists, task creation/editing, priorities, due dates, tags, completion tracking, and an HTTP service ready for Laravel synchronization.

## Implemented product features

| Feature | Details |
|---|---|
| Dashboard | Completion ring, open-task count, and a focused daily overview |
| Task lifecycle | Create, edit, complete, and delete tasks |
| Organization | Search by title, description, or tags; filter by all/open/completed |
| Planning | Due dates, priorities, descriptions, and tag chips |
| Persistence | Tasks survive app restarts through SharedPreferences |
| Integration boundary | `TaskApiService` provides typed HTTP calls for a Laravel `/tasks` API |
| Quality | Serialization unit test and separated model/provider/service layers |

## Stack

- Flutter / Dart 3
- Material 3
- Provider for reactive state management
- SharedPreferences for offline persistence
- HTTP for API integration

## Run locally

Install the Flutter SDK, then run:

```bash
git clone https://github.com/ahmedemadm90/taskflow-flutter.git
cd taskflow-flutter
flutter pub get
flutter test
flutter run
```

The app works without a server by using local storage. To connect it to a Laravel deployment, configure the `baseUrl` in `TaskApiService` and set a Sanctum token with `setToken`.

## Source layout

```text
lib/
├── main.dart                         App bootstrap and Material 3 theme
├── models/task.model.dart             Serializable task domain model
├── providers/task_provider.dart       Filters, CRUD, persistence, and derived metrics
├── services/local_task_store.dart     SharedPreferences adapter
├── services/task_api_service.dart     HTTP integration boundary
└── views/home_view.dart               Dashboard, list, forms, and task actions
test/task_model_test.dart              Serialization test
```

## Author

Ahmed Emad — Backend, Mobile, and Automation Developer.
