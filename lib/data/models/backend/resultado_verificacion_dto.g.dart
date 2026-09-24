// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_verificacion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultadoVerificacionDto _$ResultadoVerificacionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ResultadoVerificacionDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'intento_id',
        'resultado',
        'motivo_fallo',
        'score_liveness',
        'score_comparacion',
        'estado_pasajero',
        'intentos_restantes',
        'identidad_id',
        'reintentar_en_segundos',
      ],
    );
    final val = ResultadoVerificacionDto(
      intentoId: $checkedConvert('intento_id', (v) => v as String),
      resultado: $checkedConvert(
        'resultado',
        (v) => $enumDecode(_$ResultadoIntentoWireEnumMap, v),
      ),
      motivoFallo: $checkedConvert(
        'motivo_fallo',
        (v) => $enumDecodeNullable(_$MotivoFalloWireEnumMap, v),
      ),
      scoreLiveness: $checkedConvert(
        'score_liveness',
        (v) => (v as num?)?.toDouble(),
      ),
      scoreComparacion: $checkedConvert(
        'score_comparacion',
        (v) => (v as num?)?.toDouble(),
      ),
      estadoPasajero: $checkedConvert(
        'estado_pasajero',
        (v) => $enumDecode(_$EstadoPasajeroWireEnumMap, v),
      ),
      intentosRestantes: $checkedConvert(
        'intentos_restantes',
        (v) => (v as num).toInt(),
      ),
      identidadId: $checkedConvert('identidad_id', (v) => v as String?),
      reintentarEnSegundos: $checkedConvert(
        'reintentar_en_segundos',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'intentoId': 'intento_id',
    'motivoFallo': 'motivo_fallo',
    'scoreLiveness': 'score_liveness',
    'scoreComparacion': 'score_comparacion',
    'estadoPasajero': 'estado_pasajero',
    'intentosRestantes': 'intentos_restantes',
    'identidadId': 'identidad_id',
    'reintentarEnSegundos': 'reintentar_en_segundos',
  },
);

const _$ResultadoIntentoWireEnumMap = {
  ResultadoIntentoWire.exitoso: 'EXITOSO',
  ResultadoIntentoWire.fallido: 'FALLIDO',
  ResultadoIntentoWire.noConcluyente: 'NO_CONCLUYENTE',
};

const _$MotivoFalloWireEnumMap = {
  MotivoFalloWire.liveness: 'LIVENESS',
  MotivoFalloWire.comparacion: 'COMPARACION',
};

const _$EstadoPasajeroWireEnumMap = {
  EstadoPasajeroWire.pendienteVerificacion: 'PENDIENTE_VERIFICACION',
  EstadoPasajeroWire.verificado: 'VERIFICADO',
  EstadoPasajeroWire.requiereRevisionManual: 'REQUIERE_REVISION_MANUAL',
};
