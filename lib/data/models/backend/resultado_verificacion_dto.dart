import 'package:json_annotation/json_annotation.dart';

import 'backend_enums.dart';

part 'resultado_verificacion_dto.g.dart';

/// `ResultadoVerificacionResponse`, from `POST /v1/biometrics/verifications`
/// (015 contracts/backend-api.md).
///
/// The two scores are parsed only so the contract test covers them. The
/// mapper drops them: no domain type has a score field (FR-007).
@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class ResultadoVerificacionDto {
  ResultadoVerificacionDto({
    required this.intentoId,
    required this.resultado,
    required this.motivoFallo,
    required this.scoreLiveness,
    required this.scoreComparacion,
    required this.estadoPasajero,
    required this.intentosRestantes,
    required this.identidadId,
    required this.reintentarEnSegundos,
  });

  factory ResultadoVerificacionDto.fromJson(Map<String, dynamic> json) =>
      _$ResultadoVerificacionDtoFromJson(json);

  @JsonKey(required: true)
  final String intentoId;
  @JsonKey(required: true)
  final ResultadoIntentoWire resultado;
  @JsonKey(required: true)
  final MotivoFalloWire? motivoFallo;
  @JsonKey(required: true)
  final double? scoreLiveness;
  @JsonKey(required: true)
  final double? scoreComparacion;
  @JsonKey(required: true)
  final EstadoPasajeroWire estadoPasajero;
  @JsonKey(required: true)
  final int intentosRestantes;
  @JsonKey(required: true)
  final String? identidadId;
  @JsonKey(required: true)
  final int? reintentarEnSegundos;
}
