import 'package:json_annotation/json_annotation.dart';

// Wire enums of the AeroPass backend (`src/aeropass/domain/enums.py`,
// 015 contracts/backend-api.md). An unknown value fails the parse, so a
// backend enum change breaks the contract test rather than a passenger
// (FR-019). They never leave `lib/data/`.

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TipoDocumentoWire { cc, ce, pasaporte }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EstadoPasajeroWire {
  pendienteVerificacion,
  verificado,
  requiereRevisionManual,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ResultadoIntentoWire { exitoso, fallido, noConcluyente }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum MotivoFalloWire { liveness, comparacion }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EstadoCredencialWire { emitida, activa, consumida, expirada, revocada }
