import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.friendCode,
    required this.petType,
    required this.petName,
    required this.petLevel,
    required this.petExp,
  });

  final String id;
  final String email;
  final String nickname;
  final String friendCode;
  final String petType;
  final String petName;
  final int petLevel;
  final int petExp;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      friendCode: json['friend_code'] as String,
      petType: json['pet_type'] as String,
      petName: json['pet_name'] as String,
      petLevel: json['pet_level'] as int,
      petExp: json['pet_exp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'friend_code': friendCode,
      'pet_type': petType,
      'pet_name': petName,
      'pet_level': petLevel,
      'pet_exp': petExp,
    };
  }

  @override
  List<Object?> get props =>
      [id, email, nickname, friendCode, petType, petName, petLevel, petExp];
}
