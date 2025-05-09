// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'models/category.dart';
import 'models/channel.dart';
import 'models/movie.dart';
import 'models/series.dart';
import 'models/xtream_connection.dart';
import 'objectbox.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 4806788391075810133),
      name: 'Channel',
      lastPropertyId: const obx_int.IdUid(8, 1793018896279461986),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4115436968742929974),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8278203013665637938),
            name: 'streamId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 824194316933102462),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3482618212120004585),
            name: 'streamIcon',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 3379393221633022715),
            name: 'epgChannelId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 2944285960273318225),
            name: 'categoryId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 6741605205491732950),
            name: 'hasTvArchive',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 1793018896279461986),
            name: 'categoryName',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 2614739341018227784),
      name: 'Movie',
      lastPropertyId: const obx_int.IdUid(17, 5232430591768279805),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 449409157163846443),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1637241531650137192),
            name: 'streamId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 830986604045095268),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3359115130923932724),
            name: 'streamIcon',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 2869509253398054720),
            name: 'containerExtension',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 5345697955071550528),
            name: 'categoryId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2143445015226382035),
            name: 'rating',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 5989720896537485455),
            name: 'plot',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 8904269101548119155),
            name: 'releaseDate',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 3199194458435593030),
            name: 'director',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 9132291872869489916),
            name: 'actors',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 3291818810779943595),
            name: 'backdropPath',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 3528542981461824956),
            name: 'youtubeTrailer',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 6932648739928696042),
            name: 'tmdbId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(15, 7539576128831795833),
            name: 'year',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(17, 5232430591768279805),
            name: 'categoryName',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 8054284652835210210),
      name: 'ObjectBox',
      lastPropertyId: const obx_int.IdUid(1, 2439330048035688735),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 2439330048035688735),
            name: 'id',
            type: 6,
            flags: 1)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(5, 5855371537969812761),
      name: 'Series',
      lastPropertyId: const obx_int.IdUid(14, 2317007877254287243),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 9061722732642698863),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1000257120557905677),
            name: 'seriesId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 7142923180991734320),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 656843167920129514),
            name: 'cover',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 200984450297421651),
            name: 'plot',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 2930292853296091559),
            name: 'cast',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 7259714781226055273),
            name: 'director',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 2039347783218546470),
            name: 'genre',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 7065127469062821457),
            name: 'releaseDate',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 5080643047651039778),
            name: 'rating',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 4227941482319043302),
            name: 'categoryId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 5354469668819273470),
            name: 'tmdbId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 8635249152278773996),
            name: 'backdropPath',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 2317007877254287243),
            name: 'categoryName',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(6, 7371614030397791025),
      name: 'XtreamConnection',
      lastPropertyId: const obx_int.IdUid(7, 3188957082767331990),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 7341820422265501345),
            name: 'obId',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1996980510146312104),
            name: 'id',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 3141847989479762939),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2532022339691463065),
            name: 'serverUrl',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 8028257919145550955),
            name: 'username',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 3504698811328321278),
            name: 'password',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 3188957082767331990),
            name: 'addedDate',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(7, 2318150060902162151),
      name: 'Category',
      lastPropertyId: const obx_int.IdUid(6, 270301621249010508),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 6355096197913493014),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 6974840822026493455),
            name: 'playlistId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 431249211138117482),
            name: 'categoryId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 1326148488879503536),
            name: 'categoryName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 7584341946887205116),
            name: 'contentType',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 270301621249010508),
            name: 'parentId',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(7, 2318150060902162151),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [2254950287624795660],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        945473941763871377,
        1688142078322380670,
        5258361315905754779,
        6979824841748986643,
        4235518701115617448
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    Channel: obx_int.EntityDefinition<Channel>(
        model: _entities[0],
        toOneRelations: (Channel object) => [],
        toManyRelations: (Channel object) => {},
        getId: (Channel object) => object.id,
        setId: (Channel object, int id) {
          object.id = id;
        },
        objectToFB: (Channel object, fb.Builder fbb) {
          final streamIdOffset = fbb.writeString(object.streamId);
          final nameOffset = fbb.writeString(object.name);
          final streamIconOffset = fbb.writeString(object.streamIcon);
          final epgChannelIdOffset = fbb.writeString(object.epgChannelId);
          final categoryIdOffset = fbb.writeString(object.categoryId);
          final categoryNameOffset = fbb.writeString(object.categoryName);
          fbb.startTable(9);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, streamIdOffset);
          fbb.addOffset(2, nameOffset);
          fbb.addOffset(3, streamIconOffset);
          fbb.addOffset(4, epgChannelIdOffset);
          fbb.addOffset(5, categoryIdOffset);
          fbb.addBool(6, object.hasTvArchive);
          fbb.addOffset(7, categoryNameOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final streamIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final streamIconParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final epgChannelIdParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, '');
          final categoryIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final categoryNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 18, '');
          final hasTvArchiveParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 16, false);
          final object = Channel(
              streamId: streamIdParam,
              name: nameParam,
              streamIcon: streamIconParam,
              epgChannelId: epgChannelIdParam,
              categoryId: categoryIdParam,
              categoryName: categoryNameParam,
              hasTvArchive: hasTvArchiveParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    Movie: obx_int.EntityDefinition<Movie>(
        model: _entities[1],
        toOneRelations: (Movie object) => [],
        toManyRelations: (Movie object) => {},
        getId: (Movie object) => object.id,
        setId: (Movie object, int id) {
          object.id = id;
        },
        objectToFB: (Movie object, fb.Builder fbb) {
          final streamIdOffset = fbb.writeString(object.streamId);
          final nameOffset = fbb.writeString(object.name);
          final streamIconOffset = fbb.writeString(object.streamIcon);
          final containerExtensionOffset =
              fbb.writeString(object.containerExtension);
          final categoryIdOffset = fbb.writeString(object.categoryId);
          final ratingOffset =
              object.rating == null ? null : fbb.writeString(object.rating!);
          final plotOffset =
              object.plot == null ? null : fbb.writeString(object.plot!);
          final releaseDateOffset = object.releaseDate == null
              ? null
              : fbb.writeString(object.releaseDate!);
          final directorOffset = object.director == null
              ? null
              : fbb.writeString(object.director!);
          final actorsOffset =
              object.actors == null ? null : fbb.writeString(object.actors!);
          final backdropPathOffset = object.backdropPath == null
              ? null
              : fbb.writeString(object.backdropPath!);
          final youtubeTrailerOffset = object.youtubeTrailer == null
              ? null
              : fbb.writeString(object.youtubeTrailer!);
          final tmdbIdOffset =
              object.tmdbId == null ? null : fbb.writeString(object.tmdbId!);
          final yearOffset =
              object.year == null ? null : fbb.writeString(object.year!);
          final categoryNameOffset = fbb.writeString(object.categoryName);
          fbb.startTable(18);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, streamIdOffset);
          fbb.addOffset(2, nameOffset);
          fbb.addOffset(3, streamIconOffset);
          fbb.addOffset(4, containerExtensionOffset);
          fbb.addOffset(5, categoryIdOffset);
          fbb.addOffset(6, ratingOffset);
          fbb.addOffset(7, plotOffset);
          fbb.addOffset(8, releaseDateOffset);
          fbb.addOffset(9, directorOffset);
          fbb.addOffset(10, actorsOffset);
          fbb.addOffset(11, backdropPathOffset);
          fbb.addOffset(12, youtubeTrailerOffset);
          fbb.addOffset(13, tmdbIdOffset);
          fbb.addOffset(14, yearOffset);
          fbb.addOffset(16, categoryNameOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final streamIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final streamIconParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final containerExtensionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, '');
          final categoryIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final categoryNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 36, '');
          final ratingParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 16);
          final plotParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 18);
          final releaseDateParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 20);
          final directorParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 22);
          final actorsParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 24);
          final backdropPathParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 26);
          final youtubeTrailerParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 28);
          final tmdbIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 30);
          final yearParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 32);
          final object = Movie(
              streamId: streamIdParam,
              name: nameParam,
              streamIcon: streamIconParam,
              containerExtension: containerExtensionParam,
              categoryId: categoryIdParam,
              categoryName: categoryNameParam,
              rating: ratingParam,
              plot: plotParam,
              releaseDate: releaseDateParam,
              director: directorParam,
              actors: actorsParam,
              backdropPath: backdropPathParam,
              youtubeTrailer: youtubeTrailerParam,
              tmdbId: tmdbIdParam,
              year: yearParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    ObjectBox: obx_int.EntityDefinition<ObjectBox>(
        model: _entities[2],
        toOneRelations: (ObjectBox object) => [],
        toManyRelations: (ObjectBox object) => {},
        getId: (ObjectBox object) => object.id,
        setId: (ObjectBox object, int id) {
          object.id = id;
        },
        objectToFB: (ObjectBox object, fb.Builder fbb) {
          fbb.startTable(2);
          fbb.addInt64(0, object.id);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = ObjectBox()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    Series: obx_int.EntityDefinition<Series>(
        model: _entities[3],
        toOneRelations: (Series object) => [],
        toManyRelations: (Series object) => {},
        getId: (Series object) => object.id,
        setId: (Series object, int id) {
          object.id = id;
        },
        objectToFB: (Series object, fb.Builder fbb) {
          final seriesIdOffset = fbb.writeString(object.seriesId);
          final nameOffset = fbb.writeString(object.name);
          final coverOffset = fbb.writeString(object.cover);
          final plotOffset = fbb.writeString(object.plot);
          final castOffset = fbb.writeString(object.cast);
          final directorOffset = fbb.writeString(object.director);
          final genreOffset = fbb.writeString(object.genre);
          final releaseDateOffset = fbb.writeString(object.releaseDate);
          final ratingOffset = fbb.writeString(object.rating);
          final categoryIdOffset = fbb.writeString(object.categoryId);
          final tmdbIdOffset =
              object.tmdbId == null ? null : fbb.writeString(object.tmdbId!);
          final backdropPathOffset = object.backdropPath == null
              ? null
              : fbb.writeString(object.backdropPath!);
          final categoryNameOffset = fbb.writeString(object.categoryName);
          fbb.startTable(15);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, seriesIdOffset);
          fbb.addOffset(2, nameOffset);
          fbb.addOffset(3, coverOffset);
          fbb.addOffset(4, plotOffset);
          fbb.addOffset(5, castOffset);
          fbb.addOffset(6, directorOffset);
          fbb.addOffset(7, genreOffset);
          fbb.addOffset(8, releaseDateOffset);
          fbb.addOffset(9, ratingOffset);
          fbb.addOffset(10, categoryIdOffset);
          fbb.addOffset(11, tmdbIdOffset);
          fbb.addOffset(12, backdropPathOffset);
          fbb.addOffset(13, categoryNameOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final seriesIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final coverParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final plotParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final castParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final directorParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 16, '');
          final genreParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 18, '');
          final releaseDateParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 20, '');
          final ratingParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 22, '');
          final categoryIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 24, '');
          final categoryNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 30, '');
          final tmdbIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 26);
          final backdropPathParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 28);
          final object = Series(
              seriesId: seriesIdParam,
              name: nameParam,
              cover: coverParam,
              plot: plotParam,
              cast: castParam,
              director: directorParam,
              genre: genreParam,
              releaseDate: releaseDateParam,
              rating: ratingParam,
              categoryId: categoryIdParam,
              categoryName: categoryNameParam,
              tmdbId: tmdbIdParam,
              backdropPath: backdropPathParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    XtreamConnection: obx_int.EntityDefinition<XtreamConnection>(
        model: _entities[4],
        toOneRelations: (XtreamConnection object) => [],
        toManyRelations: (XtreamConnection object) => {},
        getId: (XtreamConnection object) => object.obId,
        setId: (XtreamConnection object, int id) {
          object.obId = id;
        },
        objectToFB: (XtreamConnection object, fb.Builder fbb) {
          final idOffset = fbb.writeString(object.id);
          final nameOffset = fbb.writeString(object.name);
          final serverUrlOffset = fbb.writeString(object.serverUrl);
          final usernameOffset = fbb.writeString(object.username);
          final passwordOffset = fbb.writeString(object.password);
          fbb.startTable(8);
          fbb.addInt64(0, object.obId);
          fbb.addOffset(1, idOffset);
          fbb.addOffset(2, nameOffset);
          fbb.addOffset(3, serverUrlOffset);
          fbb.addOffset(4, usernameOffset);
          fbb.addOffset(5, passwordOffset);
          fbb.addInt64(6, object.addedDate.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.obId;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final serverUrlParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final usernameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final passwordParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final addedDateParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0));
          final object = XtreamConnection(
              id: idParam,
              name: nameParam,
              serverUrl: serverUrlParam,
              username: usernameParam,
              password: passwordParam,
              addedDate: addedDateParam)
            ..obId = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    Category: obx_int.EntityDefinition<Category>(
        model: _entities[5],
        toOneRelations: (Category object) => [],
        toManyRelations: (Category object) => {},
        getId: (Category object) => object.id,
        setId: (Category object, int id) {
          object.id = id;
        },
        objectToFB: (Category object, fb.Builder fbb) {
          final categoryIdOffset = fbb.writeString(object.categoryId);
          final categoryNameOffset = fbb.writeString(object.categoryName);
          final contentTypeOffset = fbb.writeString(object.contentType);
          fbb.startTable(7);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.playlistId);
          fbb.addOffset(2, categoryIdOffset);
          fbb.addOffset(3, categoryNameOffset);
          fbb.addOffset(4, contentTypeOffset);
          fbb.addInt64(5, object.parentId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final categoryIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final categoryNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, '');
          final contentTypeParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, '');
          final playlistIdParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 6);
          final parentIdParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 14);
          final object = Category(
              categoryId: categoryIdParam,
              categoryName: categoryNameParam,
              contentType: contentTypeParam,
              playlistId: playlistIdParam,
              parentId: parentIdParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [Channel] entity fields to define ObjectBox queries.
class Channel_ {
  /// see [Channel.id]
  static final id =
      obx.QueryIntegerProperty<Channel>(_entities[0].properties[0]);

  /// see [Channel.streamId]
  static final streamId =
      obx.QueryStringProperty<Channel>(_entities[0].properties[1]);

  /// see [Channel.name]
  static final name =
      obx.QueryStringProperty<Channel>(_entities[0].properties[2]);

  /// see [Channel.streamIcon]
  static final streamIcon =
      obx.QueryStringProperty<Channel>(_entities[0].properties[3]);

  /// see [Channel.epgChannelId]
  static final epgChannelId =
      obx.QueryStringProperty<Channel>(_entities[0].properties[4]);

  /// see [Channel.categoryId]
  static final categoryId =
      obx.QueryStringProperty<Channel>(_entities[0].properties[5]);

  /// see [Channel.hasTvArchive]
  static final hasTvArchive =
      obx.QueryBooleanProperty<Channel>(_entities[0].properties[6]);

  /// see [Channel.categoryName]
  static final categoryName =
      obx.QueryStringProperty<Channel>(_entities[0].properties[7]);
}

/// [Movie] entity fields to define ObjectBox queries.
class Movie_ {
  /// see [Movie.id]
  static final id = obx.QueryIntegerProperty<Movie>(_entities[1].properties[0]);

  /// see [Movie.streamId]
  static final streamId =
      obx.QueryStringProperty<Movie>(_entities[1].properties[1]);

  /// see [Movie.name]
  static final name =
      obx.QueryStringProperty<Movie>(_entities[1].properties[2]);

  /// see [Movie.streamIcon]
  static final streamIcon =
      obx.QueryStringProperty<Movie>(_entities[1].properties[3]);

  /// see [Movie.containerExtension]
  static final containerExtension =
      obx.QueryStringProperty<Movie>(_entities[1].properties[4]);

  /// see [Movie.categoryId]
  static final categoryId =
      obx.QueryStringProperty<Movie>(_entities[1].properties[5]);

  /// see [Movie.rating]
  static final rating =
      obx.QueryStringProperty<Movie>(_entities[1].properties[6]);

  /// see [Movie.plot]
  static final plot =
      obx.QueryStringProperty<Movie>(_entities[1].properties[7]);

  /// see [Movie.releaseDate]
  static final releaseDate =
      obx.QueryStringProperty<Movie>(_entities[1].properties[8]);

  /// see [Movie.director]
  static final director =
      obx.QueryStringProperty<Movie>(_entities[1].properties[9]);

  /// see [Movie.actors]
  static final actors =
      obx.QueryStringProperty<Movie>(_entities[1].properties[10]);

  /// see [Movie.backdropPath]
  static final backdropPath =
      obx.QueryStringProperty<Movie>(_entities[1].properties[11]);

  /// see [Movie.youtubeTrailer]
  static final youtubeTrailer =
      obx.QueryStringProperty<Movie>(_entities[1].properties[12]);

  /// see [Movie.tmdbId]
  static final tmdbId =
      obx.QueryStringProperty<Movie>(_entities[1].properties[13]);

  /// see [Movie.year]
  static final year =
      obx.QueryStringProperty<Movie>(_entities[1].properties[14]);

  /// see [Movie.categoryName]
  static final categoryName =
      obx.QueryStringProperty<Movie>(_entities[1].properties[15]);
}

/// [ObjectBox] entity fields to define ObjectBox queries.
class ObjectBox_ {
  /// see [ObjectBox.id]
  static final id =
      obx.QueryIntegerProperty<ObjectBox>(_entities[2].properties[0]);
}

/// [Series] entity fields to define ObjectBox queries.
class Series_ {
  /// see [Series.id]
  static final id =
      obx.QueryIntegerProperty<Series>(_entities[3].properties[0]);

  /// see [Series.seriesId]
  static final seriesId =
      obx.QueryStringProperty<Series>(_entities[3].properties[1]);

  /// see [Series.name]
  static final name =
      obx.QueryStringProperty<Series>(_entities[3].properties[2]);

  /// see [Series.cover]
  static final cover =
      obx.QueryStringProperty<Series>(_entities[3].properties[3]);

  /// see [Series.plot]
  static final plot =
      obx.QueryStringProperty<Series>(_entities[3].properties[4]);

  /// see [Series.cast]
  static final cast =
      obx.QueryStringProperty<Series>(_entities[3].properties[5]);

  /// see [Series.director]
  static final director =
      obx.QueryStringProperty<Series>(_entities[3].properties[6]);

  /// see [Series.genre]
  static final genre =
      obx.QueryStringProperty<Series>(_entities[3].properties[7]);

  /// see [Series.releaseDate]
  static final releaseDate =
      obx.QueryStringProperty<Series>(_entities[3].properties[8]);

  /// see [Series.rating]
  static final rating =
      obx.QueryStringProperty<Series>(_entities[3].properties[9]);

  /// see [Series.categoryId]
  static final categoryId =
      obx.QueryStringProperty<Series>(_entities[3].properties[10]);

  /// see [Series.tmdbId]
  static final tmdbId =
      obx.QueryStringProperty<Series>(_entities[3].properties[11]);

  /// see [Series.backdropPath]
  static final backdropPath =
      obx.QueryStringProperty<Series>(_entities[3].properties[12]);

  /// see [Series.categoryName]
  static final categoryName =
      obx.QueryStringProperty<Series>(_entities[3].properties[13]);
}

/// [XtreamConnection] entity fields to define ObjectBox queries.
class XtreamConnection_ {
  /// see [XtreamConnection.obId]
  static final obId =
      obx.QueryIntegerProperty<XtreamConnection>(_entities[4].properties[0]);

  /// see [XtreamConnection.id]
  static final id =
      obx.QueryStringProperty<XtreamConnection>(_entities[4].properties[1]);

  /// see [XtreamConnection.name]
  static final name =
      obx.QueryStringProperty<XtreamConnection>(_entities[4].properties[2]);

  /// see [XtreamConnection.serverUrl]
  static final serverUrl =
      obx.QueryStringProperty<XtreamConnection>(_entities[4].properties[3]);

  /// see [XtreamConnection.username]
  static final username =
      obx.QueryStringProperty<XtreamConnection>(_entities[4].properties[4]);

  /// see [XtreamConnection.password]
  static final password =
      obx.QueryStringProperty<XtreamConnection>(_entities[4].properties[5]);

  /// see [XtreamConnection.addedDate]
  static final addedDate =
      obx.QueryDateProperty<XtreamConnection>(_entities[4].properties[6]);
}

/// [Category] entity fields to define ObjectBox queries.
class Category_ {
  /// see [Category.id]
  static final id =
      obx.QueryIntegerProperty<Category>(_entities[5].properties[0]);

  /// see [Category.playlistId]
  static final playlistId =
      obx.QueryIntegerProperty<Category>(_entities[5].properties[1]);

  /// see [Category.categoryId]
  static final categoryId =
      obx.QueryStringProperty<Category>(_entities[5].properties[2]);

  /// see [Category.categoryName]
  static final categoryName =
      obx.QueryStringProperty<Category>(_entities[5].properties[3]);

  /// see [Category.contentType]
  static final contentType =
      obx.QueryStringProperty<Category>(_entities[5].properties[4]);

  /// see [Category.parentId]
  static final parentId =
      obx.QueryIntegerProperty<Category>(_entities[5].properties[5]);
}
