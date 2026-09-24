import 'package:json_annotation/json_annotation.dart';

import 'backend_enums.dart';

part 'pasajero_dto.g.dart';

/// `PasajeroResponse`, from `POST /v1/identity` and `GET /v1/identity/me`
/// (015 contracts/backend-api.md). Every key is required, so a renamed field
/// fails the parse and names itself (FR-019). Never leaves `lib/data/`.
@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class PasajeroDto {
  PasajeroDto({
    required this.id,
    required this.nombreCompleto,
    required this.tipoDocumento,
    required this.numeroDocumentoEnmascarado,
    required this.fechaVencimiento,
    required this.estado,
    required this.intentosFallidos,
    required this.identidadId,
  });

  factory PasajeroDto.fromJson(Map<String, dynamic> json) =>
      _$PasajeroDtoFromJson(json);

  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final String nombreCompleto;
  @JsonKey(required: true)
  final TipoDocumentoWire tipoDocumento;

  /// Already masked by the backend (`******4050`). The app never sees, and
  /// never reconstructs, the full number (FR-004).
  @JsonKey(required: true)
  final String numeroDocumentoEnmascarado;
  @JsonKey(required: true)
  final DateTime fechaVencimiento;
  @JsonKey(required: true)
  final EstadoPasajeroWire estado;
  @JsonKey(required: true)
  final int intentosFallidos;
  @JsonKey(required: true)
  final String? identidadId;
}
