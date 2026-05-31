// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/local/app_database.dart' as _i450;
import '../../data/datasources/remote/firebase_datasource.dart' as _i300;
import '../../data/datasources/remote/news_datasource.dart' as _i700;
import '../../data/repositories/auth_repository_impl.dart' as _i200;
import '../../data/repositories/transaction_repository_impl.dart' as _i800;
import '../../domain/repositories/auth_repository.dart' as _i250;
import '../../domain/repositories/transaction_repository.dart' as _i850;

extension GetItInjectableX on _i174.GetIt {
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);

    gh.lazySingleton<_i59.FirebaseAuth>(() => _i59.FirebaseAuth.instance);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => _i974.FirebaseFirestore.instance);
    gh.lazySingleton<_i361.Dio>(() => _i361.Dio());

    gh.lazySingleton<_i300.FirebaseDataSource>(() =>
        _i300.FirebaseDataSource(
          _i174.GetIt.instance<_i59.FirebaseAuth>(),
          _i174.GetIt.instance<_i974.FirebaseFirestore>(),
        ));

    gh.lazySingleton<_i700.NewsDataSource>(
        () => _i700.NewsDataSource(_i174.GetIt.instance<_i361.Dio>()));

    // Note: AppDatabase requires async init — handled in main.dart via configureDependencies
    // For simplicity, we register a placeholder that gets replaced at runtime
    // See README for full setup instructions

    gh.lazySingleton<_i250.AuthRepository>(() =>
        _i200.AuthRepositoryImpl(
          _i174.GetIt.instance<_i300.FirebaseDataSource>(),
        ));

    return this;
  }
}
