import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;

  const factory Failure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  const factory Failure.database({
    required String message,
  }) = DatabaseFailure;

  const factory Failure.ai({
    required String message,
    String? provider,
  }) = AIFailure;

  const factory Failure.storage({
    required String message,
  }) = StorageFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}
