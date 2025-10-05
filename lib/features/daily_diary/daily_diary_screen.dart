import 'package:calorie_wise/features/daily_diary/cubit/daily_diary_cubit.dart';
import 'package:calorie_wise/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DailyDiaryScreen extends StatelessWidget {
  const DailyDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DailyDiaryCubit()..loadDiaryForDate(DateTime.now()),
      child: const DailyDiaryView(),
    );
  }
}

class DailyDiaryView extends StatefulWidget {
  const DailyDiaryView({Key? key}) : super(key: key);

  @override
  DailyDiaryViewState createState() => DailyDiaryViewState();
}

class DailyDiaryViewState extends State<DailyDiaryView> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
    context.read<DailyDiaryCubit>().loadDiaryForDate(_currentDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
      });
      context.read<DailyDiaryCubit>().loadDiaryForDate(_currentDate);
    }
  }

  Future<void> _showDeleteConfirmationDialog(String mealId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this meal?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<DailyDiaryCubit>().deleteMeal(
                  mealId,
                  _currentDate,
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditMealDialog(Map<String, dynamic> meal) async {
    final nameController = TextEditingController(text: meal['name']);
    final caloriesController = TextEditingController(
      text: meal['calories'].toString(),
    );
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Meal'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Meal Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter calories' : null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedData = {
                    'name': nameController.text.trim(),
                    'calories':
                        int.tryParse(caloriesController.text.trim()) ?? 0,
                  };
                  context.read<DailyDiaryCubit>().updateMeal(
                    mealId: meal['id'],
                    currentDate: _currentDate,
                    updatedData: updatedData,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary', style: theme.textTheme.headlineMedium),
      ),
      body: Column(
        children: [
          _buildDateNavigator(context),
          Expanded(
            child: BlocBuilder<DailyDiaryCubit, DailyDiaryState>(
              builder: (context, state) {
                if (state is DailyDiaryLoading || state is DailyDiaryInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DailyDiaryError) {
                  return Center(child: Text(state.message));
                }
                if (state is DailyDiaryLoaded) {
                  if (state.meals.isEmpty) {
                    return const Center(
                      child: Text('No meals recorded for this day.'),
                    );
                  }
                  return _buildMealsList(context, state.meals);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeDate(-1),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM d, yyyy').format(_currentDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined, size: 20),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  ListView _buildMealsList(
    BuildContext context,
    List<Map<String, dynamic>> meals,
  ) {
    final mealsBySection = <String, List<Map<String, dynamic>>>{};
    for (var meal in meals) {
      (mealsBySection[meal['section']] ??= []).add(meal);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: mealsBySection.entries.map((entry) {
        final sectionTitle = entry.key;
        final sectionMeals = entry.value;
        return _buildMealSection(
          context: context,
          title: sectionTitle,
          meals: sectionMeals,
        );
      }).toList(),
    );
  }

  Widget _buildMealSection({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> meals,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...meals.map((meal) => _buildMealCard(context, meal)).toList(),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: ListTile(
            title: Text(
              'Total $title Calories',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${_calculateTotalCalories(meals)} kcal',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final mealId = meal['id'] as String?;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: const Icon(Icons.lunch_dining_outlined),
        title: Text(meal['name'] ?? 'Unnamed Meal'),
        subtitle: Text('${meal['calories'] ?? 0} kcal'),
        trailing: mealId == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  _showDeleteConfirmationDialog(mealId);
                },
              ),
        onTap: mealId == null
            ? null
            : () {
                _showEditMealDialog(meal);
              },
      ),
    );
  }

  int _calculateTotalCalories(List<Map<String, dynamic>> meals) {
    if (meals.isEmpty) return 0;
    return meals.fold<int>(
      0,
      (sum, meal) => sum + (meal['calories'] as int? ?? 0),
    );
  }
}
