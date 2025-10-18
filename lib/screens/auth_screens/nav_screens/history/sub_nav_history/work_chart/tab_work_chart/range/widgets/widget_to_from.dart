import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/history/sub_nav_history/work_chart/sub_nav_work_bar_chart_screen.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/history/sub_nav_history/work_board/sub_nav_work_board_screen.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/history/sub_nav_history/sub_nav_work_gantt_screen.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/history/sub_nav_history/widgets/header_sub_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../../../../../../../../../helpers/tools_colors.dart';
import '../../../../../../../../../models/work.dart';

class WidgetToFrom extends StatelessWidget {
  final List<Work> works;
  final DateTime startDate;
  final DateTime endDate;

  const WidgetToFrom({
    super.key,
    required this.works,
    required this.startDate,
    required this.endDate,
  });

  // Hàm hiển thị các thứ
  String _weekdayFromDate(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  // Hàm thống kê
  Widget buildSummary(List<Map<String, dynamic>> chartData) {
    final totalMinutes = chartData.fold<double>(
      0,
      (sum, e) => sum + (e['minutes'] as double),
    );
    final totalHours = totalMinutes ~/ 60;
    final remainMinutes = totalMinutes % 60;

    final sorted = chartData.where((e) => e['minutes'] > 0).toList()
      ..sort(
        (a, b) => (b['minutes'] as double).compareTo(a['minutes'] as double),
      );

    final mostDay = sorted.isNotEmpty ? sorted.first : null;
    final leastDay = sorted.length > 1 ? sorted.last : null;
    final workedDays = chartData.where((e) => e['minutes'] > 0).length;

    TextStyle titleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    TextStyle valueStyle = const TextStyle(color: Colors.black87, fontSize: 14);

    Widget row(IconData icon, String label, String value, {Color? iconColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.blueAccent),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: valueStyle,
                  children: [
                    TextSpan(text: "$label: ", style: titleStyle),
                    TextSpan(text: value),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EDFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(
            Icons.access_time,
            "Total working time in period",
            "${totalHours}h${remainMinutes.toInt()}",
          ),
          if (mostDay != null)
            row(
              Icons.trending_up,
              "Most working day",
              "Day ${mostDay['day']} - ${_formatHourMinute(mostDay['minutes'])}",
              iconColor: Colors.green,
            ),
          if (leastDay != null)
            row(
              Icons.trending_down,
              "Least working day",
              "Day ${leastDay['day']} - ${_formatHourMinute(leastDay['minutes'])}",
              iconColor: Colors.redAccent,
            ),
          row(
            Icons.calendar_today,
            "Number of working days",
            "$workedDays / ${chartData.length} days",
          ),
        ],
      ),
    );
  }

