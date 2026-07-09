# Konten Materi Contoh: Toleransi Antar Umat Beragama (SMA Kelas 10)

Dokumen ini berisi draf konten lengkap untuk materi **"Toleransi Antar Umat Beragama"** (SMA Kelas 10) yang akan digunakan sebagai bahan demo/paper-prototype sesuai dengan **Fase 1** dalam Roadmap Redesain E-Learning.

---

## 1. PRE-TEST (5 Soal Pilihan Ganda)

Tujuan: Mengukur pemahaman awal siswa sebelum memulai aktivitas belajar.

### Soal 1
* **Pertanyaan**: Apa pengertian toleransi beragama yang paling tepat menurut nilai-nilai kewarganegaraan?
  * A. Meyakini dan membenarkan kebenaran semua agama secara teologis.
  * B. Menghormati dan menjamin hak setiap orang untuk memeluk agama dan beribadah sesuai keyakinannya tanpa paksaan. *(Benar)*
  * C. Menghindari diskusi keagamaan agar tidak terjadi perselisihan.
  * D. Mengikuti praktik ibadah umat agama lain demi menjaga kebersamaan.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Toleransi beragama berfokus pada penghormatan terhadap hak beragama dan kebebasan beribadah masing-masing individu, bukan mencampuradukkan keyakinan teologis.

### Soal 2
* **Pertanyaan**: Pancasila menjamin kebebasan beragama pada sila pertama. Sikap yang mencerminkan pengamalan sila tersebut dalam kehidupan sehari-hari adalah...
  * A. Memaksa teman sekelas untuk mengikuti tata cara ibadah kita.
  * B. Memilih-milih teman bermain berdasarkan agama yang sama saja.
  * C. Memberikan kesempatan kepada teman yang berbeda agama untuk melaksanakan ibadahnya saat kerja kelompok. *(Benar)*
  * D. Melarang pendirian rumah ibadah di lingkungan tempat tinggal kita.
* **Kunci Jawaban**: C (Index 2)
* **Penjelasan**: Menghargai dan memberikan kesempatan beribadah kepada pemeluk agama lain merupakan pengamalan sila pertama Pancasila, "Ketuhanan Yang Maha Esa".

### Soal 3
* **Pertanyaan**: Pasal UUD NRI Tahun 1945 yang secara eksplisit menyatakan perlindungan terhadap kemerdekaan tiap-tiap penduduk untuk memeluk agamanya masing-masing adalah...
  * A. Pasal 27 Ayat 1
  * B. Pasal 28
  * C. Pasal 29 Ayat 2 *(Benar)*
  * D. Pasal 30 Ayat 1
* **Kunci Jawaban**: C (Index 2)
* **Penjelasan**: Pasal 29 Ayat 2 UUD NRI 1945 berbunyi: "Negara menjamin kemerdekaan tiap-tiap penduduk untuk memeluk agamanya masing-masing dan untuk beribadat menurut agamanya dan kepercayaannya itu."

### Soal 4
* **Pertanyaan**: Mengapa sikap moderasi beragama penting bagi keutuhan bangsa Indonesia yang majemuk?
  * A. Agar seluruh penduduk Indonesia memiliki keyakinan yang seragam.
  * B. Untuk menghindari sikap ekstrem dan fanatisme berlebihan yang dapat merusak persatuan. *(Benar)*
  * C. Menghapus perbedaan suku dan budaya di Indonesia.
  * D. Meningkatkan persaingan antarkelompok agama secara sehat.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Moderasi beragama mendorong sikap tengah-tengah (tidak ekstrem kanan/kiri) sehingga kerukunan antarkelompok dapat terus terjaga secara harmonis.

### Soal 5
* **Pertanyaan**: Dampak sosial yang paling berbahaya dari tindakan intoleransi dalam masyarakat adalah...
  * A. Meningkatnya produktivitas ekonomi warga.
  * B. Munculnya disintegrasi sosial dan konflik horizontal antarkelompok. *(Benar)*
  * C. Terjadinya asimilasi budaya secara cepat.
  * D. Menguatnya kesadaran hukum masyarakat.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Intoleransi memicu kecurigaan dan kebencian antarumat beragama, yang jika dibiarkan dapat berujung pada pecahnya persatuan dan konflik horizontal (disintegrasi sosial).

