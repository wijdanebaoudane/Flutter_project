import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

class AssistantPage extends StatefulWidget {
  @override
  _AssistantPageState createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  TextEditingController _controller = TextEditingController();
  FlutterTts _flutterTts = FlutterTts();

  // Fonction pour envoyer le message au serveur FastAPI
  Future<void> _sendMessage(String message) async {
    final Uri apiUrl = Uri.parse("http://10.40.11.108:11434/chat");  // Votre adresse IP
    final response = await http.post(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"message": message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String responseText = data['response'];
      _speakResponse(responseText);  // Appeler la fonction de lecture audio
    } else {
      _speakResponse("Error: ${response.statusCode}");  // En cas d'erreur
    }
  }

  // Fonction pour lire la réponse audio via text-to-speech
  Future<void> _speakResponse(String response) async {
    await _flutterTts.setLanguage("en-US");  // Vous pouvez changer la langue ici si besoin
    await _flutterTts.setPitch(1.0);  // Ton de la voix (0.5 à 2.0)
    await _flutterTts.setSpeechRate(0.5);  // Vitesse de la parole
    await _flutterTts.speak(response);  // Lire la réponse à voix haute
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assistant Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter your message"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String message = _controller.text;
                if (message.isNotEmpty) {
                  _sendMessage(message);  // Envoyer le message et attendre la réponse
                  _controller.clear();
                }
              },
              child: Text("Send Message"),
            ),
          ],
        ),
      ),
    );
  }
}
