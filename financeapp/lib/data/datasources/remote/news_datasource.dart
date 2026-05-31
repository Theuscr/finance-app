import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../models/news_article.dart';

@lazySingleton
class NewsDataSource {
  final Dio _dio;

  // GNews API - free tier available at https://gnews.io
  // Replace with your API key
  static const _apiKey = 'YOUR_GNEWS_API_KEY';
  static const _baseUrl = 'https://gnews.io/api/v4';

  NewsDataSource(this._dio);

  Future<List<NewsArticle>> getFinancialNews() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': 'finanças investimento economia',
          'lang': 'pt',
          'country': 'br',
          'max': 10,
          'apikey': _apiKey,
        },
      );

      final articles = (response.data['articles'] as List)
          .map((json) => NewsArticle.fromJson(json))
          .toList();

      return articles;
    } on DioException catch (e) {
      // Fallback para notícias mock se a API falhar
      return _getMockNews();
    }
  }

  List<NewsArticle> _getMockNews() {
    return [
      NewsArticle(
        title: 'Selic permanece em 10,5% ao ano',
        description: 'O Comitê de Política Monetária (Copom) manteve a taxa básica de juros estável na última reunião.',
        url: 'https://www.bcb.gov.br',
        source: 'Banco Central do Brasil',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsArticle(
        title: 'Ibovespa fecha em alta de 1,2%',
        description: 'Bolsa brasileira tem recuperação após dados positivos da economia americana.',
        url: 'https://www.b3.com.br',
        source: 'B3',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NewsArticle(
        title: 'Dólar cai frente ao real',
        description: 'A moeda americana recuou 0,8% e fechou abaixo de R$ 5,00 nesta sexta-feira.',
        url: 'https://economia.uol.com.br',
        source: 'UOL Economia',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NewsArticle(
        title: 'Tesouro Direto: confira as melhores opções para investir em 2025',
        description: 'Com a Selic em patamar elevado, títulos públicos seguem atrativos para investidores conservadores.',
        url: 'https://www.tesourodireto.com.br',
        source: 'Tesouro Nacional',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      NewsArticle(
        title: 'Renda fixa segue como opção popular entre brasileiros',
        description: 'Pesquisa aponta crescimento de 18% no número de investidores em títulos de renda fixa.',
        url: 'https://www.infomoney.com.br',
        source: 'InfoMoney',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
