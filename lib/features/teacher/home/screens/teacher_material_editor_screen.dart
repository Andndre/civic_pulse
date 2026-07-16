import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';

class TeacherMaterialEditorScreen extends ConsumerStatefulWidget {
  final int classId;
  final int materialId; // 0 for Create Mode

  const TeacherMaterialEditorScreen({
    super.key,
    required this.classId,
    required this.materialId,
  });

  @override
  ConsumerState<TeacherMaterialEditorScreen> createState() => _TeacherMaterialEditorScreenState();
}

class _TeacherMaterialEditorScreenState extends ConsumerState<TeacherMaterialEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  // General fields
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _pdfPath;
  String? _audioPath;

  // Edit Mode loaded data
  LearningMaterial? _material;
  List<Question> _questions = [];
  List<LearningNode> _nodes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isCreateMode => widget.materialId == 0;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final materialService = ref.read(materialServiceProvider);

      if (!_isCreateMode) {
        // Load existing material
        _material = await materialService.getMaterial(widget.materialId);
        if (_material != null) {
          _titleController.text = _material!.title;
          _descController.text = _material!.description ?? '';
        }

        // Load pre-test questions
        final preQuestions = await materialService.getQuestions(widget.materialId, 'pre');
        // Load post-test questions
        final postQuestions = await materialService.getQuestions(widget.materialId, 'post');
        _questions = [...preQuestions, ...postQuestions];

        // Load learning nodes
        _nodes = await materialService.getLearningBoard(widget.materialId);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(bool isPdf) async {
    try {
      final result = await FilePicker.pickFiles(
        type: isPdf ? FileType.custom : FileType.audio,
        allowedExtensions: isPdf ? ['pdf'] : null,
      );

      if (!mounted) return;

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isPdf) {
            _pdfPath = result.files.single.path;
          } else {
            _audioPath = result.files.single.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _handleSaveGeneral() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final materialService = ref.read(materialServiceProvider);

      if (_isCreateMode) {
        // Create custom material
        final newMaterial = await materialService.addClassMaterial(
          classId: widget.classId,
          title: _titleController.text,
          description: _descController.text,
          filePath: _pdfPath,
          audioPath: _audioPath,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Materi kelas berhasil dibuat!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pushReplacement('/teacher/class/${widget.classId}/materials/${newMaterial.id}/edit');
        }
      } else {
        // Update general info
        final updatedMaterial = await materialService.updateClassMaterial(
          widget.materialId,
          title: _titleController.text,
          description: _descController.text,
          filePath: _pdfPath,
          audioPath: _audioPath,
        );

        if (mounted) {
          setState(() {
            _material = updatedMaterial;
            _pdfPath = null;
            _audioPath = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detail materi berhasil diperbarui!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.danger),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteMaterial() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: const Text('Apakah Anda yakin ingin menghapus materi ini dari kelas? Semua progres siswa terkait materi ini akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final materialService = ref.read(materialServiceProvider);
      await materialService.deleteClassMaterial(widget.materialId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi berhasil dihapus dari kelas!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus materi: $e'), backgroundColor: AppColors.danger),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ===========================================================================
  // QUESTION FORM & ACTIONS
  // ===========================================================================
  void _showQuestionForm([Question? question]) {
    final isEdit = question != null;
    final qTextController = TextEditingController(text: question?.content ?? '');
    final optAController = TextEditingController(text: question?.options['A'] ?? '');
    final optBController = TextEditingController(text: question?.options['B'] ?? '');
    final optCController = TextEditingController(text: question?.options['C'] ?? '');
    final optDController = TextEditingController(text: question?.options['D'] ?? '');
    String selectedType = question?.type ?? 'pre_test';
    String selectedAnswer = question?.correctAnswer ?? 'A';

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ubah Soal' : 'Tambah Soal Baru'),
              content: isSaving
                  ? const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: const InputDecoration(labelText: 'Tipe Kuis'),
                              items: const [
                                DropdownMenuItem(value: 'pre_test', child: Text('Pre-Test')),
                                DropdownMenuItem(value: 'post_test', child: Text('Post-Test')),
                              ],
                              onChanged: (val) => setDialogState(() => selectedType = val!),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: qTextController,
                              maxLines: 2,
                              decoration: const InputDecoration(labelText: 'Pertanyaan', hintText: 'Ketik isi soal...'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: optAController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(labelText: 'Opsi A'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: optBController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(labelText: 'Opsi B'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: optCController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(labelText: 'Opsi C'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: optDController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(labelText: 'Opsi D'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedAnswer,
                              decoration: const InputDecoration(labelText: 'Jawaban Benar'),
                              items: const [
                                DropdownMenuItem(value: 'A', child: Text('Opsi A')),
                                DropdownMenuItem(value: 'B', child: Text('Opsi B')),
                                DropdownMenuItem(value: 'C', child: Text('Opsi C')),
                                DropdownMenuItem(value: 'D', child: Text('Opsi D')),
                              ],
                              onChanged: (val) => setDialogState(() => selectedAnswer = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
              actions: isSaving
                  ? null
                  : [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () async {
                          if (qTextController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              const SnackBar(content: Text('Pertanyaan tidak boleh kosong!'), backgroundColor: AppColors.danger),
                            );
                            return;
                          }
                          if (optAController.text.trim().isEmpty ||
                              optBController.text.trim().isEmpty ||
                              optCController.text.trim().isEmpty ||
                              optDController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              const SnackBar(content: Text('Semua Opsi (A, B, C, D) harus diisi!'), backgroundColor: AppColors.danger),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);
                          try {
                            final materialService = ref.read(materialServiceProvider);
                            final options = [
                              optAController.text,
                              optBController.text,
                              optCController.text,
                              optDController.text
                            ];

                            if (isEdit) {
                              await materialService.updateQuestion(
                                question.id,
                                questionText: qTextController.text,
                                options: options,
                                correctAnswer: selectedAnswer,
                              );
                            } else {
                              await materialService.createQuestion(
                                materialId: widget.materialId,
                                type: selectedType,
                                questionText: qTextController.text,
                                options: options,
                                correctAnswer: selectedAnswer,
                              );
                            }
                            if (builderContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            _loadData();
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (builderContext.mounted) {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                SnackBar(content: Text('Gagal menyimpan soal: $e'), backgroundColor: AppColors.danger),
                              );
                            }
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteQuestion(int questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: const Text('Apakah Anda yakin ingin menghapus butir soal kuis ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final materialService = ref.read(materialServiceProvider);
      await materialService.deleteQuestion(questionId);
      if (mounted) {
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus soal: $e'), backgroundColor: AppColors.danger),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ===========================================================================
  // LEARNING NODE FORM & ACTIONS
  // ===========================================================================
  String _getDefaultPayload(String gameType) {
    switch (gameType) {
      case 'sorting':
        return '''{
  "categories": ["Toleran", "Intoleran"],
  "items": [
    {"id": "t1", "label": "Mengucapkan selamat hari raya keagamaan kepada teman.", "category": "Toleran"},
    {"id": "i1", "label": "Mengganggu teman yang sedang beribadah.", "category": "Intoleran"}
  ]
}''';
      case 'matching':
        return '''{
  "pairs": [
    {"id": "p1", "left": "Toleransi", "right": "Sikap menghargai perbedaan keyakinan"},
    {"id": "p2", "left": "Ekstremisme", "right": "Sikap fanatik yang memaksakan kehendak"}
  ]
}''';
      case 'true_false_swipe':
        return '''{
  "statements": [
    {"id": "s1", "text": "Negara Indonesia menjamin kebebasan beragama", "answer": true},
    {"id": "s2", "text": "Toleransi beragama berarti ikut ritual ibadah agama lain", "answer": false}
  ]
}''';
      case 'multiple_choice':
        return '''{
  "question": "Apa peran pecalang di Bali saat salat Idul Fitri?",
  "options": [
    {"id": "a", "label": "Melarang ibadah"},
    {"id": "b", "label": "Menjaga keamanan sekitar masjid"},
    {"id": "c", "label": "Ikut salat bersama"},
    {"id": "d", "label": "Mengabaikan kegiatan"}
  ],
  "correct": "b"
}''';
      default:
        return '';
    }
  }

  void _showGamePayloadEditor({
    required BuildContext context,
    required String gameType,
    required Map<String, dynamic> initialPayload,
    required Function(Map<String, dynamic> updatedPayload) onSave,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GamePayloadEditorDialog(
          gameType: gameType,
          initialPayload: initialPayload,
          onSave: onSave,
          onCancel: onCancel,
        );
      },
    );
  }

  void _openVisualGameEditor({
    required BuildContext screenContext,
    required BuildContext dialogContext,
    required String gameType,
    required TextEditingController titleController,
    required TextEditingController bodyController,
    required String nodeType,
    required LearningNode? originalNode,
    required TextEditingController payloadController,
  }) {
    Map<String, dynamic> initialPayload = {};
    try {
      if (payloadController.text.trim().isNotEmpty) {
        initialPayload = jsonDecode(payloadController.text) as Map<String, dynamic>;
      }
    } catch (_) {}

    final currentTempNode = LearningNode(
      id: originalNode?.id ?? 0,
      materialId: originalNode?.materialId ?? widget.materialId,
      nodeType: nodeType,
      title: titleController.text,
      body: bodyController.text,
      gameType: gameType,
      payload: initialPayload,
      orderIndex: originalNode?.orderIndex ?? (_nodes.length + 1),
    );

    // Close the node form dialog first to avoid stacking
    Navigator.pop(dialogContext);

    _showGamePayloadEditor(
      context: screenContext,
      gameType: gameType,
      initialPayload: initialPayload,
      onSave: (updatedPayload) {
        final updatedNode = LearningNode(
          id: currentTempNode.id,
          materialId: currentTempNode.materialId,
          nodeType: currentTempNode.nodeType,
          title: currentTempNode.title,
          body: currentTempNode.body,
          gameType: currentTempNode.gameType,
          payload: updatedPayload,
          orderIndex: currentTempNode.orderIndex,
        );
        _showNodeForm(updatedNode);
      },
      onCancel: () {
        _showNodeForm(currentTempNode);
      },
    );
  }

  void _showNodeForm([LearningNode? node]) {
    // id == 0 menandai node sementara (baru dibuat lewat editor game visual),
    // bukan node tersimpan — jadi harus tetap dibuat (POST), bukan di-update.
    final isEdit = node != null && node.id != 0;
    final titleController = TextEditingController(text: node?.title ?? '');
    final bodyController = TextEditingController(text: node?.body ?? '');
    String nodeType = node?.nodeType ?? 'content';
    String? gameType = node?.gameType;
    final payloadController = TextEditingController(
      text: node?.payload != null ? const JsonEncoder.withIndent('  ').convert(node!.payload) : '',
    );
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ubah Node Aktivitas' : 'Tambah Node Baru'),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              content: isSaving
                  ? const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: nodeType,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Tipe Node'),
                              items: const [
                                DropdownMenuItem(value: 'content', child: Text('Konten (E-Book/Penjelasan)')),
                                DropdownMenuItem(value: 'challenge', child: Text('Tantangan (Mini-Game)')),
                                DropdownMenuItem(value: 'social_task', child: Text('Tantangan Sosial (Aksi Real)')),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
                                  nodeType = val!;
                                  if (nodeType != 'challenge') {
                                    gameType = null;
                                  } else {
                                    if (gameType == null) {
                                      gameType = 'multiple_choice';
                                      if (payloadController.text.trim().isEmpty) {
                                        payloadController.text = _getDefaultPayload('multiple_choice');
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: titleController,
                              decoration: const InputDecoration(labelText: 'Judul Aktivitas'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: bodyController,
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Isi/Deskripsi Teks'),
                            ),
                            if (nodeType == 'challenge') ...[
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: gameType,
                                isExpanded: true,
                                decoration: const InputDecoration(labelText: 'Jenis Game'),
                                items: const [
                                  DropdownMenuItem(value: 'sorting', child: Text('Sorting Game')),
                                  DropdownMenuItem(value: 'matching', child: Text('Matching Game')),
                                  DropdownMenuItem(value: 'true_false_swipe', child: Text('True/False Swipe')),
                                  DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                                ],
                                onChanged: (val) {
                                  setDialogState(() {
                                    final isTypeChanged = gameType != val;
                                    gameType = val;
                                    if (val != null) {
                                      if (isTypeChanged) {
                                        payloadController.text = _getDefaultPayload(val);
                                      }
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openVisualGameEditor(
                                    screenContext: context,
                                    dialogContext: dialogContext,
                                    gameType: gameType!,
                                    titleController: titleController,
                                    bodyController: bodyController,
                                    nodeType: nodeType,
                                    originalNode: node,
                                    payloadController: payloadController,
                                  ),
                                  icon: const Icon(Icons.edit_note),
                                  label: const Text('Edit Konten & Soal Game (Visual)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 48),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
              actions: isSaving
                  ? null
                  : [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              const SnackBar(content: Text('Judul Aktivitas tidak boleh kosong!'), backgroundColor: AppColors.danger),
                            );
                            return;
                          }
                          if (nodeType == 'challenge' && gameType == null) {
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              const SnackBar(content: Text('Pilih Jenis Game terlebih dahulu!'), backgroundColor: AppColors.danger),
                            );
                            return;
                          }

                          Map<String, dynamic>? jsonPayload;
                          if (payloadController.text.trim().isNotEmpty) {
                            try {
                              jsonPayload = jsonDecode(payloadController.text) as Map<String, dynamic>;
                            } catch (e) {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                const SnackBar(content: Text('Format Payload JSON tidak valid!'), backgroundColor: AppColors.danger),
                              );
                              return;
                            }
                          }

                          setDialogState(() => isSaving = true);
                          try {
                            final materialService = ref.read(materialServiceProvider);

                            if (isEdit) {
                              await materialService.updateLearningNode(
                                node.id,
                                nodeType: nodeType,
                                title: titleController.text,
                                body: bodyController.text,
                                gameType: gameType,
                                payload: jsonPayload,
                              );
                            } else {
                              await materialService.createLearningNode(
                                materialId: widget.materialId,
                                nodeType: nodeType,
                                title: titleController.text,
                                body: bodyController.text,
                                gameType: gameType,
                                payload: jsonPayload,
                                orderIndex: _nodes.length + 1,
                              );
                            }
                            if (builderContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            _loadData();
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (builderContext.mounted) {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                  SnackBar(content: Text('Gagal menyimpan node: $e'), backgroundColor: AppColors.danger),
                              );
                            }
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteNode(int nodeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Node'),
        content: const Text('Apakah Anda yakin ingin menghapus kotak langkah aktivitas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final materialService = ref.read(materialServiceProvider);
      await materialService.deleteLearningNode(nodeId);
      if (mounted) {
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus node: $e'), backgroundColor: AppColors.danger),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ===========================================================================
  // LAYOUT & RENDERING
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isCreateMode ? 'Tambah Materi Baru' : 'Edit Materi Kelas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (!_isCreateMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _handleDeleteMaterial,
              tooltip: 'Hapus Materi dari Kelas',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage', style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Informasi Utama'),
                        Tab(text: 'Butir Kuis'),
                        Tab(text: 'Papan Aktivitas'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGeneralTab(),
                          _isCreateMode
                              ? _buildPlaceholderTab(
                                  'Kuis Belum Tersedia',
                                  'Silakan simpan Informasi Utama terlebih dahulu untuk menambahkan butir kuis.',
                                )
                              : _buildQuestionsTab(),
                          _isCreateMode
                              ? _buildPlaceholderTab(
                                  'Papan Aktivitas Belum Tersedia',
                                  'Silakan simpan Informasi Utama terlebih dahulu untuk mengatur langkah belajar/game.',
                                )
                              : _buildNodesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isCreateMode ? 'Buat Materi Baru' : 'Edit Detail Materi',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Materi', hintText: 'Contoh: Toleransi Antar Umat Beragama'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi Singkat', hintText: 'Deskripsi materi untuk panduan siswa...'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            Text('Berkas & Lampiran Media', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pdfPath != null
                        ? 'Terpilih: ${_pdfPath!.split('/').last}'
                        : (_material?.fileUrl != null ? 'E-Book PDF sudah terunggah' : 'Belum ada PDF terpilih'),
                    style: TextStyle(color: _pdfPath != null || _material?.fileUrl != null ? AppColors.success : AppColors.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(true),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Pilih PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _audioPath != null
                        ? 'Terpilih: ${_audioPath!.split('/').last}'
                        : (_material?.audioUrl != null ? 'Audio penjelasan sudah terunggah' : 'Belum ada Audio terpilih (Opsional)'),
                    style: TextStyle(color: _audioPath != null || _material?.audioUrl != null ? AppColors.success : AppColors.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(false),
                  icon: const Icon(Icons.audiotrack),
                  label: const Text('Pilih Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleSaveGeneral,
                child: Text(_isCreateMode ? 'Buat Materi' : 'Simpan Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final preTestQs = _questions.where((q) => q.type == 'pre_test' || q.type == 'pre').toList();
    final postTestQs = _questions.where((q) => q.type == 'post_test' || q.type == 'post').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Daftar Evaluasi Kuis', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold))),
              ElevatedButton.icon(
                onPressed: () => _showQuestionForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Soal'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuestionGroup('Kuis Pre-Test', preTestQs),
          const SizedBox(height: 24),
          _buildQuestionGroup('Kuis Post-Test', postTestQs),
        ],
      ),
    );
  }

  Widget _buildQuestionGroup(String title, List<Question> qs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 10),
        if (qs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Belum ada soal pada bagian ini.', style: TextStyle(color: AppColors.textSecondary))),
            ),
          )
        else ...[
          for (var i = 0; i < qs.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(qs[i].content),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: qs[i].options.entries.map((entry) {
                          final label = entry.key;
                          final text = entry.value;
                          final isCorrect = qs[i].correctAnswer.toUpperCase() == label;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 14,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.textHint,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$label. $text',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isCorrect
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kunci Jawaban: ${qs[i].correctAnswer}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showQuestionForm(qs[i])),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                      onPressed: () => _handleDeleteQuestion(qs[i].id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildNodesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Papan Langkah Belajar (Nodes)', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold))),
              ElevatedButton.icon(
                onPressed: () => _showNodeForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Langkah'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_nodes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('Belum ada langkah belajar dikonfigurasi.', style: TextStyle(color: AppColors.textSecondary))),
              ),
            )
          else ...[
            for (var i = 0; i < _nodes.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Builder(builder: (context) {
                final n = _nodes[i];
                String typeLabel = 'Konten';
                IconData typeIcon = Icons.menu_book;
                Color typeColor = AppColors.primary;

                if (n.nodeType == 'challenge') {
                  typeLabel = 'Game: ${n.gameType ?? ""}';
                  typeIcon = Icons.sports_esports;
                  typeColor = Colors.orange;
                } else if (n.nodeType == 'social_task') {
                  typeLabel = 'Tantangan Sosial';
                  typeIcon = Icons.people;
                  typeColor = Colors.teal;
                }

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: typeColor.withValues(alpha: 0.15),
                      child: Icon(typeIcon, color: typeColor, size: 20),
                    ),
                    title: Text(n.title ?? ''),
                    subtitle: Text(
                      'Tipe: $typeLabel\nDeskripsi: ${n.body ?? "Tidak ada deskripsi"}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showNodeForm(n)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                          onPressed: () => _handleDeleteNode(n.id),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GamePayloadEditorDialog extends StatefulWidget {
  final String gameType;
  final Map<String, dynamic> initialPayload;
  final Function(Map<String, dynamic> updatedPayload) onSave;
  final VoidCallback? onCancel;

  const GamePayloadEditorDialog({
    super.key,
    required this.gameType,
    required this.initialPayload,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<GamePayloadEditorDialog> createState() => _GamePayloadEditorDialogState();
}

class _GamePayloadEditorDialogState extends State<GamePayloadEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  // MCQ controllers
  late final TextEditingController _mcqQuestionController;
  late final TextEditingController _mcqOptAController;
  late final TextEditingController _mcqOptBController;
  late final TextEditingController _mcqOptCController;
  late final TextEditingController _mcqOptDController;
  late String _mcqCorrect;

  // Sorting controllers
  late final TextEditingController _sortCat1Controller;
  late final TextEditingController _sortCat2Controller;
  final List<Map<String, dynamic>> _sortItems = [];

  // Matching controllers
  final List<Map<String, dynamic>> _matchPairs = [];

  // True/False controllers
  final List<Map<String, dynamic>> _tfStatements = [];

  @override
  void initState() {
    super.initState();

    _mcqQuestionController = TextEditingController();
    _mcqOptAController = TextEditingController();
    _mcqOptBController = TextEditingController();
    _mcqOptCController = TextEditingController();
    _mcqOptDController = TextEditingController();
    _mcqCorrect = 'a';

    _sortCat1Controller = TextEditingController(text: 'Toleran');
    _sortCat2Controller = TextEditingController(text: 'Intoleran');

    _populateData();
  }

  void _populateData() {
    final gameType = widget.gameType;
    final initialPayload = widget.initialPayload;

    if (gameType == 'multiple_choice') {
      _mcqQuestionController.text = initialPayload['question']?.toString() ?? '';
      final opts = initialPayload['options'] as List?;
      if (opts != null) {
        for (var o in opts) {
          if (o is Map) {
            final id = o['id']?.toString().toLowerCase();
            final label = o['label']?.toString() ?? '';
            if (id == 'a') _mcqOptAController.text = label;
            if (id == 'b') _mcqOptBController.text = label;
            if (id == 'c') _mcqOptCController.text = label;
            if (id == 'd') _mcqOptDController.text = label;
          }
        }
      }
      _mcqCorrect = initialPayload['correct']?.toString().toLowerCase() ?? 'a';
      if (!['a', 'b', 'c', 'd'].contains(_mcqCorrect)) {
        _mcqCorrect = 'a';
      }
    } else if (gameType == 'sorting') {
      final cats = initialPayload['categories'] as List?;
      if (cats != null && cats.length >= 2) {
        _sortCat1Controller.text = cats[0].toString();
        _sortCat2Controller.text = cats[1].toString();
      }
      final items = initialPayload['items'] as List?;
      if (items != null) {
        for (var it in items) {
          if (it is Map) {
            _sortItems.add({
              'controller': TextEditingController(text: it['label']?.toString() ?? ''),
              'category': it['category']?.toString() ?? _sortCat1Controller.text,
            });
          }
        }
      }
      if (_sortItems.isEmpty) {
        _sortItems.add({
          'controller': TextEditingController(),
          'category': _sortCat1Controller.text,
        });
      }
    } else if (gameType == 'matching') {
      final pairs = initialPayload['pairs'] as List?;
      if (pairs != null) {
        for (var p in pairs) {
          if (p is Map) {
            _matchPairs.add({
              'left': TextEditingController(text: p['left']?.toString() ?? ''),
              'right': TextEditingController(text: p['right']?.toString() ?? ''),
            });
          }
        }
      }
      if (_matchPairs.isEmpty) {
        _matchPairs.add({
          'left': TextEditingController(),
          'right': TextEditingController(),
        });
      }
    } else if (gameType == 'true_false_swipe') {
      final stmts = initialPayload['statements'] as List?;
      if (stmts != null) {
        for (var s in stmts) {
          if (s is Map) {
            _tfStatements.add({
              'text': TextEditingController(text: s['text']?.toString() ?? ''),
              'answer': s['answer'] is bool ? s['answer'] as bool : true,
            });
          }
        }
      }
      if (_tfStatements.isEmpty) {
        _tfStatements.add({
          'text': TextEditingController(),
          'answer': true,
        });
      }
    }
  }

  @override
  void dispose() {
    _mcqQuestionController.dispose();
    _mcqOptAController.dispose();
    _mcqOptBController.dispose();
    _mcqOptCController.dispose();
    _mcqOptDController.dispose();

    _sortCat1Controller.dispose();
    _sortCat2Controller.dispose();

    for (var it in _sortItems) {
      (it['controller'] as TextEditingController).dispose();
    }
    for (var p in _matchPairs) {
      (p['left'] as TextEditingController).dispose();
      (p['right'] as TextEditingController).dispose();
    }
    for (var s in _tfStatements) {
      (s['text'] as TextEditingController).dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameType = widget.gameType;
    String gameTypeTitle = 'Edit Game';
    if (gameType == 'multiple_choice') gameTypeTitle = 'Multiple Choice';
    if (gameType == 'sorting') gameTypeTitle = 'Sorting Game';
    if (gameType == 'matching') gameTypeTitle = 'Matching Game';
    if (gameType == 'true_false_swipe') gameTypeTitle = 'True/False Swipe';

    Widget editorWidget = Container();

    if (gameType == 'multiple_choice') {
      editorWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teks Pertanyaan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _mcqQuestionController,
            decoration: const InputDecoration(hintText: 'Masukkan pertanyaan game...'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Pertanyaan tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          
          const Text('Pilihan A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _mcqOptAController,
            decoration: const InputDecoration(hintText: 'Masukkan opsi A...'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Pilihan A tidak boleh kosong' : null,
          ),
          const SizedBox(height: 12),
          const Text('Pilihan B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _mcqOptBController,
            decoration: const InputDecoration(hintText: 'Masukkan opsi B...'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Pilihan B tidak boleh kosong' : null,
          ),
          const SizedBox(height: 12),
          const Text('Pilihan C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _mcqOptCController,
            decoration: const InputDecoration(hintText: 'Masukkan opsi C...'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Pilihan C tidak boleh kosong' : null,
          ),
          const SizedBox(height: 12),
          const Text('Pilihan D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _mcqOptDController,
            decoration: const InputDecoration(hintText: 'Masukkan opsi D...'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Pilihan D tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          
          const Text('Jawaban Benar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _mcqCorrect,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(value: 'a', child: Text('Opsi A')),
              DropdownMenuItem(value: 'b', child: Text('Opsi B')),
              DropdownMenuItem(value: 'c', child: Text('Opsi C')),
              DropdownMenuItem(value: 'd', child: Text('Opsi D')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _mcqCorrect = val);
              }
            },
          ),
        ],
      );
    } else if (gameType == 'sorting') {
      editorWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori 1',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _sortCat1Controller,
            decoration: const InputDecoration(hintText: 'Contoh: Toleran'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kategori 2',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _sortCat2Controller,
            decoration: const InputDecoration(hintText: 'Contoh: Intoleran'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          const Text('Daftar Item & Kategori yang Benar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 10),
          ..._sortItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final controller = item['controller'] as TextEditingController;
            String selectedCategory = item['category'] as String;

            final cat1Text = _sortCat1Controller.text.trim();
            final cat2Text = _sortCat2Controller.text.trim();

            final catOptions = [
              if (cat1Text.isNotEmpty) cat1Text else 'Kategori 1',
              if (cat2Text.isNotEmpty) cat2Text else 'Kategori 2',
            ];

            if (!catOptions.contains(selectedCategory) && catOptions.isNotEmpty) {
              selectedCategory = catOptions.first;
              item['category'] = selectedCategory;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item #${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              final it = _sortItems.removeAt(idx);
                              (it['controller'] as TextEditingController).dispose();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pernyataan / Tindakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Teks tindakan/perilaku...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Item wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('Kategori Jawaban', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: catOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                item['category'] = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _sortItems.add({
                    'controller': TextEditingController(),
                    'category': _sortCat1Controller.text,
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Item Baru'),
            ),
          ),
        ],
      );
    } else if (gameType == 'matching') {
      editorWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Pasangan yang Benar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 10),
          ..._matchPairs.asMap().entries.map((entry) {
            final idx = entry.key;
            final pair = entry.value;
            final leftController = pair['left'] as TextEditingController;
            final rightController = pair['right'] as TextEditingController;

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pasangan #${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              final p = _matchPairs.removeAt(idx);
                              (p['left'] as TextEditingController).dispose();
                              (p['right'] as TextEditingController).dispose();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kunci Kiri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: leftController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Toleransi',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Sisi kiri wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('Pasangan Kanan (Jawaban)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: rightController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Saling menghormati',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Sisi kanan wajib diisi' : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _matchPairs.add({
                    'left': TextEditingController(),
                    'right': TextEditingController(),
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pasangan Baru'),
            ),
          ),
        ],
      );
    } else if (gameType == 'true_false_swipe') {
      editorWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Pernyataan & Kebenaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 10),
          ..._tfStatements.asMap().entries.map((entry) {
            final idx = entry.key;
            final stmt = entry.value;
            final textController = stmt['text'] as TextEditingController;
            final answer = stmt['answer'] as bool;

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pernyataan #${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              final s = _tfStatements.removeAt(idx);
                              (s['text'] as TextEditingController).dispose();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pernyataan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: textController,
                          decoration: const InputDecoration(
                            hintText: 'Ketik pernyataan...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Pernyataan wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Jawaban Kebenaran:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Text(
                                  answer ? 'Benar' : 'Salah',
                                  style: TextStyle(
                                    color: answer ? AppColors.success : AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: answer,
                                  activeColor: AppColors.success,
                                  inactiveThumbColor: AppColors.danger,
                                  onChanged: (val) {
                                    setState(() {
                                      stmt['answer'] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _tfStatements.add({
                    'text': TextEditingController(),
                    'answer': true,
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pernyataan Baru'),
            ),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Edit Isi Game: $gameTypeTitle'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: editorWidget,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (widget.onCancel != null) widget.onCancel!();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final updatedPayload = <String, dynamic>{};

            if (gameType == 'multiple_choice') {
              updatedPayload['question'] = _mcqQuestionController.text.trim();
              updatedPayload['options'] = [
                {'id': 'a', 'label': _mcqOptAController.text.trim()},
                {'id': 'b', 'label': _mcqOptBController.text.trim()},
                {'id': 'c', 'label': _mcqOptCController.text.trim()},
                {'id': 'd', 'label': _mcqOptDController.text.trim()},
              ];
              updatedPayload['correct'] = _mcqCorrect;
            } else if (gameType == 'sorting') {
              updatedPayload['categories'] = [
                _sortCat1Controller.text.trim(),
                _sortCat2Controller.text.trim(),
              ];
              updatedPayload['items'] = _sortItems.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final controller = item['controller'] as TextEditingController;
                final cat = item['category'] as String;
                return {
                  'id': 'item_$idx',
                  'label': controller.text.trim(),
                  'category': cat,
                };
              }).toList();
            } else if (gameType == 'matching') {
              updatedPayload['pairs'] = _matchPairs.asMap().entries.map((entry) {
                final idx = entry.key;
                final pair = entry.value;
                final left = (pair['left'] as TextEditingController).text.trim();
                final right = (pair['right'] as TextEditingController).text.trim();
                return {
                  'id': 'pair_$idx',
                  'left': left,
                  'right': right,
                };
              }).toList();
            } else if (gameType == 'true_false_swipe') {
              updatedPayload['statements'] = _tfStatements.asMap().entries.map((entry) {
                final idx = entry.key;
                final stmt = entry.value;
                final text = (stmt['text'] as TextEditingController).text.trim();
                final ans = stmt['answer'] as bool;
                return {
                  'id': 'stmt_$idx',
                  'text': text,
                  'answer': ans,
                };
              }).toList();
            }

            widget.onSave(updatedPayload);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
