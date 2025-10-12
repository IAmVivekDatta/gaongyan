class User {
  final int? id;
  final String name;
  final int level;
  final int xp;
  final String preferredLanguage;

  User({
    this.id,
    required this.name,
    required this.level,
    required this.xp,
    this.preferredLanguage = 'te',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      level: map['level'],
      xp: map['xp'],
      preferredLanguage: map['preferredLanguage'] ?? 'te',
    );
  }
}
