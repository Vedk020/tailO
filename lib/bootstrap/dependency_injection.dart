import 'package:get_it/get_it.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/pet_service.dart';
import '../core/services/health_service.dart';

// Repositories
import '../domain/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
// ... import other repos

// ViewModels
import '../presentation/auth/login/login_view_model.dart';
import '../presentation/home/health/health_view_model.dart';

// ... import other VMs

final GetIt sl = GetIt.instance; // Service Locator

Future<void> setupDependencies() async {
  // 1. Core Services (Singletons)
  final storage = StorageService();
  await storage.init();
  sl.registerSingleton<StorageService>(storage);

  final authService = AuthService(sl());
  await authService.init();
  sl.registerSingleton<AuthService>(authService);

  final petService = PetService(sl());
  await petService.init();
  sl.registerSingleton<PetService>(petService);

  sl.registerLazySingleton<HealthService>(() => HealthService());

  // 2. Data Sources & Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // Add PetRepository, etc.

  // 3. ViewModels (Factory = New instance every time)
  sl.registerFactory(() => LoginViewModel(sl()));
  sl.registerFactory(() => HealthViewModel(sl()));
  // Add other ViewModels
}
