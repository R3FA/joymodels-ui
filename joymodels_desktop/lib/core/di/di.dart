import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/repositories/auth_repository.dart';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/repositories/category_repository.dart';
import 'package:joymodels_desktop/data/repositories/community_post_repository.dart';
import 'package:joymodels_desktop/data/repositories/community_post_question_section_repository.dart';
import 'package:joymodels_desktop/data/repositories/model_faq_section_repository.dart';
import 'package:joymodels_desktop/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_desktop/data/repositories/report_repository.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/data/repositories/user_role_repository.dart';
import 'package:joymodels_desktop/data/repositories/users_repository.dart';
import 'package:joymodels_desktop/data/services/category_service.dart';
import 'package:joymodels_desktop/data/services/community_post_service.dart';
import 'package:joymodels_desktop/data/services/community_post_question_section_service.dart';
import 'package:joymodels_desktop/data/services/model_faq_section_service.dart';
import 'package:joymodels_desktop/data/services/model_reviews_service.dart';
import 'package:joymodels_desktop/data/services/report_service.dart';
import 'package:joymodels_desktop/data/services/sso_service.dart';
import 'package:joymodels_desktop/data/services/user_role_service.dart';
import 'package:joymodels_desktop/data/services/users_service.dart';

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

  sl.registerLazySingleton(() => ModelReviewsService());
  sl.registerLazySingleton(
    () => ModelReviewsRepository(sl<ModelReviewsService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => ModelFaqSectionService());
  sl.registerLazySingleton(
    () => ModelFaqSectionRepository(
      sl<ModelFaqSectionService>(),
      sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton(() => CommunityPostService());
  sl.registerLazySingleton(
    () =>
        CommunityPostRepository(sl<CommunityPostService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => CommunityPostQuestionSectionService());
  sl.registerLazySingleton(
    () => CommunityPostQuestionSectionRepository(
      sl<CommunityPostQuestionSectionService>(),
      sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton(() => ReportService());
  sl.registerLazySingleton(
    () => ReportRepository(sl<ReportService>(), sl<AuthService>()),
  );

  sl.registerLazySingleton(() => UserRoleService());
  sl.registerLazySingleton(
    () => UserRoleRepository(sl<UserRoleService>(), sl<AuthService>()),
  );
}
