# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CivicPulse is a Flutter mobile + web application for monitoring PULSE metrics (Participation, Understanding, Learning, Social Engagement) in multicultural citizenship education.

**Platforms**: Android/iOS (mobile), Web (dashboard)
**Backend**: Laravel REST API (currently using mock data/services)
**State Management**: Riverpod with code generation (`riverpod_annotation`)
**Routing**: GoRouter with ShellRoute for bottom navigation

---

## Common Commands

```bash
# Run app
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Generate code (freezed, json_serializable, riverpod_generator)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes during development
flutter pub run build_runner watch

# Analyze code
flutter analyze
```

---

## Architecture

```
lib/
├── main.dart                    # Entry point, ProviderScope wrapper
├── app.dart                     # CivicPulseApp (MaterialApp.router)
├── core/
│   ├── constants/               # Design tokens (colors, typography, spacing, radius, shadows)
│   ├── theme/                   # AppTheme (ThemeData assembly)
│   ├── widgets/                  # Reusable components (AppButton, AppCard, AppTextField, etc.)
│   ├── routes/                  # GoRouter config + AppShell (bottom nav wrapper)
│   └── network/                 # ApiClient (Dio), ApiException, ApiConstants
├── features/
│   ├── auth/                    # Authentication feature
│   │   ├── data/                # Models, repositories
│   │   └── presentation/        # Screens (splash, login, register, class_setup)
│   ├── student/                 # Student mobile app
│   │   ├── home/                # StudentHomeScreen
│   │   ├── learning/            # LearningGalleryScreen, LearningPathScreen
│   │   ├── activities/         # ActivityLogScreen
│   │   ├── scores/              # ScoresFeedbackScreen
│   │   └── profile/             # StudentProfileScreen
│   └── teacher/                 # Teacher mobile app
│       ├── home/                # TeacherHomeScreen
│       ├── class_detail/        # ClassDetailScreen
│       ├── student_profile/     # Teacher view of student
│       └── profile/             # TeacherProfileScreen
└── shared/
    └── services/                # Mock services + mock data (for development)
```

**Pattern**: Feature-first organization following Clean Architecture principles.

---

## Key Patterns

### Auth Flow & Role-Based Routing

`router.dart` handles smart routing based on auth state and user role:
- `/login`, `/register`, `/register/setup-class` → auth routes
- `/student/*` → student shell (4-tab bottom nav)
- `/teacher/*` → teacher shell

Auth state managed by `authNotifierProvider` (`features/auth/presentation/providers/auth_provider.dart`).

### Code Generation

Models use Freezed + json_serializable:
```dart
@freezed
class User with _$User {
  factory User({...}) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

Run `flutter pub run build_runner build` after modifying models.

### Mock Data

Development uses mock services in `lib/shared/services/`:
- `mock_services.dart` → service classes that return mock data
- `mock_data.dart` → static mock data

Real API integration expected in Sprint 6.

### Design Tokens

Located in `lib/core/constants/`:
- `app_colors.dart` → Primary (#2196F3), Secondary (#FFC107), semantic colors
- `app_typography.dart` → Poppins (headings), Inter (body)
- `app_spacing.dart` → Spacing constants
- `app_radius.dart` → Border radius (12-16px for cards/buttons)

---

## PULSE Metrics

Core concept: 4 dimensions for student assessment
- **P**articipation: Active involvement in class activities
- **U**nderstanding: Comprehension of multicultural concepts
- **L**earning: Knowledge acquisition (cognitive scores)
- **S**ocial **E**ngagement: Social interaction quality

Status indicators:
- `green`: All metrics ≥ 3.5
- `yellow`: At least one metric 2.5-3.4
- `red`: At least one metric < 2.5

---

## Current Development State

**Completed Sprints**:
- Sprint 1: Auth (login, register, class setup, mock API)
- Sprint 2: Student Home & Learning Gallery

**In Progress / Planned**:
- Sprint 3: Student Activities, Scores & Profile
- Sprint 4: Teacher Mobile App
- Sprint 5: Web Dashboard
- Sprint 6: Full API Integration

**API Base URL**: `http://localhost:8000/api/v1` (mock, per `api_constants.dart`)

---

## API Endpoints Reference

Key endpoints (see `API_SPECIFICATION.md` for full docs):

| Endpoint | Purpose |
|----------|---------|
| `POST /auth/login` | Login |
| `POST /auth/register` | Register |
| `POST /classes` | Teacher creates class |
| `POST /classes/join` | Student joins class |
| `GET /materials?grade_category=SMP&grade_level=7` | Get learning materials |
| `GET /materials/{id}/questions?type=pre` | Get test questions |
| `POST /materials/{id}/test-response` | Submit test |
| `POST /materials/{id}/pulse-response` | Submit PULSE assessment |
| `GET /students/{id}/scores` | Get student scores (radar + bar chart data) |
| `GET /activities` | Get activity logs |
| `POST /activities` | Create activity log |

---

## Important Files

| File | Purpose |
|------|---------|
| `lib/core/routes/router.dart` | Route config + auth redirect logic |
| `lib/core/theme/app_theme.dart` | ThemeData configuration |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Auth state management |
| `lib/shared/services/mock_services.dart` | Mock service implementations |
| `lib/core/widgets/widgets.dart` | Shared widget exports |