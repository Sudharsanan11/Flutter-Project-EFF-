import 'package:flutter/material.dart';

class AutoComplete extends StatelessWidget {
  final List<String> options;
  final String hintText;
  final ValueChanged<String> onSelected;
  // TextEditingController controller = TextEditingController();
  final TextEditingController controller;


  AutoComplete({
    required this.options,
    required this.hintText,
    required this.onSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        // if(controller.text == ''){
          // controller.text = textEditingController.text;
        // }
        // else {
        //   textEditingController.text = controller.text;
        // }
        textEditingController.text = controller.text;
        
        textEditingController.addListener(() {
          controller.text = textEditingController.text;
        });
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27.0),
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            onSubmitted: (String value) {
              onFieldSubmitted();
            },
            decoration: InputDecoration(
              // border: OutlineInputBorder(),
              // hintText: hintText,
              enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
              focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          
              fillColor: Colors.white,
              filled: true,
              labelText: hintText,
              labelStyle: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
      // optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
      //   return Align(
      //     alignment: Alignment.topLeft,
      //     child: Material(
      //       elevation: 4.0,
      //       child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 27.0),
      //         child: Container(
      //           // width: MediaQuery.of(context).size.width * 0.8,
      //           child: ListView.builder(
      //             padding: EdgeInsets.all(8.0),
      //             itemCount: options.length,
      //             itemBuilder: (BuildContext context, int index) {
      //               final String option = options.elementAt(index);
      //               return GestureDetector(
      //                 onTap: () {
      //                   onSelected(option);
      //                 },
      //                 child: ListTile(
      //                   title: Text(option),
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
      //       ),
      //     ),
      //   );
      // },
    );
  }
}
