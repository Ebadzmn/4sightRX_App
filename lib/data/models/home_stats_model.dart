class HomeStatsModel {
  final int activePatients;
  final int completedReconciliations;
  final String monthlySavings;

  HomeStatsModel({
    required this.activePatients,
    required this.completedReconciliations,
    required this.monthlySavings,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      activePatients: (json['totalActivePatients'] ??
              json['activePatients'] ??
              json['totalPatients'] ??
              0) as int,
      completedReconciliations: (json['totalCompletes'] ??
              json['completedReconciliations'] ??
              json['totalReconciliations'] ??
              0) as int,
      monthlySavings: _formatSavings(json['monthlySavings'] ?? json['totalSavings']),
    );
  }

  static String _formatSavings(dynamic value) {
    if (value == null) return '\$0';
    String s = value.toString();
    if (s.contains('\$')) return s;
    try {
      final numValue = double.parse(s);
      if (numValue >= 1000) {
        return '\$${(numValue / 1000).toStringAsFixed(1)}K';
      }
      return '\$${numValue.toStringAsFixed(0)}';
    } catch (_) {
      return '\$$s';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'activePatients': activePatients,
      'completedReconciliations': completedReconciliations,
      'monthlySavings': monthlySavings,
    };
  }
}
