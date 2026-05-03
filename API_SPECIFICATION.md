# CivicPulse API Specification

## 1. Overview

**Base URL**: `https://api.civicpulse.id/v1` (development: `http://localhost:8000/api/v1`)

**Authentication**: Bearer Token (Laravel Sanctum)

**Content-Type**: `application/json`

**Response Format**: Consistent JSON envelope

```
// Success Response
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}

// Error Response
{
  "success": false,
  "message": "Error description",
  "errors": { ... }
}
```

**Standard Status Codes**: `200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `422 Validation Error`, `500 Internal Server Error`

---

## 2. Authentication

### 2.1 Register

```
POST /auth/register
```

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Full name (3-100 chars) |
| `email` | string | Yes | Valid email address |
| `password` | string | Yes | Min 8 chars, 1 uppercase, 1 number |
| `password_confirmation` | string | Yes | Must match password |
| `role` | enum | Yes | `student` atau `teacher` |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Budi Santoso",
      "email": "budi@email.com",
      "role": "student"
    },
    "token": "1|abc123xyz..."
  }
}
```

---

### 2.2 Login

```
POST /auth/login
```

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Registered email |
| `password` | string | Yes | Account password |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Budi Santoso",
      "email": "budi@email.com",
      "role": "student",
      "class_id": 3,
      "grade_level": "VII",
      "grade_category": "SMP"
    },
    "token": "2|abc123xyz...",
    "redirect_to": "/student/home"
  }
}
```

**Redirect Logic:**

| Role | `redirect_to` |
|------|---------------|
| `student` (sudah ada class) | `/student/home` |
| `student` (belum ada class) | `/register/setup-class` |
| `teacher` | `/teacher/home` |
| `admin` | `/dashboard` |

---

### 2.3 Logout

```
POST /auth/logout
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 2.4 Get Current User

```
GET /auth/me
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Budi Santoso",
    "email": "budi@email.com",
    "role": "student",
    "avatar_url": null,
    "created_at": "2026-01-15T08:30:00Z",
    "profile": {
      "class_id": 3,
      "class_name": "VII-A",
      "class_code": "KLS-7A-X9K",
      "grade_level": "VII",
      "grade_category": "SMP"
    }
  }
}
```

---

## 3. Class Management

### 3.1 Teacher: Create Class

```
POST /classes
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Class name (e.g., "VII-A") |
| `grade_category` | enum | Yes | `SMP` atau `SMA` |
| `grade_level` | integer | Yes | 7-12 |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Class created successfully",
  "data": {
    "id": 5,
    "name": "VII-A",
    "grade_category": "SMP",
    "grade_level": 7,
    "class_code": "KLS-7A-X9K",
    "teacher_id": 2,
    "student_count": 0,
    "created_at": "2026-01-20T10:00:00Z"
  }
}
```

---

### 3.2 Teacher: Get My Classes

```
GET /classes
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `per_page` | integer | 15 | Items per page |
| `page` | integer | 1 | Current page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "classes": [
      {
        "id": 5,
        "name": "VII-A",
        "grade_category": "SMP",
        "grade_level": 7,
        "class_code": "KLS-7A-X9K",
        "student_count": 32,
        "created_at": "2026-01-20T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_items": 1,
      "per_page": 15
    }
  }
}
```

---

### 3.3 Get Class Detail

```
GET /classes/{id}
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": 5,
    "name": "VII-A",
    "grade_category": "SMP",
    "grade_level": 7,
    "class_code": "KLS-7A-X9K",
    "teacher": {
      "id": 2,
      "name": "Dr. Anwar"
    },
    "student_count": 32,
    "materials_completed_avg": 68.5,
    "pulse_avg": {
      "participation": 3.8,
      "understanding": 4.1,
      "learning": 3.5,
      "social_engagement": 3.9
    },
    "students_summary": [
      {
        "id": 1,
        "name": "Budi Santoso",
        "status": "green"
      }
    ]
  }
}
```

> **Status Indicator Rules:**
> - `green`: All metrics above threshold (default 3.5)
> - `yellow`: At least one metric between 2.5 - 3.5
> - `red`: At least one metric below 2.5

---

### 3.4 Student: Join Class

```
POST /classes/join
```

