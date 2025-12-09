import "package:fluent_ui/fluent_ui.dart";

class ScheduleManagement extends StatefulWidget {
  const ScheduleManagement({super.key});

  @override
  State<ScheduleManagement> createState() => _ScheduleManagementState();
}

class _ScheduleManagementState extends State<ScheduleManagement> {
  String nameFilter = "";

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Lịch trình chạy')),
            Expanded(
              child: TextBox(
                placeholder: 'Lọc:',
                expands: false,
                onChanged: (value) {
                  setState(() {
                    nameFilter = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
