import 'package:calorie_wise/features/camera/camera_screen.dart';
import 'package:calorie_wise/features/home/cubit/home_cubit.dart';
import 'package:calorie_wise/features/profile/profile_screen.dart';
import 'package:calorie_wise/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          if (state is HomeLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCalorieSummaryCard(context, state),
                const SizedBox(height: 24),
                _buildRecentMealsSection(context, state),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CameraScreen())),
        child: const Icon(Icons.camera_alt_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCalorieSummaryCard(BuildContext context, HomeLoaded state) {
    final percentage = (state.caloriesEaten / state.calorieGoal).clamp(
      0.0,
      1.0,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).primaryColor,
                  ),
                  Center(
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories Eaten',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${state.caloriesEaten.toInt()}',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / ${state.calorieGoal.toInt()} kcal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMealsSection(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Meals', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        if (state.recentMeals.isEmpty)
          const Center(child: Text('No meals recorded today.'))
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.recentMeals.length,
            itemBuilder: (context, index) {
              final meal = state.recentMeals[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: const Icon(Icons.restaurant_menu_outlined, size: 30),
                  title: Text(
                    meal['name']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(meal['time']!),
                  trailing: Text(
                    meal['calories']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
