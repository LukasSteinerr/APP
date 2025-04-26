class XtreamConnection {
  final String id;
  final String name;
  final String serverUrl;
  final String username;
  final String password;
  final DateTime addedDate;

  XtreamConnection({
    required this.id,
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.addedDate,
  });

  factory XtreamConnection.fromJson(Map<String, dynamic> json) {
    return XtreamConnection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serverUrl: json['serverUrl'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      addedDate: json['addedDate'] != null
          ? DateTime.parse(json['addedDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'addedDate': addedDate.toIso8601String(),
    };
  }
}
