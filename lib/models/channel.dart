class Channel {
  final String streamId;
  final String name;
  final String streamIcon;
  final String epgChannelId;
  final String categoryId;
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
}
