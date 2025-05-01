import 'package:objectbox/objectbox.dart';

@Entity()
class XtreamConnection {
  @Id()
  int obId = 0; // ObjectBox ID

  String id; // Original ID (UUID)
  String name;
  String serverUrl;
  String username;
  String password;
  DateTime addedDate;

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
}
