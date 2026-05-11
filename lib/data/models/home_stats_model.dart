class HomeStatsModel {
  final int completedReconciliations;
  final double averageSavingsPerPatient;
  final double totalMonthlySavings;
  final double operationalCostSavings;

  HomeStatsModel({
    required this.completedReconciliations,
    required this.averageSavingsPerPatient,
    required this.totalMonthlySavings,
    required this.operationalCostSavings,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      completedReconciliations: (json['completedReconciliations'] ?? 0) as int,
      averageSavingsPerPatient: _toDouble(json['averageSavingsPerPatient']),
      totalMonthlySavings: _toDouble(json['totalMonthlySavings']),
      operationalCostSavings: _toDouble(json['operationalCostSavings']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get formattedAverageSavings => _formatCurrency(averageSavingsPerPatient);
  String get formattedTotalMonthlySavings => _formatCurrency(totalMonthlySavings);
  String get formattedOperationalCostSavings => _formatCurrency(operationalCostSavings);

  static String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'completedReconciliations': completedReconciliations,
      'averageSavingsPerPatient': averageSavingsPerPatient,
      'totalMonthlySavings': totalMonthlySavings,
      'operationalCostSavings': operationalCostSavings,
    };
  }
}
