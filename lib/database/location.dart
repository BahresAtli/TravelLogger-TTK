
class Location {
  final int? recordID;
  final int? locationOrder;
  final String? latitude;
  final String? longitude;

  Location (
    this.recordID,
    this.locationOrder,
    this.latitude,
    this.longitude,
  );

  bool? get stringify => true;
}
