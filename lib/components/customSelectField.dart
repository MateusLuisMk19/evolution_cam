import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomSelectField extends StatefulWidget {
  final List<String> options;
  final String hint;
  final Function(String?)? onChanged;
  final double radius;
  final bool invisible;
  final double? marginTop;
  final double? marginBottom;
  final double maxHeight;

  const CustomSelectField({
    Key? key,
    required this.options,
    this.hint = 'Selecione uma opção',
    this.onChanged,
    this.radius = 5,
    this.invisible = false,
    this.marginTop,
    this.marginBottom,
    this.maxHeight = 200.0,
  }) : super(key: key);

  @override
  _CustomSelectFieldState createState() => _CustomSelectFieldState();
}

class _CustomSelectFieldState extends State<CustomSelectField> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    if (widget.invisible) {
      return SizedBox();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.marginTop,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 136, 136, 136),
              width: 0.2,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
            color: Theme.of(context).cardColor, // Altera conforme o tema
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  widget.hint,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                value: selectedValue,
                items: widget.options
                    .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(
                      color: const Color.fromARGB(255, 136, 136, 136),
                      width: 1.8,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius),
                    color: Theme.of(context).cardColor,
                  ),
                  maxHeight: widget.maxHeight, // Define altura máxima do menu
                )),
          ),
        ),
        SizedBox(
          height: widget.marginBottom,
        ),
      ],
    );
  }
}
