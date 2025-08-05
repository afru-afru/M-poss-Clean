import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/auth_local_data_source.dart';
import '../../data/datasources/local/cart_local_data_source.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/cart_remote_data_source.dart';
import '../../data/datasources/remote/product_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/cart/add_cart_item_usecase.dart';
import '../../domain/usecases/cart/get_cart_items_usecase.dart';
import '../../domain/usecases/cart/remove_cart_item_usecase.dart';
import '../../domain/usecases/cart/search_cart_products_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/cart/cart_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CartBloc(
      searchCartProductsUseCase: sl(),
      addCartItemUseCase: sl(),
      removeCartItemUseCase: sl(),
      getCartItemsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  
  sl.registerLazySingleton(() => SearchCartProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCartItemUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );


  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  
  // Configure Dio
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Add interceptor for debugging
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('DEBUG: HTTP Request: ${options.method} ${options.uri}');
      print('DEBUG: Request Headers: ${options.headers}');
      print('DEBUG: Request Data: ${options.data}');
      handler.next(options);
    },
    onResponse: (response, handler) {
      print('DEBUG: HTTP Response: ${response.statusCode}');
      print('DEBUG: Response Data: ${response.data}');
      handler.next(response);
    },
    onError: (error, handler) {
      print('DEBUG: HTTP Error: ${error.message}');
      print('DEBUG: Error Response: ${error.response?.data}');
      handler.next(error);
    },
  ));
  
  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(() => InternetConnectionChecker());
} 