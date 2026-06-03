// ignore_for_file: type=lint
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/remote/firebase_datasource.dart' as _i300;
import '../../data/datasources/remote/news_datasource.dart' as _i700;
import '../../data/repositories/auth_repository_impl.dart' as _i200;
import '../../domain/repositories/auth_repository.dart' as _i250;

extension GetItInjectableX on _i174.GetIt {
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);

    gh.lazySingleton<_i361.Dio>(() => _i361.Dio());
    gh.lazySingleton<_i59.FirebaseAuth>(() => _i59.FirebaseAuth.instance);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => _i974.FirebaseFirestore.instance);

    gh.lazySingleton<_i300.FirebaseDataSource>(
      () => _i300.FirebaseDataSource(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );

    gh.lazySingleton<_i700.NewsDataSource>(
      () => _i700.NewsDataSource(gh<_i361.Dio>()),
    );

    gh.lazySingleton<_i250.AuthRepository>(
      () => _i200.AuthRepositoryImpl(gh<_i300.FirebaseDataSource>()),
    );

    return this;
  }
}
