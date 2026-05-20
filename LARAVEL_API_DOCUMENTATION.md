# Laravel REST API Documentation

**Version:** 1.0.0  
**Last Updated:** 2026-05-18  
**Base URL:** `https://api.yourdomain.com`

---

## Table of Contents

1. [API Overview](#1-api-overview)
2. [Authentication Endpoints](#2-authentication-endpoints)
3. [Resource Endpoints - GET](#3-resource-endpoints---get)
4. [Resource Endpoints - POST](#4-resource-endpoints---post)
5. [Resource Endpoints - PUT/PATCH](#5-resource-endpoints---putpatch)
6. [Resource Endpoints - DELETE](#6-resource-endpoints---delete)
7. [Middleware Documentation](#7-middleware-documentation)
8. [Error Handling Pattern](#8-error-handling-pattern)
9. [API Version Control Strategy](#9-api-version-control-strategy)
10. [Best Practices](#10-best-practices)
11. [Testing Examples](#11-testing-examples)
12. [Rate Limiting & Throttling](#12-rate-limiting--throttling)

---

## 1. API Overview

### Base URL

```
Production: https://api.yourdomain.com
Staging:    https://api-staging.yourdomain.com
Local:      http://localhost:8000
```

### Version Strategy

API versioning is implemented via URL path prefix. Current active versions:

| Version | Status | Base Path | Deprecation Date |
|---------|--------|-----------|------------------|
| v1 | Active | `/api/v1/` | TBD |
| v2 | Beta | `/api/v2/` | - |

### Content Type

All requests and responses use JSON format with UTF-8 encoding.

**Request Headers:**
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
X-Requested-With: XMLHttpRequest
```

**Response Headers:**
```http
Content-Type: application/json
X-Request-Id: {uuid}
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
```

---

## 2. Authentication Endpoints

### 2.1 User Registration

Creates a new user account and returns an authentication token.

**URL:** `/api/v1/auth/register`  
**Method:** `POST`  
**Authentication:** None required

#### Request Body

```json
{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "SecurePass123!",
    "password_confirmation": "SecurePass123!",
    "role": "student",
    "phone": "+6281234567890",
    "address": "Jl. Sudirman No. 123, Jakarta"
}
```

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| name | string | Yes | Min: 2 chars, Max: 255 chars |
| email | string | Yes | Valid email, unique in database |
| password | string | Yes | Min: 8 chars, must include uppercase, lowercase, number |
| password_confirmation | string | Yes | Must match password |
| role | string | No | Enum: "student", "teacher" (default: "student") |
| phone | string | No | Valid phone number format |
| address | string | No | Max: 500 chars |

#### Success Response (HTTP 201)

```json
{
    "success": true,
    "message": "User registered successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com",
            "role": "student",
            "phone": "+6281234567890",
            "address": "Jl. Sudirman No. 123, Jakarta",
            "email_verified_at": null,
            "created_at": "2026-05-18T10:30:00.000000Z",
            "updated_at": "2026-05-18T10:30:00.000000Z"
        },
        "token": "1|laravel_sanctum_abc123xyz...",
        "token_type": "Bearer",
        "expires_at": "2026-06-18T10:30:00.000000Z"
    }
}
```

#### Error Response - Validation Failed (HTTP 422)

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email has already been taken."],
        "password": [
            "The password must be at least 8 characters.",
            "The password must contain at least one uppercase letter.",
            "The password must contain at least one number."
        ]
    }
}
```

#### Error Response - Invalid Input (HTTP 400)

```json
{
    "success": false,
    "message": "Invalid registration data",
    "error_code": "INVALID_REGISTRATION_DATA"
}
```

---

### 2.2 User Login

Authenticates a user and returns an access token.

**URL:** `/api/v1/auth/login`  
**Method:** `POST`  
**Authentication:** None required

#### Request Body

```json
{
    "email": "john.doe@example.com",
    "password": "SecurePass123!",
    "remember_me": true
}
```

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| email | string | Yes | Valid email format |
| password | string | Yes | Min: 1 char |
| remember_me | boolean | No | Extends token expiry to 30 days |

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com",
            "role": "student",
            "avatar": "https://api.yourdomain.com/storage/avatars/1/avatar.jpg",
            "phone": "+6281234567890",
            "address": "Jl. Sudirman No. 123, Jakarta",
            "email_verified_at": "2026-05-18T10:30:00.000000Z",
            "created_at": "2026-05-18T10:30:00.000000Z",
            "updated_at": "2026-05-18T10:30:00.000000Z"
        },
        "token": "2|laravel_sanctum_abc123xyz...",
        "token_type": "Bearer",
        "expires_at": "2026-06-17T10:30:00.000000Z"
    }
}
```

#### Error Response - Invalid Credentials (HTTP 401)

```json
{
    "success": false,
    "message": "Invalid credentials",
    "error_code": "INVALID_CREDENTIALS"
}
```

#### Error Response - Account Locked (HTTP 423)

```json
{
    "success": false,
    "message": "Account is locked. Please try again after 15 minutes.",
    "error_code": "ACCOUNT_LOCKED",
    "locked_until": "2026-05-18T10:45:00.000000Z"
}
```

---

### 2.3 User Logout

Invalidates the current authentication token.

**URL:** `/api/v1/auth/logout`  
**Method:** `POST`  
**Authentication:** Required (Bearer Token)

#### Request Headers

```http
Authorization: Bearer {token}
```

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Successfully logged out"
}
```

#### Error Response - Unauthorized (HTTP 401)

```json
{
    "success": false,
    "message": "Unauthenticated",
    "error_code": "UNAUTHENTICATED"
}
```

---

### 2.4 Token Refresh

Refreshes the current authentication token.

**URL:** `/api/v1/auth/refresh`  
**Method:** `POST`  
**Authentication:** Required (Bearer Token)

#### Request Headers

```http
Authorization: Bearer {token}
```

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Token refreshed successfully",
    "data": {
        "token": "3|laravel_sanctum_new_token...",
        "token_type": "Bearer",
        "expires_at": "2026-06-18T10:30:00.000000Z"
    }
}
```

#### Error Response - Token Expired (HTTP 401)

```json
{
    "success": false,
    "message": "Token has expired",
    "error_code": "TOKEN_EXPIRED"
}
```

---

## 3. Resource Endpoints - GET

### 3.1 Get All Resources

Retrieves a paginated list of resources with optional filtering, sorting, and search.

**URL:** `/api/v1/{resource}`  
**Method:** `GET`  
**Authentication:** Required (Bearer Token)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| resource | string | Yes | Resource name: `students`, `teachers`, `classes`, `activities`, `scores`, `materials` |

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number for pagination |
| per_page | integer | 15 | Items per page (max: 100) |
| sort | string | created_at | Field to sort by |
| order | string | desc | Sort order: `asc` or `desc` |
| search | string | - | Search term for full-text search |
| filter[{field}] | string | - | Filter by specific field (e.g., filter[status]=active) |
| fields | string | - | Comma-separated list of fields to include |

#### Example Request

```bash
GET /api/v1/students?page=1&per_page=20&sort=name&order=asc&filter[status]=active&search=john
```

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Students retrieved successfully",
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com",
            "role": "student",
            "status": "active",
            "class_id": 101,
            "class_name": "Grade 10-A",
            "phone": "+6281234567890",
            "avatar": "https://api.yourdomain.com/storage/avatars/1/avatar.jpg",
            "created_at": "2026-05-18T10:30:00.000000Z"
        },
        {
            "id": 2,
            "name": "John Smith",
            "email": "john.smith@example.com",
            "role": "student",
            "status": "active",
            "class_id": 101,
            "class_name": "Grade 10-A",
            "phone": "+6281234567891",
            "avatar": null,
            "created_at": "2026-05-18T11:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 20,
        "total": 150,
        "last_page": 8,
        "from": 1,
        "to": 20,
        "sort": {
            "field": "name",
            "order": "asc"
        },
        "filters": {
            "status": "active"
        }
    },
    "links": {
        "first": "https://api.yourdomain.com/api/v1/students?page=1",
        "last": "https://api.yourdomain.com/api/v1/students?page=8",
        "prev": null,
        "next": "https://api.yourdomain.com/api/v1/students?page=2"
    }
}
```

#### Error Response - Validation Error (HTTP 422)

```json
{
    "success": false,
    "message": "Invalid query parameters",
    "errors": {
        "per_page": ["The per page must be between 1 and 100."],
        "order": ["The selected order is invalid."]
    }
}
```

---

### 3.2 Get Single Resource

Retrieves a single resource by its ID.

**URL:** `/api/v1/{resource}/{id}`  
**Method:** `GET`  
**Authentication:** Required (Bearer Token)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| resource | string | Yes | Resource name: `students`, `teachers`, `classes`, `activities`, `scores`, `materials` |
| id | integer | Yes | Resource unique identifier |

#### Example Request

```bash
GET /api/v1/students/1
```

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Student retrieved successfully",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "role": "student",
        "status": "active",
        "phone": "+6281234567890",
        "address": "Jl. Sudirman No. 123, Jakarta",
        "avatar": "https://api.yourdomain.com/storage/avatars/1/avatar.jpg",
        "date_of_birth": "2008-03-15",
        "gender": "male",
        "parent_name": "Robert Doe",
        "parent_phone": "+6281234567891",
        "class": {
            "id": 101,
            "name": "Grade 10-A",
            "grade": 10,
            "homeroom_teacher": "Mrs. Jane Wilson"
        },
        "activities": [
            {
                "id": 1,
                "title": "Math Competition",
                "type": "competition",
                "date": "2026-05-10",
                "points": 85
            }
        ],
        "scores": [
            {
                "id": 1,
                "subject": "Mathematics",
                "score": 92,
                "grade": "A",
                "semester": "2026-Ganjil"
            }
        ],
        "created_at": "2026-05-18T10:30:00.000000Z",
        "updated_at": "2026-05-18T10:30:00.000000Z"
    }
}
```

#### Error Response - Not Found (HTTP 404)

```json
{
    "success": false,
    "message": "Student not found",
    "error_code": "RESOURCE_NOT_FOUND"
}
```

---

## 4. Resource Endpoints - POST

### 4.1 Create New Resource

Creates a new resource with the provided data.

**URL:** `/api/v1/{resource}`  
**Method:** `POST`  
**Authentication:** Required (Bearer Token)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| resource | string | Yes | Resource name: `students`, `teachers`, `classes`, `activities`, `scores`, `materials` |

#### Request Body - Create Student

```json
{
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "password": "SecurePass123!",
    "phone": "+6281234567892",
    "address": "Jl. Gatot Subroto No. 456, Jakarta",
    "date_of_birth": "2008-05-20",
    "gender": "female",
    "class_id": 101,
    "parent_name": "Michael Doe",
    "parent_phone": "+6281234567893"
}
```

#### Validation Rules - Students

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| name | string | Yes | Min: 2 chars, Max: 255 chars |
| email | string | Yes | Valid email, unique |
| password | string | Yes | Min: 8 chars |
| phone | string | No | Valid phone format |
| address | string | No | Max: 500 chars |
| date_of_birth | date | No | Date format: YYYY-MM-DD |
| gender | string | No | Enum: male, female |
| class_id | integer | No | Must exist in classes table |
| parent_name | string | No | Max: 255 chars |
| parent_phone | string | No | Valid phone format |

#### Success Response (HTTP 201)

```json
{
    "success": true,
    "message": "Student created successfully",
    "data": {
        "id": 3,
        "name": "Jane Doe",
        "email": "jane.doe@example.com",
        "role": "student",
        "status": "active",
        "phone": "+6281234567892",
        "address": "Jl. Gatot Subroto No. 456, Jakarta",
        "date_of_birth": "2008-05-20",
        "gender": "female",
        "class_id": 101,
        "parent_name": "Michael Doe",
        "parent_phone": "+6281234567893",
        "created_at": "2026-05-18T12:00:00.000000Z",
        "updated_at": "2026-05-18T12:00:00.000000Z"
    }
}
```

#### Error Response - Validation Failed (HTTP 422)

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "name": ["The name field is required."],
        "email": ["The email must be a valid email address.", "The email has already been taken."],
        "class_id": ["The selected class id is invalid."]
    }
}
```

---

### 4.2 Create Activity (Example for Students)

**URL:** `/api/v1/activities`  
**Method:** `POST`

#### Request Body

```json
{
    "student_id": 1,
    "title": "Science Fair 2026",
    "description": "Participated in regional science fair with project on renewable energy",
    "type": "competition",
    "date": "2026-05-15",
    "location": "Jakarta Convention Center",
    "achievement": "First Place",
    "points": 100,
    "evidence_url": "https://example.com/certificate.pdf"
}
```

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| student_id | integer | Yes | Must exist in students table |
| title | string | Yes | Min: 3 chars, Max: 255 chars |
| description | string | No | Max: 1000 chars |
| type | string | Yes | Enum: competition, sports, arts, volunteer, other |
| date | date | Yes | Date format: YYYY-MM-DD, cannot be future |
| location | string | No | Max: 255 chars |
| achievement | string | No | Max: 255 chars |
| points | integer | No | Min: 0, Max: 100 |
| evidence_url | url | No | Valid URL format |

#### Success Response (HTTP 201)

```json
{
    "success": true,
    "message": "Activity created successfully",
    "data": {
        "id": 10,
        "student_id": 1,
        "student_name": "John Doe",
        "title": "Science Fair 2026",
        "description": "Participated in regional science fair with project on renewable energy",
        "type": "competition",
        "date": "2026-05-15",
        "location": "Jakarta Convention Center",
        "achievement": "First Place",
        "points": 100,
        "status": "pending",
        "evidence_url": "https://example.com/certificate.pdf",
        "created_at": "2026-05-18T12:30:00.000000Z",
        "updated_at": "2026-05-18T12:30:00.000000Z"
    }
}
```

---

## 5. Resource Endpoints - PUT/PATCH

### 5.1 Full Update (PUT)

Replaces all fields of a resource with the provided data.

**URL:** `/api/v1/{resource}/{id}`  
**Method:** `PUT`  
**Authentication:** Required (Bearer Token)

#### Request Body - Update Student (Full)

```json
{
    "name": "Jane Doe Updated",
    "email": "jane.updated@example.com",
    "phone": "+6281234567899",
    "address": "Jl. HR Rasuna Said No. 789, Jakarta",
    "date_of_birth": "2008-06-25",
    "gender": "female",
    "class_id": 102,
    "parent_name": "Michael J. Doe",
    "parent_phone": "+6281234567800",
    "status": "active"
}
```

**Note:** All fields are required when using PUT method.

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Student updated successfully",
    "data": {
        "id": 3,
        "name": "Jane Doe Updated",
        "email": "jane.updated@example.com",
        "role": "student",
        "status": "active",
        "phone": "+6281234567899",
        "address": "Jl. HR Rasuna Said No. 789, Jakarta",
        "date_of_birth": "2008-06-25",
        "gender": "female",
        "class_id": 102,
        "parent_name": "Michael J. Doe",
        "parent_phone": "+6281234567800",
        "updated_at": "2026-05-18T13:00:00.000000Z"
    }
}
```

---

### 5.2 Partial Update (PATCH)

Updates only the specified fields of a resource.

**URL:** `/api/v1/{resource}/{id}`  
**Method:** `PATCH`  
**Authentication:** Required (Bearer Token)

#### Request Body - Update Student (Partial)

```json
{
    "phone": "+6281234567899",
    "address": "Jl. HR Rasuna Said No. 789, Jakarta"
}
```

**Note:** Only include fields that need to be updated. All validation rules still apply.

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Student updated successfully",
    "data": {
        "id": 3,
        "name": "Jane Doe Updated",
        "email": "jane.updated@example.com",
        "phone": "+6281234567899",
        "address": "Jl. HR Rasuna Said No. 789, Jakarta",
        "updated_at": "2026-05-18T13:00:00.000000Z"
    }
}
```

---

### 5.3 Update Activity Status (Teacher)

**URL:** `/api/v1/activities/{id}/status`  
**Method:** `PATCH`

#### Request Body

```json
{
    "status": "approved",
    "review_notes": "Verified with competition results"
}
```

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| status | string | Yes | Enum: pending, approved, rejected |
| review_notes | string | No | Max: 500 chars |

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Activity status updated successfully",
    "data": {
        "id": 10,
        "status": "approved",
        "review_notes": "Verified with competition results",
        "reviewed_by": 5,
        "reviewed_at": "2026-05-18T14:00:00.000000Z",
        "updated_at": "2026-05-18T14:00:00.000000Z"
    }
}
```

---

## 6. Resource Endpoints - DELETE

### 6.1 Delete Resource

Permanently removes a resource from the system.

**URL:** `/api/v1/{resource}/{id}`  
**Method:** `DELETE`  
**Authentication:** Required (Bearer Token)

#### Soft Delete Behavior

By default, resources are soft-deleted (marked as deleted but retained in database). To permanently delete, use `?force=true`.

#### Request - Soft Delete

```bash
DELETE /api/v1/students/3
```

#### Request - Force Delete

```bash
DELETE /api/v1/students/3?force=true
```

#### Success Response - Soft Delete (HTTP 200)

```json
{
    "success": true,
    "message": "Student deleted successfully",
    "data": {
        "id": 3,
        "deleted_at": "2026-05-18T15:00:00.000000Z"
    }
}
```

#### Success Response - Force Delete (HTTP 200)

```json
{
    "success": true,
    "message": "Student permanently deleted",
    "data": {
        "id": 3
    }
}
```

#### Success Response - No Content (HTTP 204)

When `X-Return-No-Content: true` header is sent:

```http
HTTP/1.1 204 No Content
```

#### Error Response - Not Found (HTTP 404)

```json
{
    "success": false,
    "message": "Student not found",
    "error_code": "RESOURCE_NOT_FOUND"
}
```

#### Error Response - Cannot Delete (HTTP 409)

```json
{
    "success": false,
    "message": "Cannot delete student with associated activities",
    "error_code": "RESOURCE_HAS_DEPENDENCIES",
    "dependencies": ["activities", "scores"]
}
```

---

### 6.2 Restore Deleted Resource

Restores a soft-deleted resource.

**URL:** `/api/v1/{resource}/{id}/restore`  
**Method:** `POST`  
**Authentication:** Required (Bearer Token)

#### Success Response (HTTP 200)

```json
{
    "success": true,
    "message": "Student restored successfully",
    "data": {
        "id": 3,
        "deleted_at": null,
        "restored_at": "2026-05-18T16:00:00.000000Z"
    }
}
```

---

## 7. Middleware Documentation

### 7.1 Authentication Middleware

Laravel Sanctum is used for API authentication.

#### Sanctum Authentication Flow

1. User logs in via `/api/v1/auth/login`
2. Server returns Bearer token
3. Client includes token in `Authorization` header for subsequent requests
4. Token expires after 24 hours (or 30 days with `remember_me`)

#### Middleware Usage

```php
// Single authentication
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Multiple authentications
Route::middleware(['auth:sanctum', 'ability:read,write'])->post('/resource');

// Role-based access
Route::middleware(['auth:sanctum', 'role:teacher'])->post('/grades');
```

#### Required Headers

```http
Authorization: Bearer 1|laravel_sanctum_abc123xyz...
```

#### Token Scopes

| Scope | Description |
|-------|-------------|
| read | Read-only access to resources |
| write | Create and update resources |
| delete | Delete resources |
| admin | Full administrative access |

---

### 7.2 Rate Limiting Middleware

Default rate limiting using Laravel's Throttle middleware.

#### Default Limits

| Endpoint Type | Limit | Window |
|--------------|-------|--------|
| General API | 60 requests | 1 minute |
| Authentication | 5 requests | 1 minute |
| File Upload | 10 requests | 1 minute |
| Search | 30 requests | 1 minute |

#### Rate Limit Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
Retry-After: 30
```

#### Custom Rate Limiting

```php
// Apply to route
Route::middleware(['throttle:custom_limit'])->get('/endpoint');

// Define in RouteServiceProvider
RateLimiter::for('custom_limit', function (Request $request) {
    return Limit::perMinute(100)->by($request->user()?->id ?: $request->ip());
});
```

---

### 7.3 Validation Middleware

Request validation is applied at the controller level using Form Requests.

#### Validation Flow

1. Request hits controller
2. FormRequest validates incoming data
3. If valid, request proceeds to controller method
4. If invalid, 422 response with validation errors

#### Custom Validation Rules

```php
// In App\Rules\CustomRule.php
public function passes($attribute, $value)
{
    // Custom validation logic
}

public function message()
{
    return 'The :attribute must meet custom requirements.';
}
```

---

### 7.4 CORS Handling

Cross-Origin Resource Sharing is configured for allowed origins.

#### CORS Configuration

```php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['https://yourdomain.com', 'https://app.yourdomain.com'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining'],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

#### Preflight Request Handling

```http
OPTIONS /api/v1/students HTTP/1.1
Origin: https://yourdomain.com
Access-Control-Request-Method: GET
Access-Control-Request-Headers: Authorization, Content-Type
```

---

### 7.5 Middleware Stack Order

```php
// app/Http/Kernel.php
protected $middlewareStack = [
    \Illuminate\Http\Middleware\HandleCors::class,
    \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
    \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
    \Illuminate\Routing\Middleware\ThrottleRequests::class,
    \Illuminate\Routing\Middleware\Authenticate::class,
];
```

---

## 8. Error Handling Pattern

### 8.1 Standard Error Response Format

All API errors follow a consistent JSON structure:

```json
{
    "success": false,
    "message": "Human-readable error message",
    "error_code": "MACHINE_READABLE_ERROR_CODE",
    "errors": {
        "field_name": ["Validation error message"]
    },
    "debug": {
        "file": "app/Http/Controllers/Controller.php",
        "line": 42,
        "trace_id": "abc123xyz"
    }
}
```

#### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Always `false` for errors |
| message | string | Human-readable error description |
| error_code | string | Machine-readable error code |
| errors | object | Field-specific validation errors (optional) |
| debug | object | Debug information (only in debug mode) |

---

### 8.2 HTTP Status Codes

| Code | Status | Description | Common Use |
|------|--------|-------------|------------|
| 200 | OK | Request successful | GET, PUT, PATCH, DELETE |
| 201 | Created | Resource created | POST |
| 204 | No Content | Success with no response body | DELETE |
| 400 | Bad Request | Malformed request | Invalid JSON |
| 401 | Unauthorized | Missing/invalid authentication | No token, expired token |
| 403 | Forbidden | Authenticated but not permitted | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist | Invalid resource ID |
| 405 | Method Not Allowed | HTTP method not supported | Wrong method for endpoint |
| 409 | Conflict | Request conflicts with state | Duplicate entry |
| 422 | Unprocessable Entity | Validation failed | Invalid input data |
| 423 | Locked | Resource locked | Account locked |
| 429 | Too Many Requests | Rate limit exceeded | Throttle limit |
| 500 | Internal Server Error | Unexpected server error | Bug, exception |
| 503 | Service Unavailable | Server maintenance | Maintenance mode |

---

### 8.3 Error Codes Reference

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| VALIDATION_FAILED | 422 | Input validation failed |
| INVALID_CREDENTIALS | 401 | Login credentials incorrect |
| TOKEN_EXPIRED | 401 | Authentication token expired |
| TOKEN_INVALID | 401 | Authentication token malformed |
| UNAUTHENTICATED | 401 | No authentication provided |
| FORBIDDEN | 403 | User lacks permission |
| RESOURCE_NOT_FOUND | 404 | Requested resource doesn't exist |
| RESOURCE_HAS_DEPENDENCIES | 409 | Cannot delete due to relationships |
| DUPLICATE_ENTRY | 409 | Unique constraint violation |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| ACCOUNT_LOCKED | 423 | Account temporarily locked |
| MAINTENANCE_MODE | 503 | Server in maintenance |
| INTERNAL_ERROR | 500 | Unexpected server error |

---

### 8.4 Example Error Responses

#### Validation Error (422)

```json
{
    "success": false,
    "message": "The given data was invalid",
    "error_code": "VALIDATION_FAILED",
    "errors": {
        "email": [
            "The email field is required.",
            "The email must be a valid email address."
        ],
        "password": [
            "The password must be at least 8 characters."
        ]
    }
}
```

#### Unauthorized Error (401)

```json
{
    "success": false,
    "message": "Your session has expired. Please login again.",
    "error_code": "TOKEN_EXPIRED"
}
```

#### Forbidden Error (403)

```json
{
    "success": false,
    "message": "You do not have permission to access this resource",
    "error_code": "FORBIDDEN"
}
```

#### Rate Limit Error (429)

```json
{
    "success": false,
    "message": "Too many requests. Please slow down.",
    "error_code": "RATE_LIMIT_EXCEEDED",
    "retry_after": 60
}
```

---

## 9. API Version Control Strategy

### 9.1 Versioning Approach

URL-based versioning is used for clear API identification.

```
/api/v1/{resource}
/api/v2/{resource}
```

### 9.2 Version Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Active    │ -> │ Deprecated  │ -> │   Retired   │
│             │    │             │    │             │
│ Full support│    │ Security    │    │ Removed from │
│ New features│    │ fixes only  │    │ API          │
│             │    │             │    │              │
│ 12+ months  │    │ 6 months    │    │ After 6 mo   │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 9.3 Version Header

```http
API-Version: 2026-05-18
```

### 9.4 Deprecation Headers

```http
Deprecation: true
Sunset: Sat, 31 Dec 2026 23:59:59 GMT
Link: <https://api.yourdomain.com/api/v2/docs>; rel="deprecation"
```

### 9.5 Migration Guide: v1 to v2

#### Breaking Changes in v2

1. **Response Format Change**
   - v1: `{id, name, email}`
   - v2: `{id, name, email, metadata}`

2. **New Required Fields**
   - `class_id` required for student creation in v2

3. **Removed Endpoints**
   - `GET /api/v2/legacy/endpoint` (removed)

#### Migration Steps

```bash
# Step 1: Update base URL
BASE_URL="https://api.yourdomain.com/api/v2"

# Step 2: Update request body for student creation
{
    "name": "John Doe",
    "email": "john@example.com",
    "class_id": 101  # New required field
}

# Step 3: Update response parsing
# v2 wraps data in metadata object
```

---

## 10. Best Practices

### 10.1 RESTful Conventions

| Action | HTTP Method | URL Pattern | Example |
|--------|-------------|-------------|---------|
| List | GET | /api/v1/{resource} | GET /api/v1/students |
| Show | GET | /api/v1/{resource}/{id} | GET /api/v1/students/1 |
| Create | POST | /api/v1/{resource} | POST /api/v1/students |
| Update | PUT/PATCH | /api/v1/{resource}/{id} | PUT /api/v1/students/1 |
| Delete | DELETE | /api/v1/{resource}/{id} | DELETE /api/v1/students/1 |

### 10.2 Security Practices

#### Input Validation
- Validate all input on server side
- Use Laravel Form Requests
- Sanitize HTML input to prevent XSS
- Use prepared statements to prevent SQL injection

#### Authentication
- Use HTTPS for all requests
- Implement CSRF protection
- Rotate tokens periodically
- Store tokens securely on client

#### Authorization
```php
// Policy-based authorization
public function update(User $user, Student $student)
{
    return $user->can('update', $student);
}

// Middleware authorization
Route::put('/students/{id}', [StudentController::class, 'update'])
    ->middleware('can:update,student');
```

### 10.3 Performance Optimization

#### Caching Strategies

```php
// Cache responses
Route::get('/students', function () {
    return Cache::remember('students_list', 3600, function () {
        return Student::all();
    });
});

// Cache invalidation
Cache::forget('students_list');
Cache::tags(['students'])->flush();
```

#### Database Optimization
- Use eager loading to prevent N+1 queries
- Add database indexes for frequently queried columns
- Use pagination for large datasets
- Implement query caching

```php
// Eager loading
$students = Student::with(['class', 'activities'])->get();

// Selective columns
$students = Student::select(['id', 'name', 'email'])->get();
```

#### Response Optimization
- Use compact JSON responses
- Implement response caching
- Enable gzip compression
- Use HTTP/2 where supported

### 10.4 Response Formatting

#### Consistent Date Format
```php
// config/api.php
'date_format' => 'Y-m-d\TH:i:s.vP',

// In model
protected $casts = [
    'created_at' => 'datetime:Y-m-d\TH:i:s.vP',
    'updated_at' => 'datetime:Y-m-d\TH:i:s.vP',
    'date_of_birth' => 'date:Y-m-d',
];
```

#### Consistent Null Handling
- Return `null` for empty values, not empty string
- Use optional fields in response with `null` when not set
- Document nullable fields clearly

---

## 11. Testing Examples

### 11.1 cURL Examples

#### User Registration

```bash
curl -X POST https://api.yourdomain.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-Requested-With: XMLHttpRequest" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "SecurePass123!",
    "password_confirmation": "SecurePass123!",
    "role": "student"
  }'
```

#### User Login

```bash
curl -X POST https://api.yourdomain.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123!"
  }'
