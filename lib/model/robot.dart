class Parameter {
  final String name;
  final dynamic defaultValue;
  final bool required;
  final String annotation;

  Parameter({
    required this.name,
    required this.required,
    required this.annotation,
    this.defaultValue,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      name: json['name'] as String,
      defaultValue: json['default'],
      required: json['required'] as bool,
      annotation: json['annotation'] as String,
    );
  }
}

class Robot {
  final String name;
  final bool active;
  final List<Parameter> parameters;

  Robot({required this.name, required this.active, required this.parameters});

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      name: json['name'] as String,
      active: json['active'] as bool,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => Parameter.fromJson(e))
          .toList(),
    );
  }
}
