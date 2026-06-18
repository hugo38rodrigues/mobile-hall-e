import 'package:flutter/material.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class ClientInformations extends StatefulWidget {
  const ClientInformations({super.key, required this.getInformations});

  final void Function(Informations) getInformations;

  @override
  State<ClientInformations> createState() => _ClientInformationsState();
}

class _ClientInformationsState extends State<ClientInformations> {
  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;

  @override
  void initState() {
    super.initState();
    _lastNameController = TextEditingController();
    _firstNameController = TextEditingController();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  void _sendInformations() {
    widget.getInformations(
      Informations.fromJson({
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
      }),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return SizedBox(
      width: 250,
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: textGold),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: textGold)),
            ],
          ),
          TextField(
              style: TextStyle(color: textWhite),
              controller: controller,
              cursorColor: textGold,
              onChanged: (_) => _sendInformations(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: textGold)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: textGold, width: 2),
                ),
              )),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildField('Votre nom', _lastNameController),
          _buildField('Votre prénom', _firstNameController),
        ],
      ),
    );
  }
}
