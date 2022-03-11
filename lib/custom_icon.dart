import 'package:flutter/material.dart';

GestureDetector customIcon(index, _selectedIndex, icon, lable, onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
          width: 4,
          color: _selectedIndex == index ? Colors.black : Colors.white,
        )),
      ),
      child: Column(
        children: <Widget>[icon, Text(lable)],
      ),
    ),
  );
}
