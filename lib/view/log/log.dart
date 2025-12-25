import 'dart:async';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:task_distribution/core/widget/log_badge.dart';
import 'package:task_distribution/core/widget/run_status_badge.dart';
import 'package:task_distribution/main.dart';
import 'package:task_distribution/model/log.dart';
import 'package:task_distribution/model/run.dart';
import 'package:task_distribution/provider/run/run.dart';

class ExecutionLogPage extends StatefulWidget {
  const ExecutionLogPage({super.key});

  @override
  State<ExecutionLogPage> createState() => _ExecutionLogPageState();
}

class _ExecutionLogPageState extends State<ExecutionLogPage> {
  List<LogEntry> logs = [];
  String? selectedRunId;
  StreamSubscription? _logSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _logSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _connectLogStream(String runId) async {
    await _logSubscription?.cancel();

    setState(() {
      logs.clear();
    });

    try {
      final uri = Uri.parse('${TaskDistribution.backendUrl}/api/logs/$runId');
      final request = http.Request('GET', uri);
      final response = await request.send();
      if (response.statusCode == 200) {
        _logSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((String line) {
              if (line.trim().isEmpty) return;
              if (mounted) {
                setState(() {
                  final logEntry = LogEntry.fromRawLine(line);
                  logs.add(logEntry);
                });
                _scrollToBottom();
              }
            });
      }
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final theme = FluentTheme.of(context);

    Run? currentRun;
    if (selectedRunId != null) {
      try {
        currentRun = runProvider.runs.firstWhere((r) => r.id == selectedRunId);
      } catch (_) {}
    }

    _scrollToBottom();

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Execution Log'),
        commandBar: AutoSuggestBox<String>(
          placeholder: 'Search...',
          leadingIcon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(FluentIcons.search),
          ),
          items: runProvider.runs.map((run) {
            return AutoSuggestBoxItem<String>(
              value: run.id,
              label: run.id,
              child: Text(
                run.id,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onSelected: () {
                setState(() {
                  selectedRunId = run.id;
                });
                _connectLogStream(run.id);
              },
            );
          }).toList(),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          spacing: 16,
          children: [
            // 1. Info Panel
            if (selectedRunId != null && currentRun != null)
              _buildRunInfoPanel(theme, currentRun),

            // 2. Log Table
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
                    _buildLogTableHeader(theme, currentRun),
                    const Divider(),
                    Expanded(
                      child: logs.isEmpty
                          ? const Center(child: Text("Waiting for logs..."))
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: logs.length,
                              separatorBuilder: (ctx, i) => Divider(
                                style: DividerThemeData(
                                  thickness: 0.5,
                                  decoration: BoxDecoration(
                                    color: theme
                                        .resources
                                        .dividerStrokeColorDefault,
                                  ),
                                ),
                              ),
                              itemBuilder: (context, index) {
                                return _buildLogTableRow(logs[index], theme);
                              },
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

  // --- UI COMPONENTS ---

  Widget _buildRunInfoPanel(FluentThemeData theme, Run run) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Run ID: ${run.id}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RunStatusBadge(run: run),
            ],
          ),
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 50,
            children: [
              _buildInfoItem("Robot Name", run.robot, FluentIcons.robot),
              _buildInfoItem(
                "Started At",
                run.createdAt.toString().split('.')[0], // Format nhẹ cho gọn
                FluentIcons.clock,
              ),
              _buildInfoItem(
                "Parameters",
                run.parameters ?? "None",
                FluentIcons.variable,
              ),
              _buildInfoItem(
                "Result",
                run.result != null ? p.basename(run.result!) : "None",
                FluentIcons.doc_library,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[100]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[100]),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // Header Bảng Log
  Widget _buildLogTableHeader(FluentThemeData theme, Run? run) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text("TIMESTAMP", style: style)),
          SizedBox(width: 100, child: Text("LEVEL", style: style)),
          Expanded(child: Text("MESSAGE", style: style)),

          // Nút Result nằm ở header
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: (run != null)
                    ? () => context.read<RunProvider>().download(run)
                    : null,
                child: const Text("Result"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Row Bảng Log
  Widget _buildLogTableRow(LogEntry log, FluentThemeData theme) {
    final monoStyle = TextStyle(
      fontSize: 13,
      fontFamily:
          'Consolas', // Dùng font monospace cho log nhìn chuyên nghiệp hơn
      color: theme.typography.body!.color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timestamp (Cố định 180 khớp Header)
          SizedBox(
            width: 180,
            child: Text(
              log.timestamp
                  .toIso8601String()
                  .split('T')[1]
                  .split('.')[0], // Chỉ hiện giờ:phút:giây
              style: monoStyle.copyWith(
                color: theme.resources.textFillColorPrimary,
              ),
            ),
          ),

          // 2. Level (Cố định 100 khớp Header)
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LogText(level: log.level),
            ),
          ),

          // 3. Message (Expanded)
          Expanded(
            child: SelectableText(
              // Cho phép copy log
              log.message,
              style: monoStyle,
            ),
          ),

          // 4. Spacer (Cố định 100) -> QUAN TRỌNG: Để cột Message không bị tràn lấn sang chỗ nút Result ở Header
          const SizedBox(width: 100),
        ],
      ),
    );
  }
}
