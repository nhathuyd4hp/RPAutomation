import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

// --- MOCK MODEL (Dùng tạm để hiển thị list log) ---
class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry(this.timestamp, this.level, this.message);
}

class ExecutionLogPage extends StatefulWidget {
  const ExecutionLogPage({super.key});

  @override
  State<ExecutionLogPage> createState() => _ExecutionLogPageState();
}

class _ExecutionLogPageState extends State<ExecutionLogPage> {
  // State quản lý text search và dữ liệu log
  String selectedRunId = "";
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu giả lập (Sau này bạn thay bằng dữ liệu từ API/Provider)
  List<LogEntry> logs = [];
  Map<String, dynamic>? currentRunDetails;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu mẫu ban đầu
    _loadMockData("RUN-001");
  }

  // Hàm giả lập load dữ liệu khi chọn RunID
  void _loadMockData(String runId) {
    setState(() {
      selectedRunId = runId;
      _searchController.text = runId;

      // Giả lập thông tin Run
      currentRunDetails = {
        "robotName": "Invoice_Processor_V2",
        "parameters": "{ 'year': 2023, 'type': 'PDF' }",
        "status": runId == "RUN-002" ? "FAILURE" : "SUCCESS",
        "createdAt": DateTime.now().subtract(const Duration(hours: 2)),
      };

      // Giả lập log
      logs = List.generate(20, (index) {
        final time = currentRunDetails!['createdAt'].add(
          Duration(seconds: index * 5),
        );
        String level = "INFO";
        String msg = "Processing step $index initialized...";

        if (index % 7 == 0) {
          level = "WARN";
          msg = "Slow network response detected at step $index.";
        }
        if (runId == "RUN-002" && index == 18) {
          level = "ERROR";
          msg = "NullPointerException: Cannot read field 'amount' of null.";
        }

        return LogEntry(time, level, msg);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      // 1. HEADER
      header: PageHeader(
        padding: 0,
        title: const Text('Execution Log'),
        commandBar: SizedBox(
          width: 300,
          child: AutoSuggestBox<String>(
            controller: _searchController,
            placeholder: 'Search Run ID...',
            leadingIcon: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(FluentIcons.search),
            ),
            items: ["RUN-001", "RUN-002", "RUN-003"].map((id) {
              return AutoSuggestBoxItem<String>(
                value: id,
                label: id,
                child: Text(
                  id,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onSelected: () => _loadMockData(id),
              );
            }).toList(),
            onChanged: (text, reason) {
              // Logic filter suggestion nếu cần
            },
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // 2. RUN DETAILS CONTAINER
            if (currentRunDetails != null)
              _buildRunInfoPanel(theme, currentRunDetails!),

            const SizedBox(height: 16),

            // 3. LOG CONSOLE CONTAINER
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    _buildLogTableHeader(theme),
                    const Divider(),
                    // Log List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: logs.length,
                        separatorBuilder: (ctx, i) => Divider(
                          style: DividerThemeData(
                            thickness: 0.5,
                            decoration: BoxDecoration(
                              color: theme.resources.dividerStrokeColorDefault
                                  .withOpacity(0.3),
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

  // --- WIDGET COMPONENTS ---

  Widget _buildRunInfoPanel(FluentThemeData theme, Map<String, dynamic> info) {
    // Kiểm tra xem có kết quả để download không (Ví dụ: Status phải là SUCCESS)
    bool canDownload = info['status'] == "SUCCESS";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Hàng Tiêu đề + Các nút hành động ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Run Details: $selectedRunId",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(info['status']),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(), // Thêm đường kẻ mờ cho đẹp
          const SizedBox(height: 12),

          // --- Thông tin chi tiết ---
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Căn lề trên để đều nhau
            children: [
              Expanded(
                child: _buildInfoItem(
                  "Robot Name",
                  info['robotName'],
                  FluentIcons.robot,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  "Started At",
                  DateFormat('dd/MM/yyyy HH:mm').format(info['createdAt']),
                  FluentIcons.clock,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  "Parameters",
                  info['parameters'],
                  FluentIcons.variable,
                ),
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
        Icon(
          icon,
          size: 16,
          color: Colors.grey[100],
        ), // Grey 100 in fluent is actually dark grey
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

  Widget _buildStatusBadge(String status) {
    Color color = status == "SUCCESS" ? Colors.green : Colors.red;
    IconData icon = status == "SUCCESS"
        ? FluentIcons.check_mark
        : FluentIcons.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTableHeader(FluentThemeData theme) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text("TIMESTAMP", style: style)),
          SizedBox(width: 80, child: Text("LEVEL", style: style)),
          Expanded(child: Text("MESSAGE", style: style)),
          SizedBox(
            width: 100,
            child: FilledButton(child: Text("Result"), onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTableRow(LogEntry log, FluentThemeData theme) {
    // Màu sắc cho Level
    Color levelColor;
    switch (log.level) {
      case 'ERROR':
        levelColor = Colors.red;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      default:
        levelColor = Colors.blue;
    }

    final monoStyle = TextStyle(
      fontFamily: 'Consolas', // Font cho log
      fontSize: 13,
      color: theme.typography.body!.color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ), // Padding mỏng hơn để hiển thị nhiều dòng
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Căn trên cùng nếu message dài xuống dòng
        children: [
          // 1. Timestamp
          SizedBox(
            width: 150,
            child: Text(
              DateFormat('HH:mm:ss.SSS').format(log.timestamp),
              style: monoStyle.copyWith(
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          // 2. Level
          SizedBox(
            width: 80,
            child: Text(
              log.level,
              style: monoStyle.copyWith(
                color: levelColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 3. Message
          Expanded(
            child: Text(
              log.message,
              style: monoStyle,
              softWrap: true, // Tự động xuống dòng nếu log quá dài
            ),
          ),
        ],
      ),
    );
  }
}
