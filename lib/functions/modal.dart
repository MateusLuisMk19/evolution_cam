import 'package:flutter/material.dart';

void modalConfirm(
    {required BuildContext context,
    title = 'Confirmação',
    content,
    required Function actions}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Deletar'),
            onPressed: () {
              Navigator.of(context).pop();
              actions();
            },
          ),
        ],
      );
    },
  );
}
