Ringkasan Eksekutif Aplikasi CivicPulse

1. Identitas Aplikasi

Nama Aplikasi: CivicPulse

Deskripsi Singkat: Sebuah sistem Integrated Analytics Dashboard dan E-Learning berbasis aplikasi mobile dan web untuk memonitoring metrik PULSE (Participation, Understanding, Learning, dan Social Engagement) peserta didik dalam konteks pendidikan multikultural dan kewarganegaraan.

2. Latar Belakang

Pengembangan CivicPulse didasari oleh fenomena dalam pendidikan kewarganegaraan dan multikultural di mana implementasi pembelajaran di sekolah masih cenderung berorientasi pada capaian kognitif semata. Dimensi non-kognitif yang krusial seperti partisipasi aktif, refleksi sosial, dan sensitivitas multikultural belum dimonitor secara sistematis dan berkelanjutan. Saat ini, guru dan sekolah umumnya belum memiliki instrumen digital yang memadai untuk memantau perkembangan sikap dan perilaku kewarganegaraan siswa secara komprehensif, terintegrasi, dan realtime.

3. Tujuan Pengembangan

Menyediakan platform digital terintegrasi yang menjembatani kesenjangan antara pembelajaran konseptual (kognitif) dengan praktik kewargaan yang kontekstual (non-kognitif).

Memfasilitasi guru dan sekolah dengan instrumen analytics berbasis data (data-driven) untuk mendukung pengambilan keputusan pedagogis yang lebih akurat.

Mendorong peningkatan kesadaran, partisipasi, toleransi, dan keterlibatan sosial siswa di lingkungan yang majemuk.

4. Target Pengguna

Pengguna Langsung (Guru & Staf): Guru Pendidikan Pancasila/Kewarganegaraan, Wali Kelas, Guru Bimbingan Konseling (BK), dan Administrator Sekolah.

Pengguna Tidak Langsung/Subjek (Siswa): Peserta didik di tingkat pendidikan dasar dan menengah (SD, SMP, SMA/SMK sederajat).

5. Penjelasan Detail Fitur Aplikasi

Aplikasi dirancang dengan alur sistematis, mulai dari pintu masuk (autentikasi) hingga antarmuka (UI) fungsional yang disesuaikan dengan peran (role) masing-masing pengguna:

A. Fitur Autentikasi & Akses

Sebagai gerbang utama aplikasi, sistem menyediakan mekanisme keamanan dan identifikasi pengguna:

Registrasi Akun: Pengguna baru mendaftarkan diri dengan mengisi Email, Password, Nama Lengkap, dan memilih Role (Siswa/Guru).

Pengaturan Kelas (Post-Registration Prompt): \* Bagi Guru: Opsi membuat kelas baru dengan menentukan jenjang (SMP/SMA) dan tingkat kelas. Sistem akan men-generate "Kode Kelas" unik.

Bagi Siswa: Prompt untuk memasukkan "Kode Kelas" agar terdaftar di kelas yang tepat.

Login Terpusat & Smart Routing: Pengguna masuk menggunakan Email dan Password. Sistem otomatis mengarahkan ke antarmuka yang sesuai (Siswa ke menu belajar/asesmen, Guru ke menu monitoring).

B. Fitur Antarmuka Siswa (Mobile App)

Antarmuka siswa dirancang agar interaktif dan ramah pengguna (user-friendly) dengan alur navigasi berbasis tab di bagian bawah layar (Bottom Navigation Bar). Setelah berhasil login, siswa akan menavigasikan menu-menu berikut:

Beranda Utama (Home Screen):

Layar pertama yang menyambut siswa dengan sapaan personal dan menampilkan kartu kelas tempat mereka bernaung (misal: "Kelas VII-A - Pendidikan Pancasila").

State Belum Terhubung (Empty State): Jika siswa belum memasukkan Kode Kelas, layar beranda akan menampilkan ilustrasi/ikon kosong dengan teks "Kamu belum bergabung dengan kelas manapun" dan sebuah tombol CTA besar bertuliskan "Masukkan Kode Kelas". Selama belum terhubung dengan sebuah kelas, tab-tab lain (Belajar, Aktivitas, Skor) akan memunculkan pop-up "Terkunci" jika diklik.

Jika sudah terhubung, terdapat widget ringkasan progres belajar harian (misal: "2 Materi belum diselesaikan") dan ikon lonceng di sudut atas untuk melihat pesan peringatan/motivasi dari guru.

