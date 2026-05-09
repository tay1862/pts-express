import 'package:test/test.dart';
import 'package:pts_express_mobile/core/models/parcel_models.dart';
import 'package:pts_express_mobile/core/models/parcel_status.dart';

void main() {
  test('maps parcel status api values', () {
    expect(ParcelStatus.fromApi('ARRIVED_IN_LAOS'), ParcelStatus.arrivedInLaos);
  });

  test('scan modes keep receive arrive pickup order', () {
    expect(ScanMode.values, [
      ScanMode.receive,
      ScanMode.arrive,
      ScanMode.pickup,
    ]);
  });

  test('public tracking history accepts status and toStatus keys', () {
    final withToStatus = ParcelEventSummary.fromJson({
      'eventType': 'STATUS_CHANGED',
      'toStatus': 'PICKED_UP',
      'happenedAt': '2026-05-09T09:00:00.000Z',
    });
    final withStatus = ParcelEventSummary.fromJson({
      'eventType': 'STATUS_CHANGED',
      'status': 'ARRIVED_IN_LAOS',
      'happenedAt': '2026-05-09T08:00:00.000Z',
    });

    expect(withToStatus.toStatus, ParcelStatus.pickedUp);
    expect(withStatus.toStatus, ParcelStatus.arrivedInLaos);
  });
}
