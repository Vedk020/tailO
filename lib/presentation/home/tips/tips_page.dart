import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/brand_footer.dart';
import '../../../core/services/tips_service.dart';
import '../../../data/models/tip_model.dart';

// Navigation
import '../../support/support_pages.dart'; // Ensure path is correct

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Data
  late final List<Tip> _allTips = TipsService.getTips();
  late final List<Faq> _allFaqs = TipsService.getFaqs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter Logic
    final filteredTips = _allTips.where((t) {
      return t.title.toLowerCase().contains(_searchQuery) ||
          t.subtitle.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredFaqs = _allFaqs.where((f) {
      return f.question.toLowerCase().contains(_searchQuery) ||
          f.answer.toLowerCase().contains(_searchQuery);
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
                    borderSide: const BorderSide(color: TailOColors.coral),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tips Section
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
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) =>
                        _TipCard(tip: filteredTips[index]),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // FAQs Section
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
                              iconColor: TailOColors.coral,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                faq.question,
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
                                    faq.answer,
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

              // Support Actions
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
                    child: _SupportButton(
                      icon: LucideIcons.messageCircle,
                      label: "Chat with Us",
                      color: TailOColors.coral,
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
                    child: _SupportButton(
                      icon: LucideIcons.bug,
                      label: "Report Bug",
                      color: Colors.redAccent,
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
              _SupportButton(
                icon: LucideIcons.fileTerminal,
                label: "Device Logs & Diagnostics",
                color: Colors.blueAccent,
                isOutlined: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceLogPage()),
                ),
              ),
              const SizedBox(height: 16),

              const BrandFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// 🧩 EXTRACTED WIDGETS
// ------------------------------------------------------

class _TipCard extends StatelessWidget {
  final Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    // Contrast check logic would be ideal here, simplified for now
    final bool isDarkColor = tip.color.computeLuminance() < 0.5;
    final Color textColor = isDarkColor ? Colors.white : Colors.black;
    final Color iconColor = isDarkColor ? Colors.white : TailOColors.coral;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tip.color,
        boxShadow: [
          BoxShadow(
            color: tip.color.withValues(alpha: 0.2),
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
                  child: Icon(tip.icon, color: iconColor, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
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
                      tip.subtitle,
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
}

class _SupportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final VoidCallback onTap;

  const _SupportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
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
