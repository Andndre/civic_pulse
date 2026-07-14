# PROGRESS.md

## Status Saat Ini

**Seluruh Fase Redesain PULSE & Gamifikasi beserta detail pengelolaan materi per-kelas telah selesai dikerjakan penuh dan disempurnakan.** Selain itu, halaman beranda siswa telah didesain ulang agar modern dan elegan sesuai desain referensi, serta menu navigasi bawah telah diperbarui. Papan Aktivitas, mini-games, dan tantangan sosial terverifikasi lulus unit test 100% dan analisis kode bersih.

## Session Log

(Entri terbaru di paling atas. Satu entri per sesi kerja — tambahkan, jangan menimpa entri lama.)

### 2026-07-10 (sesi-13) — Perbaikan Perhitungan Statistik Kelas (Materi Selesai & Rata-rata PULSE)

**Yang diselesaikan:**
- **Pembersihan Data Yatim (Orphan Data)**: Menghapus data pengerjaan siswa (`student_pulse_scores`) yang tersisa dari materi-materi yang dihapus sebelum fitur cascading delete (sesi-12) diterapkan.
- **Pembaruan Query API Statistik Kelas**: Memperbarui query di `ClassResource.php` agar perhitungan rata-rata PULSE (`boardScores` & `responses`) dan materi selesai (`completedMaterialsBoard` & `completedMaterialsLegacy`) melakukan join ke `learning_materials` dan memfilter berdasarkan `class_id` yang sesuai serta memastikan materi aktif (`deleted_at` bernilai NULL). Ini memperbaiki bug tampilan di mana total materi selesai bernilai `3/1` (300% progres kelas) dan rata-rata PULSE terdistorsi oleh data materi terhapus.
- **Pengujian & Verifikasi**: Menjalankan seluruh 61 unit test backend Laravel dan semuanya lulus sukses 100%.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-12) — Penghapusan Cascading Data Siswa saat Materi Dihapus

**Yang diselesaikan:**
- **Penghapusan Cascading di Backend**: Memperbarui method `destroy` pada `LearningMaterialController.php` agar menghapus log aktivitas siswa (`activity_logs` - soft delete/force delete) dan skor PULSE objektif (`student_pulse_scores`) secara cascading ketika guru menghapus materi pembelajaran. Hal ini mencegah data yatim (orphan data) siswa tetap tersimpan di database setelah materinya dihapus.
- **Unit Testing & Verifikasi**: Menambahkan unit test baru `test_delete_material_cascades_student_data` di `StudentFeaturesTest.php` untuk memvalidasi alur penghapusan cascading secara menyeluruh. Menjalankan seluruh 61 unit test di backend Laravel dan semuanya lulus sukses 100%.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-11) — Penyesuaian Dinamis Jumlah Materi Kelas

**Yang diselesaikan:**
- **Penghapusan Batasan Statis (3) Materi Kelas**: Mengubah API resource backend (`ClassResource.php`) agar menyertakan hitungan dinamis `'total_materials'` dari database.
- **Pembaruan Parser Model Client**: Memperbarui parser data model di Flutter (`data_models.dart` -> `TeacherClass.fromJson`) agar membaca jumlah total materi secara dinamis dari response server, alih-alih menggunakan nilai statis/hardcoded `3`. Hal ini memulihkan tampilan target selesai dari `0/3` menjadi `0/X` (sesuai jumlah materi asli di kelas).
- **Pengujian & Verifikasi**: Menjalankan seluruh 60 unit test di backend Laravel dan semuanya lulus sukses 100%.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-10) — Penyesuaian Layout Menu Utama Beranda Siswa

**Yang diselesaikan:**
- **Pemisahan Teks Label & Kartu Ikon**: Memindahkan teks label menu utama di beranda siswa (`student_home_screen.dart`) ke luar container kartu putih (diletakkan di bawah ikon card secara vertikal).
- **Penyesuaian Aspek Rasio Grid**: Mengubah `childAspectRatio` GridView menu dari `0.82` menjadi `0.7` guna memberikan ruang vertikal yang cukup bagi label menu 2-baris di bawah kartu ikon, mencegah layout overflow di perangkat mobile.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-9) — Sinkronisasi IP Local Wi-Fi (192.168.2.93)

**Yang diselesaikan:**
- **Pembaruan Konfigurasi IP**: Mengubah IP address server lokal dari `192.168.1.15` ke `192.168.2.93` pada `api_constants.dart` dan logic resolusi URL di `data_models.dart`.
- **Pengujian & Verifikasi**: Menjalankan unit test `learning_board_test.dart` dan semuanya lulus sukses 100% (5/5).

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-8) — Redesain Beranda & Navigasi Bawah Siswa

**Yang diselesaikan:**
- **Redesain & Perapian Beranda Siswa**: Mengubah total tampilan halaman `StudentHomeScreen` agar persis seperti gambar referensi. Menghapus tombol bergabung kelas dari header dan memindahkan informasi kelas aktif menjadi badge kapsul di dalam header untuk membebaskan ruang kontainer putih. Grid menu 3x2 kini tampil lebih luas dan terorganisir dengan batas kartu tipis yang rapi dan ikon pastel yang lebih besar.
- **Perbaikan Navigasi Bawah (Fix Layout Overflow)**: Membungkus setiap menu navigasi bawah dalam widget `Expanded` dan mengurangi padding horizontal agar label panjang seperti "Informasi Pengembang" dapat melipat menjadi dua baris secara vertikal tanpa memicu overflow 19px pada perangkat seluler.
- **Aksi Mandiri Join Kelas**: Menghubungkan klik kartu warning "Belum Bergabung Kelas" di beranda untuk memicu bottom sheet bergabung kelas secara langsung.
- **Halaman Panduan & Info Pengembang**: Membuat halaman `GuideScreen` dan `DeveloperInfoScreen` serta mendaftarkannya di router.
- **Analisis & Pengujian**: `flutter analyze` 100% bersih tanpa warning baru dan pengujian unit `learning_board_test.dart` lulus 100% (5/5).

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-7) — Perbaikan Pembungkusan Teks & Tata Letak Bidang Input Game & Kuis

