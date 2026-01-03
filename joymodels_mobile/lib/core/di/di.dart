import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/repositories/auth_repository.dart';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/data/services/category_service.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';
import 'package:joymodels_mobile/data/services/users_service.dart';

final sl = GetIt.instance;

void dependencyInjectionSetup() {
  // Http
  sl.registerLazySingleton(() => http.Client());

  // SsoService
  sl.registerLazySingleton(() => SsoService());

  // Auth
  sl.registerLazySingleton(() => AuthRepository(sl<SsoService>()));
  sl.registerLazySingleton(() => AuthService(sl<AuthRepository>()));

  // SsoRepository
  sl.registerLazySingleton(
    () => SsoRepository(sl<SsoService>(), sl<AuthService>()),
  );

  // Users
  sl.registerLazySingleton(() => UsersService());
  sl.registerLazySingleton(
    () => UsersRepository(sl<UsersService>(), sl<AuthService>()),
  );

  // Category
  sl.registerLazySingleton(() => CategoryService());
  sl.registerLazySingleton(
    () => CategoryRepository(sl<CategoryService>(), sl<AuthService>()),
  );
}
