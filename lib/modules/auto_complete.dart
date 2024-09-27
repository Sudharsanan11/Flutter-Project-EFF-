// import 'package:flutter/material.dart';

// class AutoComplete extends StatelessWidget {
//   final List<String> options;
//   final String hintText;
//   final ValueChanged<String> onSelected;
//   final TextEditingController controller;
//   final FormFieldValidator<String>? validator;
//   final readOnly;

//   const AutoComplete({
//     super.key,
//     required this.options,
//     required this.hintText,
//     required this.onSelected,
//     required this.controller,
//     this.readOnly = false,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Autocomplete<String>(
//       optionsBuilder: (TextEditingValue textEditingValue) {
//         if (textEditingValue.text.isEmpty) {
//           return const Iterable<String>.empty();
//         }
//         return options.where((String option) {
//           return option
//               .toLowerCase()
//               .contains(textEditingValue.text.toLowerCase());
//         });
//       },
//       onSelected: onSelected,
//       fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
//         textEditingController.text = controller.text;
        
//         textEditingController.addListener(() {
//           controller.text = textEditingController.text;
//         });
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 27.0),
//           child: TextFormField(
//             controller: textEditingController,
//             readOnly: readOnly,
//             focusNode: focusNode,
//             onFieldSubmitted: (String value) {
//               onFieldSubmitted();
//             },
//             validator: validator,
//             decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: isDarkMode ? Colors.white : Colors.black),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: isDarkMode ? Colors.white : Colors.black),
//               ),
//               fillColor: isDarkMode ? Colors.black54 : Colors.white,
//               filled: true,
//               labelText: hintText,
//               labelStyle: TextStyle(
//                   color: isDarkMode ? Colors.white70 : Colors.grey[600]),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

class AutoComplete extends StatelessWidget {
  final List<String> options;
  final String hintText;
  final ValueChanged<String> onSelected;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool readOnly;

  const AutoComplete({
    super.key,
    required this.options,
    required this.hintText,
    required this.onSelected,
    required this.controller,
    this.readOnly = false,
    this.validator,
  });

  // @override
  // void initState () {
  //   super.initState();
  // }

  void setConsignor(name) {
    print("name============== $name");
  }
 
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        textEditingController.text = controller.text;

        textEditingController.addListener(() {
          controller.text = textEditingController.text;
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27.0, vertical: 5.0),
          child: TextFormField(
            controller: textEditingController,
            readOnly: readOnly,
            focusNode: focusNode,
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
            validator: validator,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              fillColor: isDarkMode ? Colors.black54 : Colors.white,
              filled: true,
              labelText: hintText,
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              // prefixIcon: Icon(
              //   Icons.search,
              //   color: isDarkMode ? Colors.white70 : Colors.grey[600],
              // ),
            ),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              borderRadius: BorderRadius.circular(12.0),
              elevation: 4.0,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: isDarkMode ? Colors.white : Colors.grey,),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
          
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white,
                            fontSize: 17
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