**Yang diselesaikan:**
- **Perbaikan Pembungkusan Teks (Wrapping)**: Menambahkan konfigurasi `maxLines: null` dan `keyboardType: TextInputType.multiline` pada semua bidang input teks (`TextFormField`/`TextField`) di dalam dialog visual game editor (`GamePayloadEditorDialog`) dan pembuat soal kuis (`_showQuestionForm`).
- **Tata Letak Vertikal (Stacking)**: Mengubah penempatan bidang input yang sebelumnya bersampingan (`Row`) menjadi bertumpuk atas-bawah (`Column`) pada dialog game editor (Pilihan A-D pada MCQ, Kategori 1 & 2 serta Pernyataan/Kategori pada Sorting, Kunci Kiri & Kanan pada Matching, serta Pernyataan/Switch Kebenaran pada True-False). Hal ini mencegah pemotongan/penyempitan bidang input dan memaksimalkan ruang lebar dialog agar lebih rapi serta tidak menghalangi elemen lain.
- **Perbaikan Overflow Dialog**: 
  - Menambahkan properti `insetPadding` pada `AlertDialog` di `GamePayloadEditorDialog` agar dialog memanfaatkan ruang lebar layar secara maksimal di perangkat seluler (sebagaimana `_showNodeForm` di sesi-6).
  - Membungkus label teks `'Jawaban Kebenaran:'` di True/False Swipe editor dengan widget `Expanded` guna mencegah kegagalan tata letak (*layout overflow*) di sebelah kanan Switch.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-6) — Perbaikan Tampilan Editor Game Visual & Alur Dialog Guru

**Yang diselesaikan:**
- **Peningkatan Visual Editor Game**: Mendesain ulang layout modal/dialog pembuatan dan penyuntingan konten game (`GamePayloadEditorDialog`) untuk seluruh tipe game (*Multiple Choice*, *Sorting*, *Matching*, dan *True/False Swipe*).
- **Pencegahan Tampilan Bertumpuk (Overlapping)**: Menghapus properti `labelText` dalam `InputDecoration` yang memicu tumpang tindih teks pada isian formulir. Menggantinya dengan label teks (`Text`) terpisah di atas text field untuk keterbacaan yang maksimal.
- **Desain Kartu Terstruktur**: Membungkus setiap butir item data (seperti item kategori, pasangan mencocokkan, dan pernyataan benar/salah) ke dalam widget `Card` berbatas garis abu-abu tipis yang rapi dan terorganisir dengan saksama.
- **Penyelarasan Input**: Menyejajarkan bidang Dropdown input kategori dan Switch kebenaran dengan isian teks di sebelahnya agar simetris dan memiliki tinggi yang seragam.
- **Pencegahan Dialog Bertumpuk (Stacked Dialogs)**: Memperbarui alur pemanggilan visual game editor dari dialog tambah/edit node (`_showNodeForm`). Dialog input node sekarang ditutup terlebih dahulu sebelum dialog edit isi game dibuka. Setelah dialog edit isi game disimpan atau dibatalkan, dialog input node otomatis dibuka kembali dengan mempertahankan seluruh data isian sementara (seperti Judul, Deskripsi, Tipe Node, dan Tipe Game) menggunakan objek `LearningNode` temporer.

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-5) — Perbaikan Tampilan Konten & Alur Tambah Mini-Game Papan Aktivitas

**Yang diselesaikan:**
- **Perbaikan Tampilan Konten (Student)**: Menghapus pembungkus Card (container border & background) serta badge "Kartu Materi" pada `content_card.dart` agar konten penjelasan di papan aktivitas siswa tampil secara flat dan bersih sebagai teks artikel (cardless).
- **Perbaikan Alur Pemilihan Mini-Game (Teacher)**: Menghapus pemicu asinkron popup otomatis visual editor (`_openVisualGameEditor`) pada callback `onChanged` dari Tipe Node dan Jenis Game di dialog `_showNodeForm`. Guru kini dapat memilih jenis game terlebih dahulu dengan tenang, kemudian menekan tombol "Edit Konten & Soal Game (Visual)" secara manual jika sudah siap mengisi konten game.
- **List Node Tetap Memakai Card (Teacher)**: Mempertahankan/mengembalikan penggunaan widget `Card` pada item langkah belajar di tab "Papan Aktivitas" editor guru agar tetap terstruktur rapi dengan bayangan kontras.
- **Pengujian & Verifikasi**: Menjalankan unit test `learning_board_test.dart` dan berhasil lolos 100% (5/5 tests passed).

**Next:** Siap untuk penyesuaian fungsional atau visual lainnya sesuai instruksi user.

### 2026-07-10 (sesi-4) — Penyesuaian Dialog Tambah/Edit Node Papan Aktivitas

**Yang diselesaikan:**
- **Pelebaran Layout Dialog**: Menambahkan `insetPadding` horizontal 16.0 pada `AlertDialog` dan meningkatkan `maxWidth` di `ConstrainedBox` menjadi `650` untuk membuat tampilan dialog lebih lebar dan responsif pada perangkat seluler.
- **Pembersihan Form**: Menghapus dropdown template ("Pilih dari Node Template (Opsional)") dan panel input JSON langsung ("Lanjutan: Edit JSON Langsung (Optional)") sesuai permintaan agar tampilan dialog lebih bersih, ringkas, dan fokus pada input visual.
- **Pencegahan Overflow**: Menambahkan properti `isExpanded: true` pada `DropdownButtonFormField` untuk Tipe Node dan Jenis Game guna memastikan teks item yang panjang terpotong/terbungkus rapi tanpa memicu error layout overflow.

### 2026-07-10 (sesi-3) — Perbaikan Integrasi Data PULSE Siswa di Detail Kelas Guru

**Yang diselesaikan:**
- **Perbaikan Sinkronisasi Skor PULSE**: Mengubah resource API `StudentResource.php` dan `ClassResource.php` di backend Laravel agar mengambil rata-rata nilai dimensi PULSE dari tabel baru `student_pulse_scores` (alur Papan Aktivitas & Game) serta memberikan fallback ke `pulse_responses` untuk materi PDF lama. Hal ini menyelesaikan bug di mana nilai pengerjaan siswa tampak kosong/0.0 di detail kelas guru.
- **Pengujian & Verifikasi**: Menjalankan pengujian otomatis backend, seluruh 60 unit/feature test lolos sukses 100%.

