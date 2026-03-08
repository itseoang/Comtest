import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/friend.dart';
import '../../models/collection.dart';

// Events
abstract class FriendEvent extends Equatable {
  const FriendEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendEvent {
  const LoadFriends();
}

class AddFriend extends FriendEvent {
  const AddFriend({required this.friendCode});
  final String friendCode;
  @override
  List<Object?> get props => [friendCode];
}

// States
abstract class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {
  const FriendInitial();
}

class FriendLoaded extends FriendState {
  const FriendLoaded({required this.friends});
  final List<Friend> friends;
  @override
  List<Object?> get props => [friends];
}

class FriendAddSuccess extends FriendState {
  const FriendAddSuccess({required this.friends, required this.addedName});
  final List<Friend> friends;
  final String addedName;
  @override
  List<Object?> get props => [friends, addedName];
}

class FriendAddError extends FriendState {
  const FriendAddError({required this.friends, required this.message});
  final List<Friend> friends;
  final String message;
  @override
  List<Object?> get props => [friends, message];
}

// BLoC
class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc() : super(const FriendInitial()) {
    on<LoadFriends>(_onLoad);
    on<AddFriend>(_onAddFriend);
  }

  Future<void> _onLoad(LoadFriends event, Emitter<FriendState> emit) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(FriendLoaded(friends: [_testFriend]));
  }

  Future<void> _onAddFriend(AddFriend event, Emitter<FriendState> emit) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final currentFriends = List<Friend>.from(
      state is FriendLoaded
          ? (state as FriendLoaded).friends
          : state is FriendAddSuccess
              ? (state as FriendAddSuccess).friends
              : state is FriendAddError
                  ? (state as FriendAddError).friends
                  : [],
    );

    // 이미 친구인지 확인
    if (currentFriends.any((f) => f.friendCode == event.friendCode.toUpperCase())) {
      emit(FriendAddError(friends: currentFriends, message: '이미 친구입니다'));
      return;
    }

    // 코드로 친구 찾기
    if (event.friendCode.toUpperCase() == 'TREE99') {
      currentFriends.add(_testFriend2);
      emit(FriendAddSuccess(friends: currentFriends, addedName: _testFriend2.nickname));
    } else {
      emit(FriendAddError(friends: currentFriends, message: '친구를 찾을 수 없어요'));
    }
  }

  static final _testFriend = Friend(
    id: 'friend-001',
    nickname: '자연탐험가 민지',
    friendCode: 'MJ2026',
    collectionCount: 3,
    petName: '뭉치',
    petType: 'hamster',
    collections: [
      CollectionItem(
        id: 'fc-001',
        cardNumber: 'F001',
        speciesName: '벚나무',
        speciesCategory: 'plant',
        stats: const CardStats(hp: 45, attack: 30, defense: 55, speed: 20, charm: 70, rarityScore: 60),
        locationName: '여의도 한강공원',
        discoveredAt: DateTime(2026, 2, 20, 10, 30),
        weather: '🌸 맑음',
        notes: '벚꽃이 활짝 피어있었어요!',
      ),
      CollectionItem(
        id: 'fc-002',
        cardNumber: 'F002',
        speciesName: '참새',
        speciesCategory: 'bird',
        stats: const CardStats(hp: 35, attack: 40, defense: 25, speed: 75, charm: 50, rarityScore: 40),
        locationName: '학교 운동장',
        discoveredAt: DateTime(2026, 2, 28, 15, 20),
        weather: '☁️ 흐림',
        notes: '참새들이 떼로 모여있었어',
      ),
      CollectionItem(
        id: 'fc-003',
        cardNumber: 'F003',
        speciesName: '청개구리',
        speciesCategory: 'amphibian',
        stats: const CardStats(hp: 50, attack: 25, defense: 40, speed: 60, charm: 80, rarityScore: 75),
        locationName: '할머니 댁 논',
        discoveredAt: DateTime(2026, 3, 2, 11, 0),
        weather: '🌧️ 비',
        notes: '비 온 뒤에 나뭇잎 위에 있었어요',
      ),
    ],
  );

  static final _testFriend2 = Friend(
    id: 'friend-002',
    nickname: '숲속탐험가 준호',
    friendCode: 'TREE99',
    collectionCount: 2,
    petName: '솔이',
    petType: 'plant',
    collections: [
      CollectionItem(
        id: 'fc-004',
        cardNumber: 'F004',
        speciesName: '소나무',
        speciesCategory: 'plant',
        stats: const CardStats(hp: 60, attack: 20, defense: 70, speed: 15, charm: 55, rarityScore: 50),
        locationName: '북한산',
        discoveredAt: DateTime(2026, 3, 1, 9, 0),
        weather: '☀️ 맑음',
        notes: '소나무 향기가 좋았어요',
      ),
      CollectionItem(
        id: 'fc-005',
        cardNumber: 'F005',
        speciesName: '꿀벌',
        speciesCategory: 'insect',
        stats: const CardStats(hp: 30, attack: 45, defense: 20, speed: 80, charm: 65, rarityScore: 55),
        locationName: '학교 화단',
        discoveredAt: DateTime(2026, 2, 26, 14, 30),
        weather: '🌤️ 구름 조금',
        notes: '꽃에서 꿀을 모으고 있었어',
      ),
    ],
  );
}
