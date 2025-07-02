import 'package:intl/intl.dart';
import 'package:flutter/material.dart'; // For FontFeature

class FormattingUtils {
  // Example ZAR formatting from PRD 6.1
  // Text(
  //   '${NumberFormat.currency(locale: 'en_ZA', symbol: 'R').format(amount)}',
  //   style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
  // )
  static String formatCurrencyZAR(double amount) {
    final format = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    return format.format(amount);
  }

  // Helper to get TextStyle with tabularFigures for currency
  static TextStyle getCurrencyTextStyle(BuildContext context, {TextStyle? existingStyle}) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    return (existingStyle ?? defaultStyle).copyWith(
      fontFeatures: [
        ...(existingStyle?.fontFeatures ?? defaultStyle.fontFeatures ?? []),
        const FontFeature.tabularFigures(),
      ],
    );
  }

  // Example Widget using the formatting
  static Widget zarCurrencyText(BuildContext context, double amount, {TextStyle? style}) {
    return Text(
      formatCurrencyZAR(amount),
      style: getCurrencyTextStyle(context, existingStyle: style),
    );
  }
}