### 2026-07-10 (sesi-2) — Sinkronisasi IP Local WiFi

**Yang diselesaikan:**
- **Pembaruan Konfigurasi IP**: Mengubah IP address server lokal dari `192.168.2.93` ke `192.168.1.15` pada `api_constants.dart` dan logic resolusi URL di `data_models.dart`.
- **Pengujian & Verifikasi**: Berhasil memverifikasi unit test `learning_board_test.dart`.

### 2026-07-10 — Penyaringan & Proteksi Materi Pembelajaran Spesifik per Kelas

**Yang diselesaikan:**
- **Penyaringan Sisi Client**: Memperbarui provider `materialsProvider` di Flutter agar memanggil API `getClassMaterials(classId)` siswa, menggantikan pemanggilan berbasis jenjang `getMaterials(gradeCategory, gradeLevel)`.
- **Penyaringan Sisi Server**: Mengubah metode `index` pada `LearningMaterialController.php` di Laravel backend untuk membatasi materi yang dikembalikan bagi siswa hanya dari kelas yang mereka ikuti.
- **Proteksi Hak Akses (Show Route)**: Memodifikasi metode `show` di `LearningMaterialController.php` untuk mengembalikan respons `403 Forbidden` jika siswa mencoba mengakses materi dari kelas lain yang tidak diikutinya (mendukung fallback jika `class_id` null untuk data pengujian).
- **Verifikasi**: Seluruh 60 unit test Laravel backend dan unit test Flutter lolos sukses 100%.

**Next:** Siap untuk integrasi E2E lanjutan atau penambahan fitur baru sesuai permintaan user.

### 2026-07-09 (malam-7) — Perbaikan Error SQL games_status enum in_progress

**Yang diselesaikan:**
- **Sinkronisasi Schema games_status di Database**: Menyelesaikan error warning SQL 1265 "Data truncated for column 'games_status'" yang muncul saat siswa mengerjakan game di Papan Aktivitas. Masalah terjadi karena kolom `games_status` di database MySQL lokal masih menggunakan tipe ENUM versi lama (`'locked'`, `'available'`, `'completed'`), sedangkan di kode backend dan migrasi terbaru, enum tersebut telah diperluas untuk menerima status `'in_progress'`.
- **Perbaikan Schema**: Menjalankan perintah database ALTER TABLE di MySQL WSL untuk memperbarui kolom `games_status` agar mendukung opsi `'in_progress'` secara langsung tanpa menghapus data pengujian yang ada.

**Next:** Siap untuk pengujian E2E lanjutan oleh siswa dan guru.

### 2026-07-09 (malam-6) — Perbaikan Pengiriman Tantangan Sosial & Penyimpanan Jawaban Game Siswa

**Yang diselesaikan:**
- **Opsionalisasi Bukti (Foto/Video) di Backend**: Memperbarui validasi endpoint `submitSocialTask` di `LearningMaterialController.php` backend agar tidak memaksa parameter bukti file (`photo`/`video`) menjadi `required` jika tidak dikirimkan. Ini menyelaraskan backend dengan rancangan visual frontend yang melabeli unggah foto/bukti sebagai "opsional".
- **Validasi Panjang Caption di Frontend**: Menambahkan pengecekan minimal 10 karakter untuk input cerita/deskripsi tantangan sosial di `learning_path_screen.dart` sebelum mengirim data ke server. Hal ini mencegah error 422 dari database akibat isian yang terlalu pendek.
- **Penyimpanan Jawaban & Skor Pemahaman (Understanding)**:
  - Mengubah daur hidup `_onNodeDone` di `learning_path_screen.dart` agar mengalkulasi parameter `isCorrect` secara dinamis di tingkat klien berdasarkan jawaban mini-game (*Multiple Choice*, *True/False Swipe*, *Sorting*, dan *Matching*).
  - Memperbarui interface `MaterialServiceInterface`, implementasi `RealMaterialService`, notifier `CompleteNodeNotifier`, serta kelas unit test mock `learning_board_test.dart` untuk meneruskan field `isCorrect` dan `score` dalam payload request API `completeNode`.
  - Menghalangi transisi otomatis ke node berikutnya apabila API penyimpanan jawaban gagal/mengembalikan error. Halaman kini menahan indeks node aktif dan memicu SnackBar error terperinci dari `ApiException`.
  - Hal ini berhasil memulihkan perhitungan metrik objektif "Pemahaman" (*Understanding*) pada skor PULSE siswa di database yang bernilai nol akibat `is_correct` selalu terisi `null` sebelumnya.
- **Unit Testing**: Menambahkan unit test `test_submit_social_task_without_photo` di `StudentFeaturesTest.php`. Seluruh 59 test Laravel backend dan 5 unit test Flutter sukses 100%.

### 2026-07-09 (malam-5) — Perbaikan Crash Context & Validasi Node/Kuis Guru

**Yang diselesaikan:**
- **Perbaikan Crash Context & Lifecycle**: Mengubah daur hidup dialog tambah/edit kuis dan langkah belajar (node) di `teacher_material_editor_screen.dart`. Dialog kini tetap terbuka selama API diproses secara asinkron dengan loading indicator lokal, dan hanya ditutup setelah sukses. Ini memecahkan crash `Unhandled Exception: Looking up a deactivated widget's ancestor is unsafe` jika terjadi error API.
- **Validasi Input Frontend**: Menambahkan validasi wajib isi pada kolom Judul Aktivitas (node) dan butir soal/jawaban (kuis) di frontend. Ini mencegah error backend `422 Unprocessable Content (title field is required)` saat guru mencoba menyimpan game dengan judul kosong.
- **Mounted Guards**: Menambahkan guard `mounted` pada seluruh handler asinkron di file editor (seperti pick files, save general, delete material/soal/node) untuk mencegah crash asinkron lainnya.

**Next:** Siap untuk pengujian E2E penuh dan validasi pada UI mobile/web.

### 2026-07-09 (malam-4) — Penambahan Editor Game Visual & Perbaikan Popup Jenis Game di Panel Guru