Tab Belajar & Asesmen (Modul Terintegrasi):

Galeri Materi: Saat tab ini dibuka, siswa dihadapkan pada galeri kartu bergambar yang memuat topik-topik pendidikan multikultural.

Alur Pembelajaran Wajib (Learning Path): Saat sebuah kartu materi diklik, siswa tidak bisa melompat-lompat, melainkan harus mengikuti alur:

Pre-Test: Layar menampilkan kuis pilihan ganda untuk uji pemahaman awal.

E-Book Viewer: Layar membuka penampil dokumen PDF bawaan (in-app) tempat siswa membaca modul literasi.

Post-Test: Kuis evaluasi akhir. Setelah disubmit, akan muncul pop-up grafis interaktif yang membandingkan skor Pre-Test dan Post-Test siswa.

Asesmen Refleksi (PULSE): Sebagai tahap penutup materi, layar akan beralih ke formulir survei dengan slider atau tombol radio skala Likert (1-5). Di sini siswa mengevaluasi diri mereka sendiri berdasarkan pernyataan perilaku (misal: "Saya ikut aktif dalam diskusi kelas" atau "Saya menghargai pendapat yang berbeda").

Tab Aktivitas Kewargaan (Activity Logs):

Berfungsi sebagai buku harian digital siswa (digital diary). Layar ini menampilkan daftar bergulir (scrollable list) dari riwayat kontribusi sosial atau praktik baik yang pernah mereka lakukan (seperti piket kelas, menjenguk teman, atau ikut forum diskusi agama).

Siswa dapat menekan tombol melayang "+ Tambah Aktivitas" (Floating Action Button). Aplikasi akan membuka form isian sederhana (Judul Kegiatan, Tanggal, Pilihan Kategori PULSE) dan tombol kamera untuk memotret/mengunggah foto bukti kegiatan secara langsung.

Tab Skor & Umpan Balik (Feedback):

Layar ini bertindak sebagai "Rapor Karakter" mini milik siswa. Menampilkan visualisasi data berupa grafik jaring laba-laba (radar chart) atau diagram batang berwarna yang memetakan skor metrik PULSE mereka.

Di bawah grafik, terdapat kotak "Rekomendasi Pintar" berisi kalimat motivasi yang dihasilkan otomatis oleh sistem (misal: "Pemahaman teorimu sangat baik, yuk mulai beranikan diri untuk lebih aktif berpartisipasi saat diskusi kelas!").

Tab Profil:

Menampilkan pasfoto siswa, biodata dasar, tombol pengaturan/keluar (logout).

C. Fitur Antarmuka Guru (Mobile App)

Berfungsi sebagai alat pemantauan portabel yang praktis bagi guru. Sama seperti antarmuka siswa, aplikasi versi guru didesain dengan menu navigasi global di bagian bawah layar (Bottom Navigation Bar) untuk mempercepat perpindahan konteks:

Tab Beranda Utama (Home Screen):

Menampilkan "Daftar Kelas" yang diampu oleh guru dalam bentuk susunan kartu visual (misal: Kartu "Kelas VII-A", "Kelas VIII-B").

Terdapat tombol aksi melayang (Floating Action Button) berupa ikon "+" di sudut kanan bawah untuk membuat kelas baru dengan cepat.

Tab Notifikasi Global (Alerts):

Pusat pemberitahuan otomatis dari Rules Engine. Alih-alih mengecek kelas satu per satu, guru dapat langsung melihat daftar siswa dari seluruh kelas yang membutuhkan atensi mendesak (misal: ada siswa yang skor interaksi sosialnya turun drastis minggu ini).

Tab Profil:

Menampilkan identitas guru, pengaturan akun, pusat bantuan/tutorial penggunaan, dan menu keluar (logout).

Alur Detail Kelas (Class Dashboard):
Saat guru mengetuk salah satu kartu kelas di "Tab Beranda", aplikasi akan membuka layar spesifik untuk memonitor kelas tersebut. Layar ini menggunakan menu navigasi atas (Top Tab Bar) yang bisa digeser (swipe) agar tampilan lebih rapi dan fokus:

Tab Ringkasan (Quick Dashboard): Menampilkan grafik donut atau diagram batang sederhana mengenai performa kelas harian/mingguan. Guru dapat melihat persentase agregat ketuntasan E-Learning serta rata-rata tingkat partisipasi kelas secara sekilas.

