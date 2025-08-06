import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/gemini_service.dart';
import '../../../config/env_config.dart';
import 'dart:developer' as developer;

class DebugGeminiScreen extends ConsumerStatefulWidget {
  const DebugGeminiScreen({super.key});

  @override
  ConsumerState<DebugGeminiScreen> createState() => _DebugGeminiScreenState();
}

class _DebugGeminiScreenState extends ConsumerState<DebugGeminiScreen> {
  String _result = '';
  bool _isLoading = false;

  void _testGeminiConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing Gemini API connection...';
    });

    try {
      developer.log('Starting Gemini test', name: 'DebugGemini');
      
      // Check if API key is configured
      final apiKey = EnvConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        setState(() {
          _result = 'ERROR: Gemini API key is not configured in .env file';
          _isLoading = false;
        });
        return;
      }

      // Test with a simple text prompt
      final geminiService = GeminiService();
      
      setState(() {
        _result = 'API Key found: ${apiKey.substring(0, 10)}...\nTesting calorie estimation...';
      });

      final calories = await geminiService.estimateCalories('Apple');
      
      setState(() {
        _result = '''API Key: ${apiKey.substring(0, 10)}...
Status: ✅ Connected successfully!
Test result: Apple = $calories calories

The Gemini API is working correctly.
You can now use the food recognition feature.''';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _result = '''❌ Error testing Gemini API:
$e

Please check:
1. Your internet connection
2. API key is valid
3. Gemini API is enabled in your Google Cloud project''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Gemini API'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testGeminiConnection,
              child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Gemini API Connection'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty) ...[
              const Text(
                'Test Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
