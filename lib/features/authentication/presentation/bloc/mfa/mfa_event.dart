import 'package:equatable/equatable.dart';

abstract class MfaEvent extends Equatable {
  const MfaEvent();

  @override
  List<Object?> get props => [];
}

class CodeChanged extends MfaEvent {
  final String code;

  const CodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class SubmitPressed extends MfaEvent {
  const SubmitPressed();
}

class ResendPressed extends MfaEvent {
  const ResendPressed();
}
