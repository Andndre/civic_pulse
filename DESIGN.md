# CivicPulse Design System v2

> Tujuan: mengubah kesan aplikasi dari "form isi nilai" yang kaku menjadi aplikasi yang terasa hidup, memotivasi, dan pantas dipakai tiap hari — oleh siswa (SMP/SMA) maupun guru.

---

## 1. Diagnosis: kenapa terasa kaku sekarang

Dari `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart` yang ada:

- **Satu palet untuk semua orang.** Siswa dan guru melihat biru #2196F3 yang sama, layout kartu yang sama, tanpa ada yang terasa "punya saya".
- **Warna cuma dipakai sebagai label status**, bukan sebagai identitas. Semua CTA, badge, header pakai biru — tidak ada hierarki emosional (senang, capai target, butuh perhatian).
- **Tidak ada elemen permainan/reward.** Padahal PULSE (Participation, Understanding, Learning, Social Engagement) itu pada dasarnya sistem skor — cocok sekali untuk gamifikasi (streak, level, lencana), tapi sekarang hanya ditampilkan sebagai angka/pie chart datar.
- **Ikon generik Material Icons single-tone** di hampir semua tempat → terasa seperti aplikasi admin, bukan aplikasi belajar.
- **Tidak ada motion/microinteraction.** Transisi state (submit tugas, naik level, dapat feedback guru) terjadi tanpa perayaan sama sekali — momen yang seharusnya memotivasi jadi terasa seperti mengisi form birokrasi.
- **Guru dan siswa dipaksa pakai bahasa visual yang sama**, padahal kebutuhannya beda: siswa butuh *playful & rewarding*, guru butuh *cepat & dapat dipercaya datanya*.

Prinsip di bawah ini menjawab lima poin itu satu-satu, dan semuanya bisa dibangun di atas token yang sudah ada (tidak perlu rombak arsitektur, cuma perkaya token + tambah pola komponen baru).

---

## 2. Prinsip Desain

1. **Dua mood, satu bahasa visual.** Student = *energetic & rewarding*. Teacher = *calm & confident*. Keduanya berbagi grid, spacing, dan tipografi yang sama supaya tetap terasa satu produk — bedanya di saturasi warna, ilustrasi, dan tone copy.
2. **Warna bercerita, bukan sekadar branding.** Tiap dimensi PULSE punya warna tetap di seluruh app (lihat §3.3). Sekali siswa hafal "ungu = Social Engagement", itu berlaku di grafik, badge, notifikasi, di mana saja.
3. **Progres harus terlihat sebelum diklik.** Ring/bar progress, streak api, level badge — semua elemen yang membuat siswa penasaran "tinggal dikit lagi" harus terlihat di permukaan (home, bukan di halaman detail).
4. **Rayakan momen kecil.** Submit tugas, naik status hijau, dapat feedback guru → beri animasi singkat (checkmark bounce, confetti kecil, haptic). Guru: publish materi, review tugas → toast yang tegas dan cepat, tanpa perayaan berlebihan (beda tone).
5. **Ikon berilustrasi, bukan glyph tunggal.** Lanjutkan gaya sticker warna-warni yang sudah dibuat di `assets/icons/` untuk semua menu utama & empty state, ganti Material Icons single-tone secara bertahap.
6. **Aksesibilitas tetap nomor satu.** Semua kombinasi warna baru wajib lolos kontras AA (lihat §8), dan tiap elemen gamifikasi harus punya alternatif non-warna (ikon/label) untuk color-blind.

---

## 3. Warna

### 3.1 Palet inti (dipertahankan, jadi basis netral)

| Token | Hex | Peran |
|---|---|---|
| `primary` | `#2196F3` | Aksi utama, brand |
| `primaryDark` | `#1976D2` | Header gradient, pressed state |
| `secondary` | `#FFC107` | Aksen reward/highlight |
| `background` | `#F8F9FA` | Page bg |
| `surface` | `#FFFFFF` | Card |
| `textPrimary` | `#333333` | — |
| `textSecondary` | `#757575` | — |

