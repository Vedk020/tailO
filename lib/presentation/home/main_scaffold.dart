import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core
import '../../core/theme/colors.dart';
import '../../core/services/data_service.dart';

// Pages
import 'overview/overview_page.dart';
import 'health/health_page.dart';
import 'community/community_page.dart';
import 'profile/profile_page.dart';
import 'tips/tips_page.dart';
import '../settings/settings_page.dart'; // For AppBar navigation

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2; // Default to Overview (Center)
  late final PageController _pageController;

  // The 5 Main Screens
  final List<Widget> _screens = const [
    TipsPage(), // 0
    CommunityPage(), // 1
    OverviewPage(), // 2 (Home)
    HealthPage(), // 3
    ProfilePage(), // 4
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
      // 1. Custom App Bar
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: _TailOAppBar(),
      ),

      // 2. Main Content Area
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _screens,
      ),

      // 3. Curved Bottom Navigation
      bottomNavigationBar: _TailOBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ==========================================
// 🧩 COMPONENT: CUSTOM APP BAR
// ==========================================

class _TailOAppBar extends StatelessWidget {
  const _TailOAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This listener rebuilds the AppBar whenever the pet's connection status changes!
    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, _, __) {
        final userImage = DataService().ownerImage;
        final bool isConnected = DataService().activePet.isConnected;

        return Container(
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

              // ✅ NEW BLUETOOTH BUTTON
              IconButton(
                icon: Icon(
                  isConnected
                      ? LucideIcons.bluetoothConnected
                      : LucideIcons.bluetooth,
                  size: 22,
                  color: isConnected
                      ? TailOColors.coral
                      : theme.iconTheme.color,
                ),
                tooltip: isConnected ? "Disconnect Collar" : "Connect Collar",
                onPressed: () {
                  if (isConnected) {
                    DataService().disconnectHardware();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Collar Disconnected")),
                    );
                  } else {
                    DataService().connectHardware();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Connecting to TailO Collar..."),
                      ),
                    );
                  }
                },
              ),

              IconButton(
                icon: Icon(
                  LucideIcons.settings,
                  size: 22,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/settings',
                ), // Assuming you set up the route!
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.cardColor,
                backgroundImage: DataService.getImageProvider(userImage),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 🧩 COMPONENT: CURVED BOTTOM NAV BAR
// ==========================================
class _TailOBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _TailOBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                        const SizedBox(width: 80), // Gap for center button
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

              // 2. The Floating Center Button (Overview)
              Positioned(
                bottom: 20,
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
                          blurRadius: currentIndex == 2 ? 16 : 8,
                          spreadRadius: currentIndex == 2 ? 2 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/overviewIcon.png', // Ensure this asset exists!
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              LucideIcons.home,
                              color: Colors.white,
                              size: 30,
                            ),
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
      behavior: HitTestBehavior.opaque, // Improves tap area
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

    // The nice curve for the floating button
    path.quadraticBezierTo(centerX - 25, curveDepth, centerX, curveDepth);
    path.quadraticBezierTo(centerX + 25, curveDepth, centerX + curveWidth, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Optional: Add shadow to the path itself for depth
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.05), 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
