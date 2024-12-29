import 'package:flutter/material.dart';

class MyClickable extends StatefulWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final List<PopupMenuEntry<String>>? items;

  const MyClickable({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.items,
  }) : super(key: key);

  @override
  _MyClickableState createState() => _MyClickableState();
}

class _MyClickableState extends State<MyClickable> {
  final GlobalKey _key = GlobalKey();

  void _showMenu(BuildContext context) {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width / 3,
        offset.dy + 20,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: widget.items!,
    ).then((value) {
      if (value != null) {
        print('Selecionado: $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: widget.onTap,
      onLongPress: () {
        _showMenu(context);
      },
      child: widget.child,
    );
  }
}
