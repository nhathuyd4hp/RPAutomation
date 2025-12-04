import "package:fluent_ui/fluent_ui.dart";
import "package:flutter/material.dart" hide Colors, ListTile;
import "package:provider/provider.dart";
import "package:task_distribution/state/robot.dart";
import "../model/robot.dart";

class RobotManagement extends StatelessWidget {
  const RobotManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();

    return ScaffoldPage(
      header: const PageHeader(title: Text('🤖 Quản Lý Robot & Tác vụ')),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: _buildContent(context, robotProvider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RobotProvider provider) {
    // Xử lý lỗi bằng InfoBar (Native Fluent UI) - Side Effect
    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Chỉ show InfoBar nếu lỗi chưa được xóa
        if (provider.errorMessage != null) {
          displayInfoBar(
            context,
            builder: (context, close) {
              return InfoBar(
                title: const Text('Lỗi Server'),
                content: Text(provider.errorMessage!),
                severity: InfoBarSeverity.error,
                isIconVisible: true,
                action: Button(onPressed: () {}, child: const Text('Thử lại')),
                onClose: close,
              );
            },
          );
        }
      });
      // Quan trọng: Vẫn tiếp tục render nội dung để người dùng có thể thấy danh sách rỗng/lỗi cũ
    }

    // 1. TRẠNG THÁI LOADING
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ProgressRing(),
            SizedBox(height: 15),
            Text('Đang tải dữ liệu robot...'),
          ],
        ),
      );
    }

    // 2. HIỂN THỊ DỮ LIỆU HOẶC THÔNG BÁO RỖNG
    return _buildRobotList(provider.robots);
  }

  // Hàm Helper chính: Hiển thị danh sách Robot bằng Expander
  Widget _buildRobotList(List<Robot> robots) {
    if (robots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              const Icon(FluentIcons.activity_feed, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Chưa có Robot nào hoạt động.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Nút Đồng bộ Task (Ví dụ)
              Button(onPressed: () {}, child: const Text('Đồng bộ Task')),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: robots.length,
      itemBuilder: (context, index) {
        final robot = robots[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Expander(
            // Header hiển thị tóm tắt Robot và các nút Actions
            header: ListTile(
              leading: Icon(
                robot.active ? FluentIcons.robot : FluentIcons.robot,
                color: robot.active ? Colors.green : Colors.grey,
              ),
              title: Text(
                robot.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Parameters: ${robot.parameters.length} | Active: ${robot.active ? 'YES' : 'NO'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(onPressed: () {}, child: const Text('Run Task')),
                  const SizedBox(width: 10),
                  Button(onPressed: () {}, child: const Text('Stop')),
                ],
              ),
            ),
            // Nội dung Expander: Hiển thị DataTable chi tiết Parameters
            content: _buildParametersTable(robot.parameters),
          ),
        );
      },
    );
  }

  // Hàm Helper dựng DataTable cho Parameters (Nằm trong Expander)
  Widget _buildParametersTable(List<Parameters> params) {
    if (params.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 48, bottom: 8),
        child: Text('Robot này không yêu cầu tham số nào.'),
      );
    }

    // Sử dụng DataTable cho dữ liệu có cấu trúc cột/hàng
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(
            label: Text(
              'Parameter Name',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Required',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Default Value',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Annotation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: params
            .map(
              (param) => DataRow(
                cells: [
                  DataCell(Text(param.name)),
                  DataCell(
                    param.required
                        ? Icon(FluentIcons.chart_series, color: Colors.green)
                        : Icon(
                            FluentIcons.status_circle_error_x,
                            color: Colors.red,
                          ),
                  ),
                  DataCell(Text(param.defaultValue ?? 'N/A')),
                  DataCell(Text(param.annotation)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
