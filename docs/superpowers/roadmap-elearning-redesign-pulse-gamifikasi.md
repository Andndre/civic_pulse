# Rancangan Redesain E-Learning CivicPulse: Gamifikasi Pengukuran PULSE

Dokumen ini adalah tindak lanjut dari masukan pada sesi review prototype tanggal 7 Juli 2026 (lihat [meeting-summary-2026-07-07-prototype-review.md](./meeting-summary-2026-07-07-prototype-review.md)). Tujuannya: merancang pengganti materi berbasis PDF statis dengan aktivitas/mini-game yang tetap menyampaikan materi, namun juga mengukur keempat dimensi PULSE (Participation, Understanding, Learning, Social Engagement) secara objektif — bukan lewat angket self-report.

---

## 1. Diagnosis Kondisi Saat Ini

Alur belajar siswa saat ini (`lib/features/student/learning/screens/learning_path_screen.dart`) terdiri dari 4 langkah berurutan:

```
Pre-Test  →  E-Book (baca PDF)  →  Post-Test  →  Refleksi PULSE (skala Likert 1-5, self-report)
```

Tiga masalah yang diidentifikasi dosen dan sudah tervalidasi di kode:

1. **Langkah E-Book hanya menampilkan PDF.** Tidak berbeda dari membaca Wikipedia — tidak ada aktivitas yang bisa diukur sebagai Partisipasi atau Keterlibatan Sosial.
2. **Refleksi PULSE adalah angket Likert isian sendiri oleh siswa** (`_PulseStep` di `learning_path_screen.dart`, model `PulseStatement`). Ini persis yang dikritik: siswa bisa mengisi "aktif" walau sebenarnya tidak — data tidak objektif.
3. **Fitur Aktivitas Siswa (`ActivityLog`) sudah ada** (dengan kategori PULSE dan unggah foto bukti) tetapi berada di menu terpisah (`/student/activities`), **tidak terhubung ke materi yang sedang dipelajari** — sehingga aktivitas yang dicatat bisa acak/tidak relevan dengan topik.

Kabar baiknya: butir 3 berarti sebagian besar "bahan baku" yang diminta dosen (aktivitas dengan bukti nyata yang dinilai guru) **sudah dibangun**, tinggal disambungkan ke materi dan dijadikan wajib — ini jauh lebih murah daripada membangun sistem baru dari nol.

---

## 2. Konsep Solusi: "PULSE Activity Engine"

Prinsip desain: **satu mesin konten yang dikonfigurasi lewat data** (mirip cara soal pre/post-test sekarang dikonfigurasi admin), bukan game custom yang di-hardcode per materi. Ini penting supaya admin/guru tetap bisa menambah materi baru tanpa perlu development ulang tiap kali.

Alur belajar baru yang diusulkan:

```
Pre-Test  →  Papan Aktivitas (ganti E-Book)  →  Post-Test  →  Tantangan Sosial (ganti Refleksi PULSE)
```

### 2.1 Papan Aktivitas (Learning Board)

Materi dipecah menjadi rangkaian "kotak" berurutan (mirip ular tangga/board game), bukan satu dokumen panjang. Tiap kotak adalah salah satu dari dua jenis node:

| Jenis Node | Isi | Contoh |
|---|---|---|
| **Kartu Materi** | Potongan materi singkat (2-4 kalimat + gambar/ilustrasi opsional) | "Toleransi beragama berarti menghormati praktik ibadah orang lain meski berbeda keyakinan." |
| **Kartu Tantangan** | Salah satu dari beberapa jenis mini-game (lihat 2.1.1), terkait kartu materi sebelumnya | "Cocokkan istilah dengan definisinya", "Seret ke keranjang Toleran/Intoleran", dsb. |

Siswa harus menyelesaikan kotak secara berurutan (tidak bisa lompat/skip), sehingga jumlah kotak yang diselesaikan menjadi ukuran **Partisipasi** yang objektif (bukan klaim sendiri), dan jawaban benar/salah kartu tantangan menjadi ukuran **Understanding** tambahan sebelum Post-Test.

#### 2.1.1 Jenis Mini-Game Kartu Tantangan

Supaya papan aktivitas terasa variatif (bukan kuis pilihan ganda berulang-ulang), Kartu Tantangan punya beberapa jenis mekanik. Semua jenis memakai **satu skema data generik** (`game_type` + `payload` json — lihat bagian 4), bukan tabel terpisah per jenis, supaya menambah jenis baru nanti tidak perlu migrasi ulang.

