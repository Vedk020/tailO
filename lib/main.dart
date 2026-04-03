import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/data_service.dart';
import '../../../../core/theme/colors.dart';
// Screens
import 'presentation/auth/login/login_page.dart';
import 'presentation/home/overview/overview_page.dart';
import 'presentation/home/health/health_page.dart';
import 'presentation/home/tips/tips_page.dart';
import 'presentation/home/profile/profile_page.dart';
import 'presentation/home/community/community_page.dart';
import 'presentation/settings/settings_page.dart';
import 'bootstrap/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await DataService().init();
  runApp(const TailOApp());
}

class TailOApp extends StatelessWidget {
  const TailOApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to Theme Changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'tailO',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: TailOTheme.lightTheme,
          darkTheme: TailOTheme.darkTheme,
          // 2. Listen to Login State Changes (Reactive Navigation)
          // This ensures immediate redirect on Login/Logout
          home: ValueListenableBuilder<bool>(
            valueListenable: DataService().isLoggedInNotifier,
            builder: (context, isLoggedIn, _) {
              return isLoggedIn ? const MainScaffold() : const LoginPage();
            },
          ),
        );
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2; // Default to Overview (Center)
  late final PageController _pageController;

  // Screen List
  final List<Widget> _screens = const [
    TipsPage(),
    CommunityPage(),
    OverviewPage(),
    HealthPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extracted AppBar for cleaner MainScaffold
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: TailOAppBar(),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      // Extracted BottomNavBar for cleaner MainScaffold
      bottomNavigationBar: TailOBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ==========================================
// 🧩 COMPONENT: CUSTOM APP BAR
// ==========================================
class TailOAppBar extends StatelessWidget {
  const TailOAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataService = DataService(); // Singleton access

    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          // Logo
          Text(
            "tail",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const Text(
            "O",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: TailOColors.coral,
            ),
          ),
          const Spacer(),

          // QR Scan Button
          IconButton(
            icon: Icon(
              LucideIcons.scanLine,
              size: 22,
              color: theme.iconTheme.color,
            ),
            tooltip: "Scan Device",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("QR Scanner ready for integration!"),
                ),
              );
            },
          ),

          // Settings Button
          IconButton(
            icon: Icon(
              LucideIcons.settings,
              size: 22,
              color: theme.iconTheme.color,
            ),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 8),

          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: TailOColors.darkCard,
            backgroundImage: DataService.getImageProvider(
              dataService.ownerImage,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🧩 COMPONENT: CURVED BOTTOM NAV BAR
// ==========================================
class TailOBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TailOBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. The Curved Background & Icons
              Positioned.fill(
                child: CustomPaint(
                  painter: _CurvedNavBarPainter(
                    backgroundColor: theme.scaffoldBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: LucideIcons.lightbulb,
                          label: "Tips",
                          index: 0,
                          isSelected: currentIndex == 0,
                          onTap: onTap,
                        ),
                        _NavItem(
                          icon: LucideIcons.users,
                          label: "Community",
                          index: 1,
                          isSelected: currentIndex == 1,
                          onTap: onTap,
                        ),
                        const SizedBox(width: 80), // Space for center button
                        _NavItem(
                          icon: LucideIcons.heartPulse,
                          label: "Health",
                          index: 3,
                          isSelected: currentIndex == 3,
                          onTap: onTap,
                        ),
                        _NavItem(
                          icon: LucideIcons.user,
                          label: "Profile",
                          index: 4,
                          isSelected: currentIndex == 4,
                          onTap: onTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. The Floating Center Button
              Positioned(
                bottom: 15,
                left: MediaQuery.of(context).size.width / 2 - 32,
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: currentIndex == 2
                          ? TailOColors.coral
                          : const Color(0xFF8E8E93),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentIndex == 2
                              ? TailOColors.coral.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.3),
                          blurRadius: currentIndex == 2 ? 20 : 10,
                          spreadRadius: currentIndex == 2 ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/overviewIcon.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? TailOColors.coral
        : Theme.of(context).iconTheme.color;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedNavBarPainter extends CustomPainter {
  final Color backgroundColor;
  _CurvedNavBarPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    final path = Path();
    final centerX = size.width / 2;
    const curveWidth = 50.0;
    const curveDepth = -25.0;

    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(centerX - curveWidth, 0);
    path.quadraticBezierTo(centerX - 25, curveDepth, centerX, curveDepth);
    path.quadraticBezierTo(centerX + 25, curveDepth, centerX + curveWidth, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
