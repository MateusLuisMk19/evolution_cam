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

Widget ActionsGroup(
    {bool inviseble = false,
    required Function() fistBtnPressed,
    required Function() secondBtnPressed}) {
  if (inviseble) {
    return SizedBox();
  }
  return Row(
    children: [
      SizedBox(
        width: 30,
        height: 30,
        child: IconButton.filledTonal(
          onPressed: fistBtnPressed,
          icon: Icon(Icons.edit),
          color: Colors.blue,
          iconSize: 15,
        ),
      ),
      SizedBox(width: 10),
      SizedBox(
        width: 30,
        height: 30,
        child: IconButton.filledTonal(
          onPressed: secondBtnPressed,
          icon: Icon(Icons.delete),
          color: Colors.red,
          iconSize: 15,
        ),
      ),
    ],
  );
}

Widget VisibilityBox(
    {bool inviseble = false,
    required Widget child,
    double? marginTop,
    double? marginBottom}) {
  if (inviseble) {
    return SizedBox();
  }
  return Column(
    children: [
      SizedBox(height: marginTop),
      child,
      SizedBox(height: marginBottom)
    ],
  );
}

Widget ButtonGroupYN(
    {required context,
    label1,
    label2,
    Function()? onButton1,
    Function()? onButton2,
    numWidth1 = 3.5,
    numWidth2 = 4.2,
    MainAxisAlignment axisAlignment = MainAxisAlignment.spaceEvenly}) {
  return Row(
    mainAxisAlignment: axisAlignment,
    children: [
      CustomBtn(
        context: context,
        label: label1,
        numWidth: numWidth1,
        onPressedFunc: onButton1,
        rgbBgColor: Color.fromRGBO(111, 195, 223, 1),
        rgbColor: Color.fromRGBO(51, 51, 51, 1),
      ),
      CustomBtn(
        context: context,
        label: label2,
        numWidth: numWidth2,
        onPressedFunc: onButton2,
        rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
        rgbColor: Color.fromRGBO(249, 249, 249, 1),
      ),
    ],
  );
}
