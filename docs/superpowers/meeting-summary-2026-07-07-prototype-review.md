# Ringkasan Meeting Review Prototype CivicPulse (2026-07-07)

Sumber: `GMT20260707-122048_Recording.cc.vtt`

# RINGKASAN EKSEKUTIF

Meeting ini merupakan sesi presentasi prototype aplikasi mobile **CivicPulse** yang dibawakan oleh Andre (didampingi tim pengembang, disebut juga Dimas, serta dibantu Kak Lima dan Juli dalam analisis proposal & desain Figma) kepada seorang pembimbing/reviewer (disapa "Pak") dan seorang peserta lain (disapa "Mbak"). Presentasi dilakukan secara sekuensial: berpindah dari satu halaman ke halaman lain sambil menjelaskan alur registrasi, pembelajaran, skor, hingga panel admin, lalu menerima masukan langsung.

Tujuan utama meeting adalah menyiapkan aplikasi sebelum rencana presentasi ke Rektor pada **tanggal 10** — sehingga tim harus siap menjelaskan dan mempertanggungjawabkan setiap keputusan desain.

Respons umum peserta terhadap progres teknis cukup positif — fitur dasar (registrasi, join kelas, CRUD materi, soal pre/post-test, skor otomatis, panel admin) dinilai sudah cukup lengkap dan berjalan baik. Namun ada **kritik besar dan mendasar**: proses pembelajaran yang mencerminkan PULSE (terutama Partisipasi dan Keterlibatan Sosial) belum benar-benar "terlihat" dalam aplikasi. Alur saat ini (baca materi PDF → post-test) dinilai tidak berbeda dari sekadar membaca Wikipedia atau bertanya ke ChatGPT, sehingga tidak ada alasan kuat bagi pengguna untuk memakai aplikasi khusus ini. Reviewer meminta agar partisipasi dan keterlibatan sosial diukur lewat aktivitas/games nyata yang terintegrasi dengan materi, bukan lewat angket self-report yang bisa dimanipulasi siswa (subjektif). Reviewer juga meminta redesain tampilan awal (landing page pemilihan jenjang pendidikan) agar terlihat lebih elegan, mengikuti gaya aplikasi GaneshaAR/Penglipuran yang pernah dikembangkan tim sebelumnya.

---

# ALUR PRESENTASI & MASUKAN PER HALAMAN

## 1. Registrasi & Login (Siswa)

*   **Penjelasan/Fitur yang Ditunjukkan:** Andre mendemokan proses pendaftaran akun baru sebagai siswa (contoh akun "siswa 3"), pengisian password, hingga login.
*   **Masukan & Kritik dari Peserta:** Tidak ada kritik signifikan pada tahap ini; sesi masih bersifat penjelasan alur dasar.

## 2. Halaman Setelah Login — Belum Bergabung Kelas

*   **Penjelasan/Fitur yang Ditunjukkan:** Andre menunjukkan tampilan siswa yang belum join kelas — kode kelas harus dibagikan oleh guru terlebih dahulu agar siswa bisa bergabung.
*   **Masukan & Kritik dari Peserta:** Tidak ada catatan khusus; peserta meminta lanjut mencoba login sebagai akun guru.

## 3. Beranda Guru — Daftar Kelas & Siswa

*   **Penjelasan/Fitur yang Ditunjukkan:** Guru bisa melihat kode kelas, jumlah total siswa (di demo ada 2-3 siswa), dan status aktivitas masing-masing siswa (siapa yang sudah/belum beraktivitas di materi).
*   **Masukan & Kritik dari Peserta:** Belum ada kritik pada tahap ini.

## 4. Halaman Materi Pembelajaran (Free Test → Materi → Post-Test → Assessment Pulse)

*   **Penjelasan/Fitur yang Ditunjukkan:** Setelah siswa join kelas, materi otomatis menyesuaikan kelas siswa. Alur belajar terdiri dari 4 tahap berurutan: **Free Test (pre-test)** → **Materi (bacaan/PDF)** → **Post-Test** → **Assessment PULSE**. Soal pre/post-test berbentuk pilihan ganda (A/B/C).
*   **Masukan & Kritik dari Peserta:** Ini adalah titik kritik terbesar dalam meeting — proses belajar dinilai **hanya sebatas membaca PDF lalu mengerjakan post-test**, yang tidak menunjukkan partisipasi/keterlibatan sosial siswa secara nyata. Reviewer menyamakan ini dengan sekadar membaca Wikipedia atau bertanya ke ChatGPT — tidak ada nilai tambah aplikasi. Diminta agar antara Free Test dan Post-Test disisipkan **aktivitas/mini-game interaktif** yang isinya mencerminkan materi (misal materi toleransi → game "harta karun" bertema toleransi; materi Pancasila → game ular tangga dengan tantangan di tiap kotak), sehingga partisipasi, proses belajar, pemahaman, dan keterlibatan sosial bisa terukur objektif dari aktivitas itu sendiri — bukan dari angket self-report.

