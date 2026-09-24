// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_pase_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetallePaseDto _$DetallePaseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DetallePaseDto',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'credencial_id',
            'codigo_vuelo',
            'estado',
            'emitida_at',
            'expira_at',
            'historial',
          ],
        );
        final val = DetallePaseDto(
          credencialId: $checkedConvert('credencial_id', (v) => v as String),
          codigoVuelo: $checkedConvert('codigo_vuelo', (v) => v as String),
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
          historial: $checkedConvert(
            'historial',
            (v) => (v as List<dynamic>)
                .map((e) => TransicionDto.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'credencialId': 'credencial_id',
        'codigoVuelo': 'codigo_vuelo',
        'emitidaAt': 'emitida_at',
        'expiraAt': 'expira_at',
      },
    );

const _$EstadoCredencialWireEnumMap = {
  EstadoCredencialWire.emitida: 'EMITIDA',
  EstadoCredencialWire.activa: 'ACTIVA',
  EstadoCredencialWire.consumida: 'CONSUMIDA',
  EstadoCredencialWire.expirada: 'EXPIRADA',
  EstadoCredencialWire.revocada: 'REVOCADA',
};

TransicionDto _$TransicionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TransicionDto',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'estado_anterior',
            'estado_solicitado',
            'aceptada',
            'motivo',
            'created_at',
          ],
        );
        final val = TransicionDto(
          estadoAnterior: $checkedConvert(
            'estado_anterior',
            (v) => $enumDecodeNullable(_$EstadoCredencialWireEnumMap, v),
          ),
          estadoSolicitado: $checkedConvert(
            'estado_solicitado',
            (v) => $enumDecode(_$EstadoCredencialWireEnumMap, v),
          ),
          aceptada: $checkedConvert('aceptada', (v) => v as bool),
          motivo: $checkedConvert('motivo', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'estadoAnterior': 'estado_anterior',
        'estadoSolicitado': 'estado_solicitado',
        'createdAt': 'created_at',
      },
    );
