import 'package:get_it/get_it.dart';

import '../core/services/storage_service.dart';
import '../core/services/health_service.dart';
import '../core/services/esp32_service.dart';
import '../presentation/home/health/health_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // 1. Core Services
  final storage = StorageService();
  await storage.init();
  sl.registerSingleton<StorageService>(storage);

  sl.registerLazySingleton<HealthService>(() => HealthService());
  sl.registerLazySingleton<Esp32Service>(() => Esp32Service());

  // 2. ViewModels
  sl.registerFactory(() => HealthViewModel());
}
