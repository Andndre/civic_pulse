# CivicPulse - Rencana Pengembangan Flutter

## 1. Ringkasan Proyek

**CivicPulse** adalah aplikasi mobile dan web berbasis Flutter untuk monitoring metrik PULSE (Participation, Understanding, Learning, Social Engagement) peserta didik dalam konteks pendidikan multikultural dan kewarganegaraan.

- **Platform**: Mobile (Android/iOS) + Web Dashboard
- **Tech Stack**: Flutter (Dart), Laravel (REST API), MySQL
- **State Management**: Riverpod / BLoC
- **Arsitektur**: Clean Architecture + Feature-First Organization

---

## 2. Arsitektur Aplikasi

```
civic_pulse/
├── lib/
│   ├── core/                      # Shared utilities
│   │   ├── constants/             # Colors, typography, strings
│   │   ├── theme/                 # App theme configuration
│   │   ├── widgets/               # Reusable widgets (buttons, cards, etc.)
│   │   ├── utils/                 # Helpers, formatters, validators
│   │   └── network/               # API client, interceptors, errors
│   │
│   ├── features/                  # Feature-first modules
│   │   ├── auth/                  # Authentication feature
│   │   │   ├── data/              # Repositories, data sources, models
│   │   │   ├── domain/            # Entities, use cases, repository interfaces
│   │   │   └── presentation/      # Screens, widgets, controllers
│   │   │
│   │   ├── student/               # Student mobile app feature
│   │   │   ├── home/
│   │   │   ├── learning/          # E-Learning, Pre/Post-Test, PULSE assessment
│   │   │   ├── activities/        # Activity logs & photo upload
│   │   │   ├── scores/            # Radar chart & feedback
│   
│   │   │
│   │   ├── teacher/               # Teacher mobile app feature
│   │   │   ├── home/              # Class list & quick actions
│   │   │   ├── alerts/            # Global notifications
│   │   │   ├── class_detail/      # Class dashboard with top tabs
│   │   │   ├── student_profile/   # Individual student view + anecdotal notes
│   │   │   └── profile/
│   │   │
│   │   └── dashboard/             # Web dashboard (admin & teacher)
│   │       ├── admin/             # System overview, user/content management
│   │       └── teacher/           # Class analytics, reports, observations
│   │
│   ├── shared/                    # Cross-feature shared code
│   │   ├── models/                # Shared DTOs
│   │   ├── services/              # Shared services (auth, storage, etc.)
│   │   └── widgets/              # Shared feature widgets
│   │
│   └── main.dart
```

---

## 3. Spesifikasi Teknis

### 3.1 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Routing
  go_router: ^13.1.0

  # Network
  dio: ^5.4.0
  pretty_dio_logger: ^3.3.0

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  fl_chart: ^0.66.0          # Charts (bar, radar, pie)
  syncfusion_flutter_pdfviewer: ^24.1.0  # In-app PDF viewer
  photo_view: ^0.14.0

  # Forms & Input
  flutter_slidable: ^3.0.1
  image_picker: ^1.0.7
  file_picker: ^6.1.1

  # Utilities
  intl: ^0.18.1
  equatable: ^2.0.5
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # Platform-specific
  url_launcher: ^6.2.4
  share_plus: ^7.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  mockito: ^5.4.4
```

### 3.2 Color Palette

```
Primary Color     : #2196F3 (Material Blue)
Secondary Color  : #FFC107 (Amber) / #00BCD4 (Cyan)
Background       : #F8F9FA (Soft Gray)
Surface          : #FFFFFF (White)
Text Primary     : #333333 (Dark Charcoal)
Text Secondary   : #757575 (Gray)

Semantic Colors (Analytics):
  Success        : #4CAF50 (Green)
  Warning        : #FF9800 (Orange)
  Danger         : #F44336 (Red)
```

### 3.3 Route Map

```
/                          → SplashScreen
/login                     → LoginScreen
/register                  → RegisterScreen
/register/setup-class      → ClassSetupScreen (post-registration flow)

