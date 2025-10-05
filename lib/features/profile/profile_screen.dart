import 'package:calorie_wise/features/auth/auth_screen.dart';
import 'package:calorie_wise/features/profile/cubit/profile_cubit.dart';
import 'package:calorie_wise/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorie_wise/data/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showEditFieldDialog(
    BuildContext context,
    String field,
    String currentValue,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Update $field'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  context.read<ProfileCubit>().updateProfileField(
                    field,
                    newValue,
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('SAVE'),
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
        title: Text('My Profile', style: theme.textTheme.headlineMedium),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            return _buildLoadedView(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, ProfileLoaded state) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(context, state),
        const SizedBox(height: 32),
        _buildSectionTitle('My Stats', theme),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.monitor_weight_outlined,
                title: 'Weight',
                value: state.weight,
                onTap: () =>
                    _showEditFieldDialog(context, 'weight', state.weight),
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.height_outlined,
                title: 'Height',
                value: state.height,
                onTap: () =>
                    _showEditFieldDialog(context, 'height', state.height),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle('Settings', theme),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.track_changes_outlined,
                title: 'Daily Calorie Goal',
                value: state.calorieGoal,
                onTap: () => _showEditFieldDialog(
                  context,
                  'calorieGoal',
                  state.calorieGoal,
                ),
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileLoaded state) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/Avatar.png"),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(height: 12),
        Text(state.name, style: Theme.of(context).textTheme.headlineMedium),
        Text(
          state.email,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authService = AuthService();
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await authService.signOut();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log out: ${e.toString()}')),
          );
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('LOGOUT'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      ),
    );
  }
}
