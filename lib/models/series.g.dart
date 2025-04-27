// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesAdapter extends TypeAdapter<Series> {
  @override
  final int typeId = 3;

  @override
  Series read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Series(
      seriesId: fields[0] as String,
      name: fields[1] as String,
      cover: fields[2] as String,
      plot: fields[3] as String,
      cast: fields[4] as String,
      director: fields[5] as String,
      genre: fields[6] as String,
      releaseDate: fields[7] as String,
      rating: fields[8] as String,
      categoryId: fields[9] as String,
      tmdbId: fields[10] as String?,
      backdropPath: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Series obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.seriesId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cover)
      ..writeByte(3)
      ..write(obj.plot)
      ..writeByte(4)
      ..write(obj.cast)
      ..writeByte(5)
      ..write(obj.director)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.releaseDate)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.categoryId)
      ..writeByte(10)
      ..write(obj.tmdbId)
      ..writeByte(11)
      ..write(obj.backdropPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
