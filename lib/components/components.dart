import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

Widget CustomBtn(
    {context,
    onPressedFunc,
    numWidth = 1,
    label,
    rgbColor,
    rgbBgColor,
    Color borderColor = Colors.transparent}) {
  /* = "111, 195, 223, 1" /* = "51,51,51,1" */;*/

  return SizedBox(
    width: MediaQuery.of(context).size.width / numWidth,
    height: 38,
    child: ElevatedButton(
      onPressed: onPressedFunc,
      child: Text(
        label,
        style: TextStyle(
          color: rgbColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: rgbBgColor,
        textStyle: TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
      ),
    ),
  );
}

Widget CustomTextField(
    {required TextEditingController fieldController,
    required String placeholder,
    required double radius,
    required BuildContext context,
    bool isObscured = false,
    bool inviseble = false,
    double? marginTop,
    double? marginBottom}) {
  if (inviseble) {
    return SizedBox();
  }

  return Column(
    children: [
      SizedBox(
        height: marginTop,
      ),
      SizedBox(
        height: 50,
        child: Center(
          child: TextField(
            controller: fieldController,
            decoration: InputDecoration(
              fillColor: Theme.of(context).cardColor,
              filled: true,
              labelText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              ),
            ),
            obscureText: isObscured,
          ),
        ),
      ),
      SizedBox(
        height: marginBottom,
      )
    ],
  );
}

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
