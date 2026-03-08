import 'package:equatable/equatable.dart';
import 'collection.dart';

class Friend extends Equatable {
  const Friend({
    required this.id,
    required this.nickname,
    required this.friendCode,
    required this.collectionCount,
    required this.petName,
    required this.petType,
    this.collections = const [],
  });

  final String id;
  final String nickname;
  final String friendCode;
  final int collectionCount;
  final String petName;
  final String petType;
  final List<CollectionItem> collections;

  @override
  List<Object?> get props => [id, nickname, friendCode, collectionCount, petName, petType, collections];
}
