/// The three observable stages of a verification (007-validando,
/// data-model.md), always displayed in this order. The first two are
/// reported by the verification job; the third is the issuance call itself
/// (research.md §2).
enum VerificationStage { documentCheck, faceComparison, issuance }

/// What one checklist stage shows. Only a backend report can move a stage
/// to [passed] or [failed] (FR-003); elapsed time never does (FR-004).
enum StageStatus { pending, running, passed, failed }