## 5. Halaman Skor & Ringkasan Pulse (Siswa)

*   **Penjelasan/Fitur yang Ditunjukkan:** Menampilkan persentase capaian per materi: partisipasi, pemahaman, pembelajaran, keterlibatan sosial, serta persentase pre-test dan post-test.
*   **Masukan & Kritik dari Peserta:** Perhitungan skor dikonfirmasi otomatis dan berbasis persentase rasio benar/salah dari jumlah aktivitas per dimensi (misal tiap dimensi bobot 25% jika ada 4 komponen). Tidak ada kritik besar di sisi teknis perhitungan, hanya sebagai dasar diskusi soal makna "PULSE" itu sendiri (lihat diskusi konsep di bawah).

## 6. Halaman Aktivitas (Tambah/Edit/Hapus Aktivitas Siswa)

*   **Penjelasan/Fitur yang Ditunjukkan:** Siswa dapat menambah aktivitas (misalnya unggah foto) melalui menu terpisah dari alur materi; detail aktivitas bisa diedit dan dihapus.
*   **Masukan & Kritik dari Peserta:** Reviewer mempertanyakan kenapa fitur aktivitas ini terpisah dari alur pembelajaran materi — seharusnya aktivitas yang dicatat siswa **terintegrasi dan mencerminkan materi yang sedang dipelajari**, bukan aktivitas bebas/sembarangan yang tidak berkaitan.

## 7. Halaman Profil (Siswa & Guru)

*   **Penjelasan/Fitur yang Ditunjukkan:** Siswa dan guru dapat mengedit profil masing-masing; di halaman profil siswa juga tampil ringkasan skor Pulse (partisipasi, pemahaman, pembelajaran, keterlibatan).
*   **Masukan & Kritik dari Peserta:** Tidak ada catatan khusus.

## 8. Dashboard/Beranda Guru — Ringkasan per Siswa & Kelas

*   **Penjelasan/Fitur yang Ditunjukkan:** Guru bisa melihat persentase capaian tiap siswa (contoh: siswa 3 — pre-test 0%, post-test 100%, peningkatan 100%), memberi catatan pada tiap aktivitas siswa, serta menambah/menghapus aktivitas siswa dari sisi guru. Guru juga melihat ringkasan kelas (jumlah siswa, jumlah catatan).
*   **Masukan & Kritik dari Peserta:** Tidak ada kritik besar, disebutkan sebagai fitur sudah cukup baik.

## 9. Panel Admin

*   **Penjelasan/Fitur yang Ditunjukkan:** Admin dapat melihat total guru dan siswa terdaftar di sistem.
*   **Masukan & Kritik dari Peserta:** Tidak ada catatan khusus.

## 10. Admin — Manajemen Materi

*   **Penjelasan/Fitur yang Ditunjukkan:** Admin menambahkan materi baru (judul, deskripsi, upload file/PDF) yang nantinya otomatis muncul sesuai kelas siswa.
*   **Masukan & Kritik dari Peserta:** Konsisten dengan kritik utama — konten materi hanya berupa unggahan dokumen statis, tidak ada elemen interaktif/pembelajaran aktif.

## 11. Admin — Manajemen Free Test / Post-Test / Instrumen Pulse

*   **Penjelasan/Fitur yang Ditunjukkan:** Admin bisa mengunggah soal via template Excel (import massal) atau input manual (pertanyaan, opsi jawaban, kunci jawaban benar) untuk Free Test, Post-Test, dan instrumen Pulse.
*   **Masukan & Kritik dari Peserta:** Tidak ada kritik khusus pada mekanisme input soal itu sendiri.

## 12. Tampilan Awal Aplikasi (Landing Page — Pemilihan Jenjang Pendidikan)

*   **Penjelasan/Fitur yang Ditunjukkan:** Andre menunjukkan kembali tampilan paling awal saat aplikasi dibuka (sebelum login/join kelas).
*   **Masukan & Kritik dari Peserta:** Diminta redesain agar menyerupai gaya **GaneshaAR/Penglipuran** — menampilkan pilihan jenjang **SD, SMP, SMA, Perguruan Tinggi**, namun untuk tahap ini cukup **SMA (atau SMP+SMA) saja yang aktif/bisa diklik**, sisanya dikunci sebagai gambaran roadmap pengembangan ke depan. Tujuannya agar tampilan lebih "elegan" dan meyakinkan saat didemokan ke Rektor. Alur setelah memilih jenjang → pilih kelas (mis. kelas 10) → langsung ke beranda (bukan ditanyakan ulang saat proses registrasi terpisah, agar tidak membingungkan).

## 13. [Diskusi Konsep] Makna PULSE & Konsep Gamifikasi Proses Belajar

