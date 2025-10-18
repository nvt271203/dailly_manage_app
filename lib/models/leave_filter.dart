class LeaveFilterState {
  final int filterYear;
  final String sortField;
  final String sortOrder;
  final String status;

  const LeaveFilterState({
    required this.filterYear,
    required this.sortField,
    required this.sortOrder,
    required this.status,
  });

  LeaveFilterState copyWith({
    int? filterYear,
    String? sortField,
    String? sortOrder,
    String? status,
  }) {
    return LeaveFilterState(
      filterYear: filterYear ?? this.filterYear,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
    );
  }
}
