class DatabaseTables {
  // Table Names
  static const String categories = 'categories';
  static const String expenses = 'expenses';
  static const String budgets = 'budgets';
  static const String settings = 'settings';

  // Categories Table
  static const String createCategoriesTable = '''
    CREATE TABLE $categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon_code INTEGER NOT NULL,
      color INTEGER NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  // Expenses Table
  static const String createExpensesTable = '''
    CREATE TABLE $expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL CHECK(amount > 0),
      description TEXT,
      category_id INTEGER NOT NULL,
      date INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE RESTRICT
    )
  ''';

  // Budgets Table
  static const String createBudgetsTable = '''
    CREATE TABLE $budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      amount REAL NOT NULL CHECK(amount > 0),
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE CASCADE,
      UNIQUE(category_id, month, year)
    )
  ''';

  // Settings Table (for app preferences)
  static const String createSettingsTable = '''
    CREATE TABLE $settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      value TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  // Indexes for better performance
  static const List<String> createIndexes = [
    'CREATE INDEX idx_expenses_date ON $expenses(date)',
    'CREATE INDEX idx_expenses_category_id ON $expenses(category_id)',
    'CREATE INDEX idx_expenses_amount ON $expenses(amount)',
    'CREATE INDEX idx_budgets_month_year ON $budgets(month, year)',
    'CREATE INDEX idx_categories_name ON $categories(name)',
    'CREATE INDEX idx_settings_key ON $settings(key)',
  ];

  // Default Categories Data
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Food & Dining',
      'icon_code': 0xe57f, // Icons.restaurant
      'color': 0xFFE57373, // Red
      'is_default': 1,
    },
    {
      'name': 'Transportation',
      'icon_code': 0xe571, // Icons.directions_car
      'color': 0xFF64B5F6, // Blue
      'is_default': 1,
    },
    {
      'name': 'Shopping',
      'icon_code': 0xe59c, // Icons.shopping_bag
      'color': 0xFFBA68C8, // Purple
      'is_default': 1,
    },
    {
      'name': 'Entertainment',
      'icon_code': 0xe404, // Icons.movie
      'color': 0xFFFFB74D, // Orange
      'is_default': 1,
    },
    {
      'name': 'Bills & Utilities',
      'icon_code': 0xe8e8, // Icons.receipt
      'color': 0xFF4DB6AC, // Teal
      'is_default': 1,
    },
    {
      'name': 'Healthcare',
      'icon_code': 0xe57e, // Icons.local_hospital
      'color': 0xFF81C784, // Green
      'is_default': 1,
    },
    {
      'name': 'Education',
      'icon_code': 0xe80c, // Icons.school
      'color': 0xFF7986CB, // Indigo
      'is_default': 1,
    },
    {
      'name': 'Travel',
      'icon_code': 0xe539, // Icons.flight
      'color': 0xFFF06292, // Pink
      'is_default': 1,
    },
    {
      'name': 'Personal Care',
      'icon_code': 0xe8cc, // Icons.spa
      'color': 0xFFAED581, // Light Green
      'is_default': 1,
    },
    {
      'name': 'Other',
      'icon_code': 0xe8b6, // Icons.more_horiz
      'color': 0xFF90A4AE, // Blue Grey
      'is_default': 1,
    },
  ];

  // Default Settings
  static const List<Map<String, dynamic>> defaultSettings = [
    {
      'key': 'currency',
      'value': 'USD',
    },
    {
      'key': 'theme_mode',
      'value': 'system',
    },
    {
      'key': 'language',
      'value': 'en',
    },
    {
      'key': 'default_category_id',
      'value': '1',
    },
    {
      'key': 'first_launch',
      'value': 'true',
    },
  ];

  // Migration scripts for future versions
  static const Map<int, List<String>> migrations = {
    // Example migration for version 2
    // 2: [
    //   'ALTER TABLE expenses ADD COLUMN tags TEXT',
    //   'CREATE INDEX idx_expenses_tags ON expenses(tags)',
    // ],
  };

  // All table creation statements
  static const List<String> createTableStatements = [
    createCategoriesTable,
    createExpensesTable,
    createBudgetsTable,
    createSettingsTable,
  ];

  // Views for complex queries
  static const String createExpensesWithCategoryView = '''
    CREATE VIEW expenses_with_category AS
    SELECT 
      e.id,
      e.amount,
      e.description,
      e.date,
      e.created_at,
      e.updated_at,
      c.id as category_id,
      c.name as category_name,
      c.icon_code as category_icon,
      c.color as category_color
    FROM $expenses e
    INNER JOIN $categories c ON e.category_id = c.id
    WHERE c.is_active = 1
    ORDER BY e.date DESC
  ''';

  static const String createMonthlyExpenseSummaryView = '''
    CREATE VIEW monthly_expense_summary AS
    SELECT 
      strftime('%Y-%m', datetime(date, 'unixepoch')) as month,
      category_id,
      c.name as category_name,
      c.color as category_color,
      COUNT(*) as transaction_count,
      SUM(amount) as total_amount,
      AVG(amount) as average_amount
    FROM $expenses e
    INNER JOIN $categories c ON e.category_id = c.id
    WHERE c.is_active = 1
    GROUP BY month, category_id
    ORDER BY month DESC, total_amount DESC
  ''';

  static const List<String> createViews = [
    createExpensesWithCategoryView,
    createMonthlyExpenseSummaryView,
  ];
}