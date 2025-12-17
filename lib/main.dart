import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'login_page.dart';
import 'data_service.dart';
import 'overview_page.dart';
import 'health_page.dart';
import 'tips_page.dart';
import 'profile_page.dart';
import 'community_page.dart';
import 'settings_page.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DataService().init(); // Try to load data
  } catch (e) {
    print("Error loading data: $e");
    // Optionally clear bad data here if needed, or just start with empty state
  }

  runApp(const TailOApp());
}

class TailOApp extends StatelessWidget {
  const TailOApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Decide start screen based on login state
    final bool isLoggedIn = DataService().isLoggedIn;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'tailO',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: TailOTheme.lightTheme,
          darkTheme: TailOTheme.darkTheme,
          // If logged in, go to MainScaffold. If not, go to LoginPage.
          home: isLoggedIn ? const MainScaffold() : const LoginPage(),
        );
      },
    );
  }
}

// ... (Rest of MainScaffold and CurvedNavBarPainter remains exactly the same)
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2;
  late final PageController _pageController;

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

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
          color: theme.scaffoldBackgroundColor,
          child: Row(
            children: [
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
              IconButton(
                icon: Icon(
                  LucideIcons.scanLine,
                  size: 22,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.settings,
                  size: 22,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 18,
                backgroundColor: TailOColors.darkCard,
                backgroundImage: AssetImage('assets/images/pfp.jpeg'),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: Container(
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
                Positioned.fill(
                  child: CustomPaint(
                    painter: CurvedNavBarPainter(
                      backgroundColor: theme.scaffoldBackgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _navItem(LucideIcons.lightbulb, "Tips", 0),
                          _navItem(LucideIcons.users, "Community", 1),
                          const SizedBox(width: 80),
                          _navItem(LucideIcons.heartPulse, "Health", 3),
                          _navItem(LucideIcons.user, "Profile", 4),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: MediaQuery.of(context).size.width / 2 - 32,
                  child: _centerButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _currentIndex == index;
    final color = selected
        ? TailOColors.coral
        : Theme.of(context).iconTheme.color;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerButton() {
    final selected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _goToPage(2),
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: selected ? TailOColors.coral : const Color(0xFF8E8E93),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: selected
                  ? TailOColors.coral.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: selected ? 20 : 10,
              spreadRadius: selected ? 4 : 1,
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
    );
  }
}

class CurvedNavBarPainter extends CustomPainter {
  final Color backgroundColor;
  CurvedNavBarPainter({required this.backgroundColor});
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
