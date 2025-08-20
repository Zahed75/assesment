import 'package:assesment/common_ui/widgets/alerts/u_alert.dart';
import 'package:assesment/core/theme/theme_notifier.dart';
import 'package:assesment/features/sigin/signin.dart';

import 'package:assesment/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

// Placeholder data for user (replace with actual data when available)
final userProfileProvider = StateProvider<Map<String, String>>((ref) {
  return {
    'name': 'John Doe',
    'email': 'johndoe@example.com',
    'phone': '+8801234567890',
  };
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final user = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(USizes.defaultSpace),
        children: [
          /// Profile Info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(20),
                  backgroundImage: const AssetImage('assets/logo/appLogo.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  user['name'] ?? "No Name",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? "No Email",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  user['phone'] ?? "No Phone",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: USizes.spaceBtwSections),
          const Divider(),

          /// Update Name
          ListTile(
            leading: const Icon(Iconsax.edit),
            title: const Text('Update Name'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final nameController = TextEditingController(
                text: user['name'] ?? '',
              );

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Update Name'),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          UAlert.show(
                            title: 'Error',
                            message: 'Name is required',
                            context: context,
                          );
                          return;
                        }
                        // Handle updating the name logic (no API for now)
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),

          /// Update Email
          ListTile(
            leading: const Icon(Iconsax.sms),
            title: const Text('Update Email'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final emailController = TextEditingController(
                text: user['email'] ?? '',
              );

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Update Email'),
                  content: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newEmail = emailController.text.trim();
                        if (newEmail.isEmpty) {
                          UAlert.show(
                            title: 'Error',
                            message: 'Email is required',
                            context: context,
                          );
                          return;
                        }
                        // Handle updating the email logic (no API for now)
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),

          /// Update Password
          ListTile(
            leading: const Icon(Iconsax.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final passwordController = TextEditingController();

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Update Password'),
                  content: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newPass = passwordController.text.trim();
                        if (newPass.length < 6) {
                          UAlert.show(
                            title: 'Error',
                            message: 'Password must be at least 6 characters',
                            context: context,
                          );
                          return;
                        }
                        // Handle updating the password logic (no API for now)
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),

          /// Toggle Theme
          ListTile(
            leading: const Icon(Iconsax.moon),
            title: const Text('Toggle Theme'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state = value
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
          ),

          /// Logout
          ListTile(
            leading: Icon(Iconsax.logout, color: Colors.grey.shade800),
            title: const Text('Logout'),
            onTap: () async {
              // Handle logout logic (no API for now)
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),

          /// App Version
          const Divider(),
          ListTile(
            leading: const Icon(Iconsax.information),
            title: const Text('App Version'),
            trailing: Text(
              '1.0.0', // Placeholder app version
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.code),
            title: const Text('Build Number'),
            trailing: Text(
              '100', // Placeholder build number
            ),
          ),
        ],
      ),
    );
  }
}