  String _formatHourMinute(double minutes) {
    final totalMinutes = minutes.round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return "${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}";
  }
  double _getMaxY(List<Map<String, dynamic>> data) {
    final maxMin = data
        .map((e) => e['minutes'] as double)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxHour = (maxMin / 60).ceil();
    return maxHour < 10 ? 10 : maxHour + 1;
  }
  @override
  Widget build(BuildContext context) {
    // final filteredWorks = works.where((work) {
    //   final checkIn = work.checkInTime.toLocal();
    //   return !checkIn.isBefore(startDate) && !checkIn.isAfter(endDate);
    // }).toList();

    final sortedDates = _generateDateRange(startDate, endDate);
    // final chartData = _buildChartData(
    //   filteredWorks,
    //   startDate,
    //   endDate,
    // ); // Sử dụng _buildChartData thay vì _groupDataByDate
    final chartData = _buildChartData(
      works,
      startDate,
      endDate,
    );
    final maxY = _getMaxY(chartData);


    // Kiểm tra tổng số phút làm việc
    final totalMinutes = chartData.fold<double>(
      0,
      (sum, e) => sum + (e['minutes'] as double),
    );

    if (totalMinutes == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.calendar_today, size: 64, color: Colors.blueGrey),
              SizedBox(height: 12),
              Text(
                "No Work Recorded This Period",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Start logging your working hours to see your performance here!",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final barWidth = 40.0;
    final chartWidth = sortedDates.length * barWidth + 32;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(16),
    child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.easeInOut,
    builder: (context, value, _) {


          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: chartWidth,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 400,
                              child: BarChart(
                                BarChartData(
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                            final hours = rod.toY.floor();
                                            final minutes =
                                                ((rod.toY - hours) * 60).round();
                                            return BarTooltipItem(
                                              '${hours.toString().padLeft(2, '0')}h${minutes.toString().padLeft(2, '0')}',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                      tooltipPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      tooltipMargin: 8,
          
                                    ),
                                  ),
                                  alignment: BarChartAlignment.spaceAround,
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, _) => Text(
                                          "${value.toInt()}h",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index < sortedDates.length) {
                                            final date = sortedDates[index];
                                            final String weekday =
                                                _weekdayFromDate(date.weekday);
                                            return SizedBox(
                                              height: 60,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    weekday,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "${date.day}/${date.month}",
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        interval: 1,
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    horizontalInterval: 1,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                    drawVerticalLine: false,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(sortedDates.length, (
                                    index,
                                  ) {
                                    final minutes = chartData[index]['minutes'] as double;
                                    final hours = (minutes / 60).toDouble();

                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: hours * value,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF42A5F5),
                                              Color(0xFF90CAF9),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                          width: 18,
                                        ),
                                      ],
                                      showingTooltipIndicators: hours > 0
                                          ? [0]
                                          : [],
                                    );
                                  }),
                                  maxY: maxY,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                buildSummary(chartData),
              ],
            ),
          );
    },
    ),
      ),
    );
  }
  // List<Map<String, dynamic>> _buildChartData(
  //     List<Work> works,
  //     DateTime startDate,
  //     DateTime endDate,
  //     ) {
  //   final daysInRange = _generateDateRange(startDate, endDate);
  //   final Map<DateTime, double> minutesPerDay = {
  //     for (var date in daysInRange) date: 0.0,
  //   };
  //
  //   for (final work in works) {
  //     DateTime checkIn = work.checkInTime.toLocal();
  //     DateTime checkOut = checkIn.add(work.workTime);
  //     DateTime rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
  //     DateTime rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
  //
  //     // Bỏ qua nếu không giao với khoảng thời gian
  //     if (checkOut.isBefore(rangeStart) || checkIn.isAfter(rangeEnd)) {
  //       continue;
  //     }
  //
  //     DateTime currentDayStart = checkIn.isBefore(rangeStart)
  //         ? rangeStart
  //         : DateTime(checkIn.year, checkIn.month, checkIn.day);
  //
  //     while (currentDayStart.isBefore(checkOut) && !currentDayStart.isAfter(rangeEnd)) {
  //       final nextDayStart = currentDayStart.add(const Duration(days: 1));
  //       final start = currentDayStart.isAfter(checkIn) ? currentDayStart : checkIn;
  //       final end = checkOut.isBefore(nextDayStart) ? checkOut : nextDayStart;
  //
  //       if (!currentDayStart.isBefore(rangeStart) && !currentDayStart.isAfter(rangeEnd)) {
  //         final workedDuration = end.difference(start);
  //         if (workedDuration.inMinutes > 0) {
  //           minutesPerDay[currentDayStart] =
  //               (minutesPerDay[currentDayStart] ?? 0) + workedDuration.inMinutes.toDouble();
  //         }
  //       }
  //
  //       currentDayStart = nextDayStart;
  //     }
  //   }
  //
  //   print("Minutes per day: $minutesPerDay");
  //   return daysInRange.map((date) {
  //     final minutes = minutesPerDay[date] ?? 0.0;
  //     return {'day': date.day, 'minutes': minutes};
  //   }).toList();
  // }
  List<Map<String, dynamic>> _buildChartData(
      List<Work> works,
      DateTime startDate,
      DateTime endDate,
      ) {
    final daysInRange = _generateDateRange(startDate, endDate);
    final Map<DateTime, double> minutesPerDay = {
      for (var date in daysInRange) date: 0.0,
    };

    for (final work in works) {
      DateTime checkIn = work.checkInTime.toLocal();
      DateTime checkOut = checkIn.add(work.workTime!);

      // Kiểm tra xem công việc có giao với khoảng thời gian hiển thị hay không
      DateTime rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
      DateTime rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      if (checkOut.isBefore(rangeStart) || checkIn.isAfter(rangeEnd)) {
        // Công việc không giao với khoảng thời gian hiển thị, bỏ qua
        continue;
      }

      DateTime currentDayStart = DateTime(
        checkIn.year,
        checkIn.month,
        checkIn.day,
      );

      while (currentDayStart.isBefore(checkOut)) {
        final nextDayStart = currentDayStart.add(const Duration(days: 1));
        // Nếu checkIn nằm trước startDate, bắt đầu từ 0h00 của ngày trong khoảng hiển thị
        final start = checkIn.isAfter(currentDayStart)
            ? checkIn
            : (currentDayStart.isBefore(rangeStart) ? rangeStart : currentDayStart);
        final end = checkOut.isBefore(nextDayStart) ? checkOut : nextDayStart;

        final workedDuration = end.difference(start);

        if (!currentDayStart.isBefore(rangeStart) &&
            !currentDayStart.isAfter(rangeEnd)) {
          minutesPerDay[currentDayStart] =
              (minutesPerDay[currentDayStart] ?? 0) +
                  workedDuration.inMinutes.toDouble();
        }

        currentDayStart = nextDayStart;
      }
    }

    return daysInRange.map((date) {
      final minutes = minutesPerDay[date] ?? 0.0;
      return {'day': date.day, 'minutes': minutes};
    }).toList();
  }


