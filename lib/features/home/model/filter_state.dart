/// Holds the current job-filter selections on the home screen.
class FilterState {
  FilterState({
    this.level,
    this.location,
    this.minSalary,
    this.maxSalary,
    this.query,
  });

  String? level;
  String? location;
  double? minSalary;
  double? maxSalary;
  String? query;

  /// Whether any filter field is set.
  bool get hasActiveFilters =>
      level != null ||
      location != null ||
      minSalary != null ||
      maxSalary != null;

  /// Returns a copy with the given fields replaced.
  FilterState copyWith({
    String? level,
    String? location,
    double? minSalary,
    double? maxSalary,
    String? query,
  }) {
    return FilterState(
      level: level ?? this.level,
      location: location ?? this.location,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      query: query ?? this.query,
    );
  }
}