| # | Nama | Mekanik | Contoh (materi Toleransi) | PULSE Terukur | Implementasi Flutter |
|---|---|---|---|---|---|
| 1 | **Mencocokkan Pasangan** | Tarik garis / tap dua kartu yang berpasangan (istilah ↔ definisi, simbol ↔ makna) | Cocokkan "Toleransi", "Moderasi", "Ekstremisme" dengan definisinya | Understanding | `Draggable` + `DragTarget` (bawaan Flutter) |
| 2 | **Sortir Kategori** | Drag beberapa item ke salah satu dari 2-3 keranjang/kategori | Seret 8 contoh sikap ke keranjang "Toleran" vs "Intoleran" | Understanding | `Draggable` + `DragTarget` multi-target |
| 3 | **Swipe Benar/Salah** | Kartu pernyataan satu-satu, swipe kanan (benar) / kiri (salah), cepat & ritmis | 10 pernyataan cepat tentang toleransi, swipe dalam waktu terbatas | Participation (kecepatan & jumlah diselesaikan) + Understanding | `Dismissible` (bawaan Flutter) |
| 4 | **Urutkan (Sequencing)** | Susun potongan jadi urutan yang benar via drag-reorder | Urutkan sila Pancasila, atau langkah menyelesaikan konflik antarwarga | Understanding + Learning | `ReorderableListView` (bawaan Flutter) |
| 5 | **Tebak Gambar/Simbol** | Tampilkan gambar (pakaian/rumah adat, simbol) → pilih nama/makna yang benar | "Ini rumah adat dari daerah mana?" | Understanding, perkenalkan keberagaman budaya nyata | `Image` + pilihan seperti MCQ, `payload` berisi `image_url` |
| 6 | **Isi Bagian Rumpang** | Seret kata dari daftar ke tempat kosong dalam kalimat | "Toleransi adalah sikap ___ terhadap perbedaan" | Understanding | `Draggable` ke slot `DragTarget` dalam teks |
| 7 | **Kartu Memori (Memory Flip)** | Balik kartu berpasangan, cari pasangan dengan percobaan sesedikit mungkin | Versi memori dari #1, jumlah percobaan jadi skor tambahan | Participation (usaha) + Understanding | `AnimatedSwitcher` untuk animasi balik kartu |

Tidak ada satu pun yang butuh package baru — semua widget di atas sudah tersedia di Flutter SDK (`pubspec.yaml` proyek ini belum punya package drag-and-drop, dan memang tidak perlu).

**Rekomendasi mulai dari 3 jenis dulu** untuk fase pertama (bukan bangun 7 sekaligus): **Mencocokkan Pasangan**, **Sortir Kategori**, dan **Swipe Benar/Salah** — ketiganya berbagi mekanik drag/swipe yang mirip, paling murah dibangun, dan sudah cukup untuk membuat papan aktivitas terasa berbeda dari kuis biasa. Pilihan Ganda klasik tetap dipertahankan sebagai `game_type` fallback untuk konten yang belum sempat digamifikasi. Jenis 4-7 menyusul sebagai iterasi berikutnya — skemanya sudah kompatibel, tidak perlu migrasi ulang saat ditambahkan.

Skenario bercabang (cerita dengan titik keputusan berkonsekuensi) sengaja **tidak** dimasukkan sebagai jenis Kartu Tantangan — mekanismenya lebih berat (alur multi-langkah), lebih cocok jadi template terpisah untuk materi tertentu saja, bukan tipe kartu standar di semua materi.

### 2.2 Tantangan Sosial (Social Challenge)

Menggantikan angket Likert. Setelah Post-Test, siswa diberi **instruksi konkret yang terikat topik materi** (bukan generik), misalnya:

> "Dokumentasikan satu momen kamu bekerja sama atau bersikap toleran dengan teman yang berbeda agama/suku minggu ini. Unggah foto/video singkat + 1-2 kalimat cerita."

Siswa mengunggah bukti (foto/video), lalu **guru yang menilai** (approve/reject + skor 1-5) melalui halaman review — bukan siswa menilai diri sendiri. Ini secara teknis **memakai ulang model `ActivityLog`** yang sudah ada, hanya ditambah keterikatan ke `material_id` dan status review guru. Skor dari guru inilah yang menjadi sumber utama dimensi **Social Engagement**.

### 2.3 Pemetaan ke 4 Dimensi PULSE

| Dimensi | Sumber Data (Baru) | Cara Hitung |
|---|---|---|
| **Participation** | Papan Aktivitas | % kotak diselesaikan tanpa skip, dari total kotak materi |
| **Understanding** | Kartu Tantangan + Post-Test | % jawaban benar gabungan |
| **Learning** | Pre-Test vs Post-Test (sudah ada, tidak berubah) | Selisih skor post − pre |
| **Social Engagement** | Tantangan Sosial (dinilai guru) | Skor guru 1-5, dinormalisasi ke skala yang sama |

### 2.4 Nasib Refleksi Likert (Pulse Self-Report)

Direkomendasikan **tidak dihapus total**, tapi diturunkan perannya jadi jurnal reflektif pelengkap (opsional, tidak dihitung sebagai skor resmi) — supaya infrastruktur yang sudah dibangun (`PulseStatement`, `pulse_responses`) tidak terbuang percuma, tapi tidak lagi jadi satu-satunya sumber angka PULSE. **Ini salah satu poin yang perlu dikonfirmasi ke dosen** (lihat bagian 7).

---

## 3. Contoh Konkret End-to-End: Materi "Toleransi Antar Umat Beragama" (SMA Kelas 10)

Supaya tidak abstrak, berikut contoh isi lengkap satu materi sebagai bahan demo:

**Pre-Test** (5 soal pilihan ganda dasar tentang konsep toleransi — format sama seperti sekarang, tidak berubah).

**Papan Aktivitas** (8 kotak, memakai 3 jenis mini-game fase pertama):
1. Kartu Materi — "Apa itu toleransi beragama?"
2. Kartu Tantangan (**Sortir Kategori**) — seret 6 contoh sikap ke keranjang "Toleran" vs "Intoleran"
3. Kartu Materi — "Toleransi dalam UUD 1945 & Pancasila sila 1"
4. Kartu Tantangan (**Mencocokkan Pasangan**) — cocokkan istilah (kerukunan, moderasi, ekstremisme) dengan definisinya
5. Kartu Materi — "Contoh kerukunan antarumat di Indonesia (studi kasus daerah tertentu)"
6. Kartu Tantangan (**Swipe Benar/Salah**) — 5 pernyataan cepat tentang sikap toleran, swipe benar/salah
7. Kartu Materi — "Dampak intoleransi terhadap persatuan bangsa"
8. Kartu Tantangan (**Pilihan Ganda**, fallback) — kuis ringkasan (2-3 soal cepat)

**Post-Test** (5 soal, evaluasi setelah papan aktivitas).

**Tantangan Sosial** — instruksi: *"Amati dan dokumentasikan satu tindakan toleransi atau kerja sama lintas budaya/agama di lingkunganmu minggu ini. Unggah foto/video + ceritakan singkat apa yang terjadi."* → masuk antrean review guru → guru memberi skor 1-5 + catatan.

---

## 4. Perubahan Skema Database (Backend Laravel)

Referensi: `DB_SCHEMA.dbml` yang sudah ada. Perubahan dirancang **aditif** (tidak mengubah tabel lama secara merusak), supaya materi lama (PDF) tetap berfungsi selama migrasi bertahap.

