# CivicPulse - Flutter Implementation Plan

## 1. Design System & Foundation Strategy

### 1.1 Theme Architecture

```
lib/core/theme/
├── app_colors.dart          # All color tokens
├── app_typography.dart       # Font definitions (Poppins/Inter)
├── app_spacing.dart          # Spacing constants
├── app_radius.dart           # Border radius tokens
├── app_theme.dart            # ThemeData assembly
└── app_shadows.dart          # Elevation/shadow tokens
```

**Tokens Required:**

| Token | Value | Usage |
|-------|-------|-------|
| primary | #2196F3 | CTA, headers, nav active |
| secondary | #FFC107 | Accents, highlights |
| background | #F8F9FA | App background |
| surface | #FFFFFF | Cards, containers |
| textPrimary | #333333 | Headings, body |
| textSecondary | #757575 | Labels, captions |
| success | #4CAF50 | Green heatmap, OK |
| warning | #FF9800 | Yellow heatmap, attention |
| danger | #F44336 | Red heatmap, critical |

### 1.2 Typography Scale

| Style | Font | Weight | Size | Line Height |
|-------|------|--------|------|-------------|
| displayLarge | Poppins | 700 | 32sp | 40 |
| headlineMedium | Poppins | 600 | 24sp | 32 |
| titleLarge | Poppins | 600 | 20sp | 28 |
| titleMedium | Poppins | 500 | 16sp | 24 |
| bodyLarge | Inter | 400 | 16sp | 24 |
| bodyMedium | Inter | 400 | 14sp | 20 |
| labelLarge | Inter | 500 | 14sp | 20 |
| labelSmall | Inter | 400 | 12sp | 16 |

---

## 2. Core Components Library

**Priority Order (build before screens):**

### Tier 1 - Foundation (Required Everywhere)

| Component | Props | States |
|-----------|-------|--------|
| `AppButton` | label, onPressed, variant (primary/secondary/outline/text), size, loading, disabled | default, loading, disabled |
| `AppTextField` | label, hint, controller, error, prefixIcon, suffixIcon, obscureText | default, focused, error, disabled |
| `AppCard` | child, padding, onTap, radius | default, pressed |
| `AppScaffold` | body, appBar, bottomNav, fab | - |

### Tier 2 - Data Display

| Component | Props | States |
|-----------|-------|--------|
| `ShimmerLoading` | width, height, borderRadius | - |
| `StatusBadge` | label, status (success/warning/danger) | - |
| `AvatarWidget` | imageUrl, name, size | loading, fallback |
| `ProgressCard` | title, current, total, progress | - |
| `EmptyState` | icon, title, description, actionLabel, onAction | - |

### Tier 3 - Navigation

| Component | Props | States |
|-----------|-------|--------|
| `AppBottomNav` | items, currentIndex, onTap | - |
| `AppTopTabBar` | tabs, controller | - |
| `AppDrawer` | header, items | - |
| `AppSidebar` | items, collapsed, onToggle | - |

### Tier 4 - Forms & Input

| Component | Props | States |
|-----------|-------|--------|
| `AppDropdown` | label, value, items, onChanged, error | default, error |
| `AppDatePicker` | label, value, onChanged | - |
| `AppSlider` | label, value (1-5), onChanged | - |
| `ImagePickerButton` | onImageSelected, preview | empty, hasImage |

### Tier 5 - Charts & Visualization

| Component | Props | States |
|-----------|-------|--------|
| `PulseRadarChart` | data (4 dimensions) | loading, loaded |
| `ScoreBarChart` | scores[], labels[] | loading, loaded |
| `HeatmapCell` | value, threshold | green/yellow/red |
| `ClassDonutChart` | completed, total | loading, loaded |

### Tier 6 - Specialized

| Component | Props | States |
|-----------|-------|--------|
| `QuizQuestion` | question, options, selectedAnswer, onAnswer | unanswered, answered |
| `LikertScale` | statement, score, onScoreChanged | - |
| `StudentListTile` | name, avatar, statusDot, onTap | - |
| `ActivityCard` | title, date, category, photoUrl, onTap | - |
| `AnecdotalNoteCard` | content, createdAt, teacherName | - |

---

## 3. Screen Execution Sequence