```

#### Get All Students

```bash
curl -X GET "https://api.yourdomain.com/api/v1/students?page=1&per_page=20" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..."
```

#### Get Single Student

```bash
curl -X GET https://api.yourdomain.com/api/v1/students/1 \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..."
```

#### Create Student

```bash
curl -X POST https://api.yourdomain.com/api/v1/students \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..." \
  -d '{
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "password": "SecurePass123!",
    "phone": "+6281234567890",
    "class_id": 101
  }'
```

#### Update Student

```bash
curl -X PATCH https://api.yourdomain.com/api/v1/students/3 \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..." \
  -d '{
    "phone": "+6281234567899",
    "address": "New Address"
  }'
```

#### Delete Student

```bash
curl -X DELETE https://api.yourdomain.com/api/v1/students/3 \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..."
```

#### Token Refresh

```bash
curl -X POST https://api.yourdomain.com/api/v1/auth/refresh \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..."
```

#### User Logout

```bash
curl -X POST https://api.yourdomain.com/api/v1/auth/logout \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 1|laravel_sanctum_abc123xyz..."
```

---

### 11.2 Postman Collection Format

```json
{
    "info": {
        "name": "Laravel REST API v1",
        "description": "Complete Laravel REST API collection for Civic Pulse",
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    },
    "variable": [
        {
            "key": "base_url",
            "value": "https://api.yourdomain.com/api/v1"
        },
        {
            "key": "token",
            "value": ""
        }
    ],
    "auth": {
        "type": "bearer",
        "bearer": [
            {
                "key": "token",
                "value": "{{token}}",
                "type": "string"
            }
        ]
    },
    "item": [
        {
            "name": "Authentication",
            "item": [
                {
                    "name": "Register",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Content-Type",
                                "value": "application/json"
                            },
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "body": {
                            "mode": "raw",
                            "raw": "{\n    \"name\": \"John Doe\",\n    \"email\": \"john.doe@example.com\",\n    \"password\": \"SecurePass123!\",\n    \"password_confirmation\": \"SecurePass123!\",\n    \"role\": \"student\"\n}"
                        },
                        "url": {
                            "raw": "{{base_url}}/auth/register",
                            "host": ["{{base_url}}"],
                            "path": ["auth", "register"]
                        }
                    }
                },
                {
                    "name": "Login",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Content-Type",
                                "value": "application/json"
                            },
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "body": {
                            "mode": "raw",
                            "raw": "{\n    \"email\": \"john.doe@example.com\",\n    \"password\": \"SecurePass123!\"\n}"
                        },
                        "url": {
                            "raw": "{{base_url}}/auth/login",
                            "host": ["{{base_url}}"],
                            "path": ["auth", "login"]
                        }
                    }
                },
                {
                    "name": "Logout",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/auth/logout",
                            "host": ["{{base_url}}"],
                            "path": ["auth", "logout"]
                        }
                    }
                },
                {
                    "name": "Refresh Token",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/auth/refresh",
                            "host": ["{{base_url}}"],
                            "path": ["auth", "refresh"]
                        }
                    }
                }
            ]
        },
        {
            "name": "Students",
            "item": [
                {
                    "name": "Get All Students",
                    "request": {
                        "method": "GET",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/students?page=1&per_page=20&sort=name&order=asc",
                            "host": ["{{base_url}}"],
                            "path": ["students"],
                            "query": [
                                {
                                    "key": "page",
                                    "value": "1"
                                },
                                {
                                    "key": "per_page",
                                    "value": "20"
                                },
                                {
                                    "key": "sort",
                                    "value": "name"
                                },
                                {
                                    "key": "order",
                                    "value": "asc"
                                }
                            ]
                        }
                    }
                },
                {
                    "name": "Get Single Student",
                    "request": {
                        "method": "GET",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/students/1",
                            "host": ["{{base_url}}"],
                            "path": ["students", "1"]
                        }
                    }
                },
                {
                    "name": "Create Student",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Content-Type",
                                "value": "application/json"
                            },
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "body": {
                            "mode": "raw",
                            "raw": "{\n    \"name\": \"Jane Doe\",\n    \"email\": \"jane.doe@example.com\",\n    \"password\": \"SecurePass123!\",\n    \"phone\": \"+6281234567890\",\n    \"class_id\": 101\n}"
                        },
                        "url": {
                            "raw": "{{base_url}}/students",
                            "host": ["{{base_url}}"],
                            "path": ["students"]
                        }
                    }
                },
                {
                    "name": "Update Student",
                    "request": {
                        "method": "PATCH",
                        "header": [
                            {
                                "key": "Content-Type",
                                "value": "application/json"
                            },
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "body": {
                            "mode": "raw",
                            "raw": "{\n    \"phone\": \"+6281234567899\",\n    \"address\": \"New Address\"\n}"
                        },
                        "url": {
                            "raw": "{{base_url}}/students/3",
                            "host": ["{{base_url}}"],
                            "path": ["students", "3"]
                        }
                    }
                },
                {
                    "name": "Delete Student",
                    "request": {
                        "method": "DELETE",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/students/3",
                            "host": ["{{base_url}}"],
                            "path": ["students", "3"]
                        }
                    }
                }
            ]
        },
        {
            "name": "Activities",
            "item": [
                {
                    "name": "Get All Activities",
                    "request": {
                        "method": "GET",
                        "header": [
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "url": {
                            "raw": "{{base_url}}/activities?filter[student_id]=1",
                            "host": ["{{base_url}}"],
                            "path": ["activities"],
                            "query": [
                                {
                                    "key": "filter[student_id]",
                                    "value": "1"
                                }
                            ]
                        }
                    }
                },
                {
                    "name": "Create Activity",
                    "request": {
                        "method": "POST",
                        "header": [
                            {
                                "key": "Content-Type",
                                "value": "application/json"
                            },
                            {
                                "key": "Accept",
                                "value": "application/json"
                            }
                        ],
                        "body": {
                            "mode": "raw",
                            "raw": "{\n    \"student_id\": 1,\n    \"title\": \"Science Fair 2026\",\n    \"description\": \"Regional science fair competition\",\n    \"type\": \"competition\",\n    \"date\": \"2026-05-15\",\n    \"points\": 100\n}"
                        },
                        "url": {
                            "raw": "{{base_url}}/activities",
                            "host": ["{{base_url}}"],
                            "path": ["activities"]
                        }
                    }
                }
            ]
        }
    ]
}
```

---

## 12. Rate Limiting & Throttling

### 12.1 Default Rate Limits

| Endpoint Pattern | Requests | Minutes | Scope |
|-------------------|----------|---------|-------|
| `*` (global) | 60 | 1 | IP address |
| `/api/v1/auth/*` | 5 | 1 | IP address |
| `/api/v1/auth/login` | 3 | 1 | Email + IP |
| `/api/v1/search/*` | 30 | 1 | User/IP |
| `/api/v1/export/*` | 10 | 1 | User |

### 12.2 Custom Rate Limits

#### Per-User Limits

```php
// In RouteServiceProvider
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

#### Endpoint-Specific Limits

```php
// Strict limit for sensitive operations
Route::post('/auth/login', [AuthController::class, 'login'])
    ->middleware('throttle:3,1');

// Extended limit for premium users
Route::middleware(['auth:sanctum', 'throttle:200,1'])->group(function () {
    Route::get('/premium/data', [PremiumController::class, 'index']);
});
```

#### Dynamic Limits Based on User Type

```php
RateLimiter::for('tiered', function (Request $request) {
    $user = $request->user();
    
    if ($user && $user->subscription === 'premium') {
        return Limit::perMinute(200)->by($user->id);
    }
    
    if ($user && $user->subscription === 'basic') {
        return Limit::perMinute(60)->by($user->id);
    }
    
    return Limit::perMinute(20)->by($request->ip());
});
```

### 12.3 Rate Limit Response

When rate limit is exceeded, the API returns:

```json
{
    "success": false,
    "message": "Too many requests. Please try again in 45 seconds.",
    "error_code": "RATE_LIMIT_EXCEEDED",
    "retry_after": 45
}
```

With headers:

```http
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 0
Retry-After: 45
Content-Type: application/json
```

### 12.4 Skip Rate Limiting

For critical operations that should never be throttled:

```php
Route::middleware(['throttle:5,1', 'withoutThrottling:critical'])->group(function () {
    // Critical endpoints
});
```

---

## Appendix A: Complete Endpoint List

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|----------------|
| POST | /api/v1/auth/register | Register new user | No |
| POST | /api/v1/auth/login | User login | No |
| POST | /api/v1/auth/logout | User logout | Yes |
| POST | /api/v1/auth/refresh | Refresh token | Yes |
| GET | /api/v1/users/me | Get current user | Yes |
| GET | /api/v1/students | List all students | Yes |
| GET | /api/v1/students/{id} | Get student by ID | Yes |
| POST | /api/v1/students | Create student | Yes |
| PUT | /api/v1/students/{id} | Update student | Yes |
| PATCH | /api/v1/students/{id} | Partial update student | Yes |
| DELETE | /api/v1/students/{id} | Delete student | Yes |
| POST | /api/v1/students/{id}/restore | Restore student | Yes |
| GET | /api/v1/teachers | List all teachers | Yes |
| GET | /api/v1/teachers/{id} | Get teacher by ID | Yes |
| POST | /api/v1/teachers | Create teacher | Yes |
| PUT | /api/v1/teachers/{id} | Update teacher | Yes |
| DELETE | /api/v1/teachers/{id} | Delete teacher | Yes |
| GET | /api/v1/classes | List all classes | Yes |
| GET | /api/v1/classes/{id} | Get class by ID | Yes |
| POST | /api/v1/classes | Create class | Yes |
| PUT | /api/v1/classes/{id} | Update class | Yes |
| DELETE | /api/v1/classes/{id} | Delete class | Yes |
| GET | /api/v1/activities | List activities | Yes |
| GET | /api/v1/activities/{id} | Get activity by ID | Yes |
| POST | /api/v1/activities | Create activity | Yes |
| PATCH | /api/v1/activities/{id}/status | Update activity status | Yes |
| DELETE | /api/v1/activities/{id} | Delete activity | Yes |
| GET | /api/v1/scores | List scores | Yes |
| GET | /api/v1/scores/{id} | Get score by ID | Yes |
| POST | /api/v1/scores | Create score | Yes |
| PUT | /api/v1/scores/{id} | Update score | Yes |
| DELETE | /api/v1/scores/{id} | Delete score | Yes |
| GET | /api/v1/materials | List materials | Yes |
| GET | /api/v1/materials/{id} | Get material by ID | Yes |
| POST | /api/v1/materials | Create material | Yes |
| PUT | /api/v1/materials/{id} | Update material | Yes |
| DELETE | /api/v1/materials/{id} | Delete material | Yes |

---

*Document Version: 1.0.0*  
*Last Updated: 2026-05-18*  
*Maintained by: API Team*
