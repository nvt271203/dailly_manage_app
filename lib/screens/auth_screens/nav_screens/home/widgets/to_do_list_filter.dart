import 'package:daily_manage_user_app/providers/work_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../widgets/loading_status_bar_widget.dart';
import '../screens/detail_work_screen.dart';

class ToDoListFilter extends ConsumerStatefulWidget {
  const ToDoListFilter({super.key});

  @override
  _ToDoListFilterState createState() => _ToDoListFilterState();
}

class _ToDoListFilterState extends ConsumerState<ToDoListFilter> {
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(workProvider.notifier).fetchWorks()); // 🛠 gọi hàm load
  }

  @override
  Widget build(BuildContext context) {
    final workAsync = ref.watch(workProvider);
    return workAsync.when(
      data: (workList) {
        if (workList.isEmpty)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                SizedBox(height: 20),
                Text(
                  "No Work Yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "You have not joined any job yet. Click the 'Check in' button above to start your first job.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );

        // ✅ Sắp xếp worksList theo ngày giảm dần (mới nhất trước)
        final sortedWorks = List.from(workList)
          ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime)); // date là DateTime

        // ✅ Lấy 3 phần tử đầu tiên (nếu ít hơn thì lấy hết)
        final latest3Works = sortedWorks.take(3).toList();
        print(latest3Works.length);

        // ✅ Hiển thị
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 60),
                child: Container(
                  height: 1,color: HelpersColors.itemPrimary.withOpacity(0.4),),
              ),
                // SizedBox(height: 10,),
              Center(child: Text('History of recent days',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: HelpersColors.primaryColor),textAlign: TextAlign.center,)),
              SizedBox(height: 10,),


              // Nếu như dữ liệu không rỗng thì ms cho phép hiện header - ngược lại hiển thị error.
              if (workList.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HelpersColors.primaryColor,
                        HelpersColors.secondaryColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Center(child: Text("No.", style: _headerStyle)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text("Date", style: _headerStyle)),
                      ),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text("Working Time", style: _headerStyle),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text("Hours", style: _headerStyle)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text("Details", style: _headerStyle),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
              ]else ...[
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        "No Work Yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Header

              ...latest3Works.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                final checkIn = item.checkInTime.toLocal();
                final checkOut = item.checkOutTime.toLocal();
                final duration = item.workTime;

                String formatDate(DateTime date) =>
                    "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
                String formatTimeRange(DateTime start, DateTime end) {
                  String f(DateTime d) =>
                      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
                  return "${f(start)} – ${f(end)}";
                }

                String formatDuration(Duration d) {
                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                  "${index + 1 + _currentPage}.",style: TextStyle(fontSize: 12)
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(child: Text(formatDate(checkIn),style: TextStyle(fontSize: 12))),
                          ),
                          Expanded(
                            flex: 4,
                            child: Center(
                              child: Text(formatTimeRange(checkIn, checkOut,),style: TextStyle(fontSize: 12),),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                formatDuration(duration),
                                // FormatHelper.formatDurationHH_MM(duration),
                                style: TextStyle(
                                    color: HelpersColors.itemSelected,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (context) =>
                                  //       DialogDetailWorkWidget(
                                  //         onConfirm: () {},
                                  //         work: item,
                                  //       ),
                                  // );
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return DetailWorkScreen(onConfirm: () {

                                    }, work: item);
                                  },));
                                },
                                child: Text(
                                  "View",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: HelpersColors.itemPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                  ],
                );
              }).toList(),

              // Phân trang
              SizedBox(height: 30,),


            ],
          ),
        );

      },
      error: (err, _) => Center(child: Text('Error load data: $err')),
      loading: () => const Center(child: LoadingStatusBarWidget()),
    );
  }
}
const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);