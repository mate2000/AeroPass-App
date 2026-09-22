# Specification Quality Checklist: Liveness Capture (06 Selfie · liveness)

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-22
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Both [NEEDS CLARIFICATION] markers in the input were resolved directly from existing project
  precedent, without a formal question round: screenshot/recording blocking (not applied,
  mirroring 003/004's identical decision) and the failed-attempt limit (3, separate from document
  capture's counter, mirroring 003's own limit and its constitutional basis, which is already
  worded generically enough to cover this screen's counter without a fresh amendment).
- A third, genuinely non-obvious gap surfaced in `/speckit-clarify`: FR-010's original wording
  ("indistinguishable from other failures") didn't specify *which* other failures, and if attack
  detection were the only source of a generic message, the genericness itself would be the tell.
  Resolved by requiring the generic message be shared verbatim with a legitimate "unclassified
  quality failure" outcome — see the Clarifications section and the updated FR-009/FR-010/Key
  Entities.
- FR-002 / "the device never decides liveness" is this spec's most consequential requirement — it
  is a security boundary, not a UX preference, and is carried into the Delivery Mode section's
  "not relaxable, in any mode" list twice (once generally, once screen-specific) to make it hard to
  miss during planning and implementation.
- `/speckit-plan` will need to confirm the exact shape of the new attempt-counter persisted state
  against Constitution Principle I's allowlist wording, and should treat FR-013's 45-second stall
  assumption as adjustable once the processor's real contract is known.
