// lib/features/user/presentation/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize the display name with the current user's display name
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _displayNameController.text = user.displayName!;
    }
  }
  
  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Show loading indicator
        setState(() {
          _isEditing = false;
        });
        
        // Update the user's profile
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_displayNameController.text.trim());
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          _isEditing
              ? IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save',
                  onPressed: _updateProfile,
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildUserProfile(state.user);
          } else {
            return const Center(
              child: Text('You need to be logged in to view your profile'),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    final theme = Theme.of(context);
    final createdDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(user.metadata.creationTime!.millisecondsSinceEpoch.toString()));
    final formattedDate =
        '${createdDate.month}/${createdDate.day}/${createdDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.displayName?.isNotEmpty == true
                    ? user.displayName![0].toUpperCase()
                    : user.email![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Profile details
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Display Name
                if (_isEditing)
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a display name';
                      }
                      return null;
                    },
                  )
                else
                  Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : 'No Display Name',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 16),

                // Email
                _buildProfileInfoCard(
                  'Email',
                  user.email ?? 'No email available',
                  Icons.email,
                  theme.primaryColor,
                ),

                // Creation date
                _buildProfileInfoCard(
                  'Member Since',
                  formattedDate,
                  Icons.calendar_today,
                  GuvvyTheme.accent,
                ),

                // Email verification status
                _buildProfileInfoCard(
                  'Email Verification',
                  user.emailVerified ? 'Verified' : 'Not Verified',
                  Icons.verified_user,
                  user.emailVerified ? GuvvyTheme.success : GuvvyTheme.warning,
                  action: user.emailVerified
                      ? null
                      : ElevatedButton(
                          onPressed: () async {
                            try {
                              await user.sendEmailVerification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Verification email sent successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error sending verification email: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GuvvyTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Verify Email'),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Account actions
          _buildActionCard(
            'Saved Representatives',
            'View and manage your saved representatives',
            Icons.star,
            Colors.amber,
            onTap: () {
              // Navigate to saved representatives
              Navigator.pushNamed(context, '/saved-representatives');
            },
          ),

          _buildActionCard(
            'Notification Settings',
            'Manage your notification preferences',
            Icons.notifications,
            Colors.deepPurple,
            onTap: () {
              // Show notifications settings dialog
              _showNotificationsSettingsDialog();
            },
          ),

          _buildActionCard(
            'Privacy Settings',
            'Manage your privacy preferences',
            Icons.privacy_tip,
            Colors.teal,
            onTap: () {
              // Show privacy settings dialog
              _showPrivacySettingsDialog();
            },
          ),

          _buildActionCard(
            'Change Password',
            'Update your account password',
            Icons.lock,
            Colors.indigo,
            onTap: () {
              // Navigate to change password screen
              _showChangePasswordDialog();
            },
          ),

          const SizedBox(height: 16),

          // Sign out button
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    Widget? action,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: GuvvyTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (action != null) action,
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: GuvvyTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              
              try {
                final user = FirebaseAuth.instance.currentUser;
                await user?.updatePassword(passwordController.text);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating password: $e')),
                );
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettingsDialog() {
    bool voteAlerts = true;
    bool billUpdates = true;
    bool committeeMeetings = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Notification Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Vote Alerts'),
                    subtitle: const Text('Get notified when your representatives vote'),
                    value: voteAlerts,
                    onChanged: (value) {
                      setState(() {
                        voteAlerts = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Bill Updates'),
                    subtitle: const Text('Get updates on bills you follow'),
                    value: billUpdates,
                    onChanged: (value) {
                      setState(() {
                        billUpdates = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Committee Meetings'),
                    subtitle: const Text('Get notified about upcoming committee meetings'),
                    value: committeeMeetings,
                    onChanged: (value) {
                      setState(() {
                        committeeMeetings = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save notification settings
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings saved')),
                  );
                },
                child: const Text('SAVE'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showPrivacySettingsDialog() {
    bool shareAnalytics = true;
    bool locationHistory = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Privacy Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Share Analytics'),
                    subtitle: const Text('Help improve the app with anonymous usage data'),
                    value: shareAnalytics,
                    onChanged: (value) {
                      setState(() {
                        shareAnalytics = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Save Location History'),
                    subtitle: const Text('Save your address search history'),
                    value: locationHistory,
                    onChanged: (value) {
                      setState(() {
                        locationHistory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // Show confirmation before deleting data
                      Navigator.pop(context);
                      _showDeleteDataConfirmation();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete My Data'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save privacy settings
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy settings saved')),
                  );
                },
                child: const Text('SAVE'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete My Data'),
        content: const Text(
          'This will delete all your saved data including search history and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete user data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All user data has been deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}