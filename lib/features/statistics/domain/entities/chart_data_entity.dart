import 'package:flutter/material.dart';

class PieChartData {
  final String label;
  final double value;
  final Color color;
  final Map<String, dynamic> metadata;

  const PieChartData({
    required this.label,
    required this.value,
    required this.color,
    this.metadata = const {},
  });

  double calculatePercentage(double total) {
    return total > 0 ? (value / total) * 100 : 0.0;
  }

  String get formattedValue => '\$${value.toStringAsFixed(2)}';
  String formattedPercentage(double total) => '${calculatePercentage(total).toStringAsFixed(1)}%';
}

class BarChartData {
  final String label;
  final double value;
  final Color color;
  final DateTime? date;
  final Map<String, dynamic> metadata;

  const BarChartData({
    required this.label,
    required this.value,
    required this.color,
    this.date,
    this.metadata = const {},
  });

  String get formattedValue => '\$${value.toStringAsFixed(2)}';
}

class LineChartData {
  final DateTime date;
  final double value;
  final String? label;
  final Map<String, dynamic> metadata;

  const LineChartData({
    required this.date,
    required this.value,
    this.label,
    this.metadata = const {},
  });

  String get formattedValue => '\$${value.toStringAsFixed(2)}';
  String get dateLabel => '${date.month}/${date.day}';
}

class MultiLineChartData {
  final DateTime date;
  final Map<String, double> values;
  final Map<String, dynamic> metadata;

  const MultiLineChartData({
    required this.date,
    required this.values,
    this.metadata = const {},
  });

  double getValue(String key) => values[key] ?? 0.0;
  String getFormattedValue(String key) => '\$${getValue(key).toStringAsFixed(2)}';
}

class ScatterChartData {
  final double x;
  final double y;
  final String? label;
  final Color color;
  final double size;
  final Map<String, dynamic> metadata;

  const ScatterChartData({
    required this.x,
    required this.y,
    this.label,
    required this.color,
    this.size = 5.0,
    this.metadata = const {},
  });
}

class ChartDataSet<T> {
  final String title;
  final List<T> data;
  final Color primaryColor;
  final Map<String, dynamic> metadata;

  const ChartDataSet({
    required this.title,
    required this.data,
    required this.primaryColor,
    this.metadata = const {},
  });

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;
}

class ChartConfiguration {
  final String title;
  final String? subtitle;
  final bool showLegend;
  final bool showLabels;
  final bool showValues;
  final bool enableAnimation;
  final Duration animationDuration;
  final Map<String, dynamic> customSettings;

  const ChartConfiguration({
    required this.title,
    this.subtitle,
    this.showLegend = true,
    this.showLabels = true,
    this.showValues = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.customSettings = const {},
  });
}

class ChartTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final List<Color> colorPalette;

  const ChartTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.colorPalette,
  });

  static const ChartTheme defaultTheme = ChartTheme(
    primaryColor: Colors.blue,
    secondaryColor: Colors.blueAccent,
    backgroundColor: Colors.white,
    textColor: Colors.black87,
    colorPalette: [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ],
  );

  Color getColorForIndex(int index) {
    return colorPalette[index % colorPalette.length];
  }
}