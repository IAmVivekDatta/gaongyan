class User {
  final int? id;
  final String name;
  final int level;
  final int xp;

  User({this.id, required this.name, required this.level, required this.xp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      level: map['level'],
      xp: map['xp'],
    );
  }
}
