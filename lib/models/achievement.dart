class Achievement {
  final String id;
  final String title;
  final String description;
  final dynamic icon; // HugeIcons data is not IconData
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}
