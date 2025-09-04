// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';

class AIFeaturesScreen extends StatefulWidget {
  const AIFeaturesScreen({super.key});

  @override
  State<AIFeaturesScreen> createState() => _AIFeaturesScreenState();
}

class _AIFeaturesScreenState extends State<AIFeaturesScreen>
    with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;

  // State variables
  bool _isGenerating = false;
  List<String> _generatedContent = [];
  String _selectedTab = 'brainstorm';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _getTabName(_tabController.index);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'brainstorm';
      case 1:
        return 'notes';
      case 2:
        return 'collaborate';
      case 3:
        return 'generate';
      default:
        return 'brainstorm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTabBar(),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBrainstormTab(),
                      _buildNotesTab(),
                      _buildCollaborateTab(),
                      _buildGenerateTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'AI Features',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.white,
                  ),
                ).animate().scale(delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [
          Tab(icon: Icon(Icons.lightbulb_outline, size: 20), text: 'Ideas'),
          Tab(icon: Icon(Icons.note_alt_outlined, size: 20), text: 'Notes'),
          Tab(icon: Icon(Icons.group_work_outlined, size: 20), text: 'Collab'),
          Tab(icon: Icon(Icons.auto_awesome, size: 20), text: 'Generate'),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 300.ms);
  }

  Widget _buildBrainstormTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'AI Brainstorming',
            'Generate creative ideas and solutions',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: 20),
          _buildInputSection(
            'What would you like to brainstorm?',
            'Enter a topic, challenge, or goal...',
            onSubmit: () => _generateIdeas(),
          ),
          const SizedBox(height: 20),
          if (_generatedContent.isNotEmpty && _selectedTab == 'brainstorm')
            _buildResultsList(_generatedContent),
          const SizedBox(height: 20),
          _buildQuickActions([
            {
              'title': 'Product Ideas',
              'icon': Icons.inventory,
              'prompt': 'new product ideas',
            },
            {
              'title': 'Marketing Strategy',
              'icon': Icons.campaign,
              'prompt': 'marketing strategy',
            },
            {
              'title': 'Problem Solving',
              'icon': Icons.psychology,
              'prompt': 'creative solutions',
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Meeting Notes & Summaries',
            'AI-generated insights from your conversations',
            Icons.note_alt_outlined,
          ),

          const SizedBox(height: 20),

          // Current call summary card
          if (appState.callTranscriptions.isNotEmpty)
            _buildCallSummaryCard(appState),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => _generateMeetingNotes(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Meeting Notes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          if (_generatedContent.isNotEmpty && _selectedTab == 'notes')
            _buildMeetingNotesDisplay(),
        ],
      ),
    );
  }

  Widget _buildCollaborateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Live Collaboration',
            'AI-powered collaborative tools',
            Icons.group_work_outlined,
          ),

          const SizedBox(height: 20),

          // Whiteboard simulation
          _buildCollaborativeWhiteboard(),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  'Virtual Whiteboard',
                  'Collaborate in real-time',
                  Icons.draw_outlined,
                  () => _showWhiteboardDialog(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  'Screen Sharing',
                  'Share your screen (Demo)',
                  Icons.screen_share,
                  () => _simulateScreenShare(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'AI Content Generation',
            'Create images, documents, and more',
            Icons.auto_awesome,
          ),
          const SizedBox(height: 20),
          _buildInputSection(
            'Describe what you want to generate',
            'e.g., "A modern app interface design" or "Business plan outline"',
            onSubmit: () => _generateContent(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGenerationCard(
                  'Generate Image',
                  'Create AI images',
                  Icons.image,
                  () => _generateAIImage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenerationCard(
                  'Create Document',
                  'Generate text content',
                  Icons.document_scanner,
                  () => _generateDocument(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenerationCard(
                  'Design Ideas',
                  'UI/UX suggestions',
                  Icons.design_services,
                  () => _generateDesignIdeas(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_generatedContent.isNotEmpty && _selectedTab == 'generate')
            _buildGeneratedContentDisplay(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 100.ms);
  }

  Widget _buildInputSection(
    String title,
    String hint, {
    required VoidCallback onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _isGenerating ? null : onSubmit,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsList(List<String> results) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'AI Generated Results',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...results.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. '),
                  Expanded(child: Text(entry.value)),
                ],
              )
                  .animate(delay: Duration(milliseconds: entry.key * 100))
                  .slideX(begin: 0.2)
                  .fadeIn(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(List<Map<String, dynamic>> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((action) {
            return InkWell(
              onTap: () {
                _promptController.text = action['prompt'];
                _generateIdeas();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action['icon'],
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      action['title'],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCallSummaryCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Current Call Activity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('📊 Transcriptions: ${appState.callTranscriptions.length}'),
          const SizedBox(height: 4),
          Text('🎤 Recording: ${appState.isRecording ? "Active" : "Inactive"}'),
          const SizedBox(height: 4),
          Text(
            '🤖 AI Analysis: ${appState.isTranscribing ? "Running" : "Standby"}',
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingNotesDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Meeting Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generatedContent.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborativeWhiteboard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.draw, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Virtual Whiteboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to start collaborative drawing',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedContentDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Generated Content',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generatedContent.map(
            (content) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(content),
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _generateIdeas() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent.clear();
    });

    try {
      final ideas = await _aiService.generateIdeas(_promptController.text);
      setState(() {
        _generatedContent = ideas;
      });
    } catch (e) {
      _showError('Failed to generate ideas: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateMeetingNotes() async {
    final appState = context.read<AppState>();

    setState(() {
      _isGenerating = true;
      _generatedContent.clear();
    });

    try {
      final notes = await _aiService.generateMeetingNotes(
        transcriptions: appState.callTranscriptions,
        callDuration: const Duration(minutes: 5), // Demo duration
        participants: ['You', 'AI Assistant'],
      );

      List<String> formattedNotes = [
        '📋 **Meeting Summary:**',
        notes['summary'] ?? 'No summary available',
        '',
        '✅ **Action Items:**',
        ...((notes['actionItems'] as List<String>?) ?? []),
        '',
        '🎯 **Key Decisions:**',
        ...((notes['keyDecisions'] as List<String>?) ?? []),
        '',
        '➡️ **Next Steps:**',
        ...((notes['nextSteps'] as List<String>?) ?? []),
      ];

      setState(() {
        _generatedContent = formattedNotes;
      });
    } catch (e) {
      _showError('Failed to generate meeting notes: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateContent() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent.clear();
    });

    try {
      final suggestions = await _aiService.generateContentSuggestions(
        _promptController.text,
      );
      setState(() {
        _generatedContent = suggestions;
      });
    } catch (e) {
      _showError('Failed to generate content: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateAIImage() async {
    _showDialog(
      'AI Image Generator',
      '🎨 Generated: "Modern app interface with clean design"\n\n✨ Image would be displayed here in a production app with real AI image generation.',
    );
  }

  Future<void> _generateDocument() async {
    setState(() {
      _generatedContent = [
        '📄 **Document Outline Generated**',
        '',
        '1. Executive Summary',
        '2. Problem Statement',
        '3. Proposed Solution',
        '4. Implementation Plan',
        '5. Timeline & Milestones',
        '6. Budget & Resources',
        '7. Risk Assessment',
        '8. Success Metrics',
        '',
        '💡 Each section would include detailed content in a production app.',
      ];
    });
  }

  Future<void> _generateDesignIdeas() async {
    setState(() {
      _generatedContent = [
        '🎨 **UI/UX Design Suggestions**',
        '',
        '• Clean, minimalist interface',
        '• Consistent color scheme with brand colors',
        '• Intuitive navigation patterns',
        '• Responsive design for all devices',
        '• Accessibility-first approach',
        '• Dark mode support',
        '• Smooth animations and transitions',
        '• User-friendly onboarding flow',
      ];
    });
  }

  void _showWhiteboardDialog() {
    _showDialog(
      'Virtual Whiteboard',
      '🎨 Whiteboard feature activated!\n\nIn a production app, this would open a collaborative whiteboard where team members can draw, add sticky notes, and brainstorm together in real-time.',
    );
  }

  void _simulateScreenShare() {
    _showDialog(
      'Screen Sharing',
      '📺 Screen sharing simulation started!\n\nParticipants can now see your screen. This would integrate with actual screen capture APIs in a production app.',
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