**Headers:** `Authorization: Bearer {token}` (role: student)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `class_code` | string | Yes | 6-20 chars alphanumeric |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Successfully joined class VII-A",
  "data": {
    "class_id": 5,
    "class_name": "VII-A",
    "class_code": "KLS-7A-X9K",
    "grade_category": "SMP",
    "grade_level": 7
  }
}
```

**Error Response (404):**

```json
{
  "success": false,
  "message": "Class code not found"
}
```

**Error Response (409):**

```json
{
  "success": false,
  "message": "You are already a member of this class"
}
```

---


```

---

## 4. Student Profile & Scores

### 4.1 Get Student Profile

```
GET /students/{id}
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Budi Santoso",
    "email": "budi@email.com",
    "avatar_url": "https://cdn.civicpulse.id/avatars/budi.jpg",
    "grade_category": "SMP",
    "grade_level": 7,
    "class": {
      "id": 5,
      "name": "VII-A",
      "teacher_name": "Dr. Anwar"
    },
    "stats": {
      "materials_completed": 5,
      "total_materials": 12,
      "activities_logged": 8,
      "tests_taken": 10
    }
  }
}
```

---

### 4.2 Get Student Scores

```
GET /students/{id}/scores
```

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | enum | `all` | `week`, `month`, `semester`, `all` |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "cognitive": {
      "pre_test_avg": 65.0,
      "post_test_avg": 82.5,
      "improvement": 17.5,
      "history": [
        {
          "material_id": 3,
          "material_title": " Toleransi Beragama",
          "pre_score": 60,
          "post_score": 85,
          "completed_at": "2026-01-25T14:00:00Z"
        }
      ]
    },
    "pulse": {
      "current": {
        "participation": 3.8,
        "understanding": 4.2,
        "learning": 3.5,
        "social_engagement": 4.0
      },
      "history": [
        {
          "period": "2026-01",
          "participation": 3.8,
          "understanding": 4.2,
          "learning": 3.5,
          "social_engagement": 4.0
        }
      ]
    },
    "overall": {
      "total_score": 78.4,
      "grade": "B+",
      "trend": "up"
    }
  }
}
```

---

### 4.3 Get Student PULSE Assessment History

```
GET /students/{id}/pulse
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "current": {
      "participation": 3.8,
      "understanding": 4.2,
      "learning": 3.5,
      "social_engagement": 4.0,
      "last_assessed_at": "2026-02-15T10:00:00Z"
    },
    "history": [
      {
        "material_id": 5,
        "material_title": "Keberagaman Budaya",
        "assessed_at": "2026-02-15T10:00:00Z",
        "scores": {
          "participation": 4,
          "understanding": 4,
          "learning": 3,
          "social_engagement": 4
        }
      }
    ]
  }
}
```

---

### 4.4 Get Student Activities

```
GET /students/{id}/activities
```

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `category` | enum | all | `participation`, `understanding`, `learning`, `social_engagement` |
| `location` | enum | all | `rumah`, `sekolah`, `kelas`, `masyarakat` |
| `per_page` | integer | 15 | Items per page |
| `page` | integer | 1 | Current page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "activities": [
      {
        "id": 1,
        "title": "Piket Kelas",
        "category": "participation",
        "location": "kelas",
        "date": "2026-02-10",
        "photo_url": "https://cdn.civicpulse.id/activities/1.jpg",
        "created_at": "2026-02-10T16:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "total_items": 18
    }
  }
}
```

---

### 4.5 Get Student Anecdotal Notes

```
GET /students/{id}/anecdotal-notes
```

