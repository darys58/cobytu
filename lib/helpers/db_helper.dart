import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';

//metody statyczne w klasie są po to, zeby nie tworzyć instancji tej klasy 
//ale pracować z tymi metodami jak z funkcjami. Klasa jest opakowaniem dla metod, 
//które mogłyby być napisane jako funkcje poza ta klasą.

//dostep do bazy - otwarcie bazy lub utworzenie nowej jesli nie było.
class DBHelper {
  /*
  static Database _database;

  Future<Database> get database async{
    if (_database != null)
    return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async{
    final dataPath = await sql.getDatabasesPath();
    String dbPath = path.join(dataPath,'cobytu.db');
    return await sql.openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE dania(id TEXT PRIMARY KEY, nazwa TEXT, opis TEXT, idwer TEXT, wersja TEXT, foto TEXT, gdzie TEXT, kategoria TEXT, podkat TEXT, srednia TEXT, alergeny TEXT, cena TEXT, czas TEXT, waga TEXT, kcal TEXT, lubi TEXT, fav TEXT, stolik TEXT)'
          );
    
      }
      );
  }
*/


  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, "cobytu.db"); //ściekzka do bazy i nazwa bazy

     
   

print('openDatabase !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    return sql.openDatabase(path, 
        onCreate: (db, version) async{
          print('tworzenie tabeli');
      await db.execute(
          'CREATE TABLE dania(id TEXT PRIMARY KEY, nazwa TEXT, opis TEXT, idwer TEXT, wersja TEXT, foto TEXT, gdzie TEXT, kategoria TEXT, podkat TEXT, rodzaj TEXT, srednia TEXT, alergeny TEXT, cena TEXT, czas TEXT, waga TEXT, kcal TEXT, lubi TEXT, fav TEXT, stolik TEXT)'
          );
      await db.execute(
          'CREATE TABLE restauracje(id TEXT PRIMARY KEY, nazwa TEXT, obiekt TEXT, adres TEXT, miaId TEXT, miasto TEXT, wojId TEXT, woj TEXT, dostawy TEXT, opakowanie TEXT, doStolika TEXT, rezerwacje TEXT, mogeJesc TEXT, modMenu TEXT)'
          );  
      await db.execute(
          'CREATE TABLE memory(nazwa TEXT PRIMARY KEY, a TEXT, b TEXT, c TEXT, d TEXT, e TEXT, f TEXT)'
          ); 
      await db.execute(
          'CREATE TABLE podkategorie(id TEXT PRIMARY KEY, kolejnosc TEXT, kaId TEXT, nazwa TEXT)'
          );       
    }, version: 1);
  }
  
  static Future<void> deleteBase() async{
    final dbPath = await sql.getDatabasesPath();
    print('kasowanie bazy danych');
  await sql.deleteDatabase(join(dbPath, "cobytu.db"));
  }

//zapis do bazy
  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    print('wstawianie do tabeli $table');
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //odczyt z bazy całej tabeli
  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    print('pobieranie z tabeli $table');
    return db.query(table);
  }

  //usuwanie tabeli z bazy
  static Future<void> deleteTable(String table) async {
    final db = await DBHelper.database();
    print('kasowanie tabeli $table');
    db.delete(table);
  }
  
  //update polubienia dania
  static Future<void> updateFav(String id, String fav) async{
    final db = await DBHelper.database();
    print('update dania fav');
    db.update('dania', {'fav': fav}, where: 'id = ?', whereArgs:[id]);

  }

  //odczyt z bazy restauracji z unikalnymi województwami - dla location
  static Future<List<Map<String, dynamic>>> getWoj(String table) async {
    final db = await DBHelper.database();
    print('pobieranie wojewodztw z tabeli $table');
    return db.rawQuery('SELECT DISTINCT woj, wojId FROM $table ORDER BY woj ASC ');
  }

  //odczyt z bazy restauracji z unikalnymi miastami dla danego województwa - dla location
  static Future<List<Map<String, dynamic>>> getMia(String woj) async {
    final db = await DBHelper.database();
    print('pobieranie miast dla $woj');
    return db.rawQuery('SELECT DISTINCT miasto, miaId FROM restauracje WHERE woj = ? ORDER BY miasto ASC',[woj]);
  }

  //odczyt z bazy restauracji dla danego miasta - dla location
  static Future<List<Map<String, dynamic>>> getRests(String miasto) async {
    final db = await DBHelper.database();
    print('pobieranie restauracji dla $miasto');
    return db.rawQuery('SELECT  * FROM restauracje WHERE miasto = ? ORDER BY nazwa ASC',[miasto]);
  }

  //odczyt z bazy restauracji dla danego id - dla meal_item - potrzebne modMenu
  static Future<List<Map<String, dynamic>>> getRestWithId(String restId) async {
    final db = await DBHelper.database();
    print('pobieranie restauracji dla id = $restId');
    return db.rawQuery('SELECT  * FROM restauracje WHERE id = ?',[restId]);
  }

  //odczyt rekordu z bazy memory
  static Future<List<Map<String, dynamic>>> getMemory(String nazwa) async {
    final db = await DBHelper.database();
    print('pobieranie memory dla $nazwa');
    return db.rawQuery('SELECT  * FROM memory WHERE nazwa = ?',[nazwa]);
  }

}
/*class DbHelper {
      static const NEW_DB_VERSION = 2;

      static final DbHelper _instance = DbHelper.internal();

      factory DbHelper() => _instance;

      DbHelper.internal();

      Database _db;

      Future<Database> get db async {
        if (_db != null) {
          return _db;
        } else {
          _db = await initDb();
          return _db;
        }
      }

      Future<Database> initDb() async {

        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "database.db");

        var db = await openDatabase(path);

        //if database does not exist yet it will return version 0
        if (await db.getVersion() < NEW_DB_VERSION) {

          db.close();

          //delete the old database so you can copy the new one
          await deleteDatabase(path);

          try {
            await Directory(dirname(path)).create(recursive: true);
          } catch (_) {}

          //copy db from assets to database folder
          ByteData data = await rootBundle.load("assets/databases/database.db");
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes, flush: true);

          //open the newly created db 
          db = await openDatabase(path);

          //set the new version to the copied db so you do not need to do it manually on your bundled database.db
          db.setVersion(NEW_DB_VERSION);

        }

        return db;
      }*/