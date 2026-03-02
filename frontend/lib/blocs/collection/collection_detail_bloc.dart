import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../config/constants.dart';
import '../../models/collection.dart';
import '../../utils/stats_calculator.dart';
import 'collection_bloc.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class CollectionDetailEvent extends Equatable {
  const CollectionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionDetail extends CollectionDetailEvent {
  const LoadCollectionDetail({required this.collectionId});

  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}

class WriteDiary extends CollectionDetailEvent {
  const WriteDiary({
    required this.title,
    required this.textContent,
    required this.mood,
    required this.collectionId,
  });

  final String title;
  final String textContent;
  final String mood;
  final String collectionId;

  @override
  List<Object?> get props => [title, textContent, mood, collectionId];
}

class DismissBoostResult extends CollectionDetailEvent {
  const DismissBoostResult();
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class CollectionDetailState extends Equatable {
  const CollectionDetailState();

  @override
  List<Object?> get props => [];
}

class CollectionDetailInitial extends CollectionDetailState {
  const CollectionDetailInitial();
}

class CollectionDetailLoading extends CollectionDetailState {
  const CollectionDetailLoading();
}

class CollectionDetailLoaded extends CollectionDetailState {
  const CollectionDetailLoaded({
    required this.item,
    this.boostResult,
  });

  final CollectionItem item;
  final StatsBoostResult? boostResult;

  CollectionDetailLoaded copyWith({
    CollectionItem? item,
    StatsBoostResult? boostResult,
    bool clearBoostResult = false,
  }) {
    return CollectionDetailLoaded(
      item: item ?? this.item,
      boostResult: clearBoostResult ? null : (boostResult ?? this.boostResult),
    );
  }

  @override
  List<Object?> get props => [item, boostResult];
}

class CollectionDetailError extends CollectionDetailState {
  const CollectionDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class CollectionDetailBloc
    extends Bloc<CollectionDetailEvent, CollectionDetailState> {
  CollectionDetailBloc({required CollectionBloc collectionBloc})
      : _collectionBloc = collectionBloc,
        super(const CollectionDetailInitial()) {
    on<LoadCollectionDetail>(_onLoadCollectionDetail);
    on<WriteDiary>(_onWriteDiary);
    on<DismissBoostResult>(_onDismissBoostResult);
  }

  final CollectionBloc _collectionBloc;

  Future<void> _onLoadCollectionDetail(
    LoadCollectionDetail event,
    Emitter<CollectionDetailState> emit,
  ) async {
    emit(const CollectionDetailLoading());
    try {
      if (AppConstants.devMode) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        final item = CollectionBloc.mockData.firstWhere(
          (i) => i.id == event.collectionId,
          orElse: () => throw Exception('컬렉션을 찾을 수 없습니다: ${event.collectionId}'),
        );
        emit(CollectionDetailLoaded(item: item));
        return;
      }
      // TODO: 실제 API 호출 구현
      emit(const CollectionDetailError(message: '아직 구현되지 않았습니다.'));
    } catch (e) {
      emit(CollectionDetailError(message: e.toString()));
    }
  }

  Future<void> _onWriteDiary(
    WriteDiary event,
    Emitter<CollectionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CollectionDetailLoaded) return;

    try {
      final boostResult = StatsCalculator.calculateBoost(currentState.item.stats);

      if (AppConstants.devMode) {
        // mockData에서 해당 항목 스탯 교체
        final index = CollectionBloc.mockData
            .indexWhere((i) => i.id == event.collectionId);
        if (index != -1) {
          CollectionBloc.mockData[index] =
              CollectionBloc.mockData[index].copyWith(
            stats: boostResult.afterStats,
          );
        }

        // CollectionBloc에 스탯 갱신 알림
        _collectionBloc.add(
          UpdateCollectionStats(
            collectionId: event.collectionId,
            newStats: boostResult.afterStats,
          ),
        );
      }

      final updatedItem = currentState.item.copyWith(stats: boostResult.afterStats);
      emit(CollectionDetailLoaded(item: updatedItem, boostResult: boostResult));
    } catch (e) {
      emit(CollectionDetailError(message: e.toString()));
    }
  }

  void _onDismissBoostResult(
    DismissBoostResult event,
    Emitter<CollectionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is CollectionDetailLoaded) {
      emit(currentState.copyWith(clearBoostResult: true));
    }
  }
}