---

## 2. PAPAN AKTIVITAS (9 Kotak Permainan)

### Kotak 1: Kartu Materi
* **Tipe**: `content`
* **Judul**: Apa itu Toleransi Beragama?
* **Isi**: 
  Toleransi berasal dari bahasa Latin *tolerare* yang berarti menahan diri atau bersikap sabar. Dalam konteks bernegara, toleransi beragama adalah sikap saling menghormati, menghargai, dan menerima keberadaan pemeluk agama lain. Toleransi tidak berarti kita menyetujui ajaran agama lain, melainkan menghormati hak asasi setiap manusia untuk memilih keyakinannya sendiri.
* **Gambar**: (disediakan ilustrasi orang dari berbagai latar belakang agama saling bersalaman)

### Kotak 2: Kartu Tantangan (Sortir Kategori)
* **Tipe**: `challenge`
* **Game Type**: `sorting`
* **Payload JSON**:
  ```json
  {
    "categories": ["Toleran", "Intoleran"],
    "items": [
      { "id": "t1", "label": "Mengucapkan selamat hari raya keagamaan kepada teman yang merayakan.", "category": "Toleran" },
      { "id": "t2", "label": "Membiarkan teman melaksanakan ibadah di sela-sela kerja kelompok.", "category": "Toleran" },
      { "id": "t3", "label": "Bergotong royong membersihkan desa bersama seluruh warga tanpa memandang agamanya.", "category": "Toleran" },
      { "id": "i1", "label": "Mengganggu teman yang sedang beribadah atau khusyuk berdoa.", "category": "Intoleran" },
      { "id": "i2", "label": "Memaksa orang lain untuk mengikuti keyakinan atau agama kita.", "category": "Intoleran" },
      { "id": "i3", "label": "Menolak berteman dengan siswa baru hanya karena ia berbeda keyakinan.", "category": "Intoleran" }
    ]
  }
  ```

### Kotak 3: Kartu Materi
* **Tipe**: `content`
* **Judul**: Landasan Hukum Toleransi di Indonesia
* **Isi**:
  Indonesia menjamin kebebasan beragama melalui landasan konstitusional yang kokoh. Sila pertama Pancasila, "Ketuhanan Yang Maha Esa", menjadi payung moral kehidupan beragama. Landasan operasionalnya dipertegas dalam Pasal 29 Ayat 2 UUD NRI 1945, di mana negara menjamin kemerdekaan setiap penduduk untuk memeluk agama dan beribadah menurut kepercayaannya itu.
* **Gambar**: (disediakan ilustrasi Garuda Pancasila dengan teks Pasal 29)

### Kotak 4: Kartu Tantangan (Mencocokkan Pasangan)
* **Tipe**: `challenge`
* **Game Type**: `matching`
* **Payload JSON**:
  ```json
  {
    "pairs": [
      {
        "id": "p1",
        "left": "Toleransi",
        "right": "Sikap menghargai dan menghormati perbedaan keyakinan serta hak beribadah orang lain."
      },
      {
        "id": "p2",
        "left": "Moderasi Beragama",
        "right": "Cara pandang beragama secara moderat (tengah-tengah), tidak ekstrem dan tidak berlebihan."
      },
      {
        "id": "p3",
        "left": "Ekstremisme",
        "right": "Sikap fanatik berlebihan yang memaksakan kehendak hingga menggunakan kekerasan."
      }
    ]
  }
  ```

### Kotak 5: Kartu Materi
* **Tipe**: `content`
* **Judul**: Praktik Baik Indahnya Toleransi
* **Isi**:
  Di berbagai daerah di Indonesia, toleransi tumbuh subur secara alami. Contohnya di Bali, umat Hindu kerap membantu menjaga keamanan salat Idul Fitri umat Muslim (Pecalang). Sebaliknya, pemuda Muslim di NTT aktif menjaga keamanan gereja saat perayaan Natal. Ini membuktikan perbedaan keyakinan justru mempererat solidaritas kemanusiaan kita sebagai satu bangsa.
