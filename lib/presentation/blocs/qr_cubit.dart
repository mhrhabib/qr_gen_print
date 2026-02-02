import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/qr_config.dart';
import 'package:equatable/equatable.dart';

class QrState extends Equatable {
  final QrConfig config;
  final int step;
  final bool isPurchased;

  const QrState({this.config = const QrConfig(), this.step = 1, this.isPurchased = false});

  QrState copyWith({QrConfig? config, int? step, bool? isPurchased}) {
    return QrState(
      config: config ?? this.config,
      step: step ?? this.step,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  @override
  List<Object?> get props => [config, step, isPurchased];
}

class QrCubit extends Cubit<QrState> {
  QrCubit() : super(const QrState());

  void updateConfig(QrConfig config) {
    emit(state.copyWith(config: config));
  }

  void nextStep() {
    if (state.step < 2) {
      emit(state.copyWith(step: state.step + 1));
    }
  }

  void previousStep() {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }

  void setPurchased(bool purchased) {
    emit(state.copyWith(isPurchased: purchased));
  }
}
