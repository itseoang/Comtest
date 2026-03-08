import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../config/constants.dart';
import '../../models/collection.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollections extends CollectionEvent {
  const LoadCollections();
}

class UpdateCollectionStats extends CollectionEvent {
  const UpdateCollectionStats({
    required this.collectionId,
    required this.newStats,
  });

  final String collectionId;
  final CardStats newStats;

  @override
  List<Object?> get props => [collectionId, newStats];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionLoaded extends CollectionState {
  const CollectionLoaded({required this.items});

  final List<CollectionItem> items;

  @override
  List<Object?> get props => [items];
}

class CollectionError extends CollectionState {
  const CollectionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc() : super(const CollectionInitial()) {
    on<LoadCollections>(_onLoadCollections);
    on<UpdateCollectionStats>(_onUpdateCollectionStats);
  }

  /// devMode mock 데이터 (mutable — 일기 작성 후 스탯 갱신 가능)
  static final List<CollectionItem> mockData = [
    CollectionItem(
      id: 'col-001',
      cardNumber: '#001',
      speciesName: '진달래',
      speciesCategory: 'plant',
      stats: const CardStats(
        hp: 45,
        attack: 20,
        defense: 60,
        speed: 15,
        charm: 70,
        rarityScore: 55,
      ),
      locationName: '북한산',
      discoveredAt: DateTime(2026, 2, 15, 14, 30),
      weather: '☀️ 맑음',
      latitude: 37.6610,
      longitude: 126.9880,
    ),
    CollectionItem(
      id: 'col-002',
      cardNumber: '#002',
      speciesName: '청딱따구리',
      speciesCategory: 'bird',
      stats: const CardStats(
        hp: 50,
        attack: 55,
        defense: 40,
        speed: 75,
        charm: 60,
        rarityScore: 62,
      ),
      locationName: '광릉수목원',
      discoveredAt: DateTime(2026, 2, 20, 10, 15),
      weather: '⛅ 구름 조금',
      latitude: 37.7484,
      longitude: 127.1654,
    ),
    CollectionItem(
      id: 'col-003',
      cardNumber: '#003',
      speciesName: '무당벌레',
      speciesCategory: 'insect',
      stats: const CardStats(
        hp: 30,
        attack: 35,
        defense: 25,
        speed: 65,
        charm: 80,
        rarityScore: 48,
      ),
      locationName: '올림픽공원',
      discoveredAt: DateTime(2026, 2, 22, 11, 45),
      weather: '☀️ 맑음',
      latitude: 37.5209,
      longitude: 127.1237,
    ),
    CollectionItem(
      id: 'col-004',
      cardNumber: '#004',
      speciesName: '다람쥐',
      speciesCategory: 'mammal',
      stats: const CardStats(
        hp: 55,
        attack: 40,
        defense: 45,
        speed: 70,
        charm: 65,
        rarityScore: 58,
      ),
      locationName: '남산공원',
      discoveredAt: DateTime(2026, 2, 25, 15, 20),
      weather: '🌤️ 대체로 맑음',
      latitude: 37.5512,
      longitude: 126.9882,
    ),
    CollectionItem(
      id: 'col-005',
      cardNumber: '#005',
      speciesName: '도롱뇽',
      speciesCategory: 'amphibian',
      stats: const CardStats(
        hp: 40,
        attack: 30,
        defense: 35,
        speed: 45,
        charm: 50,
        rarityScore: 42,
      ),
      locationName: '청계산',
      discoveredAt: DateTime(2026, 2, 28, 9, 0),
      weather: '🌧️ 비',
      latitude: 37.4370,
      longitude: 127.0550,
    ),
    CollectionItem(
      id: 'col-006',
      cardNumber: '#006',
      speciesName: '은행나무',
      speciesCategory: 'plant',
      stats: const CardStats(
        hp: 70,
        attack: 15,
        defense: 80,
        speed: 10,
        charm: 75,
        rarityScore: 65,
      ),
      locationName: '덕수궁',
      discoveredAt: DateTime(2026, 3, 1, 16, 10),
      weather: '☁️ 흐림',
      latitude: 37.5659,
      longitude: 126.9750,
    ),
  ];

  Future<void> _onLoadCollections(
    LoadCollections event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());
    try {
      if (AppConstants.devMode) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        emit(CollectionLoaded(items: List.unmodifiable(mockData)));
        return;
      }
      // TODO: 실제 API 호출 구현
      emit(const CollectionError(message: '아직 구현되지 않았습니다.'));
    } catch (e) {
      emit(CollectionError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCollectionStats(
    UpdateCollectionStats event,
    Emitter<CollectionState> emit,
  ) async {
    final index = mockData.indexWhere((item) => item.id == event.collectionId);
    if (index != -1) {
      mockData[index] = mockData[index].copyWith(stats: event.newStats);
    }
    emit(CollectionLoaded(items: List.unmodifiable(mockData)));
  }
}
