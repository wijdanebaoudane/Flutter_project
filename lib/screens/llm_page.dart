import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class LlmPage extends StatefulWidget {
  const LlmPage({super.key});

  @override
  _LlmPageState createState() => _LlmPageState();
}

class _LlmPageState extends State<LlmPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false;
  String _errorMessage = "";

  final String ollamaApiUrl = "http://10.40.11.108:11434/chat"; // URL corrigée

  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  Future<void> sendRequest(String userInput) async {
    if (userInput.trim().isEmpty) {
      setState(() {
        _errorMessage = "Veuillez entrer un texte avant d'envoyer.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = "";
      _errorMessage = "";
    });

    try {
      var data = {
        "message": userInput // Format attendu par l'API corrigé
      };

      var response = await http.post(
        Uri.parse(ollamaApiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String apiResponse = responseData['response'] ?? "Aucune réponse reçue.";
        setState(() {
          _response = apiResponse;
          _isLoading = false;
        });
        await _speak(apiResponse); // Convertit la réponse en parole
      } else {
        setState(() {
          _errorMessage = "Erreur ${response.statusCode}: ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur s'est produite : $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.setLanguage("fr-FR"); // Changez en "en-US" si nécessaire
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.9);
      print("Speaking: $text");
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _errorMessage = "Erreur TTS: $e";
      });
    }
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Statut : $status"),
      onError: (error) => print("Erreur : $error"),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() {
        _errorMessage = "Impossible de démarrer l'écoute. Vérifiez les permissions.";
      });
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ollama avec Flutter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Entrez votre prompt :',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tapez votre texte ici...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => sendRequest(_controller.text),
                  child: Text("Envoyer à Ollama"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _response = "";
                      _errorMessage = "";
                    });
                  },
                  child: Text("Réinitialiser"),
                ),
                ElevatedButton(
                  onPressed: _isListening ? stopListening : startListening,
                  child: Text(_isListening ? "Arrêter" : "Micro"),
                ),
              ],
            ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            if (_response.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Réponse d\'Ollama :\n$_response',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
