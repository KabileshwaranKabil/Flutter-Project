import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/local/export_service.dart';

/// Profile settings screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProfileProvider>();
    _nameController.text = provider.profile?.name ?? '';
    _emailController.text = provider.profile?.email ?? '';
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl) {
    final placeholder = CircleAvatar(
      radius: 60,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'S',
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );

    if (avatarUrl == null || avatarUrl.isEmpty) return placeholder;

    final file = File(avatarUrl);
    if (file.existsSync()) {
      return CircleAvatar(radius: 60, backgroundImage: FileImage(file));
    }

    return CircleAvatar(radius: 60, backgroundImage: NetworkImage(avatarUrl));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, provider, auth, child) {
          final profile = provider.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    _buildAvatar(context, profile.avatarUrl),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _pickAvatar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Auth section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(auth.signedIn ? Icons.check_circle : Icons.link, color: auth.signedIn ? Colors.green : null),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.signedIn
                                  ? 'Signed in as ${auth.account?.email ?? ''}'
                                  : 'Not linked. Sign in with Google to sync profile basics.',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: auth.loading
                                ? null
                                : auth.signedIn
                                    ? () => _signOutGoogle(auth)
                                    : () => _signInGoogle(auth, provider),
                            child: auth.loading
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(auth.signedIn ? 'Logout' : 'Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              
              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 32),
              
              // Stats Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        context,
                        Icons.access_time,
                        'Total Focus Time',
                        '${profile.totalFocusMinutes} min',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.auto_awesome,
                        'Total Reflections',
                        '${profile.totalReflections}',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.local_fire_department,
                        'Current Streak',
                        '${profile.currentStreak} days',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.emoji_events,
                        'Longest Streak',
                        '${profile.longestStreak} days',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.calendar_today,
                        'Member Since',
                        _formatDate(profile.joinedDate),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _exportProfile,
                icon: const Icon(Icons.download),
                label: const Text('Export Profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _saveProfile() async {
    final provider = context.read<ProfileProvider>();
    await provider.updateName(_nameController.text);
    await provider.updateEmail(_emailController.text.isEmpty ? null : _emailController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 80);
    if (picked == null) return;
    await context.read<ProfileProvider>().updateAvatarFilePath(picked.path);
  }

  Future<void> _signInGoogle(AuthProvider auth, ProfileProvider profile) async {
    await auth.signIn();
    final acct = auth.account;
    if (acct != null) {
      await profile.linkGoogleAccount(
        displayName: acct.displayName ?? profile.profile?.name ?? 'User',
        email: acct.email,
        photoUrl: acct.photoUrl,
      );
      setState(() {
        _nameController.text = profile.profile?.name ?? _nameController.text;
        _emailController.text = profile.profile?.email ?? _emailController.text;
      });
    }
  }

  Future<void> _signOutGoogle(AuthProvider auth) async {
    await auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out of Google.')),
    );
  }

  Future<void> _exportProfile() async {
    try {
      final file = await ExportService.exportProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile exported to ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}
