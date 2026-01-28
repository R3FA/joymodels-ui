import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/repositories/auth_repository.dart';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/data/services/sso_service.dart';

final sl = GetIt.instance;

void dependencyInjectionSetup() {
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => SsoService());

  sl.registerLazySingleton(() => AuthRepository(sl<SsoService>()));
  sl.registerLazySingleton(() => AuthService(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => SsoRepository(sl<SsoService>(), sl<AuthService>()),
  );
}