**Headers:** `Authorization: Bearer {token}` (role: teacher atau admin)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `per_page` | integer | 15 | Items per page |
| `page` | integer | 1 | Current page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "notes": [
      {
        "id": 1,
        "content": "Budi terlihat pasif dan kurang membaur di kelompok saat materi toleransi",
        "category": "social_engagement",
        "created_by": {
          "id": 2,
          "name": "Dr. Anwar"
        },
        "created_at": "2026-02-12T09:30:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

---

## 5. Learning Materials

### 5.1 Get Materials List

```
GET /materials
```

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `grade_category` | enum | Yes | `SMP` atau `SMA` |
| `grade_level` | integer | Yes | 7-12 |
| `per_page` | integer | 15 | Items per page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "materials": [
      {
        "id": 1,
        "title": "Keberagaman Budaya Indonesia",
        "description": "Memahami kekayaan budaya Nusantara",
        "thumbnail_url": "https://cdn.civicpulse.id/thumbnails/1.jpg",
        "grade_category": "SMP",
        "grade_level": 7,
        "status": "locked",
        "learning_path_status": {
          "pre_test": "completed",
          "ebook": "completed",
          "post_test": "in_progress",
          "pulse": "locked"
        }
      }
    ],
    "pagination": { ... }
  }
}
```

> **Status Rules:**
> - `locked`: Belum bisa diakses (materi sebelumnya belum selesai)
> - `available`: Bisa diakses untuk memulai
> - `in_progress`: Sedang dikerjakan
> - `completed`: Sudah selesai semua tahap

---

### 5.2 Get Material Detail

```
GET /materials/{id}
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Keberagaman Budaya Indonesia",
    "description": "Memahami kekayaan budaya Nusantara",
    "thumbnail_url": "https://cdn.civicpulse.id/thumbnails/1.jpg",
    "grade_category": "SMP",
    "grade_level": 7,
    "estimated_duration_minutes": 45,
    "learning_path_status": {
      "pre_test": "completed",
      "ebook": "completed",
      "post_test": "available",
      "pulse": "locked"
    },
    "student_score": {
      "pre_test_score": 70,
      "post_test_score": 85,
      "pulse_scores": null
    }
  }
}
```

---

### 5.3 Get Pre-Test Questions

```
GET /materials/{id}/questions
```

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | enum | Yes | `pre` atau `post` |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "material_id": 1,
    "type": "pre",
    "questions": [
      {
        "id": 10,
        "question_number": 1,
        "content": "Apa yang dimaksud dengan keberagaman budaya?",
        "options": {
          "A": "Keseragaman suku bangsa",
          "B": "Ragaman suku, bahasa, dan adat istiadat",
          "C": "Perbedaan agama saja",
          "D": "Satu budaya dominan"
        }
      }
    ],
    "total_questions": 10
  }
}
```

---

### 5.4 Submit Test Response

```
POST /materials/{id}/test-response
```