*   **Penjelasan/Fitur yang Ditunjukkan:** Bukan navigasi halaman, melainkan diskusi mendalam tentang makna singkatan PULSE: **P**artisipasi (keterlibatan aktif), **U**nderstanding/Pemahaman, **L**earning/proses belajar, **S**ocial Engagement/keterlibatan sosial.
*   **Masukan & Kritik dari Peserta:** Reviewer menegaskan keempat dimensi ini **tidak bisa diukur lewat angket** karena bersifat subjektif (siswa bisa mengisi "aktif" walau sebenarnya tidak). Harus diukur dari aktivitas nyata siswa selama proses belajar — misalnya lewat mini-game bertema materi, atau instruksi melakukan kegiatan sosial nyata (contoh: gotong royong membersihkan selokan) yang didokumentasikan lewat foto/video dan dievaluasi manual oleh guru. Reviewer juga mengingatkan bahwa aplikasi tetap harus berbentuk **mobile app** (sesuai proposal), bukan web — sehingga integrasi dengan proyek AR/VR (Penglipuran) yang sebelumnya berbasis web tidak bisa langsung dipakai ulang dan perlu dibangun ulang untuk platform mobile.

---

# DAFTAR TINDAKAN & REVISI (ACTION ITEMS)

*   **Prioritas Tinggi (Harus Segera Diperbaiki/Mendesak):**
    *   Redesain tampilan awal aplikasi (landing page) menjadi pemilihan jenjang SD/SMP/SMA/Perguruan Tinggi bergaya GaneshaAR/Penglipuran, dengan hanya SMA (atau SMP+SMA) yang aktif untuk fase ini — Andre.
    *   Rancang ulang alur pembelajaran (antara Free Test dan Post-Test) agar menyisipkan aktivitas/mini-game yang mencerminkan materi dan mengukur PULSE secara langsung, menggantikan alur "baca PDF lalu langsung post-test" — Andre & tim.
    *   Pastikan tim siap menjelaskan ke Rektor bahwa aplikasi ini adalah mobile app sesuai proposal (bukan web), dan integrasi konten AR/VR sebelumnya memerlukan pengembangan ulang — Andre.
    *   Selesaikan revisi alur di atas dalam estimasi ±2 minggu sebelum presentasi ke Rektor tanggal 10.

*   **Prioritas Menengah (Saran/Fitur Tambahan):**
    *   Rancang minimal beberapa contoh mini-game konkret per topik materi (mis. game "harta karun" untuk materi toleransi, game "ular tangga" dengan tantangan per kotak untuk materi Pancasila).
    *   Bangun fitur "aktivitas sosial nyata" di mana siswa mengunggah bukti dokumentasi (foto/video) kegiatan, dan guru mengevaluasi/memberi skor secara manual sebagai instrumen partisipasi/keterlibatan sosial yang lebih objektif.
    *   Integrasikan menu Aktivitas Siswa (saat ini terpisah) ke dalam alur materi, sehingga aktivitas yang dicatat konsisten dengan topik materi yang sedang dipelajari, bukan aktivitas bebas.
    *   Evaluasi ulang kebutuhan fitur pengaturan Bahasa Inggris — jika memerlukan rombak besar, boleh disembunyikan/nonaktifkan dulu untuk fase ini.
    *   Pertimbangkan mengintegrasikan proyek AR/VR (Penglipuran) yang sudah ada sebagai salah satu aktivitas/game dalam CivicPulse versi mobile, agar tidak membangun dari nol.

*   **Ide Masa Depan (Disimpan untuk pengembangan selanjutnya):**
    *   Membuka jenjang pendidikan lain (SD, Perguruan Tinggi) yang saat ini masih dikunci sebagai roadmap jangka panjang.
    *   Kemungkinan Rektor sendiri menggunakan aplikasi ini untuk mengajar mata kuliah PPKn ke mahasiswa.
    *   Pengembangan lebih banyak variasi game/aktivitas gamifikasi untuk tiap materi ke depannya.

---

# CATATAN PERTANYAAN YANG BELUM TERJAWAB

*   Bentuk konkret "game" untuk tiap topik materi belum ditentukan — Andre sendiri mengakui masih "stuck" dan belum punya contoh nyata (judul materi apa, bentuk game seperti apa, cara penilaiannya) sehingga perlu didiskusikan/dirancang lebih lanjut sebelum development dimulai.
*   Skema teknis penilaian PULSE di dalam game (bagaimana tepatnya keempat dimensi diukur otomatis dari interaksi game) baru dijelaskan secara konsep, belum ada spesifikasi teknis.
*   Kejelasan status keanggotaan tim pengembang — sempat ditanyakan apakah "Gunawan" ikut bergabung dalam tim, namun jawaban di transkrip kurang jelas (disebutkan nama "Lima" dan "Juli" sebagai bagian tim).
*   Keputusan final terkait fitur Bahasa Inggris — apakah tetap dikerjakan minimal, atau dihapus total dari rencana jangka pendek, belum diputuskan secara pasti.
