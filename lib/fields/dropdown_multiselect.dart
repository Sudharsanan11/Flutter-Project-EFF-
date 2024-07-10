import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class NetworkMultiSelectDropdown extends StatelessWidget {
  final String url;
  final RequestMethod method;
  final Map<String, String> headers;

  const NetworkMultiSelectDropdown({
    super.key,
    required this.url,
    required this.method,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        MultiSelectDropDown.network(
          dropdownHeight: 300,
          onOptionSelected: (options) {
            debugPrint(options.toString());
          },
          searchEnabled: true,
          networkConfig: NetworkConfig(
            url: url,
            method: method,
            headers: headers,
          ),
          chipConfig: const ChipConfig(wrapType: WrapType.wrap),
          responseParser: (response) {
            final list = (response as List<dynamic>).map((e) {
              final item = e as Map<String, dynamic>;
              return ValueItem(
                label: item['name'],
                value: item['id'].toString(),
              );
            }).toList();

            return Future.value(list);
          },
          responseErrorBuilder: ((context, body) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error fetching the data'),
            );
          }),
        ),
      ],
    );
  }
}
