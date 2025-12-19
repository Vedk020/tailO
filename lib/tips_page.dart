import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'support_pages.dart'; // Import the new pages
import 'brand_footer.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // ... (Keep existing colors and data models: _allTips, _allFaqs) ...
  final Color colOrange = const Color(0xFFEE6C4D);
  final Color colCream = const Color(0xFFFBEFE6);
  final Color colGrey = const Color(0xFF7D7D81);
  final Color colBlack = const Color(0xFF151515);

  late final List<Map<String, dynamic>> _allTips = [
    {
      "title": "Daily Checks",
      "subtitle": "Monitor vitals",
      "icon": LucideIcons.heart,
      "textColor": Colors.white,
      "iconColor": Colors.white,
      "bgColor": colOrange,
    },
    {
      "title": "Nutrition",
      "subtitle": "Feeding guide",
      "icon": LucideIcons.utensils,
      "textColor": colBlack,
      "iconColor": colOrange,
      "bgColor": colCream,
    },
    {
      "title": "Active Play",
      "subtitle": "Fun exercises",
      "icon": LucideIcons.activity,
      "textColor": Colors.white,
      "iconColor": Colors.white,
      "bgColor": colGrey,
    },
    {
      "title": "Training",
      "subtitle": "Behavior tips",
      "icon": LucideIcons.brain,
      "textColor": Colors.white,
      "iconColor": colOrange,
      "bgColor": colBlack,
    },
    {
      "title": "Grooming",
      "subtitle": "Coat care",
      "icon": LucideIcons.scissors,
      "textColor": Colors.white,
      "iconColor": Colors.white,
      "bgColor": colOrange,
    },
  ];

  final List<Map<String, String>> _allFaqs = [
    {
      "q": "How do I set up my TailO Belt?",
      "a":
          "Turn on Bluetooth, go to the Overview page, tap 'Add', and hold the power button on the belt for 3 seconds.",
    },
    {
      "q": "What do the health alerts mean?",
      "a":
          "Red alerts indicate vitals outside the normal range. Yellow alerts suggest minor irregularities.",
    },
    {
      "q": "How often should I charge the device?",
      "a":
          "With average use, the battery lasts 3-4 days. We recommend charging it when it drops below 20%.",
    },
    {
      "q": "Can I track multiple pets?",
      "a":
          "Yes! You can add up to 5 pets in one account. Use the switcher on the Home or Profile page.",
    },
    {
      "q": "Is the device waterproof?",
      "a":
          "The TailO belt is IP67 water-resistant. It can withstand rain and splashes but is not meant for swimming.",
    },
    {
      "q": "How do I share my pet's profile?",
      "a":
          "Go to the Profile page, tap and hold your pet's card, and click 'Share ID Card'.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredTips = _allTips.where((t) {
      return t['title'].toString().toLowerCase().contains(_searchQuery) ||
          t['subtitle'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredFaqs = _allFaqs.where((f) {
      return f['q']!.toLowerCase().contains(_searchQuery) ||
          f['a']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Tips & Support",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Expert advice for your furry friend",
                style: TextStyle(fontSize: 14, color: TailOColors.muted),
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Search guides, tips, FAQs...",
                  hintStyle: const TextStyle(color: TailOColors.muted),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: TailOColors.muted,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colOrange),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tips
              if (filteredTips.isNotEmpty) ...[
                Text(
                  "Curated Guides",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTips.length,
                    itemBuilder: (context, index) =>
                        _buildFancyTipCard(context, filteredTips[index]),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // FAQs
              if (filteredFaqs.isNotEmpty) ...[
                Text(
                  "Frequently Asked Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: filteredFaqs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      return Column(
                        children: [
                          Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: colOrange,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                faq['q']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  child: Text(
                                    faq['a']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textTheme.bodyLarge?.color
                                          ?.withValues(alpha: 0.7),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index != filteredFaqs.length - 1)
                            Divider(height: 1, color: theme.dividerColor),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // --- UPDATED SUPPORT BUTTONS ---
              Text(
                "Still need help?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSupportButton(
                      context,
                      LucideIcons.messageCircle,
                      "Chat with Us",
                      colOrange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactSupportPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSupportButton(
                      context,
                      LucideIcons.bug,
                      "Report Bug",
                      Colors.redAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportBugPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Device Logs Button
              _buildSupportButton(
                context,
                LucideIcons.fileTerminal,
                "Device Logs & Diagnostics",
                Colors.blueAccent,
                isOutlined: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceLogPage()),
                ),
              ),
              const SizedBox(height: 16),

              // ADD FOOTER HERE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: BrandFooter(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildFancyTipCard(BuildContext context, Map<String, dynamic> tip) {
    final Color bgColor = tip['bgColor'] as Color;
    final Color textColor = tip['textColor'] as Color;
    final Color iconColor = tip['iconColor'] as Color;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tip['icon'] as IconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'] as String,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['subtitle'] as String,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: theme.dividerColor) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOutlined ? theme.textTheme.bodyLarge?.color : color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isOutlined ? theme.textTheme.bodyLarge?.color : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
