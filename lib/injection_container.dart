import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hotfoot/core/database/app_database.dart';
import 'package:hotfoot/core/network/network_info.dart';
import 'package:hotfoot/core/validators/validators.dart';
import 'package:hotfoot/features/login/data/repositories/login_repository_impl.dart';
import 'package:hotfoot/features/login/domain/repositories/login_repository.dart';
import 'package:hotfoot/features/login/domain/use_cases/sign_in_with_credentials.dart';
import 'package:hotfoot/features/login/domain/use_cases/sign_in_with_google.dart';
import 'package:hotfoot/features/login/presentation/bloc/login_bloc.dart';
import 'package:hotfoot/features/navigation_home/presentation/bloc/navigation_home_bloc.dart';
import 'package:hotfoot/features/navigation_auth/data/repositories/navigation_auth_repository_impl.dart';
import 'package:hotfoot/features/navigation_auth/domain/repositories/navigation_auth_repository.dart';
import 'package:hotfoot/features/navigation_auth/domain/use_cases/get_user.dart';
import 'package:hotfoot/features/navigation_auth/domain/use_cases/is_signed_in.dart';
import 'package:hotfoot/features/navigation_auth/domain/use_cases/sign_out.dart';
import 'package:hotfoot/features/navigation_auth/presentation/bloc/navigation_auth_bloc.dart';
import 'package:hotfoot/features/navigation_screen/presentation/bloc/navigation_screen_bloc.dart';
import 'package:hotfoot/features/places/data/data_sources/data_access_objects/place_dao.dart';
import 'package:hotfoot/features/places/data/data_sources/data_access_objects/place_photo_dao.dart';
import 'package:hotfoot/features/places/data/data_sources/places_local_data_source.dart';
import 'package:hotfoot/features/places/data/data_sources/places_remote_data_source.dart';
import 'package:hotfoot/features/places/data/repositories/places_repositories_impl.dart';
import 'package:hotfoot/features/places/domain/repositories/places_repository.dart';
import 'package:hotfoot/features/places/domain/use_cases/get_place_by_id.dart';
import 'package:hotfoot/features/places/domain/use_cases/get_place_photo.dart';
import 'package:hotfoot/features/places/domain/use_cases/get_places_ids.dart';
import 'package:hotfoot/features/places/presentation/blocs/place_details/place_details_bloc.dart';
import 'package:hotfoot/features/places/presentation/blocs/place_photo/place_photo_bloc.dart';
import 'package:hotfoot/features/places/presentation/blocs/places_ids/places_ids_bloc.dart';
import 'package:hotfoot/features/registration/data/repositories/registration_repository_impl.dart';
import 'package:hotfoot/features/registration/domain/repositories/registration_repository.dart';
import 'package:hotfoot/features/registration/domain/use_cases/sign_up.dart';
import 'package:hotfoot/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => LoginBloc(
        signInWithGoogle: sl(),
        signInWithCredentials: sl(),
        validators: sl(),
      ));
  sl.registerFactory(() => RegistrationBloc(
        signUp: sl(),
        validators: sl(),
      ));
  sl.registerFactory(() => NavigationAuthBloc(
        isSignedIn: sl(),
        getUser: sl(),
        signOut: sl(),
      ));
  sl.registerFactory(() => NavigationHomeBloc());
  sl.registerFactory(() => NavigationScreenBloc());
  sl.registerFactory(() => PlacesIdsBloc(
        getPlacesIds: sl(),
      ));
  sl.registerFactory(() => PlaceDetailsBloc(
        getPlaceById: sl(),
      ));
  sl.registerFactory(() => PlacePhotoBloc(
        getPlacePhoto: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(
        loginRepository: sl(),
      ));
  sl.registerLazySingleton(() => SignInWithCredentials(
        loginRepository: sl(),
      ));
  sl.registerLazySingleton(() => SignUp(
        registrationRepository: sl(),
      ));
  sl.registerLazySingleton(() => IsSignedIn(
        navigationAuthRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetUser(
        navigationAuthRepository: sl(),
      ));
  sl.registerLazySingleton(() => SignOut(
        navigationAuthRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetPlacesIds(
        placesRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetPlaceById(
        placesRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetPlacePhoto(
        placesRepository: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<ILoginRepository>(() => LoginRepository(
        firebaseAuth: sl(),
        googleSignIn: sl(),
      ));
  sl.registerLazySingleton<IRegistrationRepository>(
      () => RegistrationRepository(
            firebaseAuth: sl(),
          ));
  sl.registerLazySingleton<INavigationAuthRepository>(
      () => NavigationAuthRepository(
            firebaseAuth: sl(),
            googleSignIn: sl(),
          ));
  sl.registerLazySingleton<IPlacesRepository>(() => PlacesRepository(
        placesLocalDataSource: sl(),
        placesRemoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data Sources
  sl.registerLazySingleton<IPlacesLocalDataSource>(() => PlacesLocalDataSource(
        placeDao: sl(),
        placePhotoDao: sl(),
      ));
  sl.registerLazySingleton<IPlacesRemoteDataSource>(
      () => PlacesRemoteDataSource(
            firestore: sl(),
            firebaseStorage: sl(),
            tempPhotosDir: sl(),
            cacheManager: sl(),
          ));

  // Data Access Objects
  sl.registerLazySingleton<IPlaceDao>(() => PlaceDao(
        database: sl(),
      ));
  sl.registerLazySingleton<IPlacePhotoDao>(() => PlacePhotoDao(
        photosDir: sl(),
      ));

  // Local Dependencies
  final appDatabase = await AppDatabase.instance.database;
  sl.registerLazySingleton(() => appDatabase);

  final photosDir = await getApplicationDocumentsDirectory();
  sl.registerLazySingleton(() => photosDir);

  // External Dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => Firestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => DefaultCacheManager());

  // Core
  sl.registerLazySingleton(() => Validators());
  sl.registerLazySingleton<INetworkInfo>(() => NetworkInfo(sl()));
}
