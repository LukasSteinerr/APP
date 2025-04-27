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

  // Create from JSON (for backward compatibility with SharedPreferences)
  factory XtreamConnection.fromJson(Map<String, dynamic> json) {
    return XtreamConnection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serverUrl: json['serverUrl'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      addedDate:
          json['addedDate'] != null
              ? DateTime.parse(json['addedDate'])
              : DateTime.now(),
    );
  }

  // Create from SQLite database map
  factory XtreamConnection.fromMap(Map<String, dynamic> map) {
    return XtreamConnection(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      serverUrl: map['server_url'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      addedDate:
          map['added_date'] != null
              ? DateTime.parse(map['added_date'])
              : DateTime.now(),
    );
  }

  // Convert to JSON (for backward compatibility with SharedPreferences)
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

  // Convert to map for SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'server_url': serverUrl,
      'username': username,
      'password': password,
      'added_date': addedDate.toIso8601String(),
    };
  }
}