**Yang diselesaikan:**
- **Perbaikan Popup & Pemilihan Game**: Dropdown pemilihan Jenis Game di dialog tambah/edit node Papan Aktivitas guru kini langsung memicu (pop up) visual game editor dialog secara otomatis begitu jenis game dipilih. Tombol "Edit Konten & Soal Game (Visual)" juga disediakan di form agar guru bisa memicu kembali editor visual kapan saja secara manual.
- **Implementasi Visual Game Editor & Fix Lifecycle**:
  - Membuat modal editor visual (`GamePayloadEditorDialog` berupa `StatefulWidget` terpisah) untuk masing-masing tipe game (*Multiple Choice*, *Sorting*, *Matching*, dan *True/False Swipe*).
  - Mengelola instansiasi dan `.dispose()` controller melalui daur hidup widget `StatefulWidget` untuk menyelesaikan masalah exception *TextEditingController was used after being disposed* saat dialog ditutup.
- **Membungkus Field JSON**: Field input raw JSON disembunyikan di dalam `ExpansionTile` untuk menjaga kebersihan visual antarmuka namun tetap dapat diakses oleh user tingkat lanjut.

**Next:** Lakukan uji coba E2E lengkap dan validasi di perangkat riil.

### 2026-07-09 (malam-3) — Fix Game Tidak Muncul di Siswa & Guru serta Bug Duplikasi Node

**Yang diselesaikan:**
- **Bug 1 — Game tidak muncul di papan aktivitas siswa**: Akar masalah: Parsing JSON `payload` dan `submittedAnswer` pada `LearningNode` melempar subtype cast exception jika tipe datanya tidak cocok atau double-serialized. Juga, widget-widget game (`matching_game_card.dart`, `sorting_game_card.dart`, `true_false_swipe_card.dart`, `multiple_choice_card.dart`) mengalami crash jika item ID atau key nilainya berupa integer (akibat cast `as String` yang tidak aman). Diperbaiki dengan safe conversion menggunakan `.toString()` dan parsing Map/String yang adaptif.
- **Bug 2 — Guru tidak bisa mengubah tipe node & edit payload game**:
  - `updateLearningNode` di frontend tidak mengirim parameter `node_type`, sehingga perubahan jenis node dari Konten ke Game di dialog guru tidak tersimpan di server. Diperbaiki dengan menambahkan parameter `nodeType` ke interface & implementasi service.
  - Saat guru menambah game baru, payload JSON kosong dan tidak ada panduan visual untuk mengedit konten game. Diperbaiki dengan meng-auto-populate skeleton JSON template (MCQ, Sorting, Matching, Swipe) secara dinamis begitu guru memilih Jenis Game di editor.
- **Bug 3 — Duplikasi materi di backend menghilangkan deskripsi & urutan node**: Akar masalah di `duplicate()` di `LearningMaterialController.php`: menyalin `$node->description` (seharusnya `$node->body`) dan mengabaikan `$node->order_index`. Diperbaiki dengan menyelaraskan nama field database yang benar.

**Next:** Siap untuk verifikasi E2E lebih lanjut. Seluruh 59 test Laravel backend dan 5 unit test Flutter sukses 100%.

### 2026-07-09 (malam-2) — Fix Bug Soal Kuis Tidak Muncul, Hapus Template Auto-Fill, & Fix EBook Tidak Tampil

**Yang diselesaikan:**
- **Bug 1 — Template auto-fill dihapus dari form tambah soal:** Menghapus dropdown "Pilih dari Soal Template (Opsional)" dari `_showQuestionForm()` di `teacher_material_editor_screen.dart`. Saat guru menambah butir soal baru, form kini selalu kosong tanpa konten template.
- **Bug 2 — Soal tidak muncul di daftar Pre-Test / Post-Test:** Akar masalah: `LearningMaterialController.getQuestions()` di backend mengembalikan `type: 'pre'` / `type: 'post'`, namun filter di `_buildQuestionsTab()` frontend mencari `type == 'pre_test'` / `type == 'post_test'` — sehingga tidak pernah cocok dan soal tidak tampil. Diperbaiki dengan menambahkan pencocokan ganda: `q.type == 'pre_test' || q.type == 'pre'`.
- **Bug 3 — EBook/PDF tidak muncul di siswa setelah update materi:** Akar masalah: Backend `.env` mempunyai `APP_URL=http://localhost` (tanpa port). Fungsi `asset()` Laravel menghasilkan URL `http://localhost/storage/materials/file.pdf` tanpa port `:8000`. Fungsi `_resolvePhotoUrl` di frontend hanya mengganti `localhost:8000` → `192.168.2.93:8000` sehingga URL tanpa port tidak terkonversi dan tidak bisa diakses dari Android.
  - Fix 1 (backend): Mengubah `APP_URL=http://localhost:8000` di `.env`.
  - Fix 2 (frontend): Memperbarui `_resolvePhotoUrl` di `data_models.dart` agar juga menangani `localhost` dan `127.0.0.1` tanpa port, menggunakan regex negative lookahead.

**Next:** Siap untuk verifikasi lanjutan. Restart Laravel dev server agar `.env` baru berlaku (`php artisan serve`).

### 2026-07-09 (malam) — Perbaikan Crash Layout ElevatedButton di Row & Fix API Parameter Kuis

**Yang diselesaikan:**
- **Perbaikan Crash Infinite Width pada ElevatedButton di dalam Row:**
  - **Akar masalah ditemukan:** Tema global `ElevatedButton` di `app_theme.dart` (line 68) mengatur `minimumSize: Size(double.infinity, 48)`. Saat tombol berada di dalam `Row` (yang memberikan constraint width tak terbatas ke child non-flex), ini menghasilkan `BoxConstraints(w=Infinity)` → crash.
  - **`manage_materials_screen.dart`:** Menambahkan `minimumSize: const Size(0, 48)` pada 3 `ElevatedButton` yang berada di dalam `Row` (tombol Impor Template, Input Materi Baru, dan Ubah/Detail di kartu materi).
  - **`teacher_material_editor_screen.dart`:** Menambahkan `minimumSize: const Size(0, 48)` pada 4 `ElevatedButton.icon` yang berada di dalam `Row` (Pilih PDF, Pilih Audio, Tambah Soal, Tambah Langkah). Ini menyelesaikan masalah tab "Informasi Utama" yang tampil kosong/blank saat membuat materi baru.
