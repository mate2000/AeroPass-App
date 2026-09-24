// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pase_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaseDto _$PaseDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PaseDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'credencial_id',
        'token',
        'codigo_vuelo',
        'permisos',
        'estado',
        'emitida_at',
        'expira_at',
        'renovar_en_segundos',
      ],
    );
    final val = PaseDto(
      credencialId: $checkedConvert('credencial_id', (v) => v as String),
      token: $checkedConvert('token', (v) => v as String),
      codigoVuelo: $checkedConvert('codigo_vuelo', (v) => v as String),
      permisos: $checkedConvert(
        'permisos',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      estado: $checkedConvert(
        'estado',
        (v) => $enumDecode(_$EstadoCredencialWireEnumMap, v),
      ),
      emitidaAt: $checkedConvert(
        'emitida_at',
        (v) => DateTime.parse(v as String),
      ),
      expiraAt: $checkedConvert(
        'expira_at',
        (v) => DateTime.parse(v as String),
      ),
      renovarEnSegundos: $checkedConvert(
        'renovar_en_segundos',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'credencialId': 'credencial_id',
    'codigoVuelo': 'codigo_vuelo',
    'emitidaAt': 'emitida_at',
    'expiraAt': 'expira_at',
    'renovarEnSegundos': 'renovar_en_segundos',
  },
);

const _$EstadoCredencialWireEnumMap = {
  EstadoCredencialWire.emitida: 'EMITIDA',
  EstadoCredencialWire.activa: 'ACTIVA',
  EstadoCredencialWire.consumida: 'CONSUMIDA',
  EstadoCredencialWire.expirada: 'EXPIRADA',
  EstadoCredencialWire.revocada: 'REVOCADA',
};