### 3.2 Palet baru: "Mood accents" (dipakai selektif, bukan di semua tempat)

Ditambahkan di `app_colors.dart` sebagai `AppColors.mood*`, dipakai untuk hero section, ilustrasi, badge pencapaian — bukan untuk teks/body:

| Token | Hex | Contoh pemakaian |
|---|---|---|
| `sunrise` (gradient) | `#FF9A56 → #FF6B8B` | Hero card "streak hari ini" |
| `growth` (gradient) | `#43E97B → #38F9D7` | Level-up / naik status hijau |
| `focus` (gradient) | `#667EEA → #764BA2` | Kartu "Tanya AI" / fitur premium |
| `celebrate` | `#FFD166` | Confetti, bintang, lencana emas |

Gradient hanya dipakai di **hero/banner besar** (maks. 1 per layar), tidak pernah di body teks atau ikon kecil — supaya tetap flat & rapi di elemen kecil (sudah sesuai gaya ikon sticker yang dibuat sebelumnya).

### 3.3 Warna tetap per-dimensi PULSE (konsisten di semua chart & badge)

| Dimensi | Warna | Hex |
|---|---|---|
| Participation | Biru | `#2196F3` |
| Understanding | Hijau | `#4CAF50` |
| Learning | Oranye | `#FF9800` |
| Social Engagement | Ungu | `#9C27B0` |

Ini sudah cocok dengan warna 4 kartu menu siswa yang sekarang ada — tinggal dikunci sebagai aturan resmi, bukan kebetulan per-layar.

### 3.4 Mode Guru vs Mode Siswa

- **Siswa**: boleh pakai gradient hero, ilustrasi besar, warna jenuh penuh (100% saturasi pada aksen).
- **Guru**: base tetap sama, tapi gradient/ilustrasi besar diganti dengan *flat color + data* — dashboard harus terasa cepat dibaca, bukan didekorasi. Aksen warna dipakai lebih hemat (hanya untuk status: hijau/kuning/merah PULSE).

---

## 4. Tipografi

Poppins (heading) + Inter (body) **dipertahankan** — sudah pilihan bagus, cukup dipertegas pemakaiannya:

- Nama siswa/guru di header: `displaySmall` (24px/600), bukan `headlineMedium` seperti sekarang → beri kesan "ini halaman saya", lebih personal.
- Angka besar (skor, streak, level): style baru `AppTypography.statNumber` — Poppins 36px/700, dipakai khusus untuk angka pencapaian supaya beda dari heading biasa.
- Body tetap Inter 14–16px seperti sekarang, tidak berubah (sudah nyaman dibaca).

---

## 5. Bentuk & Elevasi

- Radius dipertahankan (`cardRadius: 16`, `buttonRadius: 12`) — sudah cukup ramah.
- Shadow diperhalus: shadow lama sudah oke, tapi tambahkan **glow tipis berwarna** (bukan hitam) di bawah kartu yang sedang "aktif/highlight" (mis. tugas yang belum dikerjakan hari ini), contoh: `boxShadow: 0 8px 20px rgba(33,150,243,0.15)` — bukan abu-abu netral. Efek ini menandakan "kartu ini penting" tanpa perlu badge tambahan.
- Kartu locked/disabled (seperti "Tanya AI") tetap pakai badge gembok kuning yang sudah ada — pola ini dipertahankan sebagai standar untuk semua fitur terkunci.

---

## 6. Ikonografi

Lanjutkan dan perluas set sticker icon yang sudah dibuat di `assets/icons/` (`menu_elearning.svg`, `menu_assessment.svg`, dst.):

- **Aturan bentuk**: semua ikon = squircle backdrop warna solid (rx 30 dari viewBox 120) + shadow ellipse tipis di bawah + highlight putih 10% opacity pojok kiri-atas + shading gelap 8% opacity di bagian bawah. Ini sudah jadi "template" — ikon baru wajib ikut pola ini supaya set terasa satu keluarga.
- **Perluasan yang disarankan**: ikon serupa untuk empty states (belum gabung kelas, belum ada tugas, belum ada feedback), dan untuk badge pencapaian (lencana emas/perak/perunggu, ikon "streak api").
- Ganti bertahap `Icons.xxx_rounded` di kartu-kartu utama (home siswa sudah selesai) → lanjutkan ke home guru, empty state, dan halaman skor.

