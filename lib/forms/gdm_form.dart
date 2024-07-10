import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/dropdown_multiselect.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:multi_dropdown/enum/app_enums.dart';

class GdmForm extends StatefulWidget {
  const GdmForm({super.key});

  @override
  State<GdmForm> createState() => _GdmFormState();
}

String? selectedDriver;
String? selectedStaff;
List<Map<String, String>> items = [];

class _GdmFormState extends State<GdmForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController dispatchOn = TextEditingController();
  final TextEditingController dispatchTime = TextEditingController();
  final TextEditingController dispatchNumber = TextEditingController();
  final TextEditingController advance = TextEditingController();
  final TextEditingController deliveryStaff = TextEditingController();
  final TextEditingController loadingStaffs = TextEditingController();
  final TextEditingController vehicleRegisterNo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDM'),
        backgroundColor: Colors.grey[200],
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
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate =
                          await DatePicker.showSimpleDatePicker(
                        context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        dateFormat: "dd-MMMM-yyyy",
                        locale: DateTimePickerLocale.en_us,
                        looping: true,
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dispatchOn.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: FieldText(
                        controller: dispatchOn,
                        labelText: "Dispatch On",
                        obscureText: false,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        showPicker(
                          context: context,
                          value: Time(
                            hour: TimeOfDay.now().hour,
                            minute: TimeOfDay.now().minute,
                          ),
                          onChange: (Time newTime) {
                            final newTimeOfDay = TimeOfDay(
                                hour: newTime.hour, minute: newTime.minute);
                            setState(() {
                              dispatchTime.text = newTimeOfDay.format(context);
                            });
                          },
                          is24HrFormat: false,
                          accentColor: Theme.of(context).colorScheme.secondary,
                          unselectedColor: Colors.grey,
                          okText: 'OK',
                          cancelText: 'Cancel',
                        ),
                      );
                    },
                    child: AbsorbPointer(
                      child: FieldText(
                        controller: dispatchTime,
                        labelText: "Dispatch Time",
                        obscureText: false,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  FieldText(
                      controller: dispatchNumber,
                      labelText: "Dispatch Number",
                      obscureText: false,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 15.0),
                  FieldText(
                      controller: advance,
                      labelText: "Advance Amount",
                      obscureText: false,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 15.0),
                  DropDown(
                    labelText: 'Driver',
                    items: const ['Ravi', 'Bhavan', 'Sudarshan'],
                    selectedItem: selectedDriver,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDriver = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 15.0),
                  DropDown(
                    labelText: 'Delivery Staff',
                    items: const ['Revi', 'Bhavan', 'Sudarshan'],
                    selectedItem: selectedStaff,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStaff = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 15.0),
                  const NetworkMultiSelectDropdown(
                    url: '',
                    method: RequestMethod.get,
                    headers: {},
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