--- STUDENT ROUTES ---
/student/home              → StudentHomeScreen
/student/learning          → LearningGalleryScreen
/student/learning/:id      → LearningPathScreen (PreTest → PDF → PostTest → PULSE)
/student/activities       → ActivityLogScreen
/student/activities/add    → AddActivityScreen
/student/scores           → ScoresFeedbackScreen
/student/profile          → StudentProfileScreen

--- TEACHER ROUTES ---
/teacher/home              → TeacherHomeScreen (class list)
/teacher/alerts           → AlertsScreen
/teacher/profile          → TeacherProfileScreen
/teacher/class/:id        → ClassDetailScreen
/teacher/class/:id/students/:studentId → StudentProfileScreen (teacher view)

--- DASHBOARD ROUTES (Web) ---
/dashboard/login          → DashboardLoginScreen
/dashboard                → AdminDashboardScreen (sidebar layout)
/dashboard/users          → UserManagementScreen
/dashboard/content        → ContentManagementScreen
/dashboard/teacher/:id     → TeacherAnalyticsScreen
```

---

## 4. Perencanaan Sprint

### Sprint 1: Fondasi Proyek & Autentikasi (6 hari)

**Tujuan**: Menyiapkan proyek, arsitektur dasar, autentikasi lengkap untuk Siswa & Guru.

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | Setup Proyek | Inisialisasi Flutter project, configure pubspec.yaml, setup folder structure, configure theme (colors, typography), buat base widgets (AppButton, AppCard, AppTextField) |
| 3 | Auth Data Layer | API client (Dio setup), auth repository, login/register models, token storage (flutter_secure_storage) |
| 4 | Auth Domain Layer | Use cases (Login, Register, Logout), auth state management (Riverpod), guarded routes |
| 5 | Auth UI Layer | LoginScreen, RegisterScreen, ClassSetupScreen (guru buat kelas / siswa input kode kelas), splash screen |
| 6 | Testing & Polish | Unit test auth, integrasi auth flow end-to-end, error handling |

**Fitur Sprint 1**:
- Login dengan email/password
- Registrasi dengan pilihan role (Siswa/Guru)
- Post-registration: Guru buat kelas → dapat Kode Kelas; Siswa input Kode Kelas
- Smart routing setelah login (Siswa → home, Guru → home, Admin → dashboard)
- Logout dengan token cleanup

---

### Sprint 2: Aplikasi Mobile Siswa - Beranda & Belajar (7 hari)

**Tujuan**: Student mobile app core — home screen dan modul e-learning lengkap.

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | Navigation Setup | Bottom Navigation Bar (4 tab: Home, Belajar, Aktivitas, Skor, Profil), AppShell, scaffold configuration |
| 3 | Student Home Screen | Greeting + class card widget, empty state (belum gabung kelas), progress widget (jumlah materi), notification bell icon |
| 4 | Learning Gallery | Material cards grid, pull-to-refresh, shimmer loading, empty state, API integration untuk fetch materi berdasarkan jenjang |
| 5 | Learning Path - PreTest | Quiz UI (radio buttons, timer, progress indicator), soal pilihan ganda, scoring logic, auto-submit |
| 6 | Learning Path - E-Book & PostTest | In-app PDF viewer (syncfusion_flutter_pdfviewer atau flutter_pdfview), Post-Test quiz dengan comparison popup Pre vs Post score |
| 7 | PULSE Assessment & Polish | Skala Likert slider (1-5) dengan touch target 48dp, submit → return to gallery, mark materi as completed |

**Fitur Sprint 2**:
- Bottom navigation dengan state aktif
- Home screen dengan empty state dan progress widget
- Galeri materi berdasarkan jenjang SMP/SMA
- Full learning path: Pre-Test → E-Book → Post-Test → PULSE Assessment
- Completion tracking per materi

---

### Sprint 3: Aplikasi Mobile Siswa - Aktivitas, Skor & Profil (6 hari)

**Tujuan**: Activity logging, score visualization, dan profile management untuk Siswa.

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | Activity Log Screen | Scrollable list, filterable by PULSE dimension, timestamp display, empty state, FAB button |
| 3 | Add Activity Screen | Form: judul, tanggal (date picker), kategori PULSE dropdown, image picker (camera + gallery), preview image, submit |
| 4 | Scores Screen | Radar chart (fl_chart) untuk 4 dimensi PULSE, bar chart untuk kognitif, animated data, color-coded metrics |
| 5 | Smart Recommendation | Auto-generated text recommendation based on scores (rule-based or simple heuristic), display in card widget |
| 6 | Profile Screen | Avatar, biodata, settings button, logout |

**Fitur Sprint 3**:
- Digital diary / activity log dengan foto bukti
- Radar chart + bar chart visualisasi PULSE score
- Auto-generated recommendation text
- Image upload untuk bukti aktivitas

---

### Sprint 4: Aplikasi Mobile Guru (7 hari)

**Tujuan**: Teacher mobile app — class management dan student monitoring.

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | Teacher Home & FAB | Class card grid layout, FAB to create new class (jenjang, tingkat), empty state |
| 3 | Class Setup & Share | Create class form, auto-generate unique class code, share via WhatsApp (share_plus), edit class settings |
| 4 | Class Detail - Dashboard | Top Tab Bar (Ringkasan, Siswa, Pengaturan), Donut/bar chart untuk ringkasan performa kelas, agregat ketuntasan E-Learning |
| 5 | Class Detail - Students | Student name list dengan color dot indicators (Green/Yellow/Red), tap → student profile |
| 6 | Student Profile (Teacher View) | Detail nilai tes, PULSE radar chart history, activity log thumbnails, anecdotal notes list |
| 7 | Anecdotal Notes | "+ Tambah Catatan Observasi" form, text input, save with timestamp, list view of past notes, edit/delete |

**Fitur Sprint 4**:
- Manajemen kelas (create, view, share code)
- Class detail dashboard dengan top tab bar
- Student list dengan status indicator
- Individual student profile (teacher view)
- Anecdotal notes (CRUD)

---

### Sprint 5: Web Dashboard - Admin & Teacher Analytics (7 hari)

**Tujuan**: Responsive web dashboard untuk Admin (CMS) dan Guru (Analytics).

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | Dashboard Shell | Sidebar navigation layout, responsive sidebar (collapsible → hamburger menu on tablet), main content area, theming for web |
| 3 | Admin: System Overview | Stats cards (Total Guru, Siswa Aktif, Materi), simple bar charts, recent activity feed |
| 4 | Admin: User Management | Data table (sortable, paginated), row actions (add, verify, edit, disable), search/filter, CRUD modal dialogs |
| 5 | Admin: CMS E-Learning | Hierarchical navigation (SMP/SMA → Kelas 7-12), drag-drop area (simulated), PDF upload, Quiz Builder (dynamic A/B/C/D options), PULSE Likert instrument builder |
| 6 | Teacher: Class Analytics | Advanced charts (fl_chart radar + bar), filter bar (date range, topic), data table with heatmap coloring (green/yellow/red transparent bg) |
| 7 | Teacher: Reports & Observations | Export PDF button (pdf package), Export Excel (excel package), Split-screen observation panel, timeline sidebar with thumbnails |

**Fitur Sprint 5**:
- Responsive sidebar (desktop → icons only, tablet → hamburger)
- Admin: user management table + CMS content builder
- Teacher: class analytics, heatmap table, date filtering
- Export laporan (PDF + Excel)
- Split-screen anecdotal notes di web

---

### Sprint 6: Integrasi Backend & Polish (6 hari)

**Tujuan**: Koneksi penuh ke Laravel API, push notifications, final polish, dan build release.

| Hari | Deliverable | Detail |
|------|-------------|--------|
| 1-2 | API Integration | Koneksi semua screens ke Laravel REST API, error handling (offline, timeout, 401/403), retry logic, loading states |
| 3 | Push Notifications | Firebase Cloud Messaging (FCM) setup, notification handling, notification bell di Home screen, deep linking |
| 4 | Animations & Polish | Skeleton loading (shimmer) di semua list, page transition animations, chart animations, FAB ripple effects, empty state illustrations |
| 5 | Performance & UX | Lazy loading images, pagination, bundle size optimization, dark mode preparation (optional), accessibility audit (contrast, touch targets) |
| 6 | Build & Release | Android APK build, iOS build (jika Mac), web build (`flutter build web`), testing on physical device, release checklist |

**Fitur Sprint 6**:
- Full API integration (Laravel backend)
- Push notifications via FCM
- Skeleton loading animations
- Performance optimization
- Android APK release ready

---

## 5. Milestone Summary

```
Sprint 1 ✅  Fondasi & Autentikasi
Sprint 2 ✅  Siswa: Beranda & Belajar
Sprint 3 ✅  Siswa: Aktivitas, Skor & Profil
Sprint 4 ✅  Guru Mobile App
Sprint 5 ✅  Web Dashboard
Sprint 6 ✅  Integrasi & Polish