---

## 7. Gamifikasi (siswa) — elemen baru yang disarankan

Ini bagian paling berdampak untuk "membuat siswa tertarik memakai aplikasi":

1. **Streak harian** — ikon api di header home siswa, angka hari berturut-turut siswa membuka/menyelesaikan aktivitas. Reset dengan lembut (bukan dipermalukan), hilang cukup dengan fade, bukan warning merah.
2. **Level/XP dari overall PULSE score** — bukan cuma warna hijau/kuning/merah seperti sekarang, tambahkan label level ("Warga Muda", "Warga Aktif", "Warga Teladan") yang naik seiring skor membaik. Ini reframe status merah (skor rendah) dari "kamu gagal" jadi "ini levelmu sekarang, ini caranya naik" — penting untuk motivasi.
3. **Lencana pencapaian** — muncul saat menyelesaikan materi pertama, streak 7 hari, submit tugas sosial pertama, dsb. Cukup ikon sticker + nama, ditampilkan di profil siswa.
4. **Progress ring, bukan cuma angka** — di kartu "E-Learning"/"Asesmen", tambahkan ring melingkar tipis di sekeliling ikon sticker menunjukkan % materi selesai, sehingga terlihat tanpa perlu masuk ke halaman detail.
5. **Perayaan kecil saat submit** — animasi checkmark 300ms + haptic `HapticFeedback.lightImpact()` saat siswa submit tugas/refleksi (pola `HapticFeedback` sudah dipakai di `student_home_screen.dart`, tinggal diperluas ke titik submit lain).

Untuk guru, jangan replikasi gamifikasi ini — cukup tampilkan hasilnya secara agregat (mis. "80% siswa punya streak aktif minggu ini") sebagai insight di dashboard guru, tanpa animasi/lencana.

---

## 8. Aksesibilitas & Konsistensi

- Semua teks pada background warna (badge, pill, gradient) wajib pakai warna gelap dari keluarga warna yang sama (bukan hitam polos) — kontras minimal 4.5:1 untuk teks kecil.
- Status PULSE tidak boleh hanya mengandalkan warna: selalu sertakan ikon/label teks (sudah dilakukan di beberapa tempat, jadikan aturan wajib di semua tempat baru).
- Target sentuh minimum tetap 48x48 (`AppSpacing.minTouchTarget`) — tidak berubah.
- Semua gradient/glow harus tetap punya fallback flat color yang sama persis dengan mode guru, supaya screenshot/dokumentasi tetap konsisten dan mudah dites.

---

## 9. Rencana Migrasi (bertahap, tidak perlu big-bang)

| Tahap | Cakupan | File utama |
|---|---|---|
| 1 (selesai) | Ikon sticker di 6 menu utama home siswa | `student_home_screen.dart`, `assets/icons/*.svg` |
| 2 | Tambah token `AppColors.mood*`, `AppTypography.statNumber` | `app_colors.dart`, `app_typography.dart` |
| 3 | Streak + level label di header home siswa | `student_home_screen.dart`, provider skor |
| 4 | Progress ring di kartu menu (E-Learning, Asesmen) | `student_home_screen.dart` |
| 5 | Ikon sticker + empty-state ilustrasi untuk halaman guru (versi warna lebih tenang) | `teacher/home`, `teacher/class_detail` |
| 6 | Lencana pencapaian di profil siswa | `student/profile` |
| 7 | Insight agregat gamifikasi di dashboard guru | `teacher/home` |

Setiap tahap independen — bisa dikerjakan satu-satu tanpa menunggu tahap lain selesai, dan tidak mengubah struktur data/backend (semua turunan dari skor PULSE yang sudah ada).
