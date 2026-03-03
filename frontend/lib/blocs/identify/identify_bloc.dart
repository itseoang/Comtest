import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/species_classifier.dart';

// Events
abstract class IdentifyEvent extends Equatable {
  const IdentifyEvent();
  @override
  List<Object?> get props => [];
}

class IdentifyImage extends IdentifyEvent {
  const IdentifyImage({required this.imageFile});
  final File imageFile;
  @override
  List<Object?> get props => [imageFile];
}

class ResetIdentify extends IdentifyEvent {
  const ResetIdentify();
}

// States
abstract class IdentifyState extends Equatable {
  const IdentifyState();
  @override
  List<Object?> get props => [];
}

class IdentifyInitial extends IdentifyState {
  const IdentifyInitial();
}

class IdentifyLoading extends IdentifyState {
  const IdentifyLoading();
}

class IdentifySuccess extends IdentifyState {
  const IdentifySuccess({
    required this.imageFile,
    required this.results,
  });
  final File imageFile;
  final List<ClassificationResult> results;
  @override
  List<Object?> get props => [imageFile, results];
}

class IdentifyError extends IdentifyState {
  const IdentifyError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

// BLoC
class IdentifyBloc extends Bloc<IdentifyEvent, IdentifyState> {
  IdentifyBloc() : super(const IdentifyInitial()) {
    on<IdentifyImage>(_onIdentify);
    on<ResetIdentify>(_onReset);
    _classifier.init();
  }

  final _classifier = SpeciesClassifier();

  Future<void> _onIdentify(
    IdentifyImage event,
    Emitter<IdentifyState> emit,
  ) async {
    emit(const IdentifyLoading());
    try {
      final results = await _classifier.classifyImage(event.imageFile);
      emit(IdentifySuccess(imageFile: event.imageFile, results: results));
    } catch (e) {
      emit(IdentifyError(message: e.toString()));
    }
  }

  void _onReset(ResetIdentify event, Emitter<IdentifyState> emit) {
    emit(const IdentifyInitial());
  }

  @override
  Future<void> close() {
    _classifier.dispose();
    return super.close();
  }
}
