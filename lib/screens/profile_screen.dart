import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _aiSuggestionsEnabled = true;
  bool _autoRecordCalls = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _statusController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    _nameController.text = 'MeetMind User';
    _emailController.text = 'user@meetmind.com';
    _statusController.text = 'Available for meetings';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildPreferencesSection(),
                  const SizedBox(height: 24),
                  _buildAISettingsSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ).animate().scale(delay: 200.ms),
                    
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ).animate().scale(delay: 400.ms),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Display Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _statusController,
            label: 'Status Message',
            icon: Icons.message,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Language',
            icon: Icons.language,
            value: _selectedLanguage,
            items: ['English', 'Spanish', 'French', 'German', 'Chinese'],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
        ],
      ),
    ).animate().slideX(begin: -0.2, delay: 100.ms);
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'App Preferences',
      icon: Icons.settings,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive notifications for calls and messages',
            value: _notificationsEnabled,
            icon: Icons.notifications_outlined,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          _buildDropdownField(
            label: 'Theme',
            icon: Icons.palette,
            value: _selectedTheme,
            items: ['System', 'Light', 'Dark'],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
                _darkModeEnabled = value == 'Dark';
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Auto-record Calls',
            subtitle: 'Automatically record all video calls for transcription',
            value: _autoRecordCalls,
            icon: Icons.record_voice_over,
            onChanged: (value) {
              setState(() {
                _autoRecordCalls = value;
              });
            },
          ),
        ],
      ),
    ).animate().slideX(begin: -0.2, delay: 200.ms);
  }

  Widget _buildAISettingsSection() {
    return _buildSection(
      title: 'AI Features',
      icon: Icons.auto_awesome,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'AI Suggestions',
            subtitle: 'Enable smart suggestions and insights',
            value: _aiSuggestionsEnabled,
            icon: Icons.lightbulb_outline,
            onChanged: (value) {
              setState(() {
                _aiSuggestionsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            title: 'Real-time Transcription',
            subtitle: 'Convert speech to text during calls',
            icon: Icons.transcribe,
            trailing: const Chip(
              label: Text('Premium', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.amber,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            title: 'Meeting Summaries',
            subtitle: 'AI-generated notes and action items',
            icon: Icons.summarize,
            trailing: Icon(
              Icons.check_circle,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -0.2, delay: 300.ms);
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            title: 'Version',
            subtitle: '1.0.0 (Beta)',
            icon: Icons.info,
            onTap: () => _showVersionInfo(),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            icon: Icons.privacy_tip,
            onTap: () => _showPrivacyPolicy(),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            title: 'Terms of Service',
            subtitle: 'Read terms and conditions',
            icon: Icons.description,
            onTap: () => _showTermsOfService(),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            icon: Icons.help,
            onTap: () => _showSupport(),
          ),
        ],
      ),
    ).animate().slideX(begin: -0.2, delay: 400.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ).animate().scale(delay: 500.ms),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ).animate().scale(delay: 600.ms),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ).animate().scale(delay: 700.ms),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings Saved'),
        content: const Text('Your preferences have been saved successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notificationsEnabled = true;
                _darkModeEnabled = false;
                _aiSuggestionsEnabled = true;
                _autoRecordCalls = false;
                _selectedLanguage = 'English';
                _selectedTheme = 'System';
              });
              _showSnackBar('Settings reset to defaults');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of MeetMind?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final appState = context.read<AppState>();
              appState.logout();
              _showSnackBar('Signed out successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MeetMind v1.0.0'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚀 AI-Powered Communication Super App'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Video calling with AI transcription'),
            Text('• Real-time chat and collaboration'),
            Text('• Meeting notes and summaries'),
            Text('• AI brainstorming and content generation'),
            SizedBox(height: 8),
            Text('Built with Flutter & ❤️'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'MeetMind Privacy Policy\n\n'
            'We are committed to protecting your privacy. This policy explains how we collect, use, and protect your information.\n\n'
            'Information We Collect:\n'
            '• Account information (name, email)\n'
            '• Call recordings and transcriptions\n'
            '• Usage analytics\n\n'
            'How We Use Your Information:\n'
            '• Provide and improve our services\n'
            '• Generate AI insights and summaries\n'
            '• Customer support\n\n'
            'Data Security:\n'
            '• End-to-end encryption for calls\n'
            '• Secure cloud storage\n'
            '• Regular security audits\n\n'
            'For the complete privacy policy, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'MeetMind Terms of Service\n\n'
            'By using MeetMind, you agree to these terms.\n\n'
            'Acceptable Use:\n'
            '• Use the service responsibly\n'
            '• Respect other users\n'
            '• No illegal or harmful content\n\n'
            'Service Availability:\n'
            '• We strive for 99.9% uptime\n'
            '• Planned maintenance will be announced\n'
            '• Beta features may be unstable\n\n'
            'Account Responsibilities:\n'
            '• Keep your account secure\n'
            '• Notify us of unauthorized access\n'
            '• You are responsible for your content\n\n'
            'For complete terms, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? We\'re here for you!'),
            SizedBox(height: 16),
            Text('📧 Email: support@meetmind.com'),
            SizedBox(height: 8),
            Text('💬 Live Chat: Available in-app'),
            SizedBox(height: 8),
            Text('📚 Help Center: help.meetmind.com'),
            SizedBox(height: 8),
            Text('🐛 Report Bug: github.com/meetmind/issues'),
            SizedBox(height: 16),
            Text('We typically respond within 24 hours.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
