import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/feature_card.dart';
import '../widgets/recent_calls_widget.dart';
import '../widgets/quick_actions_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ChatTab(),
    const CallsTab(),
    const AITab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_call_outlined),
              selectedIcon: Icon(Icons.video_call),
              label: 'Calls',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'AI',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                        Text(
                          'MeetMind',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ).animate().fadeIn().slideX(),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      borderRadius: BorderRadius.circular(25),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ).animate().scale(),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                const QuickActionsWidget(),

                const SizedBox(height: 24),

                // Features Grid
                Text(
                  'AI-Powered Features',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    FeatureCard(
                      icon: Icons.video_call,
                      title: 'Smart Video Calls',
                      description: 'FaceTime-like calls with AI transcription',
                      onTap: () => Navigator.pushNamed(context, '/video-call'),
                    ).animate().fadeIn(delay: 100.ms),
                    FeatureCard(
                      icon: Icons.chat_bubble,
                      title: 'Persistent Chat',
                      description: 'WhatsApp-style messaging with history',
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                    ).animate().fadeIn(delay: 200.ms),
                    FeatureCard(
                      icon: Icons.auto_awesome,
                      title: 'AI Summaries',
                      description: 'Auto-generated call notes & insights',
                      onTap: () => Navigator.pushNamed(context, '/ai-features'),
                    ).animate().fadeIn(delay: 300.ms),
                    FeatureCard(
                      icon: Icons.group_work,
                      title: 'Live Collaboration',
                      description: 'Real-time idea & image generation',
                      onTap: () => Navigator.pushNamed(context, '/ai-features'),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),

                const SizedBox(height: 24),

                // Coming Soon Features
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    FeatureCard(
                      icon: Icons.screen_share,
                      title: 'Screen Sharing',
                      description: 'Share your screen during calls',
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🚧 Screen Sharing - Coming Soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 500.ms),
                    FeatureCard(
                      icon: Icons.record_voice_over,
                      title: 'Voice Assistant',
                      description: 'AI voice commands & control',
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🤖 Voice Assistant - Coming Soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 600.ms),
                    FeatureCard(
                      icon: Icons.language,
                      title: 'Live Translation',
                      description: 'Real-time language translation',
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🌍 Live Translation - Coming Soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 700.ms),
                    FeatureCard(
                      icon: Icons.cloud_sync,
                      title: 'Cloud Sync',
                      description: 'Sync across all your devices',
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('☁️ Cloud Sync - Coming Soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Calls
                Text(
                  'Recent Calls',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                const RecentCallsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chat Feature Coming Soon'),
      ),
    );
  }
}

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Calls Feature Coming Soon'),
      ),
    );
  }
}

class AITab extends StatelessWidget {
  const AITab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AI Features Coming Soon'),
      ),
    );
  }
}