```dbml
// Materi kini punya tipe aktivitas — default tetap PDF lama, opt-in ke board game
Table learning_materials {
  ...kolom lama tetap...
  activity_type enum('classic_pdf', 'learning_board') [not null, default: 'classic_pdf']
}

// BARU: urutan kotak Papan Aktivitas per materi
// Kartu Tantangan TIDAK memakai tabel questions lama — datanya beragam bentuk
// (pasangan, kategori, urutan, dst) sehingga disimpan generik lewat game_type + payload.
Table learning_nodes {
  id bigint [pk, increment]
  material_id bigint [not null, ref: > learning_materials.id]
  order_index int [not null, default: 0]
  node_type enum('content', 'challenge') [not null]
  title varchar(150) [null]
  body text [null]            // teks kartu materi (untuk node_type = content)
  image_url varchar(500) [null]

  // Kolom di bawah hanya untuk node_type = challenge:
  game_type enum('multiple_choice', 'matching', 'sorting', 'true_false_swipe', 'ordering', 'picture_quiz', 'fill_blank', 'memory_flip') [null]
  payload json [null]         // bentuk bebas sesuai game_type, lihat contoh di bagian 5

  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (material_id, order_index)
  }
}

// BARU: progres siswa per kotak (untuk hitung % partisipasi & understanding)
Table learning_node_progress {
  id bigint [pk, increment]
  student_id bigint [not null, ref: > users.id]
  node_id bigint [not null, ref: > learning_nodes.id]
  material_id bigint [not null, ref: > learning_materials.id]
  status enum('viewed', 'answered') [not null]
  submitted_answer json [null]   // bentuk bebas, sesuai game_type node terkait (mis. urutan pasangan, hasil sortir)
  is_correct boolean [null]
  score int [null]               // untuk game_type yang punya skor parsial (mis. memory_flip: jumlah percobaan)
  completed_at timestamp [not null]

  indexes {
    (student_id, node_id) [unique]
    (student_id, material_id)
  }
}

// UBAH: activity_logs — tambah keterikatan ke materi + review guru
Table activity_logs {
  ...kolom lama tetap (student_id, title, category, location, activity_date, photo_url)...
  material_id bigint [null, ref: > learning_materials.id]   // null = aktivitas bebas (fitur lama tetap jalan)
  review_status enum('pending', 'approved', 'rejected') [null, default: 'pending']  // hanya relevan jika material_id terisi
  teacher_score tinyint [null]        // 1-5, diisi guru saat review
  reviewed_by bigint [null, ref: > users.id]
  reviewed_at timestamp [null]
}

// UBAH: tracking status per materi — tambah status tantangan sosial
Table student_material_progress {
  ...kolom lama tetap...
  social_task_status enum('not_started', 'pending_review', 'completed') [not null, default: 'not_started']
}
```

---

## 5. Perubahan API (menambah ke `API_SPECIFICATION.md`)

Mengikuti format & style endpoint yang sudah ada di dokumen (section 5 Learning Materials & 6 Activity Logs).

### 5.x Get Learning Board (ganti `GET /materials/{id}/ebook`)

```
GET /materials/{id}/learning-board
```

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "material_id": 1,
    "nodes": [
      { "id": 1, "order_index": 1, "node_type": "content", "title": "Apa itu Toleransi?", "body": "...", "image_url": null },
      {
        "id": 2, "order_index": 2, "node_type": "challenge", "game_type": "sorting",
        "payload": {
          "categories": ["Toleran", "Intoleran"],
          "items": [
            { "id": "a", "label": "Membiarkan teman beribadah dengan tenang", "category": "Toleran" },
            { "id": "b", "label": "Mengejek teman yang beribadah beda waktu", "category": "Intoleran" }
          ]
        }
      },
      {
        "id": 4, "order_index": 4, "node_type": "challenge", "game_type": "matching",
        "payload": {
          "pairs": [
            { "id": "p1", "left": "Kerukunan", "right": "Hidup berdampingan dengan damai antar kelompok berbeda" },
            { "id": "p2", "left": "Moderasi", "right": "Sikap tidak berlebihan dalam beragama" }
          ]
        }
      },
      {
        "id": 6, "order_index": 6, "node_type": "challenge", "game_type": "true_false_swipe",
        "payload": {
          "statements": [
            { "id": "s1", "text": "Toleransi berarti membenarkan semua keyakinan orang lain", "answer": false },
            { "id": "s2", "text": "Toleransi berarti menghormati hak orang lain untuk berbeda", "answer": true }
          ]
        }
      }
    ]
  }
}
```

### 5.x Submit Node Progress

```
POST /materials/{id}/learning-board/nodes/{nodeId}/complete
```

**Request Body** (bentuk `submitted_answer` mengikuti `game_type` node, contoh untuk `sorting`):
```json
{ "submitted_answer": { "a": "Toleran", "b": "Intoleran" } }
```

**Success Response (200):**
```json
{
  "success": true,
  "data": { "node_id": 2, "is_correct": true, "board_progress_percent": 25 }
}
```

### 5.x Submit Social Challenge (ganti `POST /materials/{id}/pulse-response`)

```
POST /materials/{id}/social-challenge
```

**Headers:** `Authorization: Bearer {token}` (role: student), `multipart/form-data`

**Request Body:** `photo` atau `video` (file), `caption` (string)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Tantangan sosial dikirim, menunggu review guru",
  "data": { "activity_log_id": 210, "material_id": 1, "review_status": "pending" }
}
```

