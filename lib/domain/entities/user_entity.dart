class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });
}
