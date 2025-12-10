import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import 'package:task_distribution/provider/page.dart';

class Header extends StatelessWidget {
  final EdgeInsets padding;
  const Header({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final pageState = context.read<PageProvider>();
    return Container(
      color: Color(0xffffffff),
      height: 75,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "QUẢN LÍ ROBOT",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                child: Text('Robot'),
                onPressed: () => pageState.setPage(AppPage.robot),
              ),
              FilledButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                child: Text('Lịch sử chạy'),
                onPressed: () => pageState.setPage(AppPage.runs),
              ),
              FilledButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                child: Text('Lịch trình chạy'),
                onPressed: () => pageState.setPage(AppPage.schedule),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
