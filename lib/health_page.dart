import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'data_service.dart';
import 'signup_flow.dart';
import 'medical_record_sheet.dart';
import 'medical_history_page.dart';
import 'pet_model.dart';
import 'brand_footer.dart'; // Ensure this is imported

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  // --- LOGIC TO SAVE VITALS ON TAP ---
  void _saveVitalToHistory(
    BuildContext context,
    String type,
    String title,
    String value,
    String unit,
  ) async {
    final activePet = DataService().activePet;

    // Simple abnormality check (Mock logic)
    String note = "Routine auto-log.";
    if (type == "Heart Rate" &&
        int.tryParse(value) != null &&
        int.parse(value) > 120) {
      note = "Abnormal High Heart Rate Detected!";
    } else if (type == "SpO2" &&
        int.tryParse(value) != null &&
        int.parse(value) < 95) {
      note = "Low Oxygen Level Detected!";
    }

    final newRecord = MedicalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: "Vet", // Categorize as Vet/Checkup
      title: "$type Log",
      date: DateTime.now(),
      weight: activePet.weight, // Keep current weight
      notes: "$title: $value $unit\n$note",
    );

    await DataService().addMedicalRecord(activePet.id, newRecord);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.checkCircle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text("$type saved to History"),
            ],
          ),
          backgroundColor: TailOColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final pets = DataService().pets;

        // --- EMPTY STATE ---
        if (pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.heartPulse,
                    size: 60,
                    color: TailOColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No health data",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Add an agent to start monitoring vitals.",
                  style: TextStyle(color: TailOColors.muted),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SignupFlow(isAddingAnotherPet: true),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text(
                    "Add Your First Agent",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailOColors.coral,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final activePet = DataService().activePet;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PET SELECTOR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...pets.map((pet) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildPetAvatar(
                            context,
                            pet.image,
                            pet.name,
                            pet.id,
                            isSelected: pet.id == activePet.id,
                            isConnected: pet.isConnected,
                            onTap: () => DataService().switchPet(pet.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- HEALTH BANNER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      if (isLight)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Health Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: activePet.isConnected
                                  ? Colors.green
                                  : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activePet.isConnected
                                ? "All vitals within normal range"
                                : "Syncing paused (Disconnected)",
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Last updated 3 min ago",
                        style: TextStyle(
                          fontSize: 12,
                          color: TailOColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- METRICS GRID (CLICKABLE) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // HEART RATE CARD
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveVitalToHistory(
                              context,
                              "Heart Rate",
                              "Heart Rate",
                              activePet.heartRate,
                              "BPM",
                            ),
                            child: _buildHeartRateCard(
                              context,
                              activePet.heartRate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              // ACTIVITY CARD (Steps & Calories)
                              GestureDetector(
                                onTap: () => _saveVitalToHistory(
                                  context,
                                  "Activity",
                                  "Daily Steps",
                                  activePet.steps,
                                  "steps",
                                ),
                                child: _buildActivityCard(
                                  context,
                                  activePet.steps,
                                  activePet.calories,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // OXYGEN CARD
                              GestureDetector(
                                onTap: () => _saveVitalToHistory(
                                  context,
                                  "SpO2",
                                  "Oxygen Level",
                                  activePet.spo2,
                                  "%",
                                ),
                                child: _buildOxygenCard(
                                  context,
                                  activePet.spo2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- MEDICAL HISTORY HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicalHistoryPage(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Medical History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 20,
                            color: TailOColors.muted,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.plusCircle,
                        color: TailOColors.coral,
                      ),
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<MedicalRecord>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const MedicalRecordSheet(),
                            );
                        if (result != null) {
                          await DataService().addMedicalRecord(
                            activePet.id,
                            result,
                          );
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // --- PREVIEW LIST ---
              if (activePet.medicalRecords.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      "No records logged yet.",
                      style: TextStyle(color: TailOColors.muted),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: activePet.medicalRecords.take(3).map((record) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMedicalCard(context, record),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              // --- BRAND FOOTER ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: BrandFooter(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildMedicalCard(BuildContext context, MedicalRecord record) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicalHistoryPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TailOColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(record.type),
                color: TailOColors.coral,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${record.date.day}/${record.date.month}/${record.date.year} · ${record.type}",
                    style: TextStyle(
                      fontSize: 13,
                      color: TailOColors.muted.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (record.weight != null && record.weight!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  record.weight!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              )
            else if (record.attachmentPath != null)
              const Icon(
                LucideIcons.paperclip,
                size: 16,
                color: TailOColors.muted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard(BuildContext context, String bpm) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (isLight)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "HEART RATE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: TailOColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                LucideIcons.plus,
                size: 14,
                color: TailOColors.muted.withValues(alpha: 0.5),
              ), // Hint that it's clickable
            ],
          ),
          const Spacer(),
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  TailOColors.coral.withValues(alpha: 0.0),
                  TailOColors.coral.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: CustomPaint(
              painter: ECGWavePainter(),
              size: const Size(double.infinity, 60),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bpm,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(LucideIcons.heart, color: TailOColors.coral, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "BPM",
                      style: TextStyle(fontSize: 14, color: TailOColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UPDATED ACTIVITY CARD WITH CALORIES ---
  Widget _buildActivityCard(
    BuildContext context,
    String steps,
    String calories,
  ) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (isLight)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ACTIVITY",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: TailOColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                LucideIcons.plus,
                size: 14,
                color: TailOColors.muted.withValues(alpha: 0.5),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 4,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  color: TailOColors.coral,
                ),
              ),
              const SizedBox(width: 12),
              // Stats Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Steps
                  Row(
                    children: [
                      Text(
                        steps.split(',').first,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Steps",
                        style: TextStyle(
                          fontSize: 10,
                          color: TailOColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Calories
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.flame,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$calories Kcal",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOxygenCard(BuildContext context, String spo2) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (isLight)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    "SpO",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: TailOColors.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "₂",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: TailOColors.muted,
                    ),
                  ),
                ],
              ),
              Icon(
                LucideIcons.plus,
                size: 14,
                color: TailOColors.muted.withValues(alpha: 0.5),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$spo2%",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(
                  LucideIcons.droplet,
                  color: TailOColors.coral,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            "Normal",
            style: TextStyle(fontSize: 11, color: TailOColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatar(
    BuildContext context,
    String assetPath,
    String name,
    String id, {
    required bool isSelected,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color dotColor = isConnected
        ? const Color(0xFF34C759)
        : TailOColors.muted;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: TailOColors.coral, width: 2.5)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: isSelected
                      ? theme.cardColor
                      : theme.cardColor.withValues(alpha: 0.5),
                  // UPDATED: Using DataService.getImageProvider for pet images
                  backgroundImage: DataService.getImageProvider(assetPath),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.textTheme.bodyLarge?.color
                  : TailOColors.muted,
            ),
          ),
          Text(
            id,
            style: const TextStyle(fontSize: 9, color: TailOColors.muted),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Vet':
        return LucideIcons.stethoscope;
      case 'Vaccine':
        return LucideIcons.syringe;
      case 'Meds':
        return LucideIcons.pill;
      case 'Weight':
        return LucideIcons.scale;
      case 'Illness':
        return LucideIcons.thermometer;
      default:
        return LucideIcons.fileText;
    }
  }
}

class ECGWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TailOColors.coral
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    final points = [
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.22, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.8),
      Offset(size.width * 0.27, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.55, size.height * 0.5),
      Offset(size.width * 0.57, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.8),
      Offset(size.width * 0.62, size.height * 0.4),
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
    ];
    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points.skip(1)) path.lineTo(point.dx, point.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
