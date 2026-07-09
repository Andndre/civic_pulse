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

## 2. Kepemilikan & Pengelolaan Materi: Model Per-Kelas (Google Classroom)

Temuan tambahan dari transkrip (menit ~38:40-39:10 dan ~48:14): ada diskusi soal siapa yang input materi — admin atau guru. Kesimpulan yang lebih tepat: **materi harus mengikuti model Google Classroom** — tiap kelas yang dibuat guru punya set materinya sendiri, bukan bank materi bersama per jenjang yang dikelola admin terpusat.

### 2.1 Dari "Bank Materi per Jenjang" ke "Materi per Kelas"

Sebelumnya (skema saat ini): `learning_materials` terikat ke `grade_category` + `grade_level` — semua kelas SMP kelas 7 dari guru manapun berbagi materi yang sama, diinput admin terpusat.

Baru: materi terikat ke `class_id` (instance kelas spesifik yang dibuat guru lewat `POST /classes`). **Guru A** yang mengajar Kelas 7A bisa menyusun materi berbeda dari **Guru B** di Kelas 7B, walau sama-sama kelas 7. Siswa hanya melihat materi dari kelas yang benar-benar dia ikuti (via `class_code`), bukan seluruh bank jenjang.

Ini sekaligus menjawab tuntas diskusi "guru vs admin" di transkrip — bukan soal memberi guru izin admin tambahan, tapi karena materi memang **milik kelasnya sendiri**. Otorisasinya jadi pengecekan kepemilikan biasa (`classes.teacher_id == guru yang login`), persis seperti guru mengelola siswa di kelasnya sekarang — tidak perlu peran "Guru Admin" baru.

### 2.2 Reuse Materi Antar Kelas (Duplikasi)

Guru yang mengajar lebih dari satu kelas (misal 2 kelas 7 berbeda) tidak harus input materi dari nol tiap kelas. Disediakan aksi **"Duplikat ke Kelas Lain"** — materi (beserta seluruh Papan Aktivitas & soalnya) disalin ke kelas tujuan, lalu independen (mengedit salinan tidak memengaruhi materi asal).

### 2.3 Bank Template dari Admin (Dipertahankan)

Fitur import Excel/template dari Admin **tetap dipertahankan**, tapi perannya berubah dari "satu-satunya sumber materi" menjadi **starting point opsional**: Admin menyiapkan bank soal/template materi generik (per jenjang, bukan per kelas), guru bisa **impor lalu sesuaikan** ke kelasnya masing-masing. Materi final tetap dimiliki & dikelola oleh kelas/guru, bukan admin.

---

## 3. Konsep Solusi: "PULSE Activity Engine"

Prinsip desain: **satu mesin konten yang dikonfigurasi lewat data** (mirip cara soal pre/post-test sekarang dikonfigurasi admin), bukan game custom yang di-hardcode per materi. Ini penting supaya admin/guru tetap bisa menambah materi baru tanpa perlu development ulang tiap kali.

**Keputusan dosen: angket Likert PULSE dihapus total** — tidak ada lagi tahap terpisah "Refleksi PULSE". Konsekuensinya, keempat dimensi PULSE harus terukur dari apa yang terjadi **di antara Pre-Test dan Post-Test** (yaitu di dalam Papan Aktivitas itu sendiri), otomatis kalau memungkinkan — dan kalau satu dimensi memang tidak mungkin dinilai otomatis (Social Engagement), skornya **ditunda** dan difinalisasi belakangan lewat penilaian manual guru. Lihat 3.4 untuk detail prinsip ini.

**Update (masukan dosen, putaran review berikutnya): sebelum masuk ke aktivitas/game, siswa tetap harus diberi kesempatan membaca materi lengkap dalam bentuk e-book.** Papan Aktivitas tidak menggantikan bacaan lengkap — perannya adalah lapisan *reinforcement* interaktif setelah siswa membaca materi utuh, bukan pengganti satu-satunya sumber bacaan. Langkah E-Book yang sebelumnya dihapus, **dikembalikan sebagai tahap tersendiri sebelum Papan Aktivitas**.