- **Perbaikan Error "Invalid question type must be pre or post":**
  - Frontend mengirim `?type=pre_test` dan `?type=post_test` ke backend API, tetapi backend (`LearningMaterialController.php` line 166) hanya menerima `?type=pre` atau `?type=post`.
  - Mengubah parameter di `_loadData()` editor dari `'pre_test'`/`'post_test'` menjadi `'pre'`/`'post'`.

**Catatan:**
- Akar masalah utama layout crash ada di tema global (`app_theme.dart` line 68: `minimumSize: Size(double.infinity, 48)`). Ini akan menyebabkan crash pada **semua** `ElevatedButton` yang diletakkan di dalam `Row` tanpa `Expanded`/`Flexible` wrapper, kecuali di-override secara lokal. Pertimbangkan untuk mengubah default tema ini di masa depan jika crash serupa terus muncul di layar lain.

**Next:** Siap untuk verifikasi lanjutan atau deploy.


### 2026-07-09 — Perbaikan Crash Blank Screen & Layout Exception pada Pengelolaan Materi Guru Selesai

**Yang diselesaikan:**
- **Perbaikan Crash Layout (SliverMultiBoxAdaptor & Infinite Width):**
  - **Daftar Materi Guru (`manage_materials_screen.dart`):** Menghapus widget `Expanded` di sekitar deskripsi materi di dalam `_buildMaterialCard`. Hal ini mencegah crash *BoxConstraints forces an infinite height/width* saat me-render grid view dengan `shrinkWrap: true` di dalam `SingleChildScrollView`.
  - **Form Edit/Tambah Materi (`teacher_material_editor_screen.dart`):** Mengganti widget `ListView.separated` di tab Kuis (`_buildQuestionGroup`) dan Papan Aktivitas (`_buildNodesTab`) dengan perulangan inline `for` di dalam `Column`/`ListView`. Hal ini menghindari nested scrollable widgets yang memicu kegagalan asersi `child.hasSize` pada `sliver_multi_box_adaptor.dart` dan menyebabkan layar editor menjadi blank putih.
  - **Dialog Template:** Membungkus dialog pemilihan template di editor dengan `Container` ber-constraint `maxHeight: 400` untuk menghindari layout error.
- **Pengujian & Analisis:** Menjalankan analisis kode `flutter analyze` dan hasilnya bersih tanpa ada error/warning baru (hanya sisa deprecation info bawaan project). Layar tambah dan edit materi kini dapat diakses dengan lancar tanpa crash, sehingga guru dapat menginputkan data materi baru dan menghapus materi yang sudah ada melalui tombol hapus (tong sampah) di AppBar secara aman.

**Next:** Siap memandu user untuk melakukan verifikasi langsung atau deploy.

### 2026-07-09 — Alur Tambah Materi Berurutan (Pre-Test, Media, Game Template, Post-Test) & Sinkronisasi IP Selesai

**Yang diselesaikan:**
- **Sinkronisasi IP WiFi:** Menyelaraskan IP baseUrl Android di `api_constants.dart` menjadi `192.168.2.93:8000` agar sinkron dengan `_resolvePhotoUrl` di `data_models.dart`.
- **Alur Pembuatan Materi Terpadu:** Mengubah penanganan pasca-pembuatan materi kelas baru di `TeacherMaterialEditorScreen` (`_handleSaveGeneral`) agar tidak kembali ke list, melainkan langsung melakukan `pushReplacement` ke halaman editor dalam mode Edit (`/teacher/class/:classId/materials/:materialId/edit`). Hal ini memungkinkan guru menambahkan materi secara berurutan: mengunggah berkas media pembelajaran, lalu langsung diarahkan untuk mengisi Pre-test, Papan Aktivitas Game, dan Post-test.
- **Pencari Soal & Game dari Template:** 
  - Menambahkan dropdown **"Pilih dari Soal Template"** di dialog tambah soal baru (`_showQuestionForm`). Guru kini dapat memilih soal kuis pre/post-test yang sudah ada di template global untuk auto-populate teks pertanyaan dan pilihan jawaban.
  - Menambahkan dropdown **"Pilih dari Node Template"** di dialog tambah node baru (`_showNodeForm`). Guru dapat memilih game interaktif (seperti Sorting, Matching, Swipe, dll.) yang ada di template global untuk auto-populate seluruh data judul, deskripsi, jenis game, dan JSON payload.
- **Refresh List Otomatis:** Menambahkan custom leading `IconButton` (back arrow) pada AppBar editor untuk selalu memanggil `Navigator.pop(context, true)`. Hal ini menjamin daftar materi di `ManageMaterialsScreen` langsung dimuat ulang dan sinkron saat guru kembali dari layar editor.
- **Analisis & Pengujian:** Menjalankan `flutter analyze` (bersih dari error) dan `flutter test` untuk `learning_board_test.dart` (5/5 unit test sukses).

### 2026-07-09 — Perbaikan Layout Flutter & Fitur Kelola/Edit Template Materi Admin Web Selesai

**Yang diselesaikan:**
- **Perbaikan Bottom Overflow Flutter:**
  - Kuis Pre-Post Test (`_QuizView` di `learning_path_screen.dart`): Membungkus pertanyaan dan pilihan jawaban dalam `Expanded(child: SingleChildScrollView(...))` untuk mencegah error layout overflow pada HP/layar kecil.
  - Kartu Materi (`MaterialCard` di `material_card.dart`): Mengubah tata letak kolom menjadi baris horizontal fleksibel menggunakan `IntrinsicHeight` dan `Row`.
  - Galeri Belajar (`learning_gallery_screen.dart`): Mengganti `GridView.builder` dengan `ListView.separated` agar kartu materi tampil rapi secara vertikal selebar layar tanpa batas tinggi statis.