**Headers:** `Authorization: Bearer {token}` (role: student)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | enum | Yes | `pre` atau `post` |
| `answers` | array | Yes | Array of answer objects |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Test submitted successfully",
  "data": {
    "type": "post",
    "total_questions": 10,
    "correct_answers": 8,
    "score": 80,
    "comparison": {
      "pre_score": 70,
      "post_score": 80,
      "improvement": 10
    }
  }
}
```

---

### 5.5 Get E-Book PDF URL

```
GET /materials/{id}/ebook
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "material_id": 1,
    "title": "Keberagaman Budaya Indonesia",
    "pdf_url": "https://cdn.civicpulse.id/ebooks/1.pdf",
    "page_count": 24,
    "expires_at": "2026-02-15T23:59:59Z"
  }
}
```

---

### 5.6 Get PULSE Instrument (Likert Scale)

```
GET /materials/{id}/pulse-instrument
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "material_id": 1,
    "material_title": "Keberagaman Budaya Indonesia",
    "statements": [
      {
        "id": 1,
        "dimension": "participation",
        "statement": "Saya ikut aktif dalam diskusi kelas"
      },
      {
        "id": 2,
        "dimension": "understanding",
        "statement": "Saya memahami pentingnya toleransi antarbudaya"
      },
      {
        "id": 3,
        "dimension": "learning",
        "statement": "Saya antusias mempelajari budaya lain"
      },
      {
        "id": 4,
        "dimension": "social_engagement",
        "statement": "Saya menghargai pendapat yang berbeda dari teman"
      }
    ],
    "scale_description": {
      "1": "Sangat Tidak Setuju",
      "2": "Tidak Setuju",
      "3": "Netral",
      "4": "Setuju",
      "5": "Sangat Setuju"
    }
  }
}
```

---

### 5.7 Submit PULSE Response

```
POST /materials/{id}/pulse-response
```

**Headers:** `Authorization: Bearer {token}` (role: student)

**Request Body:**

```json
{
  "responses": [
    { "statement_id": 1, "score": 4 },
    { "statement_id": 2, "score": 5 },
    { "statement_id": 3, "score": 3 },
    { "statement_id": 4, "score": 4 }
  ]
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "PULSE assessment submitted",
  "data": {
    "material_id": 1,
    "scores": {
      "participation": 4.0,
      "understanding": 5.0,
      "learning": 3.0,
      "social_engagement": 4.0
    },
    "material_status": "completed"
  }
}
```

---

## 6. Activity Logs

### 6.1 Get Activity Logs (Student's Own)

```
GET /activities
```

**Headers:** `Authorization: Bearer {token}` (role: student)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `category` | enum | all | `participation`, `understanding`, `learning`, `social_engagement` |
| `location` | enum | all | `rumah`, `sekolah`, `kelas`, `masyarakat` |
| `per_page` | integer | 15 | Items per page |
| `page` | integer | 1 | Current page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "activities": [
      {
        "id": 1,
        "title": "Piket Kelas",
        "category": "participation",
        "location": "kelas",
        "date": "2026-02-10",
        "photo_url": "https://cdn.civicpulse.id/activities/1.jpg",
        "created_at": "2026-02-10T16:00:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

---

### 6.2 Create Activity Log

```
POST /activities
```

**Headers:** `Authorization: Bearer {token}` (role: student)

**Request Body (multipart/form-data):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Judul kegiatan (3-100 chars) |
| `date` | string | Yes | Tanggal (format: YYYY-MM-DD) |
| `category` | enum | Yes | `participation`, `understanding`, `learning`, `social_engagement` |
| `location` | enum | Yes | `rumah`, `sekolah`, `kelas`, `masyarakat` |
| `photo` | file | No | Gambar bukti (max 5MB, jpeg/png) |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Activity logged successfully",
  "data": {
    "id": 5,
    "title": "Piket Kelas",
    "category": "participation",
    "date": "2026-02-10",
    "photo_url": "https://cdn.civicpulse.id/activities/5.jpg",
    "created_at": "2026-02-10T16:00:00Z"
  }
}
```

---

### 6.3 Get Activity Detail

```
GET /activities/{id}
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Piket Kelas",
    "category": "participation",
    "date": "2026-02-10",
    "photo_url": "https://cdn.civicpulse.id/activities/1.jpg",
    "student": {
      "id": 1,
      "name": "Budi Santoso"
    },
    "created_at": "2026-02-10T16:00:00Z"
  }
}
```

---

### 6.4 Delete Activity Log

```
DELETE /activities/{id}
```

**Headers:** `Authorization: Bearer {token}` (role: student, owner only)

**Success Response (200):**

```json
{
  "success": true,
  "message": "Activity deleted successfully"
}
```

---

## 7. Anecdotal Notes

### 7.1 Create Anecdotal Note

```
POST /students/{student_id}/anecdotal-notes
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, assigned to student's class)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Isi catatan (10-1000 chars) |
| `category` | enum | No | Kategori PULSE terkait |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Note saved successfully",
  "data": {
    "id": 3,
    "content": "Siti sangat aktif membantu teman yang kesulitan dalam diskusi kelompok",
    "category": "participation",
    "created_by": {
      "id": 2,
      "name": "Dr. Anwar"
    },
    "created_at": "2026-02-13T11:00:00Z"
  }
}
```

---

### 7.2 Update Anecdotal Note

```
PUT /anecdotal-notes/{id}
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, author only)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Isi catatan (10-1000 chars) |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Note updated successfully"
}
```

---

### 7.3 Delete Anecdotal Note

