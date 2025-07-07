import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/expense.dart';
import '../models/inventory_location.dart';
import '../models/investment.dart';
import '../models/party.dart';
import '../models/product.dart';
import '../models/profit_distribution.dart';
import '../models/sack.dart';
import '../models/season.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'stock_manager.db');

    return await openDatabase(
      databasePath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle database upgrades if schema changes
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Seasons (
        seasonId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        code TEXT NOT NULL UNIQUE,
        startDate TEXT NOT NULL,
        endDate TEXT,
        isActive INTEGER DEFAULT 0
      )
    ''');
    await db.insert('seasons', {
      'name': 'Default Season',
      'code': 'DEF001',
      'startDate': DateTime.now().toIso8601String(),
      'isActive': 1
    });

    await db.execute('''
      CREATE TABLE Parties (
        partyId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Products (
        productId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE InventoryLocations (
        locationId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        address TEXT,
        rentCostPerMonth REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Sacks (
        sackId INTEGER PRIMARY KEY AUTOINCREMENT,
        uniqueSackIdentifier TEXT NOT NULL UNIQUE,
        productId INTEGER NULL,
        productType TEXT NOT NULL,
        purchaseSeasonId INTEGER NOT NULL,
        purchaseDate TEXT NOT NULL,
        purchaseVendorId INTEGER NOT NULL,
        purchaseWeightKg REAL NOT NULL,
        purchasePricePerKg REAL NOT NULL,
        purchaseCarryingCost REAL DEFAULT 0.0,
        currentLocationId INTEGER NOT NULL,
        saleDate TEXT,
        saleCustomerId INTEGER,
        saleWeightKg REAL,
        salePricePerKg REAL,
        saleCarryingCost REAL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'In Stock',
        seasonId INTEGER NOT NULL,
        FOREIGN KEY (productId) REFERENCES Products(productId),
        FOREIGN KEY (purchaseSeasonId) REFERENCES Seasons(seasonId),
        FOREIGN KEY (purchaseVendorId) REFERENCES Parties(partyId),
        FOREIGN KEY (currentLocationId) REFERENCES InventoryLocations(locationId),
        FOREIGN KEY (saleCustomerId) REFERENCES Parties(partyId)
      )
    ''');

    await db.execute('''
      CREATE TABLE Expenses (
        expenseId INTEGER PRIMARY KEY AUTOINCREMENT,
        seasonId INTEGER NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        FOREIGN KEY (seasonId) REFERENCES Seasons(seasonId)
      )
    ''');

    await db.execute('''
      CREATE TABLE Investments (
        investmentId INTEGER PRIMARY KEY AUTOINCREMENT,
        investorId INTEGER NOT NULL,
        seasonId INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (investorId) REFERENCES Parties(partyId),
        FOREIGN KEY (seasonId) REFERENCES Seasons(seasonId)
      )
    ''');

    await db.execute('''
      CREATE TABLE ProfitDistributions (
        distributionId INTEGER PRIMARY KEY AUTOINCREMENT,
        investorId INTEGER NOT NULL,
        seasonId INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (investorId) REFERENCES Parties(partyId),
        FOREIGN KEY (seasonId) REFERENCES Seasons(seasonId)
      )
    ''');

    // Initial data for Products (Optional, but good for starting)
    await db.insert('Products', {'name': 'Paddy', 'unit': 'Kilogram'});
    await db.insert('Products', {'name': 'Corn', 'unit': 'Kilogram'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
    }
  }

  // --- Season CRUD Operations ---

  Future<int> insertSeason(Season season) async {
    final db = await database;
    // Set all other seasons to inactive if this one is being set active
    if (season.isActive) {
      await db.rawUpdate('UPDATE Seasons SET isActive = 0 WHERE isActive = 1');
    }
    return await db.insert(
      'Seasons',
      season.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Season>> getSeasons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Seasons', orderBy: 'startDate DESC');
    return List.generate(maps.length, (i) {
      return Season.fromMap(maps[i]);
    });
  }

  Future<Season?> getActiveSeason() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Seasons',
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Season.fromMap(maps.first);
    }
    return null;
  }

  Future<Season?> getSeasonById(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Seasons',
      where: 'seasonId = ?',
      whereArgs: [seasonId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Season.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSeason(Season season) async {
    final db = await database;
    if (season.isActive) {
      await db.rawUpdate('UPDATE Seasons SET isActive = 0 WHERE isActive = 1 AND seasonId != ?', [season.seasonId]);
    }
    return await db.update(
      'Seasons',
      season.toMap(),
      where: 'seasonId = ?',
      whereArgs: [season.seasonId],
    );
  }

  Future<int> deleteSeason(int id) async {
    final db = await database;
    return await db.delete(
      'Seasons',
      where: 'seasonId = ?',
      whereArgs: [id],
    );
  }

  Future<double> getSeasonTotalDistributedAmount(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) as totalDistributed
    FROM ProfitDistributions
    WHERE seasonId = ?
  ''', [seasonId]);
    return (result.first['totalDistributed'] as double?) ?? 0.0;
  }

  // --- Parties CRUD Operations ---

  Future<int> insertParty(Party party) async {
    final db = await database;
    return await db.insert(
      'Parties',
      party.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Party>> getParties() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Parties', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Party.fromMap(maps[i]);
    });
  }

  Future<List<Party>> getPartiesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Parties',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Party.fromMap(maps[i]);
    });
  }

  Future<Party?> getPartyById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Parties',
      where: 'partyId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Party.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateParty(Party party) async {
    final db = await database;
    return await db.update(
      'Parties',
      party.toMap(),
      where: 'partyId = ?',
      whereArgs: [party.partyId],
    );
  }

  Future<int> deleteParty(int id) async {
    final db = await database;
    // Consider implications before deleting: are there associated sacks, investments etc.?
    // For now, simple delete. In a real app, you'd handle foreign key constraints more robustly.
    return await db.delete(
      'Parties',
      where: 'partyId = ?',
      whereArgs: [id],
    );
  }

  // --- Products CRUD Operations ---

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'Products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Products', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Products',
      where: 'productId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'Products',
      product.toMap(),
      where: 'productId = ?',
      whereArgs: [product.productId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    // Similar to parties, be mindful of associated sacks
    return await db.delete(
      'Products',
      where: 'productId = ?',
      whereArgs: [id],
    );
  }

  // --- InventoryLocations CRUD Operations ---

  Future<int> insertInventoryLocation(InventoryLocation location) async {
    final db = await database;
    return await db.insert(
      'InventoryLocations',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryLocation>> getInventoryLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
        'InventoryLocations',
        orderBy: 'name ASC'
    );
    return List.generate(maps.length, (i) {
      return InventoryLocation.fromMap(maps[i]);
    });
  }

  Future<InventoryLocation?> getInventoryLocationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'InventoryLocations',
      where: 'locationId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return InventoryLocation.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateInventoryLocation(InventoryLocation location) async {
    final db = await database;
    return await db.update(
      'InventoryLocations',
      location.toMap(),
      where: 'locationId = ?',
      whereArgs: [location.locationId],
    );
  }

  Future<int> deleteInventoryLocation(int id) async {
    final db = await database;
    // Be mindful of sacks stored in this location! You might want to prevent deletion
    // if there are still sacks associated, or reassign them.
    return await db.delete(
      'InventoryLocations',
      where: 'locationId = ?',
      whereArgs: [id],
    );
  }

  // --- Sacks CRUD Operations ---

  // Helper to get the last sequential number for a given vendor and season
  Future<int> _getLastSackSequenceNumber(int vendorId, int seasonId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT MAX(CAST(SUBSTR(S.uniqueSackIdentifier, INSTR(S.uniqueSackIdentifier, '-') + INSTR(SUBSTR(S.uniqueSackIdentifier, INSTR(S.uniqueSackIdentifier, '-') + 1), '-') + 1) AS INTEGER)) as max_seq
      FROM Sacks AS S
      WHERE S.purchaseVendorId = ? AND S.purchaseSeasonId = ?
      ''',
      [vendorId, seasonId],
    );
    if (result.isNotEmpty && result.first['max_seq'] != null) {
      return (result.first['max_seq'] as int);
    }
    return 0; // Start from 0 if no previous sacks exist
  }

  Future<int> getTotalSacksByStatus(int seasonId, String status) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(sackId) as totalSacks
      FROM sacks
      WHERE seasonId = ? AND status = ?
    ''', [seasonId, status]);
    return (result.first['totalSacks'] as int?) ?? 0;
  }

  // Get total purchase weight of sacks for a given season and status (e.g., In Stock)
  Future<double> getTotalPurchaseWeightByStatus(int seasonId, String status) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(purchaseWeightKg) as totalWeight
      FROM sacks
      WHERE seasonId = ? AND status = ?
    ''', [seasonId, status]);
    return (result.first['totalWeight'] as double?) ?? 0.0;
  }

  // Get total sale weight of sacks for a given season and status (e.g., Sold)
  Future<double> getTotalSaleWeightByStatus(int seasonId, String status) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(saleWeightKg) as totalWeight
      FROM sacks
      WHERE seasonId = ? AND status = ?
    ''', [seasonId, status]);
    return (result.first['totalWeight'] as double?) ?? 0.0;
  }

  // Get total purchase value of sacks currently in stock for a given season
  Future<double> getTotalStockValue(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM( (purchaseWeightKg * purchasePricePerKg) + IFNULL(purchaseCarryingCost, 0) ) as totalValue
      FROM sacks
      WHERE seasonId = ? AND status = 'In Stock'
    ''', [seasonId]);
    return (result.first['totalValue'] as double?) ?? 0.0;
  }

  Future<int> getTotalSacksForSeason(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(sackId) as totalSacks
    FROM sacks
    WHERE seasonId = ?
  ''', [seasonId]);
    return (result.first['totalSacks'] as int?) ?? 0;
  }

  Future<List<Sack>> getSacksForSeason(
      int seasonId, {
        String? productType,
        String? status,
        int? locationId,
        String? searchText, // For a general text search across relevant fields
      }) async {
    final db = await database;
    List<String> whereClauses = ['seasonId = ?'];
    List<dynamic> whereArgs = [seasonId];

    if (productType != null && productType.isNotEmpty) {
      whereClauses.add('productType = ?');
      whereArgs.add(productType);
    }
    if (status != null && status.isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }
    if (locationId != null) {
      whereClauses.add('locationId = ?');
      whereArgs.add(locationId);
    }
    if (searchText != null && searchText.isNotEmpty) {
      // Add a LIKE clause for search. Adjust fields as needed.
      // Example: searching in purchaseCode, productType, or notes
      whereClauses.add('(purchaseCode LIKE ? OR productType LIKE ? OR notes LIKE ?)');
      whereArgs.add('%$searchText%');
      whereArgs.add('%$searchText%');
      whereArgs.add('%$searchText%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'sacks',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'purchaseDate DESC', // Optional: order by date for better display
    );

    return List.generate(maps.length, (i) {
      return Sack.fromMap(maps[i]);
    });
  }

  // You might also need a method to get all distinct product types and statuses for dropdowns
  Future<List<String>> getDistinctProductTypes(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sacks',
      columns: ['DISTINCT productType'],
      where: 'seasonId = ? AND productType IS NOT NULL AND productType != ""',
      whereArgs: [seasonId],
    );
    return maps.map((map) => map['productType'] as String).toList();
  }

  Future<List<String>> getDistinctSackStatuses() async {
    // These are usually fixed, but fetching from DB ensures consistency
    return ['In Stock', 'Sold', 'Discarded']; // Or fetch from a status table if you have one
  }

  Future<String> generateUniqueSackIdentifier(int vendorId, int seasonId) async {
    final db = await database;
    final Party? vendor = await getPartyById(vendorId);
    final Season? season = await getSeasonById(seasonId);

    if (vendor == null || season == null) {
      throw Exception('Vendor or Season not found for sack identifier generation.');
    }

    final String vendorCode = vendor.code;
    final String seasonCode = season.code;
    final int lastSeqNum = await _getLastSackSequenceNumber(vendorId, seasonId);
    final int nextSeqNum = lastSeqNum + 1;

    // Format: VENDORCODE-SEASONCODE-SEQNUM (e.g., "FARM001-Boro25-001")
    return '$vendorCode-$seasonCode-${nextSeqNum.toString().padLeft(3, '0')}';
  }

  Future<int> insertSack(Sack sack) async {
    final db = await database;
    return await db.insert(
      'Sacks',
      sack.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sack>> getSacks({int? seasonId, String? status, int? locationId, int? productId}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (seasonId != null) {
      whereClauses.add('purchaseSeasonId = ?');
      whereArgs.add(seasonId);
    }
    if (status != null) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }
    if (locationId != null) {
      whereClauses.add('currentLocationId = ?');
      whereArgs.add(locationId);
    }
    if (productId != null) {
      whereClauses.add('productId = ?');
      whereArgs.add(productId);
    }

    String whereString = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Sacks $whereString ORDER BY purchaseDate DESC',
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Sack.fromMap(maps[i]);
    });
  }

  Future<Sack?> getSackById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Sacks',
      where: 'sackId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Sack.fromMap(maps.first);
    }
    return null;
  }

  Future<Sack?> getSackByUniqueId(String uniqueId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Sacks',
      where: 'uniqueSackIdentifier = ?',
      whereArgs: [uniqueId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Sack.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSack(Sack sack) async {
    final db = await database;
    return await db.update(
      'sacks',
      sack.toMap(),
      where: 'sackId = ?',
      whereArgs: [sack.sackId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> bulkUpdateSacks(List<Sack> sacks) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var sack in sacks) {
        await txn.update(
          'sacks',
          sack.toMap(),
          where: 'sackId = ?',
          whereArgs: [sack.sackId],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<int> deleteSack(int id) async {
    final db = await database;
    return await db.delete(
      'Sacks',
      where: 'sackId = ?',
      whereArgs: [id],
    );
  }

  // --- Expenses CRUD Operations ---

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      'Expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses({int? seasonId, String? category}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (seasonId != null) {
      whereClauses.add('seasonId = ?');
      whereArgs.add(seasonId);
    }
    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    String whereString = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Expenses $whereString ORDER BY date DESC',
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Expenses',
      where: 'expenseId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'Expenses',
      expense.toMap(),
      where: 'expenseId = ?',
      whereArgs: [expense.expenseId],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'Expenses',
      where: 'expenseId = ?',
      whereArgs: [id],
    );
  }

  // --- Investments CRUD Operations ---

  Future<int> insertInvestment(Investment investment) async {
    final db = await database;
    return await db.insert(
      'Investments',
      investment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Investment>> getInvestments({int? seasonId, int? investorId}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (seasonId != null) {
      whereClauses.add('seasonId = ?');
      whereArgs.add(seasonId);
    }
    if (investorId != null) {
      whereClauses.add('investorId = ?');
      whereArgs.add(investorId);
    }

    String whereString = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Investments $whereString ORDER BY date DESC',
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Investment.fromMap(maps[i]);
    });
  }

  Future<Investment?> getInvestmentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Investments',
      where: 'investmentId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Investment.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateInvestment(Investment investment) async {
    final db = await database;
    return await db.update(
      'Investments',
      investment.toMap(),
      where: 'investmentId = ?',
      whereArgs: [investment.investmentId],
    );
  }

  Future<int> deleteInvestment(int id) async {
    final db = await database;
    return await db.delete(
      'Investments',
      where: 'investmentId = ?',
      whereArgs: [id],
    );
  }

  // --- ProfitDistributions CRUD Operations ---

  Future<int> insertProfitDistribution(ProfitDistribution distribution) async {
    final db = await database;
    return await db.insert(
      'ProfitDistributions',
      distribution.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProfitDistribution>> getProfitDistributions({int? seasonId, int? investorId}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (seasonId != null) {
      whereClauses.add('seasonId = ?');
      whereArgs.add(seasonId);
    }
    if (investorId != null) {
      whereClauses.add('investorId = ?');
      whereArgs.add(investorId);
    }

    String whereString = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM ProfitDistributions $whereString ORDER BY date DESC',
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return ProfitDistribution.fromMap(maps[i]);
    });
  }

  Future<ProfitDistribution?> getProfitDistributionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ProfitDistributions',
      where: 'distributionId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ProfitDistribution.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfitDistribution(ProfitDistribution distribution) async {
    final db = await database;
    return await db.update(
      'ProfitDistributions',
      distribution.toMap(),
      where: 'distributionId = ?',
      whereArgs: [distribution.distributionId],
    );
  }

  Future<int> deleteProfitDistribution(int id) async {
    final db = await database;
    return await db.delete(
      'ProfitDistributions',
      where: 'distributionId = ?',
      whereArgs: [id],
    );
  }

  // --- New financial summary methods (for Profit Calculation) ---
  Future<double> getSeasonTotalRevenue(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(saleWeightKg * salePricePerKg) as totalRevenue
    FROM sacks
    WHERE seasonId = ? AND status = 'Sold' AND saleWeightKg IS NOT NULL AND salePricePerKg IS NOT NULL
  ''', [seasonId]);
    return (result.first['totalRevenue'] as double?) ?? 0.0;
  }

  Future<double> getSeasonTotalPurchaseCost(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(purchaseWeightKg * purchasePricePerKg) as totalPurchaseCost
    FROM sacks
    WHERE seasonId = ?
  ''', [seasonId]);
    return (result.first['totalPurchaseCost'] as double?) ?? 0.0;
  }

  Future<double> getSeasonTotalPurchaseCarryingCost(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(purchaseCarryingCost) as totalCarryingCost
    FROM sacks
    WHERE seasonId = ? AND purchaseCarryingCost IS NOT NULL
  ''', [seasonId]);
    return (result.first['totalCarryingCost'] as double?) ?? 0.0;
  }

  Future<double> getSeasonTotalSaleCarryingCost(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(saleCarryingCost) as totalCarryingCost
    FROM sacks
    WHERE seasonId = ? AND saleCarryingCost IS NOT NULL
  ''', [seasonId]);
    return (result.first['totalCarryingCost'] as double?) ?? 0.0;
  }

  Future<double> getSeasonTotalExpenses(int seasonId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) as totalExpenses
    FROM expenses
    WHERE seasonId = ?
  ''', [seasonId]);
    return (result.first['totalExpenses'] as double?) ?? 0.0;
  }

  Future<void> close() async {
    final db = await _instance.database;
    db.close();
    _database = null;
  }
}