* **Gambar**: (disediacak ilustrasi Pecalang Bali menjaga area masjid saat salat Id)

### Kotak 6: Kartu Tantangan (Swipe Benar/Salah)
* **Tipe**: `challenge`
* **Game Type**: `true_false_swipe`
* **Payload JSON**:
  ```json
  {
    "statements": [
      {
        "id": "s1",
        "text": "Toleransi beragama berarti kita ikut serta dalam ritual ibadah agama lain.",
        "answer": false,
        "explanation": "Toleransi adalah menghargai hak ibadah mereka, bukan ikut serta dalam ritual keagamaan mereka."
      },
      {
        "id": "s2",
        "text": "Negara Indonesia melarang pemaksaan agama kepada penduduknya.",
        "answer": true,
        "explanation": "UUD 1945 menjamin kemerdekaan memeluk agama tanpa adanya unsur paksaan."
      },
      {
        "id": "s3",
        "text": "Fanatisme berlebihan tanpa menghargai orang lain dapat memicu konflik disintegrasi.",
        "answer": true,
        "explanation": "Sikap ekstrem yang memaksakan kebenaran mutlak kelompoknya rentan memicu perpecahan sosial."
      },
      {
        "id": "s4",
        "text": "Sikap toleran hanya perlu ditunjukkan di dalam lingkungan rumah ibadah saja.",
        "answer": false,
        "explanation": "Toleransi wajib dipraktikkan di mana saja: di sekolah, masyarakat, tempat kerja, dan kehidupan sehari-hari."
      },
      {
        "id": "s5",
        "text": "Kerukunan antarumat beragama merupakan modal penting untuk pembangunan nasional.",
        "answer": true,
        "explanation": "Tanpa kedamaian dan kerukunan, pembangunan sosial ekonomi negara akan terhambat oleh konflik."
      }
    ]
  }
  ```

### Kotak 7: Kartu Materi
* **Tipe**: `content`
* **Judul**: Bahaya Intoleransi & Konflik Sosial
* **Isi**:
  Intoleransi adalah ketidakmauan untuk menghormati perbedaan keyakinan orang lain. Sikap ini biasanya bermula dari prasangka buruk dan klaim kebenaran sepihak (*truth claim*). Jika tidak diredam dengan dialog, intoleransi akan melahirkan diskriminasi, kebencian, hingga konflik fisik yang merugikan persatuan bangsa.
* **Gambar**: (disediakan ilustrasi grafis rantai persatuan yang retak akibat konflik)

### Kotak 8: Kartu Tantangan (Pilihan Ganda - Fallback)
* **Tipe**: `challenge`
* **Game Type**: `multiple_choice`
* **Payload JSON**:
  ```json
  {
    "question": "Jika kamu mendapati salah satu temanmu dikucilkan di kelas karena agamanya berbeda, tindakan kewarganegaraan apa yang paling tepat?",
    "options": [
      "Mengabaikannya agar tidak ikut dicap berbeda oleh teman lain.",
      "Menghampiri dan menemaninya belajar bersama, serta mengajak teman lain bersikap adil.",
      "Melaporkan semua teman sekelas ke polisi tanpa menegurnya terlebih dahulu.",
      "Menyarankan teman tersebut untuk pindah ke sekolah lain saja."
    ],
    "correct_index": 1,
    "explanation": "Sebagai warga negara yang baik, kita harus merangkul perbedaan dan aktif menciptakan suasana kelas yang inklusif dan adil."
  }
  ```

### Kotak 9: Kartu Tantangan Sosial
* **Tipe**: `social_task`
* **Judul**: Tantangan Aksi Nyata Toleransi
* **Isi**:
  Amati dan carilah contoh tindakan toleransi, kerja sama, atau kerukunan antarumat beragama/budaya yang terjadi di sekitar sekolah atau tempat tinggalmu. 
  
  Ambil foto aksi tersebut (atau foto dirimu sendiri sedang melakukan aksi kebaikan serupa), lalu unggah dan ceritakan secara singkat (minimal 10 karakter) apa yang terjadi dan nilai toleransi apa yang bisa dipelajari.

---

