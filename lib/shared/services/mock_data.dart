import 'mock_models.dart';

class MockData {
  MockData._();

  static final User studentUser = User(
    id: 1,
    name: 'Andi Pratama',
    email: 'andi@email.com',
    role: 'student',
    avatarUrl: null,
  );

  static final User teacherUser = User(
    id: 2,
    name: 'Bu Siti Rahayu',
    email: 'siti@email.com',
    role: 'teacher',
    avatarUrl: null,
  );

  static const String validStudentToken = 'mock_student_token_123';
  static const String validTeacherToken = 'mock_teacher_token_456';

  static final List<LearningMaterial> materials = [
    LearningMaterial(
      id: 1,
      title: 'Keberagaman Budaya Indonesia',
      description: 'Memahami keberagaman budaya di Indonesia sebagai kekuatan bangsa.',
      thumbnailUrl: 'https://picsum.photos/seed/culture/400/300',
      gradeCategory: 'SMP',
      gradeLevel: 7,
      estimatedDuration: 45,
      orderIndex: 1,
      status: 'published',
    ),
    LearningMaterial(
      id: 2,
      title: 'Nilai-Nilai Pancasila',
      description: 'Mengkaji nilai-nilai luhur Pancasila dalam kehidupan sehari-hari.',
      thumbnailUrl: 'https://picsum.photos/seed/pancasila/400/300',
      gradeCategory: 'SMP',
      gradeLevel: 7,
      estimatedDuration: 60,
      orderIndex: 2,
      status: 'published',
    ),
    LearningMaterial(
      id: 3,
      title: 'Hak dan Kewajiban Warga Negara',
      description: 'Memahami hak dan kewajiban sebagai warga negara Indonesia.',
      thumbnailUrl: 'https://picsum.photos/seed/citizen/400/300',
      gradeCategory: 'SMP',
      gradeLevel: 8,
      estimatedDuration: 50,
      orderIndex: 3,
      status: 'published',
    ),
    LearningMaterial(
      id: 4,
      title: 'Demokrasi dan Politik',
      description: 'Memahami konsep demokrasi dan partisipasi politik.',
      thumbnailUrl: 'https://picsum.photos/seed/democracy/400/300',
      gradeCategory: 'SMA',
      gradeLevel: 10,
      estimatedDuration: 55,
      orderIndex: 1,
      status: 'published',
    ),
    LearningMaterial(
      id: 5,
      title: 'Toleransi dan Kerukunan',
      description: 'Membangun sikap toleransi antarumat beragama.',
      thumbnailUrl: 'https://picsum.photos/seed/tolerance/400/300',
      gradeCategory: 'SMA',
      gradeLevel: 11,
      estimatedDuration: 40,
      orderIndex: 2,
      status: 'published',
    ),
  ];

  static final List<Question> sampleQuestions = [
    Question(
      id: 1,
      materialId: 1,
      type: 'pre',
      questionNumber: 1,
      content: 'Apa yang dimaksud dengan multikulturalisme?',
      options: {
        'A': 'Keseragaman budaya',
        'B': 'Pengakuan terhadap keberagaman budaya',
        'C': 'Dominasi budaya tertentu',
        'D': 'Penghapusan perbedaan',
      },
      correctAnswer: 'B',
    ),
    Question(
      id: 2,
      materialId: 1,
      type: 'pre',
      questionNumber: 2,
      content: 'Berikut ini adalah contoh keberagaman budaya di Indonesia, kecuali...',
      options: {
        'A': 'Bahasa daerah yang berbeda',
        'B': 'Ras dan suku bangsa',
        'C': 'Pakaian tradisional',
        'D': 'Wajib memiliki satu agama',
      },
      correctAnswer: 'D',
    ),
    Question(
      id: 3,
      materialId: 1,
      type: 'pre',
      questionNumber: 3,
      content: 'Sikap yang tepat terhadap keberagaman budaya adalah...',
      options: {
        'A': 'Mengutamakan budaya sendiri',
        'B': 'Merendahkan budaya lain',
        'C': 'Toleransi dan saling menghormati',
        'D': 'Mengisolasi diri dari budaya lain',
      },
      correctAnswer: 'C',
    ),
  ];

  static final List<PulseStatement> pulseStatements = [
    PulseStatement(
      id: 1,
      materialId: 1,
      dimension: 'participation',
      statement: 'Saya ikut aktif dalam diskusi tentang keberagaman budaya',
      orderIndex: 1,
    ),
    PulseStatement(
      id: 2,
      materialId: 1,
      dimension: 'participation',
      statement: 'Saya berani menyampaikan pendapat dalam kelompok',
      orderIndex: 2,
    ),
    PulseStatement(
      id: 3,
      materialId: 1,
      dimension: 'understanding',
      statement: 'Saya memahami arti penting toleransi',
      orderIndex: 3,
    ),
    PulseStatement(
      id: 4,
      materialId: 1,
      dimension: 'understanding',
      statement: 'Saya tahu cara menghargai perbedaan',
      orderIndex: 4,
    ),
    PulseStatement(
      id: 5,
      materialId: 1,
      dimension: 'learning',
      statement: 'Saya berusaha belajar dari budaya lain',
      orderIndex: 5,
    ),
    PulseStatement(
      id: 6,
      materialId: 1,
      dimension: 'learning',
      statement: 'Saya aktif mencari informasi tentang budaya lain',
      orderIndex: 6,
    ),
    PulseStatement(
      id: 7,
      materialId: 1,
      dimension: 'social_engagement',
      statement: 'Saya berteman dengan orang dari budaya berbeda',
      orderIndex: 7,
    ),
    PulseStatement(
      id: 8,
      materialId: 1,
      dimension: 'social_engagement',
      statement: 'Saya ikut dalam kegiatan sosial yang melibatkan berbagai kalangan',
      orderIndex: 8,
    ),
  ];

  static final List<StudentClass> studentClasses = [
    StudentClass(
      id: 1,
      name: 'Kelas VII-A',
      gradeCategory: 'SMP',
      gradeLevel: 7,
      classCode: 'VIIA2024',
      teacherId: 2,
      teacherName: 'Bu Siti Rahayu',
    ),
  ];

  static final List<ActivityLog> activityLogs = [
    ActivityLog(
      id: 1,
      studentId: 1,
      title: 'Ikut gotong royong membersihkan lingkungan',
      category: 'participation',
      location: 'masyarakat',
      activityDate: DateTime.now().subtract(const Duration(days: 3)),
      photoUrl: 'https://picsum.photos/seed/activity1/400/300',
    ),
    ActivityLog(
      id: 2,
      studentId: 1,
      title: 'Membantu teman mengerjakan tugas kelompok',
      category: 'social_engagement',
      location: 'sekolah',
      activityDate: DateTime.now().subtract(const Duration(days: 1)),
      photoUrl: 'https://picsum.photos/seed/activity2/400/300',
    ),
  ];

  static final PulseScores samplePulseScores = PulseScores(
    participation: 3.5,
    understanding: 4.0,
    learning: 3.8,
    socialEngagement: 3.2,
  );
}
