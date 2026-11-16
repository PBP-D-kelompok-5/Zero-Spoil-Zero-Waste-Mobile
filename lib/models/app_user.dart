/// Pengguna yang sedang login, dari respons `/api/auth/login/` atau `/api/auth/me/`.
class AppUser {
  const AppUser({required this.id, required this.username});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        username: json['username'] as String,
      );

  final int id;
  final String username;

  Map<String, dynamic> toJson() => {'id': id, 'username': username};
}
