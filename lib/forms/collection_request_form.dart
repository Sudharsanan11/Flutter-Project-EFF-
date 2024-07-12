import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:erpnext_logistics_mobile/fields/date_picker.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';



class CollectionRequestForm extends StatefulWidget {
  const CollectionRequestForm({super.key});
  

  @override
  State<CollectionRequestForm> createState() => _CollectionRequestFormState();
}

class _CollectionRequestFormState extends State<CollectionRequestForm> {

  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController location = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController timePicker = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController no_of_pcs = TextEditingController();

  @override
  void initState () {
    super.initState();
    status.text = "Open";
  }

  Future<void> _showDatePicket (BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2150),
      // barrierLabel : "Hiiiiiiiiiiiiiiiiii",
      // barrierColor: const Color(Colors.black)
      );
    
    if(picked != null) {
      setState(() {
        date.text = "${picked.toLocal()}".split(" ")[0];
      });
    }
  }

  Future<void> _showTimePicker (BuildContext context) async{
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      );
    if(picked != null) {
      setState(() {
        timePicker.text = "${picked.format(context)}".split(" ")[0];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Request'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            FieldText(
              controller: consignor,
              labelText: "Consignor",
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 10.0,),
            FieldText(
              controller: location,
              labelText: "Location",
              keyboardType: TextInputType.text
            ),
            const SizedBox(height: 10.0,),
            // FieldText(
            //   controller: consignor,
            //   labelText: "Vehicle Required Date",
            //   obscureText: false,
            //   keyboardType: TextInputType.text
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 3.0
              ),
              child: TextField(
              controller: date,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                fillColor: Colors.white,
                filled: true,
                labelText: "Date",
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                _showDatePicket(context);
              },
            ),
            ),
            const SizedBox(height: 10.0,),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 3.0
              ),
              child: TextField(
                controller: timePicker,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  labelText: "Required Time",
                  labelStyle: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  _showTimePicker(context);
                },
              ),
            ),
            // ElevatedButton(
            //   child: Text(dateTime.toString()),
            //   style: ButtonStyle(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: EdgeInsets.all())),
            //   onPressed: () {
            //     _showDatePicket();
            //   }),
            const SizedBox(height: 10.0,),
            FieldText(
              controller: status,
              labelText: "Status",
              readOnly: true,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10.0,),
            FieldText(
              controller: no_of_pcs,
              labelText: "No. of Pcs",
              readOnly: true,
              keyboardType: TextInputType.none),
            Text("Items"),
            const SizedBox(height: 10.0,),
            
          ]
        ),
      ),
    );
  }
}