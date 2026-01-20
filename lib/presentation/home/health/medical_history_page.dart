import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/health_service.dart'; // REQUIRED
import '../../medical/medical_record_sheet.dart';
import '../../../data/models/pet_model.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  String _selectedFilter = "All";
  bool _isNewestFirst = true;

  final List<String> _filters = [
    "All",
    "Vet",
    "Vaccine",
    "Meds",
    "Illness",
    "Weight",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePet = DataService().activePet;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Medical History",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isNewestFirst
                  ? LucideIcons.arrowDownNarrowWide
                  : LucideIcons.arrowUpNarrowWide,
              color: TailOColors.coral,
            ),
            onPressed: () => setState(() => _isNewestFirst = !_isNewestFirst),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet<MedicalRecord>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const MedicalRecordSheet(),
          );
          if (result != null) {
            await DataService().addMedicalRecord(activePet.id, result);
          }
        },
        backgroundColor: TailOColors.coral,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text("Add Record", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // FILTER BAR
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: theme.cardColor,
                  selectedColor: TailOColors.coral,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? TailOColors.coral
                          : theme.dividerColor,
                    ),
                  ),
                );
              },
            ),
          ),

          // LIST
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: DataService().selectedPetIdNotifier,
              builder: (context, _, __) {
                var records = List<MedicalRecord>.from(
                  DataService().activePet.medicalRecords,
                );

                if (_selectedFilter != "All") {
                  records = records
                      .where((r) => r.type == _selectedFilter)
                      .toList();
                }

                records.sort(
                  (a, b) => _isNewestFirst
                      ? b.date.compareTo(a.date)
                      : a.date.compareTo(b.date),
                );

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.filter,
                          size: 64,
                          color: TailOColors.muted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No ${_selectedFilter == 'All' ? '' : _selectedFilter} records found",
                          style: const TextStyle(color: TailOColors.muted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return _HistoryCard(
                      record: records[index],
                      petId: activePet.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MedicalRecord record;
  final String petId;

  const _HistoryCard({required this.record, required this.petId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: TailOColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: TailOColors.error),
      ),
      onDismissed: (direction) {
        DataService().removeMedicalRecord(petId, record.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Record deleted"),
            backgroundColor: TailOColors.coral,
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                        Text(
                          "${record.date.day}/${record.date.month}/${record.date.year}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: TailOColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (record.notes != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Text(
                  record.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
