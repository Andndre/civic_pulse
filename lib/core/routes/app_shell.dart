import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/constants.dart';

// Navigation items
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

// Student navigation items
const studentNavItems = [
  NavItem(
    label: 'Beranda',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/student/home',
  ),
  NavItem(
    label: 'Belajar',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    route: '/student/learning',
  ),
  NavItem(
    label: 'Aktivitas',
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    route: '/student/activities',
  ),
  NavItem(
    label: 'Skor',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    route: '/student/scores',
  ),
  NavItem(
    label: 'Profil',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    route: '/student/profile',
  ),
];

// Teacher navigation items
const teacherNavItems = [
  NavItem(
    label: 'Beranda',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/teacher/home',
  ),
  NavItem(
    label: 'Kelas',
    icon: Icons.class_outlined,
    activeIcon: Icons.class_,
    route: '/teacher/home',
  ),
  NavItem(
    label: 'Profil',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    route: '/teacher/profile',
  ),
];

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  List<NavItem> get _navItems {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/student')) {
      return studentNavItems;
    }
    return teacherNavItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.shadowSm,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () => _onNavTap(index, item.route),
      borderRadius: AppRadius.radiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index, String route) {
    setState(() => _currentIndex = index);
    context.go(route);
  }
}
