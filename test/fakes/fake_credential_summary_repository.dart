import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';

/// Scripted `CredentialSummaryRepository` (012-mis-viajes). Each read takes
/// the next scripted result, then repeats the last one.
class FakeCredentialSummaryRepository implements CredentialSummaryRepository {
  FakeCredentialSummaryRepository([Result<CredentialSummary>? initial]) {
    if (initial != null) _last = initial;
  }

  final List<Result<CredentialSummary>> _queue = [];
  Result<CredentialSummary>? _last;
  int callCount = 0;

  static const confirmedActive = CredentialSummary(
    holderName: 'Mateo González',
    documentLast4: '4821',
    state: CredentialDisplayState.active,
    confirmed: true,
  );

  void scriptResults(List<Result<CredentialSummary>> results) {
    _queue
      ..clear()
      ..addAll(results);
  }

  @override
  Future<Result<CredentialSummary>> getSummary() async {
    callCount++;
    if (_queue.isNotEmpty) _last = _queue.removeAt(0);
    return _last ??
        Result.error(
          StateError('FakeCredentialSummaryRepository: nothing scripted'),
        );
  }
}