- **Perbaikan Crash Dialog Kelola Materi Guru:** Membungkus `ElevatedButton` di dialog pilih template dan duplikasi materi dalam `SizedBox(width: 72)` untuk membatasi constraint lebar dan mencegah crash *BoxConstraints forces an infinite width*.
- **CRUD Template Materi (Backend & Admin Web):**
  - **Backend:** Menambahkan route `PUT` & `DELETE` untuk `/api/v1/material-templates/{template}` serta metode controller `updateTemplate()` dan `deleteTemplate()` untuk memfasilitasi kelola blueprint materi global.
  - **Admin Web Dashboard:** Menambahkan subtab **"Template Admin"** di menu Manajemen Konten, merender daftar template global, dan membuat full-screen modal editor interaktif untuk memperbarui metadata, butir kuis pre/post-test, dan learning nodes beserta payload game.
  - **Testing:** Membuat unit/feature test `test_admin_material_template_crud` untuk memvalidasi keamanan peran admin dan pembaruan struktur JSON. Seluruh **58 unit test backend sukses**.

**Next:** Siap jika ada revisi tambahan pada mini-game atau tantangan sosial dari user/dosen.

### 2026-07-09 — Fase 1 sampai 6 Selesai (Sinkronisasi, Backend, & Frontend Gamifikasi PULSE Lengkap)

**Yang diselesaikan:**
- **Sinkronisasi & Konflik**: Sinkronisasi repository frontend berhasil dilakukan, konflik file roadmap diselesaikan dengan menggunakan versi remote (e-book dikembalikan sebagai tahap terpisah sebelum Papan Aktivitas).
- **Aset Fisik Fase 1**: Menyiapkan file `storage/app/public/materials/toleransi.pdf` dan `storage/app/public/materials/audio/toleransi_penjelasan.mp3` secara fisik di backend agar materi contoh Toleransi siap dimuat di player/viewer.
- **Seeding Database**: Fresh migrate & seeding ulang seeder `LearningBoardSeeder` di WSL berhasil, data game & test toleransi tersimpan konsisten.
- **Revisi Query & Enum Backend (Fase 2)**: Memperbaiki constraint enum `games_status` (menambah `in_progress`), membenahi validasi dynamic upload `photo`/`caption`, serta menghapus query filter status non-eksisten di tabel pivot `class_student` agar API backend kompatibel dengan client.
- **Testing Lulus 100% (Backend & Frontend)**: Merombak total `StudentFeaturesTest.php` backend menjadi 2 skenario uji (classic & board). Seluruh **58 test Laravel backend lulus 100%** tanpa error. Verifikasi `learning_board_test.dart` frontend Flutter lulus 100% (5/5 tests passed). Hasil `flutter analyze` 100% bersih tanpa error/warning.
- **Alur 4-Langkah Frontend (Fase 3)**: Menyelaraskan alur belajar 4-langkah di Flutter (`_PreTestStep` -> `_EBookStep` -> `_LearningBoardStep` -> `_PostTestStep`) dengan pemanggilan API `completeMedia` untuk meng-unlock Papan Aktivitas.
- **Tinjauan Guru & Sosial (Fase 4)**: Menambahkan field `description` dan `studentName` ke model `ActivityLog` di Flutter. Memperbaiki visualisasi `SocialChallengesReviewScreen` agar me-render cerita esai asli dari siswa (bukan string lokasi `"masyarakat"`) dan menampilkan nama siswa pengirim di kartu review guru.
- **Target Server Lokal**: Mengubah `ApiConstants.baseUrl` agar mengarah secara dinamis ke localhost / `10.0.2.2` (pada Android) dan memastikan dev server backend Laravel di port 8000 WSL aktif. Hal ini mengatasi error "kelas tidak ditemukan" (404) karena mengakses server remote yang belum dimigrasi.
- **Roadmap Update**: Menandai seluruh checklist **Fase 1** sampai **Fase 6** di roadmap (`roadmap-elearning-redesign-pulse-gamifikasi.md`) ke ✅.

**Next:** Siap melakukan deployment final, demo aplikasi ke Rektor, dan monitoring masukan dari pengguna real.

### 2026-07-08 — Fase 2 & 2b: Pembersihan & Pengelolaan Materi Per Kelas Selesai

**Yang diselesaikan:**
- **Pembersihan PULSE Lama (Fase 2)**: Menonaktifkan route instrumen kuesioner PULSE Likert lama di backend (`routes/api.php`) sepenuhnya agar sistem terfokus pada pengukuran objektif baru.
- **Model & Migrasi Template (Fase 2b)**: Membuat tabel `material_templates` dan model `MaterialTemplate.php` di Laravel backend untuk memfasilitasi authoring materi oleh guru berdasarkan bank template admin.
- **REST API Pengelolaan & Duplikasi (Fase 2b)**: Menambahkan endpoint di backend untuk mengambil materi per-kelas (`GET /classes/{id}/materials`), membuat materi kelas (`POST /classes/{id}/materials`), impor template (`POST /classes/{id}/materials/import-template`), mengambil template (`GET /material-templates`), dan menduplikasi materi antar kelas (`POST /materials/{id}/duplicate`).
- **Layar Flutter Web Guru (Fase 2b)**: Membuat layar `ManageMaterialsScreen` (`manage_materials_screen.dart`) yang responsif untuk mengelola materi kelas, mengimpor template dari admin, dan menduplikasi materi ke kelas guru yang lain.
- **Navigasi & Integrasi (Fase 2b)**: Mendaftarkan rute GoRouter `/teacher/class/:classId/materials` dan menyisipkan tombol akses "Kelola Materi Kelas" di halaman detail kelas guru (`ClassDetailScreen.dart`).
- **Seeder & Verifikasi**: Memperbarui `LearningBoardSeeder.php` untuk otomatis merekam materi toleransi ke dalam tabel template materi saat melakukan `migrate:fresh --seed` di WSL. Seluruh unit test lulus 100% dan analisis kode bersih.

### 2026-07-08 — Fase 6: Testing & Demo Selesai

**Yang diselesaikan:**
- Database lokal WSL (`gunawan/Code/civic_pulse_backend`) sukses dimigrasi ulang dan diseed penuh via command `php artisan migrate:fresh --seed`.
- Database lokal kini memiliki data Guru Contoh (`guru@civicpulse.com`), Siswa Contoh (`siswa@civicpulse.com`), kelas **`TOL123`**, serta materi Papan Aktivitas **"Toleransi Antar Umat Beragama"** yang siap digunakan untuk demo Rektor.
- Verifikasi E2E & Unit Test: Seluruh unit test model Riverpod lulus 100% dan `flutter analyze` terverifikasi bersih.
- Menandai checklist Fase 6 di roadmap (`roadmap-elearning-redesign-pulse-gamifikasi.md`) ke ✅.

