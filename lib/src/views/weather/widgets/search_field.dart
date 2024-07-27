import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField(
      {super.key,
      required this.onFieldSubmitted,
      required this.locationController});
  final Function(String) onFieldSubmitted;
  final TextEditingController locationController;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: widget.locationController,
        onFieldSubmitted: widget.onFieldSubmitted,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
            enabled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14),
            suffixIconConstraints: BoxConstraints(maxHeight: 20, minHeight: 20),
            suffixIcon: Icon(Icons.search, color: Colors.white, size: 20),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
      ),
    );
  }
}
