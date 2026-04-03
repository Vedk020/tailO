import 'package:flutter/foundation.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/health_service.dart';
import '../../../data/models/pet_model.dart';

class HealthViewModel extends ChangeNotifier {
  HealthViewModel();

  Pet get activePet => DataService().activePet;

  Future<void> logVital(
    String type,
    String title,
    String value,
    String unit,
  ) async {
    final record = HealthService.createVitalLog(
      type: type,
      title: title,
      value: value,
      unit: unit,
      currentWeight: activePet.weight,
    );

    await DataService().addMedicalRecord(activePet.id, record);
    notifyListeners();
  }
}