//   List<Map<String, dynamic>> _buildChartData(
//     List<Work> works,
//     DateTime startDate,
//     DateTime endDate,
//   ) {
//     final daysInRange = _generateDateRange(startDate, endDate);
//     final Map<DateTime, double> minutesPerDay = {
//       for (var date in daysInRange) date: 0.0,
//     };
//
//     for (final work in works) {
//       DateTime checkIn = work.checkInTime.toLocal();
//       DateTime checkOut = checkIn.add(work.workTime);
//       // Xác định thời gian bắt đầu và kết thúc của khoảng thời gian làm việc
//       // trong khoảng [startDate, endDate]
//       DateTime rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
//       DateTime rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
// // Nếu checkOut nằm trước startDate hoặc checkIn nằm sau endDate, bỏ qua công việc này
//       if (checkOut.isBefore(rangeStart) || checkIn.isAfter(rangeEnd)) {
//         continue;
//       }
//
//       DateTime currentDayStart = DateTime(
//         checkIn.year,
//         checkIn.month,
//         checkIn.day,
//       );
//
//       while (currentDayStart.isBefore(checkOut)) {
//         final nextDayStart = currentDayStart.add(const Duration(days: 1));
//         //
//         // final start = checkIn.isAfter(currentDayStart)
//         //     ? checkIn
//         //     : currentDayStart;
// // Nếu checkIn trước startDate, bắt đầu từ 0h00 của ngày trong khoảng hiển thị
//         final start = checkIn.isBefore(rangeStart) && !currentDayStart.isBefore(rangeStart)
//             ? currentDayStart
//             : checkIn.isAfter(currentDayStart)
//             ? checkIn
//             : currentDayStart;
//
//         final end = checkOut.isBefore(nextDayStart) ? checkOut : nextDayStart;
//
//         final workedDuration = end.difference(start);
//
//         if (!currentDayStart.isBefore(startDate) &&
//             !currentDayStart.isAfter(endDate)) {
//           minutesPerDay[currentDayStart] =
//               (minutesPerDay[currentDayStart] ?? 0) +
//               workedDuration.inMinutes.toDouble();
//         }
//
//         currentDayStart = nextDayStart;
//       }
//     }
//
//     return daysInRange.map((date) {
//       final minutes = minutesPerDay[date] ?? 0.0;
//       return {'day': date.day, 'minutes': minutes};
//     }).toList();
//   }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final List<DateTime> days = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  double _calculateMaxY(List<double> values) {
    if (values.isEmpty || values.every((v) => v == 0)) return 10;
    final maxValue = values.reduce(max);
    final padded = (maxValue * 1.3).ceilToDouble();
    return padded < 10 ? 10 : padded.clamp(10, 24);
  }
}
