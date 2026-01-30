import 'package:fluent_ui/fluent_ui.dart';

class ScheduleForm extends StatefulWidget {
  final BuildContext dialogContext;
  const ScheduleForm({super.key, required this.dialogContext});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  // From - To
  late DateTime startDate;
  // Run At
  late DateTime runTime;
  // Day of week
  List<bool> dayOfWeek = [true, true, true, true, true, true, true];
  List<String> labelDayOfWeek = ["2", "3", "4", "5", "6", "7", "SU"];
  List<String> keyDayOfWeek = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
  // Day of month
  bool isClear = true;
  final List<int> days = List.generate(31, (i) => i + 1);
  final Set<int> selectedDays = List.generate(31, (i) => i + 1).toSet();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toLocal();
    startDate = now;
    runTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxWidth: 345, maxHeight: 655),
      title: Text('Schedule'),
      content: Column(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            header: "From",
            headerStyle: TextStyle(fontWeight: FontWeight.w500),
            selected: startDate,
            onChanged: (time) {
              setState(() {
                startDate = time;
              });
            },
          ),
          TimePicker(
            header: "Run at",
            headerStyle: TextStyle(fontWeight: FontWeight.w500),
            selected: DateTime.now(),
            onChanged: (time) {
              runTime = time;
            },
            hourFormat: HourFormat.HH,
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Day of week",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                spacing: 11,
                children: List.generate(dayOfWeek.length, (i) {
                  return ToggleButton(
                    checked: dayOfWeek[i],
                    onChanged: (v) {
                      setState(() {
                        dayOfWeek[i] = v;
                      });
                    },
                    child: Text(labelDayOfWeek[i]),
                  );
                }),
              ),
            ],
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Day of month",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ToggleSwitch(
                    checked: isClear,
                    onChanged: (value) {
                      setState(() {
                        isClear = value;
                        if (isClear) {
                          selectedDays.addAll(days);
                        } else {
                          selectedDays.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1,
                          ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isSelected = selectedDays.contains(day);
                        return HoverButton(
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                          },
                          cursor: SystemMouseCursors.click,
                          builder: (context, states) {
                            final isHovering = states.isHovered;
                            final theme = FluentTheme.of(context);
                            Color backgroundColor = Colors.transparent;
                            if (isSelected) {
                              backgroundColor = theme.accentColor;
                            } else if (isHovering) {
                              backgroundColor =
                                  theme.resources.controlFillColorSecondary;
                            }
                            Color textColor = theme.typography.body!.color!;
                            if (isSelected) {
                              textColor = Colors.white;
                            }
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isHovering
                                            ? Colors.grey.withValues(alpha: .2)
                                            : Colors.grey.withValues(
                                                alpha: 0.1,
                                              )),
                                ),
                              ),
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: textColor,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        Button(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(widget.dialogContext, null);
          },
        ),
        FilledButton(
          child: Text('Confirm'),
          onPressed: () {
            final Map<String, dynamic> result = {
              "start_date": startDate.toUtc().toIso8601String(),
              "hour": runTime.toUtc().hour,
              "minute": runTime.toUtc().minute,
              "day_of_week": [
                for (int i = 0; i < dayOfWeek.length; i++)
                  if (dayOfWeek[i]) keyDayOfWeek[i],
              ].join(','),
              "day_of_month": selectedDays.join(','),
            };
            final Map<String, String> schedule = result.map((key, value) {
              return MapEntry(key, value.toString());
            });
            Navigator.pop(widget.dialogContext, schedule);
          },
        ),
      ],
    );
  }
}
