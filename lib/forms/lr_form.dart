import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';

class LrForm extends StatefulWidget {
  const LrForm({super.key});

  @override
  State<LrForm> createState() => _LrFormState();
}

class _LrFormState extends State<LrForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController boxMismatchFromOrder = TextEditingController();
  final TextEditingController boxMismatchOnRescan = TextEditingController();
  final TextEditingController freight = TextEditingController();
  final TextEditingController lrCharge = TextEditingController();
  final TextEditingController totalFreight = TextEditingController();
  final TextEditingController boxDelivered = TextEditingController();

  String? selectedLrType;

  void submitData() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Form is valid, proceed with submission logic
      print(_formKey.currentState?.value);
    } else {
      // Form is invalid, display validation errors
      print("Validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LR Form'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  DropDown(
                    labelText: 'LR Type',
                    items: const [
                      'By Collection Request',
                      'By Log Sheet',
                      'By Manual'
                    ],
                    selectedItem: selectedLrType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLrType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: consignor,
                    labelText: 'Consignor Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: consignee,
                    labelText: 'Consignee Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                      controller: destination,
                      labelText: 'Destination',
                      obscureText: false),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxMismatchFromOrder,
                          labelText: 'Box Mismatch from order',
                          obscureText: false,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxMismatchOnRescan,
                          labelText: 'Box mismatch on rescan',
                          obscureText: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: LoginText(
                            controller: boxCount,
                            labelText: 'Box Count',
                            obscureText: false),
                      ),
                      Flexible(
                        flex: 1,
                        child: LoginText(
                            controller: boxDelivered,
                            labelText: 'Box Delivered',
                            obscureText: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                      controller: freight,
                      labelText: 'Freight',
                      obscureText: false),
                  const SizedBox(height: 25),
                  LoginText(
                      controller: lrCharge,
                      labelText: 'LR Charge',
                      obscureText: false),
                  const SizedBox(height: 25),
                  LoginText(
                      controller: totalFreight,
                      labelText: 'Total Freight',
                      obscureText: false,
                      readOnly: true),
                  const SizedBox(height: 25),
                  const SizedBox(height: 25),
                  MyButton(onTap: submitData, name: 'Submit'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
