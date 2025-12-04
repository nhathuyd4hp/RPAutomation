import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/state/page.dart';
import 'package:task_distribution/state/robot.dart';
import 'package:window_manager/window_manager.dart';
import "screen/home.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(750, 525),
    size: Size(1000, 700),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // Run
  runApp(const TaskDistribution());
}

class TaskDistribution extends StatelessWidget {
  const TaskDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider()),
        ChangeNotifierProvider(create: (_) => RobotProvider()),
      ],
      child: FluentApp(
        title: "Task Distribution",
        debugShowCheckedModeBanner: false,
        home: const Main(),
      ),
    );
  }
}
