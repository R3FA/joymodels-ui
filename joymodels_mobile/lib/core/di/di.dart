import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/repositories/auth_repository.dart';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/community_post_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_availability_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_faq_section_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_review_type_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_mobile/data/repositories/shopping_cart_repository.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/data/services/category_service.dart';
import 'package:joymodels_mobile/data/services/community_post_service.dart';
import 'package:joymodels_mobile/data/services/model_faq_section_service.dart';
import 'package:joymodels_mobile/data/services/model_review_type_service.dart';
import 'package:joymodels_mobile/data/services/shopping_cart_service.dart';
import 'package:joymodels_mobile/data/services/model_availability_service.dart';
import 'package:joymodels_mobile/data/services/model_reviews_service.dart';
import 'package:joymodels_mobile/data/services/model_service.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';
import 'package:joymodels_mobile/data/services/users_service.dart';

final sl = GetIt.instance;

void dependencyInjectionSetup() {
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => SsoService());

  sl.registerLazySingleton(() => AuthRepository(sl<SsoService>()));
  sl.registerLazySingleton(() => AuthService(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => SsoRepository(sl<SsoService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => UsersService());
  sl.registerLazySingleton(
    () => UsersRepository(sl<UsersService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => CategoryService());
  sl.registerLazySingleton(
    () => CategoryRepository(sl<CategoryService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => ModelService());
  sl.registerLazySingleton(
    () => ModelRepository(sl<ModelService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => ModelAvailabilityService());
  sl.registerLazySingleton(
    () => ModelAvailabilityRepository(
      sl<ModelAvailabilityService>(),
      sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton(() => ModelReviewsService());
  sl.registerLazySingleton(
    () => ModelReviewsRepository(sl<ModelReviewsService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => ShoppingCartService());
  sl.registerLazySingleton(
    () => ShoppingCartRepository(sl<ShoppingCartService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => ModelFaqSectionService());
  sl.registerLazySingleton(
    () => ModelFaqSectionRepository(
      sl<ModelFaqSectionService>(),
      sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton(() => ModelReviewTypeService());
  sl.registerLazySingleton(
    () => ModelReviewTypeRepository(
      sl<ModelReviewTypeService>(),
      sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton(() => CommunityPostService());
  sl.registerLazySingleton(
    () =>
        CommunityPostRepository(sl<CommunityPostService>(), sl<AuthService>()),
  );
}