Tab Daftar Siswa: Menampilkan senarai nama siswa di kelas tersebut. Terdapat indikator titik warna (Hijau/Kuning/Merah) di samping setiap nama sebagai visualisasi cepat status perilaku atau nilai siswa.

Tab Pengaturan Kelas: Menu khusus untuk meninjau "Kode Kelas", menyetujui permintaan bergabung siswa baru, dan tombol pintas "Bagikan Kode via WhatsApp".

Profil Individual Siswa & Catatan Observasi (Anecdotal Notes):

Jika guru menekan nama salah satu siswa (baik melalui daftar siswa maupun panel notifikasi), aplikasi akan menavigasikan guru ke Profil Detail Siswa.

Layar ini berfungsi sebagai rapor portabel. Guru dapat meninjau rincian nilai tes kognitif, grafik riwayat metrik PULSE, serta mengecek log bukti aktivitas kewargaan (foto-foto kegiatan) yang telah diunggah oleh siswa bersangkutan.

Di bagian paling bawah layar profil, terdapat tombol besar "+ Tambah Catatan Observasi". Saat ditekan, akan muncul form input di mana guru bisa mengetik langsung catatan kualitatif harian saat mengajar (misal: "Budi terlihat pasif dan kurang membaur di kelompok saat materi toleransi"). Catatan ini akan otomatis tersinkronisasi dan melengkapi data analitik kuantitatif siswa di database.

D. Fitur Analytics Dashboard & CMS (Web untuk Guru & Admin)

Diakses melalui layar lebar PC/Laptop, antarmuka ini didesain menggunakan tata letak Sidebar Navigation (menu di sisi kiri) dan Main Content Area (area kerja di tengah) agar pengguna dapat melihat tabel data dan grafik dengan leluasa. Terdapat pemisahan hak akses dan alur UI yang jelas:

Alur Antarmuka Admin (Administrator View):
Admin tidak melihat data detail individu kelas, melainkan berfokus pada manajemen operasional sistem.

Menu Dasbor Utama (System Overview): Menampilkan panel statistik global berupa cards (misal: Total Guru Terdaftar, Total Siswa Aktif, dan Total Materi tersedia).

Menu Manajemen Pengguna: Berisi tabel pangkalan data akun (Guru & Siswa). Admin disediakan tombol aksi (action buttons) di setiap baris tabel untuk menambah akun baru, memverifikasi email, mengedit password (jika ada yang lupa), atau menonaktifkan akun.

Menu Manajemen Konten (CMS E-Learning): Area kerja drag-and-drop bagi admin untuk menyusun database materi.

Navigasi Berjenjang: Admin memilih tab "SMP" atau "SMA", lalu mengklik sub-folder "Kelas 7" hingga "Kelas 12".

Form Input Terpadu: Di dalam folder kelas, admin disajikan formulir untuk mengunggah file E-Book PDF, membuat soal Pre/Post-Test menggunakan antar muka Quiz Builder dinamis (tambah opsi A, B, C, D), dan menyusun instrumen skala Likert untuk asesmen PULSE.

Alur Antarmuka Guru (Teacher View):
Guru langsung difokuskan pada analitik siswa dan kelas yang diampunya tanpa direcoki urusan input materi. 4. Beranda (Home): Guru disambut dengan deretan Kartu "Kelas Anda". Dengan mengklik tombol "Buka Dasbor" pada sebuah kelas, UI akan beralih ke dalam Ruang Analitik Kelas khusus. 5. Ruang Analitik Kelas - Menu Ringkasan Indikator: Menampilkan kanvas visualisasi grafis komprehensif. Terdapat diagram batang (kognitif) dan grafik jaring/radar (PULSE) untuk performa rata-rata kelas. Di bagian atas, terdapat Filter Bar canggih untuk mengubah rentang tanggal atau memfilter berdasarkan topik tertentu. 6. Ruang Analitik Kelas - Menu Rekapitulasi & Heatmap: Layar menampilkan Data Table interaktif (bisa diurutkan dan difilter) yang memuat seluruh nama siswa secara vertikal, dan dimensi nilai/PULSE secara horizontal. Setiap sel nilai otomatis diberikan indikator warna/ heatmap (Hijau=Aman, Kuning=Peringatan, Merah=Butuh Perhatian), sehingga guru dapat langsung melihat "anomali" tanpa harus menganalisis angka satu per satu. 7. Menu Penelusuran & Catatan Observasi: Layar terbagi dua panel (split-screen). Sisi kiri menampilkan linimasa riwayat Activity Logs siswa beserta thumbnail foto buktinya. Sisi kanan adalah area form khusus guru untuk mengetik dan mengevaluasi "Catatan Observasi" kualitatif harian dengan leluasa menggunakan keyboard PC/Laptop. 8. Menu Laporan (Reporting): Fitur generator laporan yang ringkas. Guru cukup memilih dropdown kelas, mencentang metrik apa saja yang ingin dilampirkan, lalu menekan tombol "Ekspor PDF" atau "Unduh Excel" untuk kebutuhan arsip/akreditasi sekolah.

