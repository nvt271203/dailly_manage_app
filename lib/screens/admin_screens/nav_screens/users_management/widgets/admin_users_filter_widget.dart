// import 'package:daily_manage_user_app/providers/admin/admin_department_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../../widgets/circular_loading_widget.dart';
//
// class AdminUsersFilterWidget extends ConsumerStatefulWidget {
//   const AdminUsersFilterWidget({super.key});
//
//   @override
//   _AdminUsersFilterWidgetState createState() => _AdminUsersFilterWidgetState();
// }
//
// class _AdminUsersFilterWidgetState
//     extends ConsumerState<AdminUsersFilterWidget> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Future.microtask(() {
//       ref.read(adminDepartmentProvider.notifier).fetchAllDepartments();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final departmentsState = ref.watch(adminDepartmentProvider);
//     return DraggableScrollableSheet(
//       initialChildSize: 0.8,
//       minChildSize: 0.5,
//       maxChildSize: 0.8,
//       builder: (context, scrollController) {
//         return SafeArea(
//           top: false, // giữ cho nó dính sát appbar nhưng tránh status bar
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Colors.white, // nền trắng
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(16), // bo góc trên
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text('Filter'),
//                 Container(
//                   child: Expanded(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [Text('Clear All'), Text('Apply')],
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsetsGeometry.symmetric(
//                               horizontal: 20,
//                             ),
//                             child: ListView(
//                               controller: scrollController,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Divider(),
//                                     Text('Work Status'),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text('All'),
//                                         Text('Retained'),
//                                         Text('Resigned'),
//                                       ],
//                                     ),
//                                     Divider(),
//                                     Text('Sex'),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text('All'),
//                                         Text('Male'),
//                                         Text('Female'),
//                                       ],
//                                     ),
//                                     Divider(),
//                                     Text('Department'),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: departmentsState.when(
//                                             data: (departments) {
//                                               if (departments.isEmpty) {
//                                                 return const Text('No department found');
//                                               }
//
//                                               // giữ state selected trong Widget State
//                                               return Wrap(
//                                                 spacing: 8,
//                                                 runSpacing: 4,
//                                                 children: departments.map((d) {
//                                                   final isSelected = _selectedDepartments.contains(d.id);
//
//                                                   return FilterChip(
//                                                     label: Text(d.name),
//                                                     selected: isSelected,
//                                                     onSelected: (bool selected) {
//                                                       setState(() {
//                                                         if (selected) {
//                                                           _selectedDepartments.add(d.id);
//                                                         } else {
//                                                           _selectedDepartments.remove(d.id);
//                                                         }
//                                                       });
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                               );
//                                             },
//                                             error: (error, stack) => Text('Error: $error'),
//                                             loading: () => const CircularLoadingWidget(),
//                                           ),
//                                         ),
//                                       ],
//                                     )
//
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
