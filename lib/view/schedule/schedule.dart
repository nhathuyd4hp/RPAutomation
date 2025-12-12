import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/text_box.dart";
import "package:task_distribution/model/schedule.dart";
import "package:task_distribution/provider/schedule.dart";

class ScheduleManagement extends StatefulWidget {
  const ScheduleManagement({super.key});

  @override
  State<ScheduleManagement> createState() => _ScheduleManagementState();
}

class _ScheduleManagementState extends State<ScheduleManagement> {
  String nameContains = "";
  String statusFilter = "--";

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    return ScaffoldPage(
      content: Column(
        spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch trình chạy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                'Số lượng: ${scheduleProvider.schedules.length}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            spacing: 25,
            children: [
              Container(
                padding: EdgeInsets.all(0),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffffffff),
                ),
                child: DropDownButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  title: Text(statusFilter),
                  items: ["--", "Active", "Expired"].map((e) {
                    return MenuFlyoutItem(
                      text: Text(e),
                      onPressed: () {
                        setState(() => statusFilter = e);
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffffffff),
                  ),
                  child: WinTextBox(
                    prefix: WindowsIcon(WindowsIcons.search, size: 18.0),
                    placeholder: "Lọc theo tên",
                    onChanged: (value) {
                      setState(() {
                        nameContains = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffffffff),
              ),
              child: table(context, scheduleProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget table(BuildContext context, ScheduleProvider provider) {
    if (provider.isLoading) {
      return Center(child: ProgressRing());
    }
    if (provider.errorMessage != null) {
      final String errorMessage = provider.errorMessage!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.warning, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final filtered = provider.schedules.where((schedule) {
      // Lọc theo nameFilter
      final matchesName = nameContains.isEmpty
          ? true
          : schedule.name
                .split('.')
                .last
                .toLowerCase()
                .replaceAll("_", " ")
                .contains(nameContains.toLowerCase());

      // Lọc theo statusFilter
      final matchesStatus = statusFilter == "--"
          ? true
          : schedule.status.toLowerCase() == statusFilter.toLowerCase();

      return matchesName && matchesStatus;
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRuns(context, filtered[index]);
      },
    );
  }

  Widget _listRuns(BuildContext context, Schedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xfff8fafc),
        border: Border.all(color: Color(0xffe5eaf1), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 50,
            children: [
              Text(
                schedule.status,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                schedule.name
                    .replaceAll("_", " ")
                    .split(".")
                    .last
                    .toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                schedule.nextRunTime != null
                    ? schedule.nextRunTime.toString()
                    : "",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          FlyoutTarget(
            controller: FlyoutController(),
            child: FilledButton(
              onPressed: () async {
                final provider = context.read<ScheduleProvider>();
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => ContentDialog(
                    title: const Text('Xóa lịch chạy?'),
                    actions: [
                      FilledButton(
                        child: const Text('Xóa'),
                        onPressed: () {
                          Navigator.pop(context, true);
                          // Delete file here
                        },
                      ),
                      Button(
                        child: const Text('Hủy'),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                );
                if (result == true) {
                  provider.delete(schedule);
                }
              },
              child: const Text('Xóa'),
            ),
          ),
        ],
      ),
    );
  }
}
