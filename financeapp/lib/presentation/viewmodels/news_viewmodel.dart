import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/datasources/remote/news_datasource.dart';
import '../../data/models/news_article.dart';

final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final dataSource = getIt<NewsDataSource>();
  return dataSource.getFinancialNews();
});
