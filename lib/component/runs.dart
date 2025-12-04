import "package:fluent_ui/fluent_ui.dart";

class RunsManagement extends StatelessWidget {
  const RunsManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(FluentIcons.search),
      onPressed: () {
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Đang tìm kiếm...'),
              content: const Text('Hệ thống đang quét dữ liệu robot.'),
              action: IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: close,
              ),
              severity: InfoBarSeverity.info,
            );
          },
        );
      },
    );
  }
}
