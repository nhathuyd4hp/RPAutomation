import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/empty_state.dart";
import "package:task_distribution/core/widget/run_status_badge.dart";
import "package:task_distribution/provider/run/run_filter.dart";
import "package:task_distribution/view/run/widget/information_dialog.dart";
import "package:task_distribution/model/run.dart";
import "package:task_distribution/provider/run/run.dart";

class RunsPage extends StatefulWidget {
  const RunsPage({super.key});

  @override
  State<RunsPage> createState() => _RunsPageState();
}

class _RunsPageState extends State<RunsPage> {
  bool isAscending = true;
  late TextEditingController _controller;

  final Map<String, String> statusMap = {
    "--": "",
    "Cancel": "Cancel",
    "Waiting": "Waiting",
    "Pending": "Pending",
    "Failure": "Failure",
    "Success": "Success",
  };

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<RunFilterProvider>().nameQuery;
    _controller = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final statusFilter = Selector<RunFilterProvider, String>(
      selector: (_, provider) => provider.statusQuery ?? "",
      builder: (context, query, child) {
        return ComboBox<String>(
          placeholder: const Text("Status"),
          value: query,
          items: statusMap.entries.map((e) {
            return ComboBoxItem(value: e.value, child: Text(e.key));
          }).toList(),
          onChanged: (value) {
            context.read<RunFilterProvider>().setStatus(value);
          },
        );
      },
    );

    final nameFilter = Selector<RunFilterProvider, String>(
      selector: (_, provider) => provider.nameQuery,
      builder: (context, query, child) {
        return TextBox(
          controller: _controller,
          placeholder: 'Search...',
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(FluentIcons.search),
          ),
          suffixMode: OverlayVisibilityMode.editing,
          onChanged: (value) {
            context.read<RunFilterProvider>().setNameContains(value);
          },
        );
      },
    );
    final runs = Consumer2<RunProvider, RunFilterProvider>(
      builder: (context, sourceProvider, filterProvider, child) {
        final filtered = filterProvider.apply(sourceProvider.runs);
        if (filtered.isEmpty) {
          return EmptyState();
        }
        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (ctx, i) => const Divider(),
          itemBuilder: (context, index) {
            return _buildTableRow(context, filtered[index], theme);
          },
        );
      },
    );

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Runs'),
        commandBar: Row(
          spacing: 25,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            statusFilter,
            Expanded(child: nameFilter),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(theme),
                    const Divider(),
                    Expanded(child: runs),
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
                            color: theme.resources.dividerStrokeColorDefault,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Text("Count: 0", style: theme.typography.body),
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
          SizedBox(width: 300, child: Text("ID", style: headerStyle)),
          Expanded(child: Text("ROBOT NAME", style: headerStyle)),
          SizedBox(width: 150, child: Text("STATUS", style: headerStyle)),
          SizedBox(
            width: 250,
            child: Row(
              spacing: 5,
              children: [
                Text("RUN AT", style: headerStyle),
                IconButton(
                  icon: Icon(FluentIcons.sort),
                  onPressed: () {
                    context.read<RunFilterProvider>().setIsAscending();
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 100, child: Text("ACTIONS", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Run run, FluentThemeData theme) {
    final robotName = run.robot;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: SelectableText(
              run.id,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              robotName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 150, child: RunStatusBadge(run: run)),
          SizedBox(
            width: 250,
            child: Text(
              run.createdAt.toString().split('.')[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: IconButton(
              icon: Icon(FluentIcons.info, color: theme.accentColor, size: 18),
              onPressed: () async {
                final provider = context.read<RunProvider>();
                final result = await showDialog(
                  context: context,
                  builder: (ctx) =>
                      InformationDialog(dialogContext: ctx, run: run),
                );
                if (result != null) provider.download(run);
              },
            ),
          ),
        ],
      ),
    );
  }
}
