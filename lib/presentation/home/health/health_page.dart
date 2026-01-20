import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/health_service.dart'; // Import New Service
import '../../../core/widgets/brand_footer.dart';
import '../../auth/signup/signup_flow.dart';
import 'medical_history_page.dart'; // Ensure correct path
import '../../medical/medical_record_sheet.dart'; // Ensure correct path
import '../../../data/models/pet_model.dart'; // Import Models

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  // --- SAVE LOGIC (Delegated to HealthService) ---
  void _saveVitalToHistory(
    BuildContext context,
    String type,
    String title,
    String value,
    String unit,
  ) async {
    final activePet = DataService().activePet;

    final newRecord = HealthService.createVitalLog(
      type: type,
      title: title,
      value: value,
      unit: unit,
      currentWeight: activePet.weight,
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
          backgroundColor: TailOColors.success,
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

        // EMPTY STATE
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
                  "Add an agent to start monitoring.",
                  style: TextStyle(color: TailOColors.muted),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SignupFlow(isAddingAnotherPet: true),
                    ),
                  ),
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text(
                    "Add Your First Agent",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailOColors.coral,
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
              // 1. PET SELECTOR (Simple horizontal list)
              _buildPetSelector(context, pets, activePet),

              const SizedBox(height: 10),

              // 2. HEALTH BANNER
              _buildHealthBanner(context, activePet, isLight),

              const SizedBox(height: 20),

              // 3. METRICS GRID
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _saveVitalToHistory(
                          context,
                          "Heart Rate",
                          "Heart Rate",
                          activePet.heartRate.toString(),
                          "BPM",
                        ),
                        child: _HeartRateCard(
                          bpm: activePet.heartRate.toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _saveVitalToHistory(
                              context,
                              "Activity",
                              "Daily Steps",
                              activePet.steps.toString(),
                              "steps",
                            ),
                            child: _ActivityCard(
                              steps: activePet.steps.toString(),
                              calories: activePet.calories.toString(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _saveVitalToHistory(
                              context,
                              "SpO2",
                              "Oxygen Level",
                              activePet.spo2.toString(),
                              "%",
                            ),
                            child: _OxygenCard(spo2: activePet.spo2.toString()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. MEDICAL HISTORY PREVIEW
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
                          const Icon(
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
                        // 1. Wait for result
                        final result =
                            await showModalBottomSheet<MedicalRecord>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const MedicalRecordSheet(),
                            );

                        // 2. Check & Save
                        if (result != null) {
                          await DataService().addMedicalRecord(
                            activePet.id,
                            result,
                          );
                          // 3. Force UI Rebuild
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Record Saved!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // LIST
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
                        child: _MedicalPreviewCard(record: record),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),
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

  Widget _buildPetSelector(
    BuildContext context,
    List<Pet> pets,
    Pet activePet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: pets.map((pet) {
            final isSelected = pet.id == activePet.id;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => DataService().switchPet(pet.id),
                child: Column(
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
                        backgroundImage: DataService.getImageProvider(
                          pet.image,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : TailOColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHealthBanner(BuildContext context, Pet pet, bool isLight) {
    final theme = Theme.of(context);
    return Padding(
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
                    color: pet.isConnected
                        ? TailOColors.success
                        : TailOColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  pet.isConnected
                      ? "All vitals within normal range"
                      : "Syncing paused (Disconnected)",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// 🧩 EXTRACTED WIDGETS (For Performance)
// ------------------------------------------------------

class _HeartRateCard extends StatelessWidget {
  final String bpm;
  const _HeartRateCard({required this.bpm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HEART RATE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: TailOColors.muted,
            ),
          ),
          const Spacer(),
          // ECG Wave (Simplified for now)
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
              painter: _ECGWavePainter(),
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
                child: Text(
                  "BPM",
                  style: TextStyle(fontSize: 14, color: TailOColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String steps;
  final String calories;
  const _ActivityCard({required this.steps, required this.calories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACTIVITY",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: TailOColors.muted,
            ),
          ),
          const Spacer(),
          Row(
            children: [
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$steps Steps",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    "$calories Kcal",
                    style: TextStyle(fontSize: 11, color: TailOColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OxygenCard extends StatelessWidget {
  final String spo2;
  const _OxygenCard({required this.spo2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SpO₂",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: TailOColors.muted,
            ),
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
              const Icon(
                LucideIcons.droplet,
                color: TailOColors.coral,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicalPreviewCard extends StatelessWidget {
  final MedicalRecord record;
  const _MedicalPreviewCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
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
              HealthService.getIconForType(record.type),
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
                  "${record.date.day}/${record.date.month}/${record.date.year}",
                  style: TextStyle(
                    fontSize: 13,
                    color: TailOColors.muted.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ECGWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TailOColors.coral
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.15, h * 0.5);
    path.lineTo(w * 0.2, h * 0.5);
    path.lineTo(w * 0.22, h * 0.2); // P
    path.lineTo(w * 0.25, h * 0.8); // Q
    path.lineTo(w * 0.27, h * 0.1); // R (Peak)
    path.lineTo(w * 0.3, h * 0.5); // S
    path.lineTo(w * 0.5, h * 0.5);
    path.lineTo(w * 0.55, h * 0.5);
    path.lineTo(w * 0.6, h * 0.3); // T
    path.lineTo(w * 0.65, h * 0.5);
    path.lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