6. Arsitektur & Spesifikasi Teknis Utama

Sistem CivicPulse dibangun dengan arsitektur Client-Server modern:

Frontend (Mobile App & Web Dashboard): Menggunakan Flutter (Dart). Memungkinkan codebase tunggal untuk diekspor menjadi aplikasi Android (bagi siswa & guru portabel) dan aplikasi Web (untuk Analytics Dashboard), mempercepat proses development dan pemeliharaan. Manajemen state menggunakan Riverpod/Provider/BLoC.

Backend & API Service: Menggunakan arsitektur RESTful API dengan framework Laravel (PHP). Bertugas menangani Data Ingestion & Validation, Processing & Scoring Engine (penghitungan skor instrumen & tren waktu), serta autentikasi aman melalui Laravel Sanctum (RBAC).

Rancangan Database: Menggunakan MySQL dengan skema relasional terstruktur untuk mengakomodasi aliran data realtime dan historis (longitudinal). Entitas utamanya didetailkan sebagai berikut:

users: Menyimpan kredensial (email, password), profil (nama_lengkap), dan otorisasi (role: Admin, Guru, Siswa).

classes: Menyimpan data jenjang SMP/SMA, tingkat_kelas 7-12, guru_id sebagai pengampu, dan kode_kelas unik. Dilengkapi tabel relasi pivot class_students untuk mendata siswa yang tergabung di kelas tersebut.

learning_materials (Modul E-Learning): Dikelola oleh Admin, memuat judul, deskripsi, tingkat_kelas sasaran, dan URL file PDF (E-Book).

instruments (Bank Soal & Survei): Terdiri dari tabel questions (butir soal pilihan ganda Pre-Test/Post-Test beserta kunci jawaban) dan pulse_instruments (kumpulan butir pernyataan skala Likert yang dipetakan pada dimensi P, U, L, atau SE).

responses (Data Interaksi Siswa): Memisahkan tabel test_responses (menyimpan jawaban dan skor kognitif tes) dan pulse_responses (menyimpan input metrik skala 1-5). Keduanya dilengkapi timestamp dan direlasikan dengan ID materi.

activity_logs & anecdotal_notes: activity_logs menyimpan input jurnal siswa (judul, tanggal, kategori_pulse, dan URL foto_bukti). Sedangkan anecdotal_notes menyimpan catatan observasi kualitatif/teks dari guru terhadap siswa tertentu.

aggregated_scores (Tabel Komputasi): Tabel denormalisasi yang menyimpan hasil kalkulasi dari Scoring Engine (rata-rata nilai kognitif dan agregat skor P, U, L, SE per siswa/kelas secara periodik) untuk meringankan beban komputasi/ query saat menampilkan grafik di dashboard.

audit_logs: Mencatat jejak keamanan sistem (user_id, action_type, timestamp) seperti pelacakan aktivitas unggah konten atau perubahan nilai.

Infrastruktur: Cloud Hosting (AWS/GCP/VPS yang setara) untuk memastikan kelancaran API dan ketersediaan storage untuk unggahan file E-Book serta foto bukti aktivitas kewargaan siswa.

7. Panduan Desain UI/UX (Design System)

Untuk memastikan konsistensi visual dan pengalaman pengguna (User Experience) yang optimal di kedua platform (Mobile dan Web), pengembangan CivicPulse mematuhi panduan sistem desain berikut:

A. Palet Warna (Color Palette)

Warna disusun untuk merepresentasikan kepercayaan, keprofesionalan pendidikan, dan kejelasan data analitik.

