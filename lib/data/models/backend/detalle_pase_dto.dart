import 'package:json_annotation/json_annotation.dart';

import 'backend_enums.dart';

part 'detalle_pase_dto.g.dart';

/// `DetallePaseResponse`, from `GET /v1/passes/{credencial_id}` (015
/// contracts/backend-api.md). It carries no token. The app reads [estado]
/// to detect `CONSUMIDA`, `EXPIRADA` and `REVOCADA`; [historial] is parsed
/// for the contract test only.
@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class DetallePaseDto {
  DetallePaseDto({
    required this.credencialId,
    required this.codigoVuelo,
    required this.estado,
    required this.emitidaAt,
    required this.expiraAt,
    required this.historial,
  });

  factory DetallePaseDto.fromJson(Map<String, dynamic> json) =>
      _$DetallePaseDtoFromJson(json);

  @JsonKey(required: true)
  final String credencialId;
  @JsonKey(required: true)
  final String codigoVuelo;
  @JsonKey(required: true)
  final EstadoCredencialWire estado;
  @JsonKey(required: true)
  final DateTime emitidaAt;
  @JsonKey(required: true)
  final DateTime expiraAt;
  @JsonKey(required: true)
  final List<TransicionDto> historial;
}

/// `TransicionResponse`: one credential state transition.
@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class TransicionDto {
  TransicionDto({
    required this.estadoAnterior,
    required this.estadoSolicitado,
    required this.aceptada,
    required this.motivo,
    required this.createdAt,
  });

  factory TransicionDto.fromJson(Map<String, dynamic> json) =>
      _$TransicionDtoFromJson(json);

  @JsonKey(required: true)
  final EstadoCredencialWire? estadoAnterior;
  @JsonKey(required: true)
  final EstadoCredencialWire estadoSolicitado;
  @JsonKey(required: true)
  final bool aceptada;
  @JsonKey(required: true)
  final String? motivo;
  @JsonKey(required: true)
  final DateTime createdAt;
}
