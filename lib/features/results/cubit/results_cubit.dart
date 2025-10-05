import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'results_state.dart';

class ResultsCubit extends Cubit<ResultsState> {
  ResultsCubit() : super(ResultsInitial());

  final String modelId = 'food-item-recognition';
  final String modelVersionId = '1d5fd481e0cf4826aa72ec3ff049e044';

  Future<void> analyzeImage(String imagePath) async {
    emit(ResultsLoading());
    try {
      final apiKey = dotenv.env['CLARIFAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        emit(ResultsError('354f91aa1575486cab1c2ed6de948da6'));
        return;
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        emit(ResultsError('❌ File not found at $imagePath'));
        return;
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
        'https://api.clarifai.com/v2/models/$modelId/versions/$modelVersionId/outputs',
      );

      print('📸 Analyzing image at: $imagePath');
      print('🔑 Using API Key (first 6 chars): ${apiKey.substring(0, 6)}...');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": [
            {
              "data": {
                "image": {"base64": base64Image},
              },
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final outputs = data['outputs'] as List;
        if (outputs.isEmpty) {
          emit(ResultsError('❌ No outputs returned from Clarifai.'));
          return;
        }

        final concepts = outputs.first['data']['concepts'] as List;
        final recognizedItems = concepts.map((c) {
          return {
            'name': c['name'],
            'confidence': (c['value'] as num).toDouble(),
          };
        }).toList();

        print('✅ Recognized items: $recognizedItems');
        emit(ResultsSuccess(recognizedItems));
      } else {
        print('❌ API returned ${response.statusCode}: ${response.body}');
        emit(ResultsError('API error: ${response.statusCode}'));
      }
    } catch (e) {
      print('❗ Error analyzing image: $e');
      emit(ResultsError('Error analyzing image: $e'));
    }
  }

  void saveAnalysisResults({
    required ResultsSuccess currentState,
    required String mealName,
  }) {
    try {
      print(
        '💾 Saving meal "$mealName" with items: ${currentState.recognizedItems}',
      );
      emit(MealSavedSuccess());
    } catch (e) {
      emit(MealSaveError('Failed to save meal: $e'));
    }
  }
}