Primary Color: #2196F3 (Material Blue). Digunakan untuk identitas utama aplikasi, Header/App Bar, Call-to-Action (CTA) Buttons, ikon aktif, dan navigasi utama. Warna biru ini dipilih karena eye-catching, memberi kesan akademis yang modern, dan tidak memicu ketegangan mata bagi siswa maupun guru.

Secondary/Accent Color: #FFC107 (Amber) atau #00BCD4 (Cyan). Digunakan sesekali untuk menyorot notifikasi penting atau elemen interaktif sekunder.

Background Color: #F8F9FA (Soft Light Gray) untuk latar belakang utama aplikasi/web agar tidak terlalu silau, dan #FFFFFF (Putih Murni) untuk kanvas Card atau kontainer data agar memberikan efek timbul (depth).

Text Color: #333333 (Dark Charcoal) untuk teks paragraf utama/judul agar keterbacaannya (readability) tinggi, dan #757575 (Gray) untuk teks deskripsi atau label sekunder.

Semantic Analytics Colors (Untuk Heatmap/Alert): \* Success/Good: #4CAF50 (Hijau - Aman/Partisipasi Tinggi)

Warning: #FF9800 (Oranye - Perlu Perhatian)

Danger/Alert: #F44336 (Merah - Kritis/Skor Rendah)

B. Tipografi (Typography)

Font Family: Menggunakan keluarga font Sans-Serif modern bawaan sistem atau Google Fonts (seperti Poppins untuk Heading/Title yang membulat dan ramah, serta Inter atau Roboto untuk Body Text karena sangat mudah dibaca pada ukuran kecil maupun format tabel panjang).

C. Panduan Desain Aplikasi Mobile (Flutter)

Desain mobile difokuskan pada pengoperasian satu tangan (one-handed use) dan meminimalisir cognitive load (beban pikiran saat melihat layar).

Komponen Bersudut Melengkung (Rounded Corners): Menggunakan BorderRadius sekitar 12px - 16px pada setiap kartu materi (Card), tombol (Button), dan form input untuk memberikan kesan ramah (friendly) dan modern.

Navigasi Intuitif: Menggunakan Bottom Navigation Bar dengan ikon berlapis (filled saat aktif dengan warna #2196F3, dan outlined abu-abu saat inaktif).

Skala Asesmen yang Touch-Friendly: Pada modul asesmen PULSE, slider skala Likert (1-5) atau tombol pilihan ganda dirancang dengan area sentuh (touch target) minimal 48x48 dp sesuai standar accessibility, agar mudah ditekan oleh jempol siswa tanpa typo-click.

State & Animasi: Menggunakan Skeleton Loading (animasi bayangan abu-abu berkedip) saat memuat data grafik dari server, menggantikan animasi spinner putar biasa agar aplikasi terasa lebih premium dan cepat. Menggunakan tombol aksi melayang (Floating Action Button / FAB) berwarna #2196F3 untuk input krusial (seperti "+" Tambah Catatan / Tambah Aktivitas).

D. Panduan Desain Dashboard Web (Admin & Guru)

Desain dashboard web memprioritaskan tata letak data padat (data-dense layout) namun tetap memiliki ruang bernapas (white space) yang proporsional.

Tata Letak (Layout): Menggunakan pola Responsive Sidebar di sebelah kiri (dengan latar belakang gelap atau #2196F3 tebal) untuk menu utama, dan area konten utama berskala penuh di sebelah kanan. Sidebar dapat dilipat (collapsed) menjadi ikon saja untuk memperluas layar tabel.

Visualisasi Data (Widgets): \* Grafik diletakkan di dalam Cards putih berbayang halus (subtle drop-shadow).

Heatmap pada tabel menggunakan pewarnaan background sel transparan (dengan opacity sekitar 20-30% dari warna merah/kuning/hijau) agar angka di dalamnya tetap terbaca jelas tanpa merusak mata guru.

Interaktivitas (Hover States): Setiap baris tabel, tombol ekspor, atau elemen grafik harus memiliki efek hover (perubahan warna tipis saat mouse pointer diarahkan ke elemen tersebut) untuk memberikan umpan balik visual (visual feedback) seketika.

Responsivitas (Fluid Design): Meskipun diakses via web, tata letak berbasis grid harus bersifat responsif. Jika guru mengakses dashboard web ini menggunakan tablet (iPad), sidebar akan otomatis disembunyikan dalam hamburger menu, dan grafik sejajar horizontal akan ditumpuk menjadi vertikal.
