import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'key.dart';

class OpenAIService {
  static Future<String> requestAI(String prompt) async {
//    const endpoint = 'https://api.deepseek.com/v1/chat/completions';
    const endpoint = 'https://openrouter.ai/api/v1/chat/completions';

    var apiKey = apiKeyOpenRouter; // Your DeepSeek key

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo", // Use "deepseek-coder" for coding tasks
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant that predicts moods and suggests ToDos based on mood patterns."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "max_tokens": 1000,
          "temperature": 0.7,
        }),
      );

      print("🔄 GPT Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        print("🧠 DeepSeek Response: $reply");
        return reply.trim();
      } else {
        print("❌ DeepSeek Error: ${response.body}");
        throw Exception("DeepSeek API error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
      throw Exception("Failed to connect to DeepSeek: $e");
    }
  }
}