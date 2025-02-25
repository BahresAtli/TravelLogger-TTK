
class MainTable {
  final int? recordID;
  final String? startTime;
  final String? endTime;
  final int? elapsedMilisecs;
  final String? startLatitude;
  final String? startLongitude;
  final String? endLatitude;
  final String? endLongitude;

  MainTable(
    this.recordID,
    this.startTime,
    this.endTime,
    this.elapsedMilisecs,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  );

  bool? get stringify => true;
}
