class UserFilter {
  final String filterFullName;

  UserFilter({required this.filterFullName});

  UserFilter copyWith({
    String? filterFullName
  }) {
    return UserFilter(
      filterFullName: filterFullName ?? this.filterFullName
    );
  }
}