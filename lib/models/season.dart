class Season {
  int? seasonId;
  String name;
  String code;
  DateTime startDate;
  DateTime? endDate;
  bool isActive;

  Season({
    this.seasonId,
    required this.name,
    required this.code,
    required this.startDate,
    this.endDate,
    this.isActive = false,
  });

  // Convert a Season object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'seasonId': seasonId,
      'name': name,
      'code': code,
      'startDate': startDate.toIso8601String(), // Store DateTime as ISO 8601 string
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Extract a Season object from a Map object
  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      seasonId: map['seasonId'],
      name: map['name'],
      code: map['code'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isActive: map['isActive'] == 1,
    );
  }
}

extension SeasonCopyWith on Season {
  Season copyWith({
    int? seasonId,
    String? name,
    String? code,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Season(
      seasonId: seasonId ?? this.seasonId,
      name: name ?? this.name,
      code: code ?? this.code,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
