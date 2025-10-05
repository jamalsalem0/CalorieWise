import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.clarifai.com/v2',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization':
                'Key ${dotenv.env['354f91aa1575486cab1c2ed6de948da6']}',
            'Content-Type': 'application/json',
          },
        ),
      );

  Future<List<Map<String, dynamic>>> analyzeImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found at path: $imagePath');
      }

      final Uint8List imageBytes = await file.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      const modelId = 'food-item-recognition';
      const modelVersionId = '1d5fd481e0cf4826aa72ec3ff049e044';

      final requestBody = {
        "inputs": [
          {
            "data": {
              "image": {"base64": base64Image},
            },
          },
        ],
      };

      final url = '/models/$modelId/versions/$modelVersionId/outputs';

      print('📤 Sending request to Clarifai...');
      print('🌐 URL: $url');
      print(
        '🔑 API Key starts with: ${dotenv.env['354f91aa1575486cab1c2ed6de948da6']?.substring(0, 6)}...',
      );
      print('📸 Image size: ${imageBytes.length} bytes');

      final response = await _dio.post(url, data: requestBody);

      if (response.statusCode == 200) {
        final outputs = response.data['outputs'] as List;
        if (outputs.isEmpty) {
          throw Exception('No outputs returned from Clarifai.');
        }

        final concepts = outputs[0]['data']['concepts'] as List;
        final recognizedItems = concepts.map<Map<String, dynamic>>((concept) {
          return {'name': concept['name'], 'confidence': concept['value']};
        }).toList();

        return recognizedItems;
      } else {
        print('❌ Clarifai returned status: ${response.statusCode}');
        print('❌ Full response: ${response.data}');
        throw Exception('Clarifai API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🌐 DioException: ${e.message}');
      print('📡 Response data: ${e.response?.data}');
      throw Exception(
        'Failed to communicate with Clarifai: ${e.response?.statusCode}',
      );
    } catch (e) {
      print('❗ Unexpected error: $e');
      throw Exception('Image analysis failed: $e');
    }
  }
}
