import 'package:flutter/material.dart';
import 'appColors.dart';

class AppAppBar {

  static PreferredSizeWidget build(String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.appBar,
      centerTitle: true,
      elevation: 0,
    );
  }

}