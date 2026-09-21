# Contract: `DocumentQualityAssessor`

## Interface

```text
abstract class DocumentQualityAssessor {
  QualityAssessment assess(Uint8List frameBytes);
}
```

Synchronous and on-device (research.md §2) — no `Future`, no network, no I/O. Deliberately not
named `...Repository` — it has no state, no persistence, and isn't a source of truth for anything;
it's a pure function over a frame's bytes, closer to a domain service than a repository.

## Contract test suite

Run against the fake (scripted) and the real heuristic implementation. The real implementation's
cases use small fixture images checked into `test/fixtures/` (synthetic, not real documents).

1. A sharp, well-lit, correctly-framed cédula-shaped fixture → `usable`.
2. A heavily blurred fixture → `rejected(blur)`.
3. A fixture with a large blown-out highlight region → `rejected(glare)`.
4. A fixture cropped at the frame edge → `rejected(framing)`.
5. A fixture with a shape matching neither accepted document ratio → `rejected(wrongDocument)`.
6. A fixture below the minimum resolution floor → `rejected(lowResolution)`.

## Fake implementation

`FakeDocumentQualityAssessor` — returns a pre-scripted `QualityAssessment` regardless of input
bytes, for widget/unit tests that don't care about the real heuristic's behavior, only about how
`CaptureViewModel` reacts to each outcome.

## Real implementation

`HeuristicQualityAssessor` (research.md §2) — no dependency on `DocumentVerificationRepository` or
any network-facing type; testable fully offline, in a plain Dart unit test, with no widget pump
required.