### 2026-07-08 — Fase 5: Pemilihan Jenjang/Kelas Siswa Setelah Login Selesai

**Yang diselesaikan:**
- `splash_screen.dart`: Mengembalikan redirect unauthenticated ke `/login` (tidak menampilkan Landing Page sebelum login).
- `class_setup_screen.dart`: Menambahkan alur pemilihan jenjang pendidikan (SD, SMP, SMA, PT) setelah siswa berhasil login:
  - Kartu **SMP** dan **SMA** aktif (bisa diklik) untuk memandu proses selanjutnya.
  - Kartu **SD** dan **PT** terkunci (ikon gembok + SnackBar "Segera Hadir").
  - Menampilkan form input kode kelas setelah jenjang dipilih, lengkap dengan tombol "Ubah" untuk mengganti jenjang terpilih.
  - Memperbaiki bug navigasi: Memanggil `ref.invalidate` untuk `studentClassesProvider`, `materialsProvider`, dan `activitiesProvider` segera setelah join kelas berhasil. Hal ini memaksa aplikasi untuk membuang cache kosong yang lama dan memuat data kelas/materi yang baru secara instan di beranda utama siswa.
  - Memperbaiki bug tombol kembali (Back Button): Mengubah fungsi tombol `arrow_back` di AppBar agar melakukan logout terlebih dahulu sebelum berpindah ke `/login`. Hal ini memecahkan masalah redirect loop di mana GoRouter otomatis me-redirect siswa yang login tanpa kelas kembali ke layar setup kelas ketika mereka mencoba menekan tombol kembali.
- `student_home_screen.dart`: Menambahkan pembersihan cache `materialsProvider` and `activitiesProvider` yang serupa saat bergabung kelas melalui BottomSheet di beranda utama agar daftar materi langsung diperbarui.
- `auth_provider.dart`: Mengubah penentuan `needsClassSetup` agar bernilai `true` hanya bagi pengguna dengan peran siswa (`UserRole.student`) yang belum bergabung kelas mana pun. Guru (`UserRole.teacher`) secara otomatis langsung diarahkan ke beranda `/teacher/home`.
- Flutter analyze: **0 issues found** (100% bersih tanpa error/warning).
- Semua item checklist Fase 5 di roadmap di-update ke ✅.

**Keputusan & catatan:**
- Pemilihan jenjang/kelas terjadi sepenuhnya setelah login di bagian akun siswa saja.
- Mengaktifkan dua jenjang: **SMP** dan **SMA**. Jenjang lainnya tetap terkunci sebagai roadmap masa depan.
- Masalah join kelas disebabkan oleh cache state lama (Riverpod provider) yang tidak dibersihkan setelah siswa bergabung kelas baru, sehingga beranda siswa tetap menampilkan "Belum Bergabung Kelas" / kosong. Ini telah diperbaiki dengan metode invalidasi dinamis.



### 2026-07-08 — Testing Unit Test Sukses (Fase 6 Terpenuhi Sebagian)

**Yang diselesaikan:**
- Membuat file unit test baru di `test/features/student/learning/learning_board_test.dart`
- Menguji JSON parsing untuk model `LearningNode` (tipe `content` & `challenge`) serta `NodeCompleteResult`
- Menguji behavior Riverpod provider `learningBoardProvider` dan `pendingSocialChallengesProvider` dengan mock service
- Menjalankan perintah pengujian local `flutter test` dan berhasil lolos **5/5 tests (100% SUKSES)**
- Meng-update checklist Fase 6 di roadmap untuk aktivitas pengujian end-to-end siswa & guru

**Keputusan & catatan:**
- Pengujian local mock mengonfirmasi integrasi model baru dan logic provider berjalan lancar tanpa regression isu
- Hubungan data statis model JSON aman

### 2026-07-08 — Fase 3 Frontend Selesai

**Yang diselesaikan:**
- `data_models.dart`: tambah model `LearningNode`, `NodeCompleteResult`; extend `LearningMaterial` dengan `activityType`, `boardStatus`, `socialEngagementStatus`; extend `ActivityLog` dengan `materialId`, `nodeId`, `reviewStatus`, `teacherScore`
- `service_interfaces.dart`: tambah 3 method baru ke `MaterialServiceInterface` (`getLearningBoard`, `completeNode`, `submitSocialTask`)
- `real_services.dart`: implementasi 3 method API baru di `RealMaterialService`
- `material_provider.dart`: tambah `learningBoardProvider` + `CompleteNodeNotifier` + `completeNodeProvider`
- Widget game baru di `lib/features/student/learning/widgets/challenge_games/`:
  - `content_card.dart` — Kartu Materi teks
  - `multiple_choice_card.dart` — Pilihan Ganda (fallback)
  - `matching_game_card.dart` — Mencocokkan Pasangan (klik kiri → kanan)
  - `sorting_game_card.dart` — Sortir Kategori (drag chip ke bucket DragTarget)
  - `true_false_swipe_card.dart` — Benar/Salah (klik tombol atau swipe kartu)
- `learning_path_screen.dart`: refactor besar —
  - Alur 4-step → **3-step** (Pre-Test → Papan Aktivitas → Post-Test)
  - Routing berdasarkan `activityType`: `learning_board` → `_LearningBoardStep`, `classic_pdf` → tetap `_EBookStep` (backward compat)
  - Tambah `_LearningBoardStep` (load nodes, progress bar, dispatch ke game widget berdasarkan `gameType`)
  - Tambah `_SocialTaskCard` (upload foto + caption, submit ke API, lanjut tanpa menunggu review)
  - **Hapus total** `_PulseStep` dan `_LikertAssessmentView`
- Flutter analyze: **0 errors, 0 warnings** (hanya 3 infos gaya kode)
- Semua 7 item checklist Fase 3 di roadmap di-update ke ✅

