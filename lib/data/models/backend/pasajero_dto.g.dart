// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pasajero_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasajeroDto _$PasajeroDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PasajeroDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'nombre_completo',
        'tipo_documento',
        'numero_documento_enmascarado',
        'fecha_vencimiento',
        'estado',
        'intentos_fallidos',
        'identidad_id',
      ],
    );
    final val = PasajeroDto(
      id: $checkedConvert('id', (v) => v as String),
      nombreCompleto: $checkedConvert('nombre_completo', (v) => v as String),
      tipoDocumento: $checkedConvert(
        'tipo_documento',
        (v) => $enumDecode(_$TipoDocumentoWireEnumMap, v),
      ),
      numeroDocumentoEnmascarado: $checkedConvert(
        'numero_documento_enmascarado',
        (v) => v as String,
      ),
      fechaVencimiento: $checkedConvert(
        'fecha_vencimiento',
        (v) => DateTime.parse(v as String),
      ),
      estado: $checkedConvert(
        'estado',
        (v) => $enumDecode(_$EstadoPasajeroWireEnumMap, v),
      ),
      intentosFallidos: $checkedConvert(
        'intentos_fallidos',
        (v) => (v as num).toInt(),
      ),
      identidadId: $checkedConvert('identidad_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'nombreCompleto': 'nombre_completo',
    'tipoDocumento': 'tipo_documento',
    'numeroDocumentoEnmascarado': 'numero_documento_enmascarado',
    'fechaVencimiento': 'fecha_vencimiento',
    'intentosFallidos': 'intentos_fallidos',
    'identidadId': 'identidad_id',
  },
);

const _$TipoDocumentoWireEnumMap = {
  TipoDocumentoWire.cc: 'CC',
  TipoDocumentoWire.ce: 'CE',
  TipoDocumentoWire.pasaporte: 'PASAPORTE',
};

const _$EstadoPasajeroWireEnumMap = {
  EstadoPasajeroWire.pendienteVerificacion: 'PENDIENTE_VERIFICACION',
  EstadoPasajeroWire.verificado: 'VERIFICADO',
  EstadoPasajeroWire.requiereRevisionManual: 'REQUIERE_REVISION_MANUAL',
};
