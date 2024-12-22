import 'dart:io'; // Import pour Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img; // Import le package image
import 'package:flutter/services.dart'; // Import pour charger les assets

class FruitsPage extends StatefulWidget {
  const FruitsPage({super.key});

  @override
  _FruitsPageState createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage> {
  File? _image;
  List? _output;
  bool _loading = false;
  Interpreter? _interpreter; // Interpreter from tflite_flutter
  List<String> _labels = []; // Pour stocker les étiquettes des classes

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      loadLabels(); // Charger les étiquettes après le modèle
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _interpreter
        ?.close(); // Fermer l'interpréteur lors de la suppression du widget
    super.dispose();
  }

  // Charger le modèle tflite avec Interpreter.fromAsset
  Future<void> loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/fruits_model.tflite');
      print("Modèle chargé avec succès");
    } catch (e) {
      print("Erreur de chargement du modèle: $e");
    }
  }

  // Charger les étiquettes depuis le fichier label.txt
  Future<void> loadLabels() async {
    try {
      // Charger le fichier label.txt depuis les assets
      String labelData = await rootBundle.loadString('assets/models/label.txt');

      // Séparer les lignes du fichier et les stocker dans une liste
      _labels = labelData.split('\n');
      _labels = _labels
          .map((label) => label.trim())
          .toList(); // Nettoyer les espaces supplémentaires
      print("Étiquettes chargées avec succès");
    } catch (e) {
      print("Erreur de chargement des étiquettes: $e");
    }
  }

  // Exécuter le modèle sur l'image sélectionnée
  Future<void> classifyImage(File image) async {
    var inputImage = await image.readAsBytes();
    var input = await _preprocessImage(inputImage);

    var output = List.filled(1, List.filled(10, 0.0)); // Forme ajustée: [1, 10]
    _interpreter?.run(input, output);

    // Trouver la classe avec la probabilité la plus élevée
    int predictedClassIndex =
        output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    // Obtenir l'étiquette correspondante à la probabilité la plus élevée
    String predictedClassLabel = _labels[predictedClassIndex];

    setState(() {
      _output = [
        predictedClassLabel
      ]; // Stocker l'étiquette de la classe prédite
      _loading = false;
    });
  }

  // Prétraiter l'image (redimensionner à 32x32 sans normalisation)
  Future<List<List<List<List<int>>>>> _preprocessImage(
      List<int> imageBytes) async {
    // Charger l'image en utilisant le package image
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

    if (image == null) {
      throw Exception("Impossible de décoder l'image");
    }

    // Redimensionner l'image à 32x32
    img.Image resizedImage = img.copyResize(image, width: 32, height: 32);

    // Convertir l'image redimensionnée en un format de tenseur 4D : [batch, height, width, channels]
    var imageTensor = List.generate(1, (i) {
      return List.generate(32, (j) {
        return List.generate(32, (k) {
          var pixel = resizedImage.getPixel(k, j);
          // Obtenir les valeurs RGB directement sans normalisation
          return [
            img.getRed(pixel), // Canal rouge
            img.getGreen(pixel), // Canal vert
            img.getBlue(pixel), // Canal bleu
          ];
        });
      });
    });

    // Retourner l'image prétraitée sous forme de liste (taille de batch de 1)
    return imageTensor;
  }

  // Choisir une image depuis la galerie
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _loading = true;
        _image = File(image.path);
      });
      classifyImage(File(image.path));
    }
  }

  // Choisir une image depuis la caméra
  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _loading = true;
        _image = File(image.path);
      });
      classifyImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classificateur de Fruits"),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                SizedBox(height: 20),
                _image == null
                    ? Text("Aucune image sélectionnée")
                    : Image.file(_image!, height: 250, width: 250),
                SizedBox(height: 20),
                _output != null
                    ? Text(
                        "Prédiction : ${_output![0]}", // Afficher l'étiquette prédite
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text("Sélectionner une image depuis la galerie"),
                ),
                ElevatedButton(
                  onPressed: pickImageFromCamera,
                  child: Text("Prendre une photo avec la caméra"),
                ),
              ],
            ),
    );
  }
}
