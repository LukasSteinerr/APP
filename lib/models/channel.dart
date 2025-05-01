import 'package:objectbox/objectbox.dart';

@Entity()
class Channel {
  @Id()
  int id = 0;

  String streamId;
  String name;
  String streamIcon;
  String epgChannelId;
  String categoryId;
  String categoryName;
  bool hasTvArchive;

  Channel({
    required this.streamId,
    required this.name,
    required this.streamIcon,
    required this.epgChannelId,
    required this.categoryId,
    required this.categoryName,
    required this.hasTvArchive,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      streamId: json['stream_id']?.toString() ?? '',
      name: json['name'] ?? '',
      streamIcon: json['stream_icon'] ?? '',
      epgChannelId: json['epg_channel_id'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? '',
      hasTvArchive: json['tv_archive'] == '1',
    );
  }

  Map<String, dynamic> toJson() => {
    'stream_id': streamId,
    'name': name,
    'stream_icon': streamIcon,
    'epg_channel_id': epgChannelId,
    'category_id': categoryId,
    'category_name': categoryName,
    'tv_archive': hasTvArchive ? '1' : '0',
  };
}
