import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MyDropdownFormField extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const MyDropdownFormField(
      {super.key,
      required this.selectedValue,
      required this.items,
      required this.onChanged,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: items,
      selectedItem: selectedValue,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        itemBuilder: _customPopupItemBuilder,
      ),
      onChanged: onChanged,
      validator: validator,
      dropdownBuilder: _customDropdownBuilder,
    );
  }

  Widget _customDropdownBuilder(BuildContext context, String? selectedItem) {
    return Text(
      selectedItem ?? '',
      style: TextStyle(
        color: Colors.blueGrey[900],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, String item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.blueGrey[100],
            ),
      child: ListTile(
        title: Text(item),
      ),
    );
  }
}
