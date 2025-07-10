import 'package:flutter/material.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:provider/provider.dart';

class ClientInformations extends StatefulWidget {
  final Function(Informations) getInformations;
  ClientInformations({required this.getInformations});
  @override
  _ClientInformationsState createState() => _ClientInformationsState();
}

class _ClientInformationsState extends State<ClientInformations> {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();

  void sendInformations() {
    Informations informations = Informations.fromJson({
      'lastName': lastNameController.text,
      'firstName': firstNameController.text
    });
    widget.getInformations(informations);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 250,
                height: 120,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Votre nom',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                    TextField(
                      controller: lastNameController,
                      cursorColor: secondaryColor,
                      onChanged: (value) => sendInformations(),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.person, color: secondaryColor),
                  Text('Votre prénom', style: TextStyle(color: secondaryColor)),
                ],
              ),
              TextField(
                controller: firstNameController,
                cursorColor: secondaryColor,
                onChanged: (value) => sendInformations(),
              )
            ],
          ),
        );
      },
    );
  }
}
