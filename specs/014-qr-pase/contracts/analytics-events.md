# Contract: analytics events (FR-015, FR-017, FR-018)

These are new `AnalyticsEmitter` methods. Their payloads are enums, booleans and integers only.
They never carry a pass payload, pass id, secret, flight number, route or date.

| Method | Event | Payload |
|---|---|---|
| `passDisplayed({checkpoint, offlineCapable})` | `pass_displayed` | `Checkpoint` name, bool |
| `passRotated({checkpoint})` | `pass_rotated` | `Checkpoint` name |
| `passValidated({checkpoint, secondsSinceOpened})` | `pass_validated` | `Checkpoint` name, int |
| `passUnavailable({reason})` | `pass_expired` | `PassUnavailableReason` name |
| `passReissueRequested({succeeded})` | `pass_reissue_requested` | bool |
| `passHelpOpened()` | `pass_help_opened` | none |

FR-018's time to validation is `pass_validated.secondsSinceOpened`.

A test asserts that every value fits these types, and that no value matches the payload prefix
`AP1`, a flight number or a date.