**Keputusan & catatan:**
- `SocialTaskCard` sudah termasuk dalam `_LearningBoardStep` (bukan file terpisah), karena itu bagian integral dari alur board
- `image_picker: ^1.0.7` sudah ada di `pubspec.yaml` dari sebelumnya — tidak perlu `flutter pub add`
- Backward compatibility: materi `classic_pdf` lama tetap pakai `_EBookStep` biasa — tidak ada perubahan alur untuk materi lama

**Next:** Mulai **Fase 4 — Tantangan Sosial + review guru**:
- `SocialTaskCard` sudah ada di dalam `learning_path_screen.dart`
- Yang belum: halaman guru untuk **review antrean Tantangan Sosial** (list pending) + form approve/reject + skor 1-5
- Paralel (opsional di sesi ini): **Fase 2b** — endpoint backend `GET /classes/{classId}/materials` + layar Flutter Web untuk guru kelola materi



### 2026-07-08 — Fase 2 Backend Selesai, Siap Fase 3 Frontend

**Yang diselesaikan:**
- Mengimplementasikan semua sisa controller backend Fase 2:
  - `ActivityController::reviewSocialChallenge` — guru approve/reject tantangan sosial + hitung ulang PULSE score
  - `TeacherController::getSocialChallenges` — guru melihat antrean tantangan sosial pending dari siswanya
  - `MaterialResource` diperbarui total: kini membaca dari `StudentMaterialProgress` (bukan dari `TestResponse`/`PulseResponse` langsung), dengan backward compatibility untuk materi tipe `classic_pdf`
- Membuat migrasi baru `2026_07_08_051600_create_student_pulse_scores_table.php` (tabel ini belum ada sebelumnya, menyebabkan test gagal)
- Membuat `LearningBoardSeeder` dengan data penuh:
  - Guru (`guru@civicpulse.com`), Siswa (`siswa@civicpulse.com`), Kelas X-A
  - Materi "Toleransi Antar Umat Beragama" tipe `learning_board`
  - 5 soal Pre-Test + 5 soal Post-Test
  - 9 Learning Node (3 konten + 1 sorting + 1 matching + 1 swipe + 1 MC + 1 social_task)
- Menambah `$attributes` default di model `StudentMaterialProgress` sehingga `firstOrCreate` langsung mengembalikan status awal yang benar
- Menambah `LearningBoardSeeder` ke `DatabaseSeeder`
- Checklist Fase 2 di roadmap di-update (hampir semua ✅, kecuali "Hapus pulse_statements" yang sengaja dibiarkan)
- Semua **57 test Laravel lulus** ✅

**Keputusan & catatan:**
- `pulse_statements` & `pulse_responses` belum dihapus/dinon-aktifkan — dibiarkan agar materi lama (`classic_pdf`) tetap bisa jalan dengan alur lama
- `MaterialResource` mendukung dua mode: `classic_pdf` (alur lama) dan `learning_board` (alur baru)
- `student_pulse_scores` adalah tabel baru yang disimpan terpisah dari `student_material_progress`

**Next:** Mulai **Fase 3 — Frontend Flutter: Learning Board**.
- Implementation plan sudah dibuat, menunggu konfirmasi user atas 2 pertanyaan:
  1. Alur 4-step baru: Pre-Test → Media → Game Board → Post-Test — apakah sudah benar?
  2. Materi lama `classic_pdf` tetap pakai alur 3-step lama — apakah backward compatibility ini sudah benar?
- Setelah konfirmasi, mulai dari: update `data_models.dart` (tambah `LearningNode` + field baru di `LearningMaterial`), lalu `service_interfaces.dart`, `real_services.dart`, providers, game widgets, dan akhirnya `learning_path_screen.dart`.

### 2026-07-08 — Review Fase 1 Selesai, Mulai Fase 2
- Melakukan review konten materi "Toleransi Antar Umat Beragama" dengan user/dosen.
- Menyepakati alur pembelajaran berurutan: Pre-Test -> Media (PDF & Audio bersamaan) -> Games (Sorting, Matching, Swipe, Social Task) -> Post-Test.
- Memperbarui checklist Fase 1 di [roadmap-elearning-redesign-pulse-gamifikasi.md](file:///c:/Latihan%20coding/Jokian/mobile/civic_pulse/docs/superpowers/roadmap-elearning-redesign-pulse-gamifikasi.md) menjadi selesai.
- Menyesuaikan rencana database untuk mendukung `audio_url` di `learning_materials` dan memfokuskan `learning_nodes` sebagai game.
- **Next:** Menyusun rencana implementasi (Implementation Plan) untuk migrasi database & API endpoint backend Laravel (Fase 2).

### 2026-07-08 — Draf Konten Toleransi Selesai (Fase 1)
- Melakukan `git pull` untuk memperbarui berkas repositori dengan dokumen inisiatif redesain e-learning.
- Menyusun dokumen draf lengkap [toleransi-materi-content.md](file:///c:/Latihan%20coding/Jokian/mobile/civic_pulse/docs/superpowers/toleransi-materi-content.md) yang mendefinisikan 5 soal pre-test, isi data payload untuk 9 kotak Papan Aktivitas (kartu sortir, pencocokan pasangan, swipe benar/salah, pilihan ganda, dan aksi sosial), serta 5 soal post-test.
- Memperbarui checklist Fase 1 di [roadmap-elearning-redesign-pulse-gamifikasi.md](file:///c:/Latihan%20coding/Jokian/mobile/civic_pulse/docs/superpowers/roadmap-elearning-redesign-pulse-gamifikasi.md).
- **Next:** Menunggu konfirmasi review draf materi contoh dari pengguna/dosen sebelum melangkah ke Fase 2 (Migrasi Database Backend).

### 2026-07-08 — Setup GEMINI.md & PROGRESS.md
- Dibuat oleh Claude Code atas permintaan user, sebagai sistem kerja untuk sesi Gemini (Antigravity) berikutnya.
- Belum ada kode yang diubah untuk inisiatif redesain PULSE. Dokumen roadmap sudah final (lihat bagian "Status Saat Ini" di atas).
- **Next:** mulai Fase 1 di roadmap — finalisasi isi lengkap materi contoh "Toleransi Antar Umat Beragama" (bagian 4 roadmap) sebagai bahan demo, sebelum mulai coding Fase 2 (migrasi skema backend).
