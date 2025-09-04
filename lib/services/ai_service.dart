import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  
  // Free Hugging Face API endpoint for text processing
  static const String _hfApiUrl = 'https://api-inference.huggingface.co/models';
  
  bool get isListening => _isListening;

  // Initialize speech recognition
  Future<bool> initializeSpeechRecognition() async {
    try {
      bool available = await _speechToText.initialize();
      return available;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  // Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              onResult(result.recognizedWords);
            }
          },
        );
      } else {
        onError('Speech recognition not available');
      }
    }
  }

  // Stop listening
  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
    }
  }

  // Generate AI summary (using free Hugging Face models)
  Future<String> generateCallSummary(List<String> transcriptions) async {
    try {
      if (transcriptions.isEmpty) {
        return "No conversation to summarize.";
      }

      // Combine all transcriptions
      String fullText = transcriptions.join(' ');
      
      // Use Hugging Face free summarization model
      final response = await http.post(
        Uri.parse('$_hfApiUrl/facebook/bart-large-cnn'),
        headers: {
          'Content-Type': 'application/json',
          // Note: For demo, we'll use a simple local summarization
        },
        body: jsonEncode({
          'inputs': fullText,
          'parameters': {
            'max_length': 100,
            'min_length': 20,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[0]['summary_text'] ?? _generateLocalSummary(transcriptions);
      } else {
        // Fallback to local summarization
        return _generateLocalSummary(transcriptions);
      }
    } catch (e) {
      print('Error generating AI summary: $e');
      return _generateLocalSummary(transcriptions);
    }
  }

  // Local fallback summarization
  String _generateLocalSummary(List<String> transcriptions) {
    if (transcriptions.isEmpty) {
      return "No conversation to summarize.";
    }

    // Simple keyword-based summarization for demo
    String fullText = transcriptions.join(' ').toLowerCase();
    List<String> keyPoints = [];

    // Look for common meeting patterns
    if (fullText.contains('project') || fullText.contains('work')) {
      keyPoints.add('• Discussed project-related topics');
    }
    if (fullText.contains('meeting') || fullText.contains('discuss')) {
      keyPoints.add('• Team meeting discussion');
    }
    if (fullText.contains('ai') || fullText.contains('technology')) {
      keyPoints.add('• Technology and AI topics covered');
    }
    if (fullText.contains('plan') || fullText.contains('schedule')) {
      keyPoints.add('• Planning and scheduling discussed');
    }

    if (keyPoints.isEmpty) {
      keyPoints.add('• General conversation');
      keyPoints.add('• Duration: ${transcriptions.length} exchanges');
    }

    return '''Call Summary:
${keyPoints.join('\n')}

Key Topics: ${_extractKeywords(fullText).take(3).join(', ')}
Participants: Active discussion with AI transcription''';
  }

  // Extract keywords for summary
  List<String> _extractKeywords(String text) {
    List<String> commonWords = ['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these', 'those'];
    
    List<String> words = text.split(' ')
        .where((word) => word.length > 3 && !commonWords.contains(word))
        .toList();
    
    Map<String, int> wordCount = {};
    for (String word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    var sortedWords = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords.map((e) => e.key).toList();
  }

  // Generate AI insights
  Future<List<String>> generateCallInsights(List<String> transcriptions) async {
    try {
      if (transcriptions.isEmpty) {
        return ['No insights available - start speaking to generate AI insights'];
      }

      // For demo purposes, generate some smart insights
      List<String> insights = [];
      String fullText = transcriptions.join(' ').toLowerCase();

      // Sentiment analysis (simple)
      if (fullText.contains('good') || fullText.contains('great') || fullText.contains('excellent')) {
        insights.add('✨ Positive sentiment detected in conversation');
      }
      
      if (fullText.contains('problem') || fullText.contains('issue') || fullText.contains('challenge')) {
        insights.add('⚠️ Problem-solving discussion identified');
      }

      if (fullText.contains('ai') || fullText.contains('technology')) {
        insights.add('🤖 Technology-focused conversation');
      }

      if (fullText.contains('meeting') || fullText.contains('schedule')) {
        insights.add('📅 Meeting planning discussion');
      }

      // Action items detection
      if (fullText.contains('need to') || fullText.contains('should') || fullText.contains('will')) {
        insights.add('📋 Action items mentioned in conversation');
      }

      if (insights.isEmpty) {
        insights.addAll([
          '💬 Active conversation detected',
          '🎯 ${transcriptions.length} speech segments processed',
          '⏱️ Real-time AI analysis active',
        ]);
      }

      return insights;
    } catch (e) {
      return ['Error generating insights: $e'];
    }
  }

  // Demo AI image generation
  Future<String> generateCollaborativeImage(String prompt) async {
    // For demo, return a placeholder
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
  }

  // Demo AI brainstorming
  Future<List<String>> generateIdeas(String topic) async {
    await Future.delayed(const Duration(seconds: 1));
    
    List<String> ideas = [];
    String lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('app') || lowerTopic.contains('software')) {
      ideas.addAll([
        '💡 Create user-friendly interface design',
        '🚀 Implement real-time collaboration features',
        '🔐 Add secure authentication system',
        '📊 Include analytics and insights dashboard',
      ]);
    } else if (lowerTopic.contains('business') || lowerTopic.contains('startup')) {
      ideas.addAll([
        '📈 Develop go-to-market strategy',
        '💰 Explore revenue model options',
        '🎯 Define target customer segments',
        '🤝 Build strategic partnerships',
      ]);
    } else {
      ideas.addAll([
        '💭 Brainstorm creative solutions',
        '🔍 Research market opportunities',
        '⚡ Implement innovative features',
        '🌟 Focus on user experience',
      ]);
    }

    return ideas;
  }

  // Generate meeting notes
  Future<Map<String, dynamic>> generateMeetingNotes({
    required List<String> transcriptions,
    required Duration callDuration,
    required List<String> participants,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate AI processing
      
      String fullText = transcriptions.join(' ');
      List<String> actionItems = _extractActionItems(fullText);
      List<String> keyDecisions = _extractKeyDecisions(fullText);
      List<String> nextSteps = _extractNextSteps(fullText);
      
      return {
        'summary': await generateCallSummary(transcriptions),
        'actionItems': actionItems,
        'keyDecisions': keyDecisions,
        'nextSteps': nextSteps,
        'insights': await generateCallInsights(transcriptions),
        'duration': _formatDuration(callDuration),
        'participants': participants,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to generate meeting notes: $e',
      };
    }
  }
  
  List<String> _extractActionItems(String text) {
    List<String> actionItems = [];
    String lowerText = text.toLowerCase();
    
    if (lowerText.contains('need to') || lowerText.contains('should')) {
      actionItems.add('📋 Follow up on discussed items');
    }
    if (lowerText.contains('schedule') || lowerText.contains('meeting')) {
      actionItems.add('📅 Schedule next meeting');
    }
    if (lowerText.contains('review') || lowerText.contains('check')) {
      actionItems.add('🔍 Review and validate discussed points');
    }
    if (lowerText.contains('implement') || lowerText.contains('build')) {
      actionItems.add('🛠️ Implement discussed solutions');
    }
    
    if (actionItems.isEmpty) {
      actionItems.add('📝 No specific action items identified');
    }
    
    return actionItems;
  }
  
  List<String> _extractKeyDecisions(String text) {
    List<String> decisions = [];
    String lowerText = text.toLowerCase();
    
    if (lowerText.contains('decided') || lowerText.contains('agree')) {
      decisions.add('✅ Team alignment achieved on key points');
    }
    if (lowerText.contains('project') || lowerText.contains('plan')) {
      decisions.add('🎯 Project direction confirmed');
    }
    if (lowerText.contains('ai') || lowerText.contains('technology')) {
      decisions.add('🤖 Technology approach validated');
    }
    
    if (decisions.isEmpty) {
      decisions.add('💭 Discussion-focused session');
    }
    
    return decisions;
  }
  
  List<String> _extractNextSteps(String text) {
    List<String> nextSteps = [];
    String lowerText = text.toLowerCase();
    
    if (lowerText.contains('next') || lowerText.contains('follow')) {
      nextSteps.add('➡️ Continue discussion in next session');
    }
    if (lowerText.contains('research') || lowerText.contains('study')) {
      nextSteps.add('🔬 Conduct further research');
    }
    if (lowerText.contains('team') || lowerText.contains('collaborate')) {
      nextSteps.add('🤝 Coordinate with team members');
    }
    
    if (nextSteps.isEmpty) {
      nextSteps.addAll([
        '📧 Share meeting summary with participants',
        '🔄 Schedule follow-up if needed',
      ]);
    }
    
    return nextSteps;
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      String hours = twoDigits(duration.inHours);
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
  
  // Generate collaborative whiteboard content
  Future<List<String>> generateWhiteboardIdeas(String topic) async {
    await Future.delayed(const Duration(seconds: 1));
    
    List<String> ideas = [
      '💡 Mind Map: $topic',
      '🎯 Goals & Objectives',
      '📊 Current State Analysis',
      '🚀 Future Vision',
      '⚡ Quick Wins',
      '🛠️ Implementation Steps',
      '🤝 Team Responsibilities',
      '📅 Timeline & Milestones',
    ];
    
    return ideas;
  }
  
  // Generate content suggestions
  Future<List<String>> generateContentSuggestions(String context) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<String> suggestions = [
      '📝 Create detailed documentation',
      '🎥 Record instructional video',
      '📊 Design infographic summary',
      '🎨 Generate visual mockups',
      '📱 Develop interactive prototype',
      '📋 Write step-by-step guide',
      '🔗 Compile relevant resources',
      '🌟 Highlight best practices',
    ];
    
    return suggestions.take(5).toList();
  }

  void dispose() {
    stopListening();
  }
}
