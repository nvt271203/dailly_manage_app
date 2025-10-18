import 'leave.dart';

class PaginatedLeavesResponse {
  final List<Leave> leaves;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  PaginatedLeavesResponse({
    required this.leaves,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory PaginatedLeavesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'];
    return PaginatedLeavesResponse(
      leaves: list.map((e) => Leave.fromMap(e)).toList(),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
    );
  }
}
