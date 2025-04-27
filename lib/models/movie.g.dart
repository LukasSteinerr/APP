// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 2;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      streamId: fields[0] as String,
      name: fields[1] as String,
      streamIcon: fields[2] as String,
      containerExtension: fields[3] as String,
      categoryId: fields[4] as String,
      rating: fields[5] as String?,
      plot: fields[6] as String?,
      releaseDate: fields[7] as String?,
      director: fields[8] as String?,
      actors: fields[9] as String?,
      backdropPath: fields[10] as String?,
      youtubeTrailer: fields[11] as String?,
      tmdbId: fields[12] as String?,
      year: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.streamId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamIcon)
      ..writeByte(3)
      ..write(obj.containerExtension)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.plot)
      ..writeByte(7)
      ..write(obj.releaseDate)
      ..writeByte(8)
      ..write(obj.director)
      ..writeByte(9)
      ..write(obj.actors)
      ..writeByte(10)
      ..write(obj.backdropPath)
      ..writeByte(11)
      ..write(obj.youtubeTrailer)
      ..writeByte(12)
      ..write(obj.tmdbId)
      ..writeByte(13)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
