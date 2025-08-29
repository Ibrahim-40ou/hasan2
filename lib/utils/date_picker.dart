import 'dart:developer';

import 'package:flutter/material.dart';

Future<DateTime?> selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900, 1, 1),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Cairo')),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    log('The selected date is: $pickedDate');
  }

  return pickedDate;
}