Alur belajar yang diusulkan (revisi):

```
Pre-Test  →  Baca E-Book (materi lengkap, tidak berubah dari alur lama)  →  Papan Aktivitas (Kartu Materi ringkas, Kartu Tantangan, dan Kartu Tantangan Sosial)  →  Post-Test
```

Ini bukan kembali ke desain lama yang dikritik dosen (bagian 1) — bedanya:
- Bacaan e-book sekarang **diikuti** oleh aktivitas interaktif nyata (Papan Aktivitas), bukan langsung lompat ke Post-Test seperti alur lama.
- Refleksi PULSE (angket Likert) **tetap dihapus total** — statusnya tidak dikembalikan. Yang dikembalikan hanya kesempatan membaca materi lengkap, bukan angket self-report-nya.
- Kartu Materi ringkas di dalam Papan Aktivitas tetap ada, berfungsi sebagai pengingat konteks singkat tepat sebelum tiap mini-game — bukan pengganti bacaan lengkap, melainkan pelengkapnya.

### 3.1 Papan Aktivitas (Learning Board)

Papan Aktivitas dibuka **setelah** siswa menyelesaikan tahap Baca E-Book. Materi di dalam papan dipecah menjadi rangkaian "kotak" berurutan (mirip ular tangga/board game), bukan satu dokumen panjang. Tiap kotak adalah salah satu dari tiga jenis node:

| Jenis Node | Isi | Contoh |
|---|---|---|
| **Kartu Materi** | Potongan materi singkat (2-4 kalimat + gambar/ilustrasi opsional) — recap konteks, bukan pengganti Baca E-Book | "Toleransi beragama berarti menghormati praktik ibadah orang lain meski berbeda keyakinan." |
| **Kartu Tantangan** | Salah satu dari beberapa jenis mini-game (lihat 3.1.1), terkait kartu materi sebelumnya | "Cocokkan istilah dengan definisinya", "Seret ke keranjang Toleran/Intoleran", dsb. |
| **Kartu Tantangan Sosial** | Minimal satu per materi — instruksi aksi nyata terkait topik, siswa unggah bukti (lihat 3.2) | "Dokumentasikan satu momen kamu bersikap toleran minggu ini." |

Siswa harus menyelesaikan kotak secara berurutan (tidak bisa lompat/skip), sehingga jumlah kotak yang diselesaikan menjadi ukuran **Partisipasi** yang objektif (bukan klaim sendiri), dan jawaban benar/salah kartu tantangan menjadi ukuran **Understanding** tambahan sebelum Post-Test.

#### 3.1.1 Jenis Mini-Game Kartu Tantangan

Supaya papan aktivitas terasa variatif (bukan kuis pilihan ganda berulang-ulang), Kartu Tantangan punya beberapa jenis mekanik. Semua jenis memakai **satu skema data generik** (`game_type` + `payload` json — lihat bagian 5), bukan tabel terpisah per jenis, supaya menambah jenis baru nanti tidak perlu migrasi ulang.

Mockup tampilan tiap jenis game (termasuk Kartu Materi & Kartu Tantangan Sosial) sudah dibuat di [`docs/superpowers/mockups-minigame/`](./mockups-minigame/) dan sudah disisipkan ke dokumen `.docx` yang dikirim ke dosen.

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

### 3.2 Tantangan Sosial (Social Challenge)

Menggantikan angket Likert sepenuhnya. Muncul sebagai salah satu kotak **di dalam** Papan Aktivitas (jadi tetap di antara Pre-Test dan Post-Test, sesuai arahan dosen), berisi **instruksi konkret yang terikat topik materi** (bukan generik), misalnya:

> "Dokumentasikan satu momen kamu bekerja sama atau bersikap toleran dengan teman yang berbeda agama/suku minggu ini. Unggah foto/video singkat + 1-2 kalimat cerita."

