import 'package:hive/hive.dart';

part 'channel.g.dart';

@HiveType(typeId: 4)
class Channel {
  @HiveField(0)
  final String streamId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamIcon;

  @HiveField(3)
  final String epgChannelId;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final bool hasTvArchive;

  Channel({
    required this.streamId,
    required this.name,
    required this.streamIcon,
    required this.epgChannelId,
    required this.categoryId,
    required this.hasTvArchive,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      streamId: json['stream_id']?.toString() ?? '',
      name: json['name'] ?? '',
      streamIcon: json['stream_icon'] ?? '',
      epgChannelId: json['epg_channel_id'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      hasTvArchive: json['tv_archive'] == '1',
    );
  }

  Map<String, dynamic> toJson() => {
    'stream_id': streamId,
    'name': name,
    'stream_icon': streamIcon,
    'epg_channel_id': epgChannelId,
    'category_id': categoryId,
    'tv_archive': hasTvArchive ? '1' : '0',
  };
}
