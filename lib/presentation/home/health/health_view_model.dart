import 'package:flutter/foundation.dart';
import '../../../core/services/pet_service.dart';
import '../../../core/services/health_service.dart';
import '../../../data/models/pet_model.dart';

class HealthViewModel extends ChangeNotifier {
  final PetService _petService;

  HealthViewModel(this._petService);

  Pet get activePet => _petService.activePet;

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
    await _petService.addMedicalRecord(activePet.id, record);
    notifyListeners();
  }
}
