import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePickerFormField extends FormField<File?> {
  FilePickerFormField({
    FormFieldSetter<File?>? onSaved,
    FormFieldValidator<File?>? validator,
    File? initialValue,
    bool autoValidate = false,
    Key? key,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<File?> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                  // onPressed: () async {
                  //   if (await Permission.storage.request().isGranted) {
                  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
                  //       type: FileType.custom,
                  //       allowedExtensions: ['jpg', 'pdf', 'png', 'doc'],
                  //     );

                  //     if (result != null) {
                  //       state.didChange(File(result.files.single.path!));
                  //     }
                  //   } else {
                  //     ScaffoldMessenger.of(state.context).showSnackBar(
                  //       SnackBar(content: Text('Storage permission is required')),
                  //     );
                  //   }
                  // },
                  onPressed: () async {
                    // Check and request storage permission
                    PermissionStatus status = await Permission.storage.status;

                    print("$status ==============================");
                      PermissionStatus permissionStatus = await Permission.photos.request();
                    if (status.isDenied || status.isPermanentlyDenied) {
                      if (!permissionStatus.isGranted) {
                        ScaffoldMessenger.of(state.context).showSnackBar(
                          SnackBar(content: Text('Storage permission is required to pick a file.')),
                        );
                        return;
                      }
                    }

                    // If permission is granted, pick the file
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );

                    if (result != null) {
                      // state.didChange(File(result.files.single.path!));
                      final file = result.files.first;
                      
                    }
                  },
                  child: const Text('Select File'),
                ),
                state.value == null
                    ? const Text('No file selected')
                    // : Text('Selected file: \n ${state.value!.path.substring(0, 20)}...'),
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Selected file: \n ${state.value!.path.substring(0, 20)}...', // Limit path length
                          style: const TextStyle(
                            fontSize: 14, // Change to desired font size
                            fontWeight: FontWeight.w500, // Font weight
                            color: Colors.blueGrey, // Text color
                            fontStyle: FontStyle.italic, // Italic text style
                          ),
                        ),
                      ),
                state.hasError
                    ? Text(
                        state.errorText ?? '',
                        style: const TextStyle(color: Colors.red),
                      )
                    : Container(),
              ],
            );
          },
        );
}