```
DELETE /anecdotal-notes/{id}
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, author only)

**Success Response (200):**

```json
{
  "success": true,
  "message": "Note deleted successfully"
}
```

---

## 8. Teacher Alerts / Notifications

### 8.1 Get Alerts

```
GET /alerts
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `priority` | enum | all | `critical`, `warning`, `normal` |
| `per_page` | integer | 20 | Items per page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": 1,
        "type": "score_drop",
        "priority": "critical",
        "title": "Skor Interaksi Sosial Menurun Drastis",
        "description": "Rudi Santoso - skor social_engagement turun dari 4.0 ke 2.1 minggu ini",
        "student": {
          "id": 8,
          "name": "Rudi Santoso",
          "avatar_url": null
        },
        "class": {
          "id": 5,
          "name": "VII-A"
        },
        "created_at": "2026-02-13T08:00:00Z",
        "action_url": "/teacher/class/5/students/8"
      }
    ],
    "unread_count": 3,
    "pagination": { ... }
  }
}
```

> **Alert Types & Rules (Rules Engine):**
> - `score_drop`: Jika skor PULSE turun >1.0 dalam 1 minggu
> - `inactive_student`: Jika siswa tidak login >7 hari
> - `test_failed`: Jika post-test score < 50

---

### 8.2 Mark Alert as Read

```
PUT /alerts/{id}/read
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Success Response (200):**

```json
{
  "success": true,
  "message": "Alert marked as read"
}
```

---

### 8.3 Mark All Alerts as Read

```
PUT /alerts/read-all
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Success Response (200):**

```json
{
  "success": true,
  "message": "All alerts marked as read"
}
```

---

## 9. Web Dashboard - Admin

### 9.1 Admin: System Overview Stats

```
GET /dashboard/admin/stats
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "total_teachers": 45,
    "total_students": 1280,
    "total_classes": 62,
    "total_materials": 48,
    "active_today": {
      "students": 890,
      "teachers": 38
    },
    "completion_rate_avg": 68.5,
    "recent_registrations": [
      {
        "id": 15,
        "name": "Siti Aminah",
        "role": "student",
        "created_at": "2026-02-13T09:00:00Z"
      }
    ]
  }
}
```

---

### 9.2 Admin: User Management List

```
GET /dashboard/admin/users
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `role` | enum | all | `student`, `teacher`, `admin` |
| `search` | string | - | Search by name/email |
| `per_page` | integer | 20 | Items per page |
| `page` | integer | 1 | Current page |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 2,
        "name": "Dr. Anwar",
        "email": "anwar@sekolah.sch.id",
        "role": "teacher",
        "email_verified_at": "2026-01-01T00:00:00Z",
        "is_active": true,
        "created_at": "2025-08-01T00:00:00Z",
        "stats": {
          "classes_count": 3,
          "students_count": 96
        }
      }
    ],
    "pagination": { ... }
  }
}
```

---

### 9.3 Admin: Create User

```
POST /dashboard/admin/users
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Full name |
| `email` | string | Yes | Valid email |
| `password` | string | Yes | Min 8 chars |
| `role` | enum | Yes | `student`, `teacher`, `admin` |

**Success Response (201):**

```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 20,
    "name": "Admin Baru",
    "email": "admin@email.com",
    "role": "admin"
  }
}
```

---

### 9.4 Admin: Update User

```
PUT /dashboard/admin/users/{id}
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Full name |
| `email` | string | No | Valid email |
| `password` | string | No | New password |
| `is_active` | boolean | No | Active status |

**Success Response (200):**

```json
{
  "success": true,
  "message": "User updated successfully"
}
```

---

### 9.5 Admin: Verify User Email

```
PUT /dashboard/admin/users/{id}/verify-email
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Success Response (200):**

```json
{
  "success": true,
  "message": "Email verified"
}
```

---

### 9.6 Admin: Disable User

