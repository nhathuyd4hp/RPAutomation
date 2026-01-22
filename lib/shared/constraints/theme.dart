import 'package:fluent_ui/fluent_ui.dart';

final FluentThemeData lightTheme = FluentThemeData(
  accentColor: Colors.teal,
  brightness: Brightness.light,
  visualDensity: VisualDensity.standard,
  focusTheme: const FocusThemeData(glowFactor: 1.0),
);

final FluentThemeData darkTheme = FluentThemeData(
  accentColor: Colors.teal,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff111823),
  cardColor: const Color(0xff19222c),
  visualDensity: VisualDensity.standard,
  focusTheme: const FocusThemeData(glowFactor: 1.0),
);