Siswa mengunggah bukti (foto/video) saat mencapai kotak ini, lalu **melanjutkan ke kotak berikutnya tanpa menunggu** (Partisipasi & Understanding tetap bisa selesai penuh hari itu juga). Skor Social Engagement-nya sendiri berstatus **"tertunda" (pending)** sampai **guru menilai** (approve/reject + skor 1-5) lewat halaman review — bukan siswa menilai diri sendiri. Ini secara teknis **memakai ulang model `ActivityLog`** yang sudah ada, hanya ditambah keterikatan ke `material_id`/node papan dan status review guru.

Konsekuensi: skor PULSE materi tampil sebagai **provisional (3 dari 4 dimensi)** sampai guru menuntaskan review, baru kemudian **Social Engagement final** dan skor keseluruhan dianggap tuntas.

### 3.3 Pemetaan ke 4 Dimensi PULSE

| Dimensi | Sumber Data (Baru) | Cara Hitung |
|---|---|---|
| **Participation** | Papan Aktivitas | % kotak diselesaikan tanpa skip, dari total kotak materi — **otomatis, tersedia begitu Post-Test selesai** |
| **Understanding** | Kartu Tantangan + Post-Test | % jawaban benar gabungan — **otomatis, tersedia begitu Post-Test selesai** |
| **Learning** | Pre-Test vs Post-Test (sudah ada, tidak berubah) | Selisih skor post − pre — **otomatis, tersedia begitu Post-Test selesai** |
| **Social Engagement** | Kartu Tantangan Sosial (dinilai guru) | Skor guru 1-5, dinormalisasi ke skala yang sama — **tidak bisa otomatis, berstatus "pending" sampai guru mengisi penilaian manual** |

### 3.4 Prinsip Penilaian: Otomatis, atau Tertunda Sampai Guru Menilai — Tidak Ada Self-Report

**Keputusan final dosen: angket Likert (`PulseStatement`, `pulse_responses`) dihapus total**, bukan sekadar diturunkan jadi pelengkap. Prinsip penggantinya:

1. Kalau satu dimensi PULSE **bisa** diukur objektif dari interaksi siswa (Participation, Understanding, Learning) — dihitung **otomatis** begitu siswa menyelesaikan Papan Aktivitas + Post-Test, tidak menunggu siapa pun.
2. Kalau satu dimensi **tidak memungkinkan** diukur otomatis (Social Engagement — butuh judgment manusia atas bukti nyata) — skornya **ditunda (status: pending)** dan **difinalisasi belakangan oleh guru** lewat halaman review, bukan diisi sendiri oleh siswa lewat angket.

Tidak ada jalan tengah "jurnal reflektif pelengkap" — kalau tidak bisa objektif & otomatis, jawabannya selalu "tunda ke guru", bukan "tanya siswa".

---

## 4. Contoh Konkret End-to-End: Materi "Toleransi Antar Umat Beragama" (SMA Kelas 10)

Supaya tidak abstrak, berikut contoh isi lengkap satu materi sebagai bahan demo:

**Pre-Test** (5 soal pilihan ganda dasar tentang konsep toleransi — format sama seperti sekarang, tidak berubah).

**Baca E-Book** — materi lengkap "Toleransi Antar Umat Beragama" dalam bentuk PDF/e-book (alur baca sama seperti `_EBookStep` yang sudah ada sekarang), harus diselesaikan (scroll/buka penuh) sebelum tombol lanjut ke Papan Aktivitas aktif.

**Papan Aktivitas** (9 kotak, memakai 3 jenis mini-game fase pertama + 1 Tantangan Sosial — dibuka setelah Baca E-Book selesai):
1. Kartu Materi — "Apa itu toleransi beragama?"
2. Kartu Tantangan (**Sortir Kategori**) — seret 6 contoh sikap ke keranjang "Toleran" vs "Intoleran"
3. Kartu Materi — "Toleransi dalam UUD 1945 & Pancasila sila 1"
4. Kartu Tantangan (**Mencocokkan Pasangan**) — cocokkan istilah (kerukunan, moderasi, ekstremisme) dengan definisinya
5. Kartu Materi — "Contoh kerukunan antarumat di Indonesia (studi kasus daerah tertentu)"
6. Kartu Tantangan (**Swipe Benar/Salah**) — 5 pernyataan cepat tentang sikap toleran, swipe benar/salah
7. Kartu Materi — "Dampak intoleransi terhadap persatuan bangsa"
8. Kartu Tantangan (**Pilihan Ganda**, fallback) — kuis ringkasan (2-3 soal cepat)
9. **Kartu Tantangan Sosial** — instruksi: *"Amati dan dokumentasikan satu tindakan toleransi atau kerja sama lintas budaya/agama di lingkunganmu minggu ini. Unggah foto/video + ceritakan singkat apa yang terjadi."* Siswa unggah bukti, lalu **langsung lanjut ke Post-Test** tanpa menunggu — skor Social Engagement berstatus "pending" sampai guru mereview dari antrean → guru memberi skor 1-5 + catatan.

**Post-Test** (5 soal, evaluasi setelah papan aktivitas — menandai materi "selesai (PULSE Sosial menunggu penilaian guru)" sampai guru menuntaskan review kotak 9).

---

## 5. Perubahan Skema Database (Backend Laravel)

Referensi: `DB_SCHEMA.dbml` yang sudah ada. Perubahan dirancang **aditif** (tidak mengubah tabel lama secara merusak), supaya materi lama (PDF) tetap berfungsi selama migrasi bertahap.

```dbml
// Materi sekarang milik SATU kelas (bukan bank bersama per jenjang), plus tipe aktivitas
Table learning_materials {
  ...kolom lama tetap (title, description, thumbnail_url, order_index, status, dst)...
  class_id bigint [not null, ref: > classes.id]   // penentu utama siapa yang melihat materi ini
  activity_type enum('classic_pdf', 'learning_board') [not null, default: 'classic_pdf']

  indexes {
    class_id
  }
}
// grade_category & grade_level tetap disimpan sebagai atribut deskriptif (dipakai untuk filter
// bank template admin di bawah), tapi TIDAK lagi menentukan siapa yang melihat materi — itu
// sekarang murni lewat class_id.

// BARU: bank template opsional dari Admin — tidak terikat kelas manapun, hanya starting point
Table material_templates {
  id bigint [pk, increment]
  title varchar(255) [not null]
  description text [null]
  grade_category enum('SMP', 'SMA') [not null]
  grade_level tinyint [not null]
  created_by bigint [not null, ref: > users.id]   // admin yang menyiapkan template
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (grade_category, grade_level)
  }
}
// Struktur konten template (learning_nodes & questions versi template) bentuknya sama dengan
// milik learning_materials, tapi saat guru "impor" template ke kelasnya, isinya DISALIN
// (bukan direferensikan) ke learning_materials + learning_nodes miliknya sendiri — supaya
// materi kelas tetap independen begitu guru mulai menyesuaikannya.

// BARU: urutan kotak Papan Aktivitas per materi
// Kartu Tantangan TIDAK memakai tabel questions lama — datanya beragam bentuk
// (pasangan, kategori, urutan, dst) sehingga disimpan generik lewat game_type + payload.
Table learning_nodes {
  id bigint [pk, increment]
  material_id bigint [not null, ref: > learning_materials.id]
  order_index int [not null, default: 0]
  node_type enum('content', 'challenge', 'social_task') [not null]
  title varchar(150) [null]
  body text [null]            // teks kartu materi (untuk node_type = content), atau instruksi (untuk social_task)
  image_url varchar(500) [null]

  // Kolom di bawah hanya untuk node_type = challenge:
  game_type enum('multiple_choice', 'matching', 'sorting', 'true_false_swipe', 'ordering', 'picture_quiz', 'fill_blank', 'memory_flip') [null]
  payload json [null]         // bentuk bebas sesuai game_type, lihat contoh di bagian 6

  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (material_id, order_index)
  }
}

// DIHAPUS (bukan lagi dipakai — keputusan dosen: angket Likert dihapus total):
// Table pulse_statements { ... }
// Table pulse_responses { ... }
// Table student_pulse_scores.overall_score tetap ada sebagai agregat 4 dimensi,
// tapi sumber datanya sekarang dari learning_node_progress + activity_logs, bukan pulse_responses.

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

// UBAH: activity_logs — tambah keterikatan ke node papan + review guru
Table activity_logs {
  ...kolom lama tetap (student_id, title, category, location, activity_date, photo_url)...
  material_id bigint [null, ref: > learning_materials.id]   // null = aktivitas bebas (fitur lama tetap jalan)
  node_id bigint [null, ref: > learning_nodes.id]           // node_type = social_task yang memicu submission ini
  review_status enum('pending', 'approved', 'rejected') [null, default: 'pending']  // hanya relevan jika material_id terisi
  teacher_score tinyint [null]        // 1-5, diisi guru saat review
  reviewed_by bigint [null, ref: > users.id]
  reviewed_at timestamp [null]
}

// UBAH: tracking status per materi — ebook_status DIPERTAHANKAN (masukan dosen: siswa tetap
// harus diberi kesempatan baca materi lengkap sebelum aktivitas/game), tambah board_status
// untuk Papan Aktivitas, dan ganti pulse_status (Likert, dihapus) dengan status finalisasi
// Social Engagement
Table student_material_progress {
  ...kolom lama tetap (student_id, material_id, pre_test_status, pre_test_score, post_test_status, post_test_score)...
  ebook_status enum('not_started', 'in_progress', 'completed') [not null, default: 'not_started']  // TETAP ADA, tidak jadi dihapus
  board_status enum('not_started', 'in_progress', 'completed') [not null, default: 'not_started']  // status Papan Aktivitas (baru), hanya bisa mulai setelah ebook_status = completed
  social_engagement_status enum('not_submitted', 'pending_review', 'finalized') [not null, default: 'not_submitted']  // ganti pulse_status
}
```

