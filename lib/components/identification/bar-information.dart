import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:image_picker/image_picker.dart';

class BarInformations extends StatefulWidget {
  final Function getInformation;
  final String role;

  BarInformations({required this.getInformation, required this.role});

  @override
  _BarInformationsState createState() => _BarInformationsState();
}

class _BarInformationsState extends State<BarInformations> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _image; // Stocke l'image sélectionnée
  final ImagePicker _picker = ImagePicker(); // Instance du sélecteur d'images

  // Fonction pour récupérer une image depuis la galerie ou la caméra
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void sendInformations() {
    String address = '${streetController.text}, ${postalCodeController.text}, ${cityController.text}';
    Informations informations = Informations.fromJson({
      'name': nameController.text,
      'description': descriptionController.text,
      'address': address
    }, widget.role);
    widget.getInformation(informations);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          // Ajout du ScrollView pour rendre le contenu défilable
          child: Column(
            // Retirer Expanded ici
            children: [
              SizedBox(
                width: 250,
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Nom du bar',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: nameController,
                      cursorColor: secondaryColor,
                     onChanged: (value) => (sendInformations()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Une description',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: descriptionController,
                      cursorColor: secondaryColor,
                      onChanged: (value) => (sendInformations()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Rue', style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: streetController,
                      cursorColor: secondaryColor,
                      onChanged: (value) => (sendInformations()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Ville', style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: cityController,
                      cursorColor: secondaryColor,
                      onChanged: (value) => (sendInformations()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Code postale',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: postalCodeController,
                      cursorColor: secondaryColor,
                      onChanged: (value) => (sendInformations()),
                    ),
                  ],
                ),
              ),
              _image != null
                  ? Image.file(_image!,
                      height: 100, width: 100, fit: BoxFit.cover)
                  : Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    ),

              // Boutons pour choisir une image
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Galerie"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Caméra"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
