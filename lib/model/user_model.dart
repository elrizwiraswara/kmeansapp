class UserModel {
  String username;
  String password;
  String name;
  String photo;

  UserModel({
    required this.username,
    required this.password,
    required this.name,
    required this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      name: json['name'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'photo': photo,
    };
  }
}
