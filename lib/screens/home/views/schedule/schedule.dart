import "package:fluent_ui/fluent_ui.dart";
import "package:lottie/lottie.dart";
import 'package:intl/intl.dart';
import "package:provider/provider.dart";
import "package:task_distribution/data/model/schedule.dart";
import "package:task_distribution/providers/schedule/schedule.dart";
import "package:task_distribution/providers/socket.dart";

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String nameContains = "";
  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final theme = FluentTheme.of(context);
    final server = context.watch<ServerProvider>();

    // Logic lọc dữ liệu
    final filtered = scheduleProvider.schedules.where((schedule) {
      final matchesName = nameContains.isEmpty
          ? true
          : schedule.name
                .split('.')
                .last
                .replaceAll("_", " ")
                .toLowerCase()
                .contains(nameContains.toLowerCase());
      return matchesName;
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text("Schedule"),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 300,
              child: TextBox(
                placeholder: 'Search...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(FluentIcons.search),
                ),
                suffixMode: OverlayVisibilityMode.editing,
                suffix: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () => setState(() => nameContains = ""),
                ),
                onChanged: (value) => setState(() => nameContains = value),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.resources.dividerStrokeColorDefault,
                  ),
                ),
                child: server.status == ConnectionStatus.connecting
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/Loading.json',
                              width: 250,
                              height: 250,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Connecting to server...",
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      )
                    : server.status == ConnectionStatus.disconnected
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FluentIcons.plug_disconnected,
                              size: 48,
                              color: theme.resources.textFillColorSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text("Disconnected", style: theme.typography.title),
                            const SizedBox(height: 8),
                            Text(
                              server.errorMessage ??
                                  "Lost connection to server",
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Header của bảng
                          _buildTableHeader(theme),
                          const Divider(),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Lottie.asset(
                                      'assets/lottie/Loading.json',
                                      width: 250,
                                      height: 250,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filtered.length,
                                    separatorBuilder: (ctx, i) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      return _buildTableRow(
                                        context,
                                        filtered[index],
                                        theme,
                                      );
                                    },
                                  ),
                          ),

                          // Footer thống kê
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withValues(
                                alpha: 0.5,
                              ),
                              border: Border(
                                top: BorderSide(
                                  color:
                                      theme.resources.dividerStrokeColorDefault,
                                ),
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Count: ${filtered.length}",
                              style: theme.typography.body,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(FluentThemeData theme) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text("ROBOT", style: headerStyle)),
          SizedBox(width: 200, child: Text("NEXT RUN", style: headerStyle)),
          SizedBox(width: 200, child: Text("START DATE", style: headerStyle)),
          SizedBox(width: 225, child: Text("DAY OF WEEK", style: headerStyle)),
          SizedBox(width: 50, child: Text("DELETE", style: headerStyle)),
        ],
      ),
    );
  }

  String displayNextRun(DateTime date) {
    final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    final weekday = DateFormat('EEE', 'en_US').format(date).toUpperCase();

    final dayLabel = weekday == 'SUN' ? '[SU]' : '[${date.weekday + 1}]';

    return '$dateTime $dayLabel';
  }

  Widget _buildTableRow(
    BuildContext context,
    Schedule schedule,
    FluentThemeData theme,
  ) {
    final nextRun = displayNextRun(schedule.nextRunTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 1. Tên Robot
          Expanded(
            child: Text(
              schedule.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              nextRun,
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              schedule.startDate.toString().split('.')[0],
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 225,
            child: Text(
              schedule.dayOfWeek,
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: IconButton(
              icon: const Icon(FluentIcons.delete, color: Color(0xffef314c)),
              onPressed: () => _handleDelete(context, schedule),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Schedule schedule) async {
    final provider = context.read<ScheduleProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 600),
        title: Text('Delete: ${schedule.name}'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      provider.deleteSchedule(schedule);
    }
  }
}
