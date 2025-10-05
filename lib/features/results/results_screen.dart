import 'dart:io';
import 'package:calorie_wise/common/widgets/loading_overlay.dart';
import 'package:calorie_wise/features/results/cubit/results_cubit.dart';
import 'package:calorie_wise/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultsScreen extends StatelessWidget {
  final String imagePath;
  const ResultsScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResultsCubit()..analyzeImage(imagePath),
      child: _ResultsScreenView(imagePath: imagePath),
    );
  }
}

class _ResultsScreenView extends StatelessWidget {
  final String imagePath;
  const _ResultsScreenView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result', style: theme.textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ResultsCubit, ResultsState>(
        listener: (context, state) {
          if (state is SavingMeal) {
            LoadingOverlay.show(context);
          } else if (state is MealSavedSuccess || state is MealSaveError) {
            LoadingOverlay.hide();
          }

          if (state is MealSavedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meal saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is MealSaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ResultsCubit, ResultsState>(
          buildWhen: (previous, current) {
            return current is ResultsInitial ||
                current is ResultsLoading ||
                current is ResultsSuccess ||
                current is ResultsError;
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      File(imagePath),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state is ResultsLoading || state is ResultsInitial)
                    _buildLoadingState(context),
                  if (state is ResultsSuccess)
                    _buildSuccessState(context, state),
                  if (state is ResultsError) Center(child: Text(state.message)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  void _showSaveMealDialog(BuildContext context, ResultsSuccess state) {
    final mealNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save Meal'),
          content: TextField(
            controller: mealNameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter meal name"),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('SAVE'),
              onPressed: () {
                final mealName = mealNameController.text.trim();
                if (mealName.isNotEmpty) {
                  context.read<ResultsCubit>().saveAnalysisResults(
                    currentState: state,
                    mealName: mealName,
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 32),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analyzing your meal...'),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, ResultsSuccess state) {
    final theme = Theme.of(context);
    if (state.recognizedItems.isEmpty) {
      return const Center(child: Text('Could not recognize any food items.'));
    }
    final topItem = state.recognizedItems.first;
    final estimatedCalories = 250 + (topItem['name'] as String).length * 10;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'ESTIMATED CALORIES',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$estimatedCalories',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Recognized Ingredients', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recognizedItems.length,
          itemBuilder: (context, index) {
            final item = state.recognizedItems[index];
            final name = item['name'] as String;
            final confidence = (item['confidence'] as double) * 100;
            return Card(
              child: ListTile(
                title: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  '${confidence.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ResultsCubit, ResultsState>(
      builder: (context, state) {
        final isSaving = state is SavingMeal;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('RETAKE'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (state is ResultsSuccess && !isSaving)
                      ? () => _showSaveMealDialog(context, state)
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('SAVE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionRow(String nutrient, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: theme.textTheme.bodyLarge),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
