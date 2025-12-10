import 'package:fluent_ui/fluent_ui.dart';

class WinTextBox extends StatelessWidget {
  final Widget? prefix;
  final String? placeholder;
  final Function(String)? onChanged;
  const WinTextBox({super.key, this.prefix, this.placeholder, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextBox(
      prefix: prefix,
      placeholder: placeholder,
      placeholderStyle: TextStyle(fontWeight: FontWeight.w500),
      style: TextStyle(fontWeight: FontWeight.w500),
      decoration: WidgetStatePropertyAll(
        BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      unfocusedColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onChanged: onChanged,
    );
  }
}
