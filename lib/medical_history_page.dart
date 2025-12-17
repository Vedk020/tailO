import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'data_service.dart';
import 'medical_record_sheet.dart';
import 'pet_model.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  // State for Filtering & Sorting
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Medical History",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // SORT BUTTON
          IconButton(
            icon: Icon(
              _isNewestFirst
                  ? LucideIcons.arrowDownNarrowWide
                  : LucideIcons.arrowUpNarrowWide,
              color: TailOColors.coral,
            ),
            tooltip: _isNewestFirst ? "Newest First" : "Oldest First",
            onPressed: () {
              setState(() {
                _isNewestFirst = !_isNewestFirst;
              });
            },
          ),
          const SizedBox(width: 8),
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
            setState(() {}); // Refresh list
          }
        },
        backgroundColor: TailOColors.coral,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text("Add Record", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // --- FILTER BAR ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                    backgroundColor: theme.cardColor,
                    selectedColor: TailOColors.coral,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? TailOColors.coral
                            : theme.dividerColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- LIST ---
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: DataService().selectedPetIdNotifier,
              builder: (context, _, __) {
                // 1. Get List
                var records = List<MedicalRecord>.from(
                  DataService().activePet.medicalRecords,
                );

                // 2. Apply Filter
                if (_selectedFilter != "All") {
                  records = records
                      .where((r) => r.type == _selectedFilter)
                      .toList();
                }

                // 3. Apply Sort
                records.sort((a, b) {
                  return _isNewestFirst
                      ? b.date.compareTo(a.date) // Newest first
                      : a.date.compareTo(b.date); // Oldest first
                });

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
                    final record = records[index];
                    return _buildDismissibleCard(context, record, activePet.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- DELETE WRAPPER ---
  Widget _buildDismissibleCard(
    BuildContext context,
    MedicalRecord record,
    String petId,
  ) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.red),
      ),
      onDismissed: (direction) {
        DataService().removeMedicalRecord(petId, record.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Record deleted"),
            backgroundColor: TailOColors.coral,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: _buildRecordCard(context, record, petId),
    );
  }

  // --- CARD UI ---
  Widget _buildRecordCard(
    BuildContext context,
    MedicalRecord record,
    String petId,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        "${record.date.day}/${record.date.month}/${record.date.year} • ${record.type}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: TailOColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // DELETE BUTTON
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    DataService().removeMedicalRecord(petId, record.id);
                    setState(() {}); // Refresh local UI immediately
                  },
                ),
              ],
            ),
          ),

          // Image Preview
          if (record.attachmentPath != null)
            GestureDetector(
              onTap: () => _showFullImage(context, record.attachmentPath!),
              child: Container(
                width: double.infinity,
                height: 150,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(record.attachmentPath!)),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.maximize2,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

          // Details Footer
          if ((record.notes != null && record.notes!.isNotEmpty) ||
              record.weight != null)
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.weight != null && record.weight!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.scale,
                            size: 14,
                            color: TailOColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Weight: ${record.weight}",
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (record.notes != null && record.notes!.isNotEmpty)
                    Text(
                      record.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color?.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(path)),
          ),
        ),
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
