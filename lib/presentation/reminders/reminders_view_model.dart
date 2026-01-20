import 'package:flutter/foundation.dart';
import '../../../core/services/data_service.dart'; // Or ReminderRepository

class RemindersViewModel extends ChangeNotifier {
  final DataService _dataService = DataService();

  ValueListenable<List<Map<String, dynamic>>> get reminders =>
      _dataService.remindersNotifier;

  void toggle(int index) => _dataService.toggleReminder(index);

  void delete(int index) => _dataService.deleteReminder(index);

  void add(Map<String, dynamic> reminder) => _dataService.addReminder(reminder);
}
