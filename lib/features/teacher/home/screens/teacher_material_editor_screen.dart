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
  int? _selectedTemplateId;

  // Edit Mode loaded data
  LearningMaterial? _material;
  List<Question> _questions = [];
  List<LearningNode> _nodes = [];
  List<Map<String, dynamic>> _templates = [];

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

      // Load templates for creation or reference
      _templates = await materialService.getMaterialTemplates();

      if (!_isCreateMode) {
        // Load existing material
        _material = await materialService.getMaterial(widget.materialId);
        if (_material != null) {
          _titleController.text = _material!.title;
          _descController.text = _material!.description ?? '';
        }

        // Load pre-test questions
        final preQuestions = await materialService.getQuestions(widget.materialId, 'pre_test');
        // Load post-test questions
        final postQuestions = await materialService.getQuestions(widget.materialId, 'post_test');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e'), backgroundColor: AppColors.danger),
      );
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
          templateId: _selectedTemplateId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi kelas berhasil dibuat!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Seamlessly switch to Edit Mode for the newly created material
        if (mounted) {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.danger),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteMaterial() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: const Text('Apakah Anda yakin ingin menghapus materi ini dari kelas? Semua progres siswa terkait materi ini akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi berhasil dihapus dari kelas!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus materi: $e'), backgroundColor: AppColors.danger),
      );
      setState(() => _isLoading = false);
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

    final allTemplateQuestions = <Map<String, dynamic>>[];
    for (var temp in _templates) {
      final qPayload = temp['questions_payload'];
      if (qPayload is List) {
        for (var q in qPayload) {
          if (q is Map) {
            allTemplateQuestions.add(Map<String, dynamic>.from(q));
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ubah Soal' : 'Tambah Soal Baru'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isEdit && allTemplateQuestions.isNotEmpty) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            labelText: 'Pilih dari Soal Template (Opsional)',
                            hintText: 'Pilih soal yang sudah ada...',
                          ),
                          isExpanded: true,
                          items: allTemplateQuestions.map((q) {
                            final qText = q['question_text']?.toString() ?? '';
                            final type = q['type'] == 'pre_test' ? 'Pre' : 'Post';
                            final shortText = qText.length > 35 ? '${qText.substring(0, 35)}...' : qText;
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: q,
                              child: Text('[$type] $shortText'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                qTextController.text = val['question_text']?.toString() ?? '';
                                selectedType = val['type']?.toString() ?? 'pre_test';
                                selectedAnswer = val['correct_answer']?.toString() ?? 'A';
                                final opts = val['options'];
                                if (opts is List && opts.length >= 4) {
                                  optAController.text = opts[0].toString();
                                  optBController.text = opts[1].toString();
                                  optCController.text = opts[2].toString();
                                  optDController.text = opts[3].toString();
                                } else if (opts is Map) {
                                  optAController.text = opts['A']?.toString() ?? '';
                                  optBController.text = opts['B']?.toString() ?? '';
                                  optCController.text = opts['C']?.toString() ?? '';
                                  optDController.text = opts['D']?.toString() ?? '';
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
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
                      TextField(controller: optAController, decoration: const InputDecoration(labelText: 'Opsi A')),
                      TextField(controller: optBController, decoration: const InputDecoration(labelText: 'Opsi B')),
                      TextField(controller: optCController, decoration: const InputDecoration(labelText: 'Opsi C')),
                      TextField(controller: optDController, decoration: const InputDecoration(labelText: 'Opsi D')),
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
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
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
                      _loadData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan soal: $e'), backgroundColor: AppColors.danger),
                      );
                      setState(() => _isLoading = false);
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
      builder: (context) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: const Text('Apakah Anda yakin ingin menghapus butir soal kuis ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus soal: $e'), backgroundColor: AppColors.danger),
      );
      setState(() => _isLoading = false);
    }
  }

  // ===========================================================================
  // LEARNING NODE FORM & ACTIONS
  // ===========================================================================
  void _showNodeForm([LearningNode? node]) {
    final isEdit = node != null;
    final titleController = TextEditingController(text: node?.title ?? '');
    final bodyController = TextEditingController(text: node?.body ?? '');
    String nodeType = node?.nodeType ?? 'content';
    String? gameType = node?.gameType;
    final payloadController = TextEditingController(
      text: node?.payload != null ? const JsonEncoder.withIndent('  ').convert(node!.payload) : '',
    );

    final allTemplateNodes = <Map<String, dynamic>>[];
    for (var temp in _templates) {
      final nPayload = temp['nodes_payload'];
      if (nPayload is List) {
        for (var n in nPayload) {
          if (n is Map) {
            allTemplateNodes.add(Map<String, dynamic>.from(n));
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ubah Node Aktivitas' : 'Tambah Node Baru'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isEdit && allTemplateNodes.isNotEmpty) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            labelText: 'Pilih dari Node Template (Opsional)',
                            hintText: 'Pilih langkah yang sudah ada...',
                          ),
                          isExpanded: true,
                          items: allTemplateNodes.map((n) {
                            final nTitle = n['title']?.toString() ?? '';
                            final type = n['node_type'] ?? 'content';
                            final typeStr = type == 'challenge' ? 'Game: ${n['game_type']}' : (type == 'social_task' ? 'Aksi Sosial' : 'Konten');
                            final shortTitle = nTitle.length > 35 ? '${nTitle.substring(0, 35)}...' : nTitle;
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: n,
                              child: Text('[$typeStr] $shortTitle'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                titleController.text = val['title']?.toString() ?? '';
                                bodyController.text = val['description']?.toString() ?? val['body']?.toString() ?? '';
                                nodeType = val['node_type']?.toString() ?? 'content';
                                gameType = val['game_type']?.toString();
                                final pl = val['payload'];
                                if (pl != null) {
                                  payloadController.text = const JsonEncoder.withIndent('  ').convert(pl);
                                } else {
                                  payloadController.text = '';
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<String>(
                        value: nodeType,
                        decoration: const InputDecoration(labelText: 'Tipe Node'),
                        items: const [
                          DropdownMenuItem(value: 'content', child: Text('Konten (E-Book/Penjelasan)')),
                          DropdownMenuItem(value: 'challenge', child: Text('Tantangan (Mini-Game)')),
                          DropdownMenuItem(value: 'social_task', child: Text('Tantangan Sosial (Aksi Real)')),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            nodeType = val!;
                            if (nodeType != 'challenge') gameType = null;
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
                          decoration: const InputDecoration(labelText: 'Jenis Game'),
                          items: const [
                            DropdownMenuItem(value: 'sorting', child: Text('Sorting Game')),
                            DropdownMenuItem(value: 'matching', child: Text('Matching Game')),
                            DropdownMenuItem(value: 'true_false_swipe', child: Text('True/False Swipe')),
                            DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                          ],
                          onChanged: (val) => setDialogState(() => gameType = val),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: payloadController,
                        maxLines: 5,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        decoration: const InputDecoration(
                          labelText: 'Payload Data (JSON Format)',
                          hintText: '{\n  "items": [...]\n}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic>? jsonPayload;
                    if (payloadController.text.trim().isNotEmpty) {
                      try {
                        jsonPayload = jsonDecode(payloadController.text) as Map<String, dynamic>;
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Format Payload JSON tidak valid!'), backgroundColor: AppColors.danger),
                        );
                        return;
                      }
                    }

                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    try {
                      final materialService = ref.read(materialServiceProvider);

                      if (isEdit) {
                        await materialService.updateLearningNode(
                          node.id,
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
                      _loadData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan node: $e'), backgroundColor: AppColors.danger),
                      );
                      setState(() => _isLoading = false);
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
      builder: (context) => AlertDialog(
        title: const Text('Hapus Node'),
        content: const Text('Apakah Anda yakin ingin menghapus kotak langkah aktivitas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus node: $e'), backgroundColor: AppColors.danger),
      );
      setState(() => _isLoading = false);
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
            if (_isCreateMode) ...[
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ListTile(
                  title: const Text('Template Pembelajaran (Opsional)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  subtitle: Text(
                    _selectedTemplateId == null
                        ? 'Mulai dari Kosong (Tanpa Game/Soal)'
                        : (_templates.firstWhere((t) => t['id'] == _selectedTemplateId, orElse: () => {'title': ''})['title'] ?? ''),
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  onTap: () async {
                    final selected = await showDialog<int?>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pilih Template Pembelajaran'),
                        content: Container(
                          width: 400,
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                title: const Text('Mulai dari Kosong (Tanpa Game/Soal)'),
                                onTap: () => Navigator.pop(context, null),
                              ),
                              const Divider(),
                              ..._templates.map(
                                (t) => ListTile(
                                  title: Text(t['title'] as String),
                                  subtitle: Text(t['description'] as String? ?? ''),
                                  onTap: () => Navigator.pop(context, t['id'] as int),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    setState(() => _selectedTemplateId = selected);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Pilih template untuk menyalin game & soal kuis bawaan secara otomatis.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceVariant, foregroundColor: AppColors.textPrimary),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceVariant, foregroundColor: AppColors.textPrimary),
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
    final preTestQs = _questions.where((q) => q.type == 'pre_test').toList();
    final postTestQs = _questions.where((q) => q.type == 'post_test').toList();

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
                      Wrap(
                        spacing: 12,
                        children: qs[i].options.entries.map((entry) {
                          final label = entry.key;
                          final text = entry.value;
                          final isCorrect = qs[i].correctAnswer.toUpperCase() == label;
                          return Text(
                            '$label. $text',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                              color: isCorrect ? AppColors.success : AppColors.textSecondary,
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
