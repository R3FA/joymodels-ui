import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';

final sl = GetIt.instance;

void dependencyInjectionSetup() {
  // Http
  sl.registerLazySingleton(() => http.Client());

  // Sso
  sl.registerLazySingleton(() => SsoService());
  sl.registerLazySingleton(() => SsoRepository(sl()));
}
