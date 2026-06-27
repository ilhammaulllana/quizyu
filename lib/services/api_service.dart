import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    final String baseUrl = _getBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logger interceptor for debugging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[API Request] ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API Response] ${response.statusCode} from ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('[API Error] ${e.message} from ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Android emulator loops back to localhost via 10.0.2.2
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  /// Calls POST /api/generate-quiz to get a list of structured questions.
  Future<Map<String, dynamic>> generateQuiz({
    required String topic,
    required int count,
    required String difficulty,
    required String modelVersion,
  }) async {
    try {
      final response = await _dio.post(
        '/api/generate-quiz',
        data: {
          'topic': topic,
          'count': count,
          'difficulty': difficulty,
          'modelVersion': modelVersion,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Format respon tidak sesuai. Diharapkan JSON object.');
      }
    } on DioException catch (e) {
      final String errMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      throw Exception('Koneksi ke backend gagal: $errMsg');
    }
  }

  /// Calls POST /api/generate-study-guide to generate a Markdown guide based on wrong answers.
  Future<String> generateStudyGuide({
    required String topic,
    required List<Map<String, dynamic>> incorrectQuestions,
  }) async {
    try {
      final response = await _dio.post(
        '/api/generate-study-guide',
        data: {
          'topic': topic,
          'incorrectQuestions': incorrectQuestions,
        },
        options: Options(
          responseType: ResponseType.plain, // Return text/markdown directly
        ),
      );

      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      final String errMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      throw Exception('Gagal mendapatkan panduan belajar dari AI: $errMsg');
    }
  }
}