### 6.x Teacher: Review Queue

```
GET /teacher/social-challenges?status=pending
```

```
POST /activities/{id}/review
```
**Request Body:**
```json
{ "review_status": "approved", "teacher_score": 4, "note": "Bagus, dokumentasinya jelas" }
```

---

## 6. Perubahan Frontend Flutter

| File | Perubahan |
|---|---|
| `lib/shared/services/data_models.dart` | Tambah model `LearningNode` (dengan `gameType` + `payload` dinamis); extend `ActivityLog` dengan `materialId`, `reviewStatus`, `teacherScore` |
| `lib/features/student/learning/screens/learning_path_screen.dart` | Ganti `_EBookStep` → `_LearningBoardStep` (render kartu materi/tantangan berurutan); ganti `_PulseStep` → `_SocialChallengeStep` (form upload + caption) |
| `lib/features/student/learning/widgets/challenge_games/` (baru) | Satu widget per `game_type`: `MatchingGameCard`, `SortingGameCard`, `TrueFalseSwipeCard` (fase 1); `OrderingGameCard`, `PictureQuizCard`, `FillBlankCard`, `MemoryFlipCard` (fase lanjutan) — dipilih lewat `switch (node.gameType)` di `_LearningBoardStep` |
| `lib/features/teacher/` | Screen baru: antrean review Tantangan Sosial (list pending + form approve/reject/skor) |
| `lib/features/student/learning/providers/material_provider.dart` | Provider baru untuk `learningBoardProvider`, mutasi `completeNodeProvider` |

Semua widget game di atas dibangun dari widget bawaan Flutter (`Draggable`, `DragTarget`, `Dismissible`, `ReorderableListView`, `AnimatedSwitcher`) — tidak menambah dependency baru di `pubspec.yaml`.

Materi lama yang masih `activity_type = classic_pdf` tetap dirender dengan `_EBookStep` versi sekarang — tidak ada migrasi paksa, jadi tidak ada risiko materi lama rusak.

---

## 7. Roadmap & Estimasi

| Fase | Deliverable | Estimasi |
|---|---|---|
| 1 | Finalisasi isi 1 materi contoh (seperti contoh Toleransi di atas) — bisa jadi bahan demo/paper-prototype ke dosen sebelum coding | 2 hari |
| 2 | Backend: migrasi tabel baru + endpoint (`learning_nodes`, `learning_node_progress`, extend `activity_logs`) | 3-4 hari |
| 3 | Frontend: `_LearningBoardStep` + 3 widget game fase pertama (Mencocokkan, Sortir, Swipe Benar/Salah) | 4-5 hari |
| 4 | Frontend: `_SocialChallengeStep` (upload bukti) + halaman review guru | 3 hari |
| 5 | Redesain landing page pemilihan jenjang (SD/SMP/SMA/PT, hanya SMA aktif) — item terpisah dari masukan meeting sebelumnya | 2 hari |
| 6 | Testing end-to-end + siapkan materi contoh untuk demo Rektor | 2 hari |

**Total estimasi: ±16-18 hari kerja (±3 minggu).** Ini lebih panjang dari estimasi verbal "2 minggu" yang disebut di meeting sebelumnya — perlu didiskusikan prioritas: kemungkinan Fase 1, 3, 4 (papan aktivitas + tantangan sosial untuk 1 materi contoh) cukup untuk demo tanggal 10, sementara Fase 5-6 menyusul.

---

## 8. Keputusan yang Perlu Dikonfirmasi ke Dosen

1. Apakah Refleksi PULSE (angket Likert) **dihapus total**, atau tetap ada sebagai jurnal reflektif pelengkap yang tidak dihitung skor resmi?
2. Untuk demo tanggal 10: cukup **1 materi contoh** lengkap (Papan Aktivitas + Tantangan Sosial), atau perlu lebih dari satu topik?
3. Rubrik penilaian guru untuk Tantangan Sosial (skala 1-5) — perlu instrumen/kriteria penilaian yang lebih jelas supaya penilaian antar guru konsisten.
4. Prioritas jika waktu 2 minggu tidak cukup untuk semua fase: apakah redesain landing page (Fase 5) boleh menyusul setelah demo, atau wajib selesai bersamaan?
