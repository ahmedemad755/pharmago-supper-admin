import 'package:flutter/material.dart';

class AppLayout {
  // دالة تحسب الحشو الجانبي بناءً على عرض الشاشة
  static double horizontalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return width * 0.12; // للكمبيوتر
    if (width > 800) return 40; // للتابلت
    return 16; // للموبايل
  }

  // دالة لتحديد عدد الأعمدة في أي شبكة (Grid)
  static int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }
}
