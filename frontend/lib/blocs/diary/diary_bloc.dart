import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/diary.dart';

// Events
abstract class DiaryEvent extends Equatable {
  const DiaryEvent();
  @override
  List<Object?> get props => [];
}

class LoadDiaries extends DiaryEvent {
  const LoadDiaries();
}

class AddDiary extends DiaryEvent {
  const AddDiary({required this.entry});
  final DiaryEntry entry;
  @override
  List<Object?> get props => [entry];
}

// States
abstract class DiaryState extends Equatable {
  const DiaryState();
  @override
  List<Object?> get props => [];
}

class DiaryInitial extends DiaryState {
  const DiaryInitial();
}

class DiaryLoaded extends DiaryState {
  const DiaryLoaded({required this.entries});
  final List<DiaryEntry> entries;
  @override
  List<Object?> get props => [entries];
}

// BLoC
class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  DiaryBloc() : super(const DiaryInitial()) {
    on<LoadDiaries>(_onLoad);
    on<AddDiary>(_onAdd);
  }

  static final List<DiaryEntry> mockEntries = [
    DiaryEntry(
      id: 'diary-001',
      speciesName: '무당벌레',
      title: '무당벌레 관찰일기',
      content: '올림픽공원 에서 무당벌레 을(를) 만났어요.\n무당벌레 은(는) 꽃 위에 앉아서 꿀을 먹고 있었어.\n생김새는 빨간색이고 검은 점이 7개 있었어.\n신기했던 점: 날개를 펼치니까 투명한 속날개가 보였어!',
      mood: 'surprised',
      createdAt: DateTime(2026, 2, 22),
    ),
  ];

  Future<void> _onLoad(LoadDiaries event, Emitter<DiaryState> emit) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    emit(DiaryLoaded(entries: List.from(mockEntries)));
  }

  Future<void> _onAdd(AddDiary event, Emitter<DiaryState> emit) async {
    mockEntries.insert(0, event.entry);
    emit(DiaryLoaded(entries: List.from(mockEntries)));
  }
}
