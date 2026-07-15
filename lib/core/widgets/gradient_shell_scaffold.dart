import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Varian mood header per peran (DESIGN.md §3.4):
/// siswa = biru cerah penuh energi, guru = biru lebih dalam & tenang.
enum ShellVariant { student, teacher }

/// Scaffold standar aplikasi: header gradient + lembar putih melengkung.
/// Dipakai di semua tab utama supaya seluruh app berbagi bahasa visual
/// yang sama dengan home siswa (DESIGN.md §2 prinsip 1).
class GradientShellScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ShellVariant variant;

  /// Widget di kanan header (mis. avatar, tombol aksi).
  final Widget? trailing;

  /// Widget tambahan di bawah judul, masih di area gradient
  /// (mis. baris badge, search bar, ringkasan statistik).
  final Widget? headerExtra;

  /// Isi lembar putih. Diletakkan dalam scroll view + RefreshIndicator
  /// jika [onRefresh] diberikan.
  final Widget body;

  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry bodyPadding;
  final bool showBackButton;

  /// Aksi tombol kembali; default [Navigator.maybePop].
  final VoidCallback? onBack;
  final Widget? floatingActionButton;

  const GradientShellScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.variant = ShellVariant.student,
    this.trailing,
    this.headerExtra,
    this.onRefresh,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
    this.showBackButton = false,
    this.onBack,
    this.floatingActionButton,
  });

  List<Color> get _gradient => switch (variant) {
        ShellVariant.student => const [Color(0xFF2196F3), Color(0xFF1976D2)],
        ShellVariant.teacher => const [Color(0xFF1565C0), Color(0xFF0D47A1)],
      };

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showBackButton)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: onBack ??
                              () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Kembali',
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          Text(
                            title,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (headerExtra != null) ...[
                  const SizedBox(height: 16),
                  headerExtra!,
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 180,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: bodyPadding,
            child: body,
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _gradient.last,
      floatingActionButton: floatingActionButton,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradient,
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: onRefresh != null
              ? RefreshIndicator(onRefresh: onRefresh!, child: content)
              : content,
        ),
      ),
    );
  }
}
