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
    label: 'Panduan',
    icon: Icons.article_outlined,
    activeIcon: Icons.article,
    route: '/student/guide',
  ),
  NavItem(
    label: 'Pengaturan',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
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
  List<NavItem> get _navItems {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/student')) {
      return studentNavItems;
    }
    return teacherNavItems;
  }

  int get _currentIndex {
    final location = GoRouterState.of(context).matchedLocation;
    final items = _navItems;
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) {
        return i;
      }
    }
    return 0;
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => Expanded(
                child: _buildNavItem(index),
              ),
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
          vertical: AppSpacing.xs,
          horizontal: 2.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index, String route) {
    context.go(route);
  }
}