---

## 6. Perubahan API (menambah ke `API_SPECIFICATION.md`)

Mengikuti format & style endpoint yang sudah ada di dokumen (section 5 Learning Materials & 6 Activity Logs).

### 5.x Get Class Materials (ganti `GET /materials?grade_category=SMP&grade_level=7`)

```
GET /classes/{classId}/materials
```

**Headers:** `Authorization: Bearer {token}` — guru hanya boleh akses kelas miliknya sendiri (`classes.teacher_id`), siswa hanya kelas yang sudah dia join.

### 5.x Teacher: Create/Update Material (scoped ke kelas)

```
POST /classes/{classId}/materials
PUT  /materials/{id}
```

**Headers:** `Authorization: Bearer {token}` (role: teacher, harus pemilik `classId`)

### 5.x Duplikat Materi ke Kelas Lain

```
POST /materials/{id}/duplicate
```

**Request Body:**
```json
{ "target_class_id": 12 }
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Materi berhasil diduplikat",
  "data": { "new_material_id": 88, "class_id": 12 }
}
```

### 5.x Import Template Admin ke Kelas

```
GET  /material-templates?grade_category=SMA&grade_level=10
POST /classes/{classId}/materials/import-template
```

**Request Body:**
```json
{ "template_id": 5 }
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Template berhasil diimpor, silakan sesuaikan isinya",
  "data": { "material_id": 89, "class_id": 12 }
}
```

