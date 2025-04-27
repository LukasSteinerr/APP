import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/xtream_connection.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  // Database name
  static const String _databaseName = "xtream_iptv.db";

  // Database version
  static const int _databaseVersion = 1;

  // Table names
  static const String tableConnections = 'connections';

  // Common column names
  static const String columnId = 'id';

  // Connections table columns
  static const String columnName = 'name';
  static const String columnServerUrl = 'server_url';
  static const String columnUsername = 'username';
  static const String columnPassword = 'password';
  static const String columnAddedDate = 'added_date';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if it doesn't exist
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the directory for the app's document directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Open/create the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableConnections (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnServerUrl TEXT NOT NULL,
        $columnUsername TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnAddedDate TEXT NOT NULL
      )
    ''');
  }

  // Insert a connection into the database
  Future<int> insertConnection(XtreamConnection connection) async {
    Database db = await database;

    // Use the toMap method from the model
    Map<String, dynamic> row = connection.toMap();

    // Check if the connection already exists
    List<Map<String, dynamic>> result = await db.query(
      tableConnections,
      where: '$columnId = ?',
      whereArgs: [connection.id],
    );

    if (result.isNotEmpty) {
      // Update existing connection
      return await db.update(
        tableConnections,
        row,
        where: '$columnId = ?',
        whereArgs: [connection.id],
      );
    } else {
      // Insert new connection
      return await db.insert(tableConnections, row);
    }
  }

  // Get all connections from the database
  Future<List<XtreamConnection>> getConnections() async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.query(tableConnections);

    return result.map((map) => XtreamConnection.fromMap(map)).toList();
  }

  // Delete a connection from the database
  Future<int> deleteConnection(String id) async {
    Database db = await database;

    return await db.delete(
      tableConnections,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete all connections from the database
  Future<int> deleteAllConnections() async {
    Database db = await database;

    return await db.delete(tableConnections);
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
