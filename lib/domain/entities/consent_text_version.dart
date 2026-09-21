import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_text_version.freezed.dart';

/// Decorative categorization of a [ConsentPoint], per data-model.md. The
/// icon never carries the point's actual meaning by itself — the
/// heading/body text does (FR-014-style "no icon-only meaning"), so this
/// is a plain closed enum rather than a payload-carrying sealed class, the
/// same modeling choice 001-bienvenida made for `ExpiryReason` and
/// `DeviceUnsupportedReason`.
enum ConsentPointIcon { camera, clock, share }

/// One of the gate's privacy points (the reference shows three; the app
/// does not hard-code that count — see data-model.md).
@freezed
sealed class ConsentPoint with _$ConsentPoint {
  const factory ConsentPoint({
    required ConsentPointIcon icon,
    required String heading,
    required String body,
  }) = _ConsentPoint;
}

/// The versioned, structured consent document fetched fresh every time the
/// gate is presented (research.md §5). **Never persisted** — a
/// `ConsentRecord` only ever stores this version's `id`, never its text
/// (Constitution Principle I minimization; data-model.md's "no entity here
/// is written to disk outside the single `ConsentRecord`").
@freezed
sealed class ConsentTextVersion with _$ConsentTextVersion {
  const factory ConsentTextVersion({
    /// The identifier a `ConsentRecord.textVersionId` references.
    required String id,

    /// Rendered in order (FR-002/FR-014).
    required List<ConsentPoint> points,

    /// FR-002: the passenger's rights over their data.
    required String rightsStatement,

    /// FR-003: that providing sensitive data is optional.
    required String optionalityStatement,

    /// FR-002: names the external processor performing verification
    /// (resolves the UI reference's undisclosed-processor gap).
    required String processorDisclosure,

    /// FR-012.
    required String privacyPolicyUrl,

    /// FR-012.
    required String termsUrl,

    /// Displayed if useful for FR-014's "what changed" framing; not
    /// otherwise used by app logic.
    required DateTime publishedAt,
  }) = _ConsentTextVersion;
}
