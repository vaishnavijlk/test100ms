/**
 * 100ms auth token
 */
class HmsDetails {
  final String token;

  HmsDetails({required this.token});

  factory HmsDetails.fromJson(Map<String, dynamic> json) {
    return HmsDetails(token: json['token']);
  }
}
