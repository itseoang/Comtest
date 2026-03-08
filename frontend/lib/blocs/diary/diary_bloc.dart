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

class AddDiaryImage extends DiaryEvent {
  const AddDiaryImage({required this.diaryId, required this.imagePath});
  final String diaryId;
  final String imagePath;
  @override
  List<Object?> get props => [diaryId, imagePath];
}

class AddGuardianComment extends DiaryEvent {
  const AddGuardianComment({
    required this.diaryId,
    required this.authorName,
    required this.content,
  });
  final String diaryId;
  final String authorName;
  final String content;
  @override
  List<Object?> get props => [diaryId, authorName, content];
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
    on<AddDiaryImage>(_onAddImage);
    on<AddGuardianComment>(_onAddGuardianComment);
  }

  static final List<DiaryEntry> mockEntries = [
    DiaryEntry(
      id: 'diary-001',
      speciesName: '무당벌레',
      speciesCategory: 'insect',
      title: '무당벌레 관찰일기',
      content: '올림픽공원 에서 무당벌레 을(를) 만났어요.\n무당벌레 은(는) 꽃 위에 앉아서 꿀을 먹고 있었어.\n생김새는 빨간색이고 검은 점이 7개 있었어.\n신기했던 점: 날개를 펼치니까 투명한 속날개가 보였어!',
      mood: 'surprised',
      createdAt: DateTime(2026, 2, 22),
      location: '올림픽공원',
      latitude: 37.5209,
      longitude: 127.1237,
      companion: '엄마',
      guardianComments: [
        GuardianComment(
          id: 'gc-001',
          authorName: '엄마',
          content: '무당벌레를 잘 관찰했구나! 날개 속에 투명한 속날개가 있다는 걸 발견한 거 정말 대단해 👏',
          createdAt: DateTime(2026, 2, 22, 20, 30),
        ),
      ],
    ),
    DiaryEntry(
      id: 'diary-002',
      speciesName: '진달래',
      speciesCategory: 'plant',
      title: '진달래 관찰일기',
      content: '북한산 에서 진달래 을(를) 만났어요.\n진달래 은(는) 산 중턱에서 예쁘게 피어 있었어.\n생김새는 분홍색 꽃잎이 다섯 장이었어.',
      mood: 'happy',
      createdAt: DateTime(2026, 2, 15),
      location: '북한산',
      latitude: 37.6610,
      longitude: 126.9880,
      companion: '아빠, 누나',
    ),
    DiaryEntry(
      id: 'diary-003',
      speciesName: '다람쥐',
      speciesCategory: 'mammal',
      title: '다람쥐 관찰일기',
      content: '남산공원 에서 다람쥐 을(를) 만났어요.\n다람쥐 은(는) 도토리를 양 볼에 가득 물고 있었어.\n생김새는 갈색 줄무늬가 등에 있었어.\n신기했던 점: 나무를 엄청 빨리 올라갔어!',
      mood: 'curious',
      createdAt: DateTime(2026, 2, 25),
      location: '남산공원',
      latitude: 37.5512,
      longitude: 126.9882,
      companion: '친구 민수',
      guardianComments: [
        GuardianComment(
          id: 'gc-002',
          authorName: '엄마',
          content: '다람쥐가 도토리를 볼에 물고 있는 모습을 잘 묘사했어! 자연 관찰력이 점점 좋아지고 있구나 🌟',
          createdAt: DateTime(2026, 2, 26, 19, 0),
        ),
      ],
    ),
    DiaryEntry(
      id: 'diary-004',
      speciesName: '은행나무',
      speciesCategory: 'plant',
      title: '은행나무 관찰일기',
      content: '덕수궁 에서 은행나무 을(를) 만났어요.\n은행나무 은(는) 아직 잎이 안 났지만 가지가 멋있었어.\n생김새는 키가 엄청 크고 가지가 넓게 퍼져 있었어.',
      mood: 'calm',
      createdAt: DateTime(2026, 3, 1),
      location: '덕수궁',
      latitude: 37.5659,
      longitude: 126.9750,
      companion: '할머니',
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

  Future<void> _onAddImage(AddDiaryImage event, Emitter<DiaryState> emit) async {
    final index = mockEntries.indexWhere((e) => e.id == event.diaryId);
    if (index != -1) {
      mockEntries[index] = mockEntries[index].copyWith(imagePath: event.imagePath);
      emit(DiaryLoaded(entries: List.from(mockEntries)));
    }
  }

  Future<void> _onAddGuardianComment(
    AddGuardianComment event,
    Emitter<DiaryState> emit,
  ) async {
    final index = mockEntries.indexWhere((e) => e.id == event.diaryId);
    if (index != -1) {
      final newComment = GuardianComment(
        id: 'gc-${DateTime.now().millisecondsSinceEpoch}',
        authorName: event.authorName,
        content: event.content,
        createdAt: DateTime.now(),
      );
      final updatedComments = List<GuardianComment>.from(
        mockEntries[index].guardianComments,
      )..add(newComment);
      mockEntries[index] = mockEntries[index].copyWith(
        guardianComments: updatedComments,
      );
      emit(DiaryLoaded(entries: List.from(mockEntries)));
    }
  }
}