```
PUT /dashboard/admin/users/{id}/disable
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Success Response (200):**

```json
{
  "success": true,
  "message": "User disabled"
}
```

---

## 10. Web Dashboard - Teacher Analytics

### 10.1 Teacher: Class Analytics Summary

```
GET /dashboard/teacher/classes/{class_id}/analytics
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, owns class)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `date_from` | string | 30 days ago | Start date (YYYY-MM-DD) |
| `date_to` | string | today | End date (YYYY-MM-DD) |
| `topic` | string | all | Filter by material topic |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "class_id": 5,
    "class_name": "VII-A",
    "date_range": {
      "from": "2026-01-15",
      "to": "2026-02-15"
    },
    "summary": {
      "total_students": 32,
      "avg_completion_rate": 68.5,
      "avg_post_test_score": 75.2,
      "avg_pulse": {
        "participation": 3.6,
        "understanding": 3.9,
        "learning": 3.4,
        "social_engagement": 3.7
      }
    },
    "cognitive_chart": {
      "labels": ["Minggu 1", "Minggu 2", "Minggu 3", "Minggu 4"],
      "pre_scores": [60, 62, 65, 68],
      "post_scores": [72, 75, 78, 82]
    },
    "pulse_radar": {
      "participation": 3.6,
      "understanding": 3.9,
      "learning": 3.4,
      "social_engagement": 3.7
    }
  }
}
```

---

### 10.2 Teacher: Class Recapitulation (Heatmap)

```
GET /dashboard/teacher/classes/{class_id}/recapitulation
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, owns class)

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `date_from` | string | 30 days ago | Start date |
| `date_to` | string | today | End date |

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "class_id": 5,
    "metrics": [
      { "key": "participation", "label": "Partisipasi" },
      { "key": "understanding", "label": "Pemahaman" },
      { "key": "learning", "label": "Pembelajaran" },
      { "key": "social_engagement", "label": "Keterlibatan Sosial" },
      { "key": "post_test", "label": "Post-Test" }
    ],
    "students": [
      {
        "id": 1,
        "name": "Budi Santoso",
        "scores": {
          "participation": { "value": 4.0, "status": "green" },
          "understanding": { "value": 4.5, "status": "green" },
          "learning": { "value": 3.0, "status": "yellow" },
          "social_engagement": { "value": 4.0, "status": "green" },
          "post_test": { "value": 85, "status": "green" }
        }
      },
      {
        "id": 2,
        "name": "Dewi Lestari",
        "scores": {
          "participation": { "value": 2.0, "status": "red" },
          "understanding": { "value": 3.5, "status": "yellow" },
          "learning": { "value": 2.5, "status": "yellow" },
          "social_engagement": { "value": 1.5, "status": "red" },
          "post_test": { "value": 45, "status": "red" }
        }
      }
    ]
  }
}
```

> **Heatmap Status Thresholds:**
> | Status | PULSE Score | Post-Test Score |
> |--------|------------|-----------------|
> | `green` | ≥ 3.5 | ≥ 70 |
> | `yellow` | 2.5 - 3.4 | 50 - 69 |
> | `red` | < 2.5 | < 50 |

---

### 10.3 Teacher: Activity Timeline (Student)

```
GET /dashboard/teacher/students/{student_id}/activities-timeline
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "student": {
      "id": 1,
      "name": "Budi Santoso"
    },
    "activities": [
      {
        "date": "2026-02-10",
        "items": [
          {
            "id": 1,
            "type": "activity",
            "title": "Piket Kelas",
            "category": "participation",
            "photo_url": "https://cdn.civicpulse.id/activities/1.jpg"
          },
          {
            "id": 2,
            "type": "pulse_assessment",
            "title": "Asesmen PULSE: Toleransi Beragama",
            "scores": { "participation": 4, "understanding": 4, "learning": 3, "social_engagement": 4 }
          }
        ]
      }
    ]
  }
}
```

---

### 10.4 Teacher: Export Report

```
GET /dashboard/teacher/classes/{class_id}/export
```

**Headers:** `Authorization: Bearer {token}` (role: teacher)

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `format` | enum | Yes | `pdf` atau `excel` |
| `metrics` | array | Yes | Array of metrics to include |
| `date_from` | string | No | Start date |
| `date_to` | string | No | End date |

**Example:** `?format=pdf&metrics[]=participation&metrics[]=post_test`

**Success Response (200):**
- `format=pdf`: Returns PDF binary with `Content-Type: application/pdf`
- `format=excel`: Returns XLSX binary with `Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

---

## 11. Admin: CMS E-Learning

### 11.1 Get Content Hierarchy

```
GET /dashboard/admin/content
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "SMP": {
      "7": [
        { "id": 1, "title": "Keberagaman Budaya Indonesia", "status": "published" },
        { "id": 2, "title": "Nilai-Nilai Pancasila", "status": "draft" }
      ],
      "8": [ ... ],
      "9": [ ... ]
    },
    "SMA": {
      "10": [ ... ],
      "11": [ ... ],
      "12": [ ... ]
    }
  }
}
```

---

### 11.2 Create Material

