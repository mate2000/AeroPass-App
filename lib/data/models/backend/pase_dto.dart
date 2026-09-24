import 'package:json_annotation/json_annotation.dart';

import 'backend_enums.dart';

part 'pase_dto.g.dart';

/// `PaseResponse`, from `POST /v1/passes` (015 contracts/backend-api.md).
/// [token] is the signed JWS rendered as the QR code. It exists only here,
/// in memory, and is never logged (FR-011, FR-017).
@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class PaseDto {
  PaseDto({
    required this.credencialId,
    required this.token,
    required this.codigoVuelo,
    required this.permisos,
    required this.estado,
    required this.emitidaAt,
    required this.expiraAt,
    required this.renovarEnSegundos,
  });

  factory PaseDto.fromJson(Map<String, dynamic> json) =>
      _$PaseDtoFromJson(json);

  @JsonKey(required: true)
  final String credencialId;
  @JsonKey(required: true)
  final String token;
  @JsonKey(required: true)
  final String codigoVuelo;
  @JsonKey(required: true)
  final List<String> permisos;
  @JsonKey(required: true)
  final EstadoCredencialWire estado;
  @JsonKey(required: true)
  final DateTime emitidaAt;
  @JsonKey(required: true)
  final DateTime expiraAt;
  @JsonKey(required: true)
  final int renovarEnSegundos;

  /// Never prints the token.
  @override
  String toString() => 'PaseDto($estado)';
}
