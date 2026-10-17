import 'package:flutter/material.dart';

class MyCustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const MyCustomSwitch({required this.value, required this.onChanged, Key? key})
      : super(key: key);

  @override
  _MyCustomSwitchState createState() => _MyCustomSwitchState();
}

class _MyCustomSwitchState extends State<MyCustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: SizedBox(
        width: 30, // Largura total do switch
        height: 30, // Altura total do switch
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Trilha retangular
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 30, // Largura da trilha
              height: 10, // Altura da trilha
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                color: widget.value
                    ? Colors.grey[300]
                    : Colors.grey, // Cor da trilha
              ),
            ),
            // Botão circular
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: widget.value ? 10 : 0, // Movimenta o botão
              child: Container(
                width: 20, // Botão maior que a trilha
                height: 20, // Botão maior que a trilha
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.value
                      ? Colors.black
                      : Colors.white, // Cor do botão
                  border: Border.all(
                    color: Colors.grey, // Borda preta
                    width: 2.0, // Espessura da borda
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