```
POST /dashboard/admin/materials
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Request Body (multipart/form-data):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Judul materi |
| `description` | string | No | Deskripsi singkat |
| `grade_category` | enum | Yes | `SMP` atau `SMA` |
| `grade_level` | integer | Yes | 7-12 |
| `estimated_duration` | integer | No | Durasi estimasi dalam menit |
| `ebook_pdf` | file | No | File PDF e-book (max 20MB) |
| `thumbnail` | file | No | Gambar thumbnail (max 2MB) |
| `status` | enum | No | `draft` atau `published` |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Material created successfully",
  "data": {
    "id": 10,
    "title": "Demokrasi dan Sistem Pemerintahan",
    "grade_category": "SMA",
    "grade_level": 10,
    "status": "draft"
  }
}
```

---

### 11.3 Add Pre/Post Test Questions

```
POST /dashboard/admin/materials/{id}/questions
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Request Body:**

```json
{
  "type": "pre",
  "questions": [
    {
      "question_number": 1,
      "content": "Apa fungsi utama demokrasi?",
      "options": {
        "A": "Memilih pemimpin secara langsung",
        "B": "Menjamin kekuasaan satu orang",
        "C": "Melindungi hak rakyat dan keberagaman",
        "D": "Menghapuskan perbedaan pendapat"
      },
      "correct_answer": "C"
    }
  ]
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "Questions added successfully",
  "data": {
    "material_id": 10,
    "type": "pre",
    "questions_count": 1
  }
}
```

---

### 11.4 Update PULSE Instrument

```
PUT /dashboard/admin/materials/{id}/pulse-instrument
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Request Body:**

```json
{
  "statements": [
    {
      "id": 1,
      "dimension": "participation",
      "statement": "Saya aktif berkontribusi dalam diskusi kelompok"
    },
    {
      "id": 2,
      "dimension": "understanding",
      "statement": "Saya memahami pentingnya toleransi"
    },
    {
      "id": 3,
      "dimension": "learning",
      "statement": "Saya antusias mempelajari budaya baru"
    },
    {
      "id": 4,
      "dimension": "social_engagement",
      "statement": "Saya menghargai pendapat yang berbeda"
    }
  ]
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "PULSE instrument updated"
}
```

---

### 11.5 Publish Material

```
PUT /dashboard/admin/materials/{id}/publish
```

**Headers:** `Authorization: Bearer {token}` (role: admin)

**Success Response (200):**

```json
{
  "success": true,
  "message": "Material published successfully"
}
```

---

## 12. File Upload

### 12.1 Upload Image

```
POST /upload/image
```

**Headers:**
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | file | Yes | Image file (max 5MB, jpeg/png/webp) |
| `type` | enum | Yes | `activity_photo`, `avatar`, `thumbnail` |

**Success Response (201):**

```json
{
  "success": true,
  "data": {
    "url": "https://cdn.civicpulse.id/uploads/activities/abc123.jpg",
    "filename": "abc123.jpg"
  }
}
```

---

## 13. Error Codes Reference

| HTTP Code | Error Code | Description |
|-----------|------------|-------------|
| 400 | `INVALID_REQUEST` | Request format tidak valid |
| 401 | `UNAUTHENTICATED` | Token tidak valid atau expired |
| 403 | `FORBIDDEN` | Akses ditolak (role tidak sesuai) |
| 403 | `NOT_CLASS_OWNER` | Bukan pemilik kelas |
| 403 | `NOT_STUDENT_OWNER` | Bukan pemilik data siswa |
| 404 | `USER_NOT_FOUND` | User tidak ditemukan |
| 404 | `CLASS_NOT_FOUND` | Kelas tidak ditemukan |
| 404 | `MATERIAL_NOT_FOUND` | Materi tidak ditemukan |
| 404 | `ACTIVITY_NOT_FOUND` | Aktivitas tidak ditemukan |
| 409 | `ALREADY_JOINED_CLASS` | Sudah bergabung dengan kelas |
| 422 | `VALIDATION_ERROR` | Input tidak valid |
| 422 | `CLASS_CODE_INVALID` | Kode kelas tidak valid |
| 429 | `TOO_MANY_ATTEMPTS` | Terlalu banyak percobaan login |

---

*Dokumen ini adalah spesifikasi API v1 untuk backend Laravel CivicPulse. Endpoint dan response dapat berkembang sesuai kebutuhan development.*
