import 'package:flutter/material.dart';

Expanded customIcon(index, _selectedIndex, icon, lable, onPressed) {
  return Expanded(
    child: Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 4,
                color: _selectedIndex == index ? Colors.black : Colors.white,
              ),
            ),
          ),
          child: Column(
            children: <Widget>[
              icon,
              Text(
                lable,
                textScaleFactor: 0.8,
              )
            ],
          ),
        ),
      ),
    ),
  );
}