Total Estimasi: 6 sprints × 6-7 hari = ±39 hari kerja
```

---

## 6. Catatan Teknis Tambahan

### 6.1 State Management Strategy

```
Auth State          → Riverpod (AuthNotifier - global)
Student Data       → Riverpod (StudentRepository + Family)
Teacher Data       → Riverpod (TeacherRepository + Family)
Learning Materials → Riverpod (MaterialRepository + Family)
Analytics Data     → Riverpod (AnalyticsRepository + Family)
Local Preferences  → Riverpod (SharedPrefsProvider)
```

### 6.2 API Endpoints (Referensi untuk Laravel Backend)

```
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/logout

GET    /api/classes
POST   /api/classes
GET    /api/classes/{id}
POST   /api/classes/join

GET    /api/students/{id}/profile
GET    /api/students/{id}/scores
GET    /api/students/{id}/activities
GET    /api/students/{id}/pulse
GET    /api/students/{id}/anecdotal-notes
POST   /api/students/{id}/anecdotal-notes

GET    /api/materials?grade={grade}
GET    /api/materials/{id}
GET    /api/materials/{id}/questions?type={pre|post}
POST   /api/materials/{id}/test-response
POST   /api/materials/{id}/pulse-response

GET    /api/activities
POST   /api/activities
GET    /api/activities/{id}

GET    /api/dashboard/stats (admin)
GET    /api/dashboard/users (admin)
GET    /api/dashboard/analytics?class_id={id}&date_from={}&date_to={} (teacher)
```

### 6.3 Offline Strategy (Phase 2)

- Cache materi yang sudah di-download menggunakan `flutter_cache_manager`
- Queue activity logs saat offline → sync saat online
- Local score caching untuk dashboard

---

## 7. Referensi Desain

| Aspek | Spesifikasi |
|-------|------------|
| Border Radius | 12px - 16px (cards, buttons, forms) |
| Touch Target | Minimum 48×48 dp |
| Bottom Nav Icons | Filled (#2196F3) saat aktif, Outlined gray saat inaktif |
| Loading State | Shimmer animation (replace spinner) |
| FAB Color | #2196F3 |
| Semantic Heatmap | Green #4CAF50 (opacity 20-30%), Orange #FF9800, Red #F44336 |
| Typography | Poppins (headings), Inter/Roboto (body) |
| Web Sidebar | Collapsible, dark or #2196F3 background |
| Hover States | Light color change on mouse hover (web) |

---

*Dokumen ini adalah rencana pengembangan awal dan dapat disesuaikan selama proses development berlangsung.*
