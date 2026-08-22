import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class BarInformations extends StatefulWidget {
  final Function getInformation;

  BarInformations({required this.getInformation});

  @override
  _BarInformationsState createState() => _BarInformationsState();
}

class _BarInformationsState extends State<BarInformations> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void sendInformations() {
    String address =
        '${streetController.text}, ${postalCodeController.text} ${cityController.text}';
    Informations informations = Informations.fromJson({
      'name': nameController.text,
      'description': descriptionController.text,
      'address': address
    });
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
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: textGold),
                        Text('Nom du bar', style: TextStyle(color: textGold)),
                      ],
                    ),
                    TextField(
                      style: TextStyle(color: textWhite),
                      controller: nameController,
                      cursorColor: textGold,
                      onChanged: (value) => (sendInformations()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: textGold)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: textGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: textGold),
                        Text('Une description',
                            style: TextStyle(color: textGold)),
                      ],
                    ),
                    TextField(
                      style: TextStyle(color: textWhite),
                      controller: descriptionController,
                      cursorColor: textGold,
                      onChanged: (value) => (sendInformations()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: textGold)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: textGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: textGold),
                        Text('Rue', style: TextStyle(color: textGold)),
                      ],
                    ),
                    TextField(
                      style: TextStyle(color: textWhite),
                      controller: streetController,
                      cursorColor: textGold,
                      onChanged: (value) => (sendInformations()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: textGold)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: textGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: textGold),
                        Text('Code postale', style: TextStyle(color: textGold)),
                      ],
                    ),
                    TextField(
                      style: TextStyle(color: textWhite),
                      controller: postalCodeController,
                      cursorColor: textGold,
                      onChanged: (value) => (sendInformations()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: textGold)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: textGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: textGold),
                        Text('Ville', style: TextStyle(color: textGold)),
                      ],
                    ),
                    TextField(
                      style: TextStyle(color: textWhite),
                      controller: cityController,
                      cursorColor: textGold,
                      onChanged: (value) => (sendInformations()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: textGold)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: textGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