### Phase 1: Project Setup & Auth (Days 1-6)

**Rationale:** Auth is gatekeeper. Build it first to enable all other features.

```
Day 1-2: Project Foundation
├── flutter create civic_pulse
├── configure pubspec.yaml (all deps)
├── setup folder structure
├── build AppTheme with all tokens
└── implement Tier 1-2 core widgets

Day 3-4: Auth Data & Domain
├── Dio client setup with interceptors
├── Auth repository (login, register, logout)
├── Token storage (flutter_secure_storage)
├── AuthNotifier (Riverpod state)
└── GoRouter with auth guards

Day 5-6: Auth UI
├── SplashScreen
├── LoginScreen
├── RegisterScreen (role selection)
├── ClassSetupScreen (teacher creates / student joins)
└── E2E auth flow test
```

### Phase 2: Student App Core (Days 7-13)

**Rationale:** Student home + learning path = core value proposition.

```
Day 7-8: Navigation Shell
├── AppShell with BottomNavBar
├── Route configuration
└── StudentApp (4 tabs structure)

Day 9-10: Student Home & Learning Gallery
├── StudentHomeScreen (greeting, class card, progress)
├── LearningGalleryScreen (material cards grid)
├── ShimmerLoading integration
└── Empty states

Day 11-13: Learning Path Flow
├── PreTestScreen (quiz UI, radio buttons)
├── EBookViewerScreen (PDF viewer)
├── PostTestScreen (quiz + Pre vs Post popup)
├── PulseAssessmentScreen (Likert sliders)
└── Progress tracking integration
```

### Phase 3: Student Activity & Scores (Days 14-19)

**Rationale:** Completes student experience. Activity log = engagement, Scores = motivation.

```
Day 14-15: Activity Log
├── ActivityLogScreen (list, filter by PULSE dim)
├── AddActivityScreen (form + image picker)
└── Activity detail view

Day 16-17: Scores & Feedback
├── ScoresFeedbackScreen (radar chart, bar chart)
├── fl_chart integration
└── Auto-recommendation card

Day 18-19: Student Profile
├── StudentProfileScreen (avatar, biodata)
├── Settings screen
└── Logout flow
```

### Phase 4: Teacher App (Days 20-26)

**Rationale:** Teacher monitors students. Build after student app complete (data exists to show).

```
Day 20-21: Teacher Home & Class Management
├── TeacherHomeScreen (class cards grid)
├── CreateClassScreen (FAB flow)
├── ClassSetupScreen (code generation, share)
└── JoinRequest approval

Day 22-23: Class Detail Dashboard
├── ClassDetailScreen (TopTabBar: Ringkasan, Siswa, Pengaturan)
├── Donut/bar charts (aggregate completion)
└── Student list with status dots

Day 24-26: Student Profile & Anecdotal Notes
├── StudentProfileScreen (teacher view)
├── Test scores detail, PULSE radar history
├── Activity log thumbnails
├── AnecdotalNoteScreen (CRUD)
└── Teacher profile/settings
```

### Phase 5: Web Dashboard (Days 27-33)

**Rationale:** Admin/Teacher analytics. Build after mobile apps proven (understand data model).

```
Day 27-28: Dashboard Shell
├── ResponsiveSidebar (desktop/tablet/mobile)
├── Main content area
├── Web theme adjustments
└── Route guards

Day 29-30: Admin Features
├── SystemOverviewScreen (stats cards)
├── UserManagementScreen (data table, CRUD modals)
└── ContentManagementScreen (hierarchical nav)

Day 31-32: Teacher Analytics
├── ClassAnalyticsScreen (advanced charts)
├── FilterBar (date range, topic)
├── HeatmapTable (green/yellow/red cells)
└── Radar + bar charts

Day 33: Reports & Polish
├── ExportPDF functionality
├── ExportExcel functionality
├── Split-screen anecdotal notes
└── Responsive polish
```

### Phase 6: Integration & Polish (Days 34-39)

**Rationale:** Connect to real backend, fix edge cases, prepare release.

```
Day 34-35: API Integration
├── Connect all screens to Laravel API
├── Error handling (offline, timeout, 401)
├── Retry logic
└── Loading states consistency

Day 36-37: Animations & Polish
├── Skeleton loading everywhere
├── Page transitions
├── Chart animations
└── FAB ripple effects

Day 38-39: Performance & Release
├── Lazy loading images
├── Bundle size optimization
├── Accessibility audit
└── Android APK + Web build
```