### 5.x Get Learning Board (endpoint baru — `GET /materials/{id}/ebook` yang lama TETAP ADA dan tetap dipanggil lebih dulu, tidak diganti)

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
      },
      {
        "id": 9, "order_index": 9, "node_type": "social_task",
        "title": "Tantangan Sosial",
        "body": "Amati dan dokumentasikan satu tindakan toleransi atau kerja sama lintas budaya/agama di lingkunganmu minggu ini. Unggah foto/video + ceritakan singkat apa yang terjadi."
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

### 5.x Submit Social Challenge (ganti `POST /materials/{id}/pulse-response` — endpoint Likert lama dihapus)

Dipanggil saat siswa mencapai kotak `node_type: social_task` di Papan Aktivitas. Siswa **tidak menunggu** hasil review untuk lanjut ke kotak berikutnya / Post-Test.

```
POST /materials/{id}/learning-board/nodes/{nodeId}/social-task
```

**Headers:** `Authorization: Bearer {token}` (role: student), `multipart/form-data`

**Request Body:** `photo` atau `video` (file), `caption` (string)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Tantangan sosial dikirim, menunggu review guru. Kamu bisa lanjut ke kotak berikutnya.",
  "data": { "activity_log_id": 210, "material_id": 1, "node_id": 9, "review_status": "pending" }
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

## 7. Perubahan Frontend Flutter

| File | Perubahan |
|---|---|
| `lib/shared/services/data_models.dart` | Tambah model `LearningNode` (dengan `gameType` + `payload` dinamis); tambah `classId` pada `LearningMaterial`; extend `ActivityLog` dengan `materialId`, `reviewStatus`, `teacherScore` |
| `lib/features/student/learning/screens/learning_path_screen.dart` | Alur jadi 4 langkah: `_EBookStep` **dipertahankan** (masukan dosen — siswa tetap harus baca materi lengkap dulu), lalu tambah `_LearningBoardStep` baru sesudahnya (render kartu materi ringkas/tantangan/sosial berurutan); **hapus** `_PulseStep` sepenuhnya (angket Likert dihapus total, tidak dikembalikan) |
| `lib/features/student/learning/widgets/challenge_games/` (baru) | Satu widget per `game_type`: `MatchingGameCard`, `SortingGameCard`, `TrueFalseSwipeCard` (fase 1); `OrderingGameCard`, `PictureQuizCard`, `FillBlankCard`, `MemoryFlipCard` (fase lanjutan) — dipilih lewat `switch (node.gameType)`. Plus `SocialTaskCard` khusus untuk `node_type: social_task` (form upload foto/video + caption, submit lalu langsung lanjut) — semua dirender berurutan di dalam `_LearningBoardStep` |
| `lib/features/teacher/class_detail/screens/manage_materials_screen.dart` (baru) | Layar guru untuk CRUD materi kelasnya sendiri: susun Papan Aktivitas, tombol "Duplikat ke Kelas Lain", tombol "Impor dari Template Admin". Dioptimalkan untuk **Flutter Web** (layar lebar, drag-reorder kartu), tapi tetap satu codebase dengan app mobile |
| `lib/features/teacher/` | Screen baru: antrean review Tantangan Sosial (list pending + form approve/reject/skor) |
| `lib/features/student/learning/providers/material_provider.dart` | Ganti filter grade-level jadi `classId`; provider baru untuk `learningBoardProvider`, mutasi `completeNodeProvider` |

Semua widget game di atas dibangun dari widget bawaan Flutter (`Draggable`, `DragTarget`, `Dismissible`, `ReorderableListView`, `AnimatedSwitcher`) — tidak menambah dependency baru di `pubspec.yaml`.

`_EBookStep` dipakai oleh **semua** materi (baik `activity_type = classic_pdf` maupun `learning_board`) sebagai tahap baca lengkap sebelum lanjut. Untuk materi `classic_pdf` (belum sempat digamifikasi), alur berhenti seperti sekarang (E-Book → Post-Test langsung, tanpa Papan Aktivitas) — tidak ada migrasi paksa, jadi tidak ada risiko materi lama rusak.

---

## 8. Roadmap & Estimasi

| Fase | Deliverable | Estimasi |
|---|---|---|
| 1 | Finalisasi isi 1 materi contoh (seperti contoh Toleransi di atas) — bisa jadi bahan demo/paper-prototype ke dosen sebelum coding | 2 hari |
| 2 | Backend: migrasi tabel baru + endpoint (`learning_nodes`, `learning_node_progress`, extend `activity_logs`) | 3-4 hari |
| 2b | Backend + Frontend: materi jadi per-kelas (`class_id`), layar guru "Kelola Materi Kelas" (Flutter Web), fitur duplikasi antar kelas, import bank template admin | 3-4 hari |
| 3 | Frontend: `_LearningBoardStep` + 3 widget game fase pertama (Mencocokkan, Sortir, Swipe Benar/Salah), hapus `_PulseStep` lama | 4-5 hari |
| 4 | Frontend: `SocialTaskCard` (kotak Tantangan Sosial di dalam papan, upload bukti) + halaman antrean review guru | 3 hari |
| 5 | Redesain landing page pemilihan jenjang (SD/SMP/SMA/PT, hanya SMA aktif) — item terpisah dari masukan meeting sebelumnya | 2 hari |
| 6 | Testing end-to-end + siapkan materi contoh untuk demo Rektor | 2 hari |

**Target penyelesaian: 2 minggu.** Backend (Fase 2, 2b) dan frontend (Fase 3, 4) dikerjakan paralel, bukan berurutan, sehingga total ±19-22 hari kerja tetap muat dalam kalender 2 minggu. Semua fase (termasuk Fase 5 dan bagian lanjutan Fase 2b) dikerjakan tanpa deprioritas.

### Checklist Per Fase

Centang tiap item saat selesai. Ini yang jadi sumber kebenaran progres — update `PROGRESS.md` untuk catatan sesi, tapi status "selesai/belum" tiap task tetap di sini.

**Fase 1 — Materi contoh**
- [ ] Finalisasi isi 9 kotak Papan Aktivitas materi "Toleransi Antar Umat Beragama" (bagian 4)
- [ ] Siapkan 5 soal Pre-Test & 5 soal Post-Test
- [ ] Review isi materi ke dosen sebelum mulai coding

**Fase 2 — Backend: Papan Aktivitas inti**
- [ ] Migrasi `learning_nodes` (`node_type`, `game_type`, `payload`)
- [ ] Migrasi `learning_node_progress`
- [ ] Extend `activity_logs` (`material_id`, `node_id`, `review_status`, `teacher_score`, `reviewed_by`, `reviewed_at`)
- [ ] Update `student_material_progress` (`board_status`, `social_engagement_status`)
- [ ] Hapus/nonaktifkan `pulse_statements` & `pulse_responses`
- [ ] Endpoint `GET /materials/{id}/learning-board`
- [ ] Endpoint `POST /materials/{id}/learning-board/nodes/{nodeId}/complete`
- [ ] Endpoint `POST /materials/{id}/learning-board/nodes/{nodeId}/social-task`
- [ ] Endpoint `GET /teacher/social-challenges` + `POST /activities/{id}/review`

**Fase 2b — Materi per kelas**
- [ ] Migrasi `learning_materials.class_id`
- [ ] Migrasi `material_templates`
- [ ] Endpoint `GET /classes/{classId}/materials`
- [ ] Endpoint `POST /classes/{classId}/materials` & `PUT /materials/{id}`
- [ ] Endpoint `POST /materials/{id}/duplicate`
- [ ] Endpoint `GET /material-templates` & `POST /classes/{classId}/materials/import-template`
- [ ] Layar guru `manage_materials_screen.dart` (Flutter Web)

**Fase 3 — Frontend: Learning Board**
- [ ] Model `LearningNode` di `data_models.dart`
- [ ] `_LearningBoardStep` baru, ditambahkan **setelah** `_EBookStep` (`_EBookStep` dipertahankan, tidak diganti)
- [ ] `MatchingGameCard`
- [ ] `SortingGameCard`
- [ ] `TrueFalseSwipeCard`
- [ ] Hapus `_PulseStep`
- [ ] `learningBoardProvider` + `completeNodeProvider`

**Fase 4 — Tantangan Sosial + review guru**
- [ ] `SocialTaskCard` widget
- [ ] Halaman antrean review guru (list pending)
- [ ] Form approve/reject + skor 1-5 (pakai rubrik draft di bagian 9)

**Fase 5 — Landing page**
- [ ] Redesain tampilan awal (SD/SMP/SMA/PT), hanya SMA aktif untuk fase ini
- [ ] Konsolidasi alur "pilih kelas" supaya tidak ditanya dua kali

**Fase 6 — Testing & demo**
- [ ] Testing end-to-end alur siswa (Pre-Test → Papan Aktivitas → Post-Test)
- [ ] Testing end-to-end alur guru (kelola materi kelas, review Tantangan Sosial)
- [ ] Siapkan materi contoh final untuk demo Rektor

---

## 9. Keputusan

### Sudah diputuskan (dikonfirmasi dosen)

- **Materi per kelas, bukan per jenjang** — guru mengelola materi di kelasnya sendiri lewat kepemilikan kelas (`teacher_id`), bukan lewat peran "Guru Admin" terpisah.
- **Duplikasi materi antar kelas diizinkan** — guru dengan banyak kelas bisa menyalin materi ke kelas lain miliknya, lalu mengedit salinan secara independen.
- **Bank template Admin dipertahankan** sebagai starting point opsional (import Excel/template per jenjang), bukan lagi satu-satunya sumber materi.
- **Input materi di Flutter Web** (bukan panel Laravel/Blade terpisah) — satu codebase dengan app mobile, cocok untuk authoring yang butuh layar lebar (drag-reorder kartu papan aktivitas).
- **Angket Likert PULSE dihapus total.** Sebagai gantinya: Participation/Understanding/Learning dinilai otomatis dari Papan Aktivitas + Pre/Post-Test; Social Engagement (yang tidak mungkin otomatis) skornya **ditunda** dan difinalisasi lewat penilaian manual guru — lihat prinsip di bagian 3.4.
- **Demo tanggal 10 cukup 1 materi contoh** (Toleransi Antar Umat Beragama, bagian 4) — tidak perlu materi tambahan.
- **Waktu dianggap cukup untuk semua fase** — Fase 5 (redesain landing page) dan bagian lanjutan Fase 2b (duplikasi, import template) **tidak** perlu ditunda, dikerjakan bersamaan sesuai roadmap di bagian 8.
- **(Update) Baca E-Book dikembalikan sebagai tahap tersendiri sebelum Papan Aktivitas** — masukan dosen di putaran review berikutnya: siswa tetap harus diberi kesempatan membaca materi lengkap sebelum masuk ke aktivitas/game. Ini bukan pembatalan penghapusan angket Likert (itu tetap dihapus total) — yang dikembalikan hanya kesempatan baca materi, lihat bagian 3.

### Masih perlu dilengkapi (usulan draft, mohon dikonfirmasi/direvisi dosen)

Rubrik penilaian guru untuk Tantangan Sosial (skala 1-5) belum ada kriteria eksplisit dari dosen. Supaya penilaian antar guru konsisten, berikut **usulan draft** yang bisa disesuaikan:

| Skor | Kriteria |
|---|---|
| 1 | Tidak ada bukti, atau bukti tidak relevan dengan instruksi/topik materi |
| 2 | Ada bukti, tapi tidak sesuai instruksi (mis. foto tidak berkaitan dengan toleransi) |
| 3 | Bukti sesuai instruksi, tapi ceritanya dangkal/tidak menjelaskan konteks |
| 4 | Bukti sesuai + cerita menjelaskan konteks & keterkaitan dengan materi dengan baik |
| 5 | Bukti sesuai + cerita reflektif mendalam, menunjukkan inisiatif lebih dari sekadar instruksi minimum |
