class UserModel {
  final String playerName;

  UserModel({required this.playerName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      playerName: json['playerName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
    };
  }
}