---

## 4. State & Routing Approach

### 4.1 Riverpod Architecture

```
Providers:
├── authProvider (AuthNotifier)           → Global auth state
├── userProvider (UserNotifier)           → Current user data
├── classProvider (ClassNotifier)         → Class list
├── materialsProvider (MaterialNotifier) → Learning materials
├── progressProvider (ProgressNotifier)   → Student progress
├── activityProvider (ActivityNotifier)  → Activity logs
├── analyticsProvider (AnalyticsNotifier) → Dashboard data
└── preferencesProvider                  → Local prefs
```

**Pattern:** Each feature gets a Family provider with `.autoDispose` for memory efficiency.

```dart
@riverpod
class MaterialsNotifier extends _$MaterialsNotifier {
  @override
  FutureOr<List<LearningMaterial>> build(String gradeCategory) async {
    return ref.read(materialRepositoryProvider).getByGrade(gradeCategory);
  }
}
```

### 4.2 GoRouter Configuration

```
Routes (GoRouter):
├── /splash → SplashScreen
├── /login → LoginScreen
├── /register → RegisterScreen
├── /register/setup-class → ClassSetupScreen
│
├── /student
│   ├── /home → StudentHomeScreen
│   ├── /learning → LearningGalleryScreen
│   ├── /learning/:id → LearningPathScreen
│   ├── /activities → ActivityLogScreen
│   ├── /activities/add → AddActivityScreen
│   ├── /scores → ScoresFeedbackScreen
│   └── /profile → StudentProfileScreen
│
├── /teacher
│   ├── /home → TeacherHomeScreen
│   ├── /class/:id → ClassDetailScreen
│   ├── /class/:id/students/:studentId → StudentProfileScreen
│   └── /profile → TeacherProfileScreen
│
└── /dashboard
    ├── /login → DashboardLoginScreen
    ├── / → AdminDashboardScreen
    ├── /users → UserManagementScreen
    ├── /content → ContentManagementScreen
    └── /teacher/:id → TeacherAnalyticsScreen
```

**Auth Guards:** Use `redirect` callback in GoRouter.

```dart
router = GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) {
      return authNotifier.user?.role == 'student'
        ? '/student/home'
        : '/teacher/home';
    }
    return null;
  },
);
```

---

## 5. Dependency Priority Matrix

| Package | Purpose | Sprint Needed |
|---------|---------|---------------|
| flutter_riverpod | State management | Sprint 1 |
| go_router | Navigation | Sprint 1 |
| dio + pretty_dio_logger | Network | Sprint 1 |
| flutter_secure_storage | Token storage | Sprint 1 |
| shimmer | Loading states | Sprint 1 |
| fl_chart | Charts/Radar | Sprint 3 |
| cached_network_image | Image caching | Sprint 3 |
| image_picker | Photo upload | Sprint 3 |
| syncfusion_flutter_pdfviewer | E-Book viewer | Sprint 2 |

---

## 6. File Structure Summary

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── widgets/
│   ├── utils/
│   └── network/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── student/
│   │   ├── home/
│   │   ├── learning/
│   │   ├── activities/
│   │   ├── scores/
│   │   └── profile/
│   ├── teacher/
│   │   ├── home/
│   │   ├── class_detail/
│   │   ├── student_profile/
│   │   └── profile/
│   └── dashboard/
│       ├── admin/
│       └── teacher/
│
└── shared/
    ├── models/
    ├── services/
    └── widgets/
```

---

## Milestone Checklist

- [ ] **Sprint 1:** Auth complete (login, register, class setup)
- [ ] **Sprint 2:** Student home + learning path (4-step flow)
- [ ] **Sprint 3:** Student activities + scores visualization
- [ ] **Sprint 4:** Teacher app (class management, anecdotal notes)
- [ ] **Sprint 5:** Web dashboard (admin CMS + teacher analytics)
- [ ] **Sprint 6:** Full API integration + release builds

**Total:** 6 sprints × ~6 days = 36 working days

---

Awaiting approval to proceed with implementation.