## 3. POST-TEST (5 Soal Pilihan Ganda)

Tujuan: Mengukur peningkatan pemahaman siswa (*Learning*) setelah melalui papan aktivitas.

### Soal 1
* **Pertanyaan**: Dari pernyataan berikut, manakah batasan toleransi beragama yang paling tepat di Indonesia?
  * A. Bebas melakukan ibadah bersama di tempat umum tanpa aturan.
  * B. Menghargai keyakinan orang lain tanpa harus mengikuti ajaran atau ritual ibadahnya. *(Benar)*
  * C. Memperbolehkan pencampuran ajaran agama demi persatuan.
  * D. Menerima ajaran agama lain sebagai bagian dari agama kita sendiri.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Toleransi dibatasi pada aspek sosial kemasyarakatan (saling menghormati hak), bukan mencampurkan ranah ibadah dan keyakinan (*akidah*).

### Soal 2
* **Pertanyaan**: Toleransi antarumat beragama diatur dalam Pasal 29 Ayat 2 UUD NRI 1945. Makna implisit dari pasal tersebut adalah...
  * A. Umat beragama dibebaskan menyebarkan ajaran agamanya dengan cara apa pun.
  * B. Negara menjamin perlindungan hukum bagi setiap warga negara untuk memeluk dan beribadat sesuai agamanya. *(Benar)*
  * C. Pemerintah berhak menentukan agama apa saja yang boleh hidup di Indonesia.
  * D. Semua warga negara wajib memiliki tata cara ibadah yang seragam.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Negara bertindak sebagai penjamin kebebasan dan keamanan warganya dalam memeluk agama serta beribadah, melindungi mereka dari diskriminasi atau paksaan.

### Soal 3
* **Pertanyaan**: Ketika terjadi perbedaan penentuan hari raya keagamaan, sikap moderat yang sebaiknya ditunjukkan oleh masyarakat adalah...
  * A. Saling mencibir kelompok lain yang merayakan di hari berbeda.
  * B. Memaksa pemerintah untuk menetapkan satu tanggal secara sepihak.
  * C. Saling menghormati perbedaan keputusan tersebut tanpa merusak kerukunan sosial. *(Benar)*
  * D. Mengadakan unjuk rasa untuk menuntut kesamaan tanggal.
* **Kunci Jawaban**: C (Index 2)
* **Penjelasan**: Menghormati perbedaan penafsiran atau metode tanpa memicu perselisihan merupakan bentuk kedewasaan sosial yang moderat.

### Soal 4
* **Pertanyaan**: Sikap pecalang (petugas keamanan adat Hindu) menjaga keamanan masjid saat umat Islam salat Idul Fitri menunjukkan bahwa...
  * A. Nilai kemanusiaan dan persaudaraan kebangsaan melampaui sekat-sekat perbedaan agama. *(Benar)*
  * B. Umat Hindu di Bali takut terhadap umat Muslim.
  * C. Pemerintah memaksa pecalang untuk bekerja di masjid.
  * D. Pecalang ingin mempelajari tata cara salat Idul Fitri.
* **Kunci Jawaban**: A (Index 0)
* **Penjelasan**: Aksi solidaritas pecalang menunjukkan bahwa nilai kerukunan nasional dan solidaritas kemanusiaan dapat berjalan beriringan melintasi perbedaan agama.

### Soal 5
* **Pertanyaan**: Salah satu contoh bahaya laten jika intoleransi dibiarkan berkembang subur di lingkungan sekolah adalah...
  * A. Prestasi akademik siswa secara keseluruhan akan merosot tajam.
  * B. Terjadinya pengelompokan (eksklusivisme) siswa berdasarkan latar belakang agama, memicu perundungan. *(Benar)*
  * C. Kurangnya jam belajar untuk pelajaran Pendidikan Pancasila.
  * D. Meningkatnya anggaran operasional sekolah secara drastis.
* **Kunci Jawaban**: B (Index 1)
* **Penjelasan**: Intoleransi di sekolah memicu eksklusivisme, prasangka, hingga perundungan (*bullying*) berbasis SARA yang dapat merusak iklim belajar yang aman bagi siswa.
