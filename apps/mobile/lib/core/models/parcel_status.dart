enum ParcelStatus {
  receivedInThailand('RECEIVED_IN_THAILAND'),
  arrivedInLaos('ARRIVED_IN_LAOS'),
  pickedUp('PICKED_UP');

  const ParcelStatus(this.apiValue);

  final String apiValue;

  String label(String languageCode) {
    final lao = languageCode == 'lo';
    return switch (this) {
      ParcelStatus.receivedInThailand => lao ? 'ຮັບແລ້ວທີ່ໄທ' : 'รับที่ไทยแล้ว',
      ParcelStatus.arrivedInLaos => lao ? 'ຮອດລາວແລ້ວ' : 'ถึงลาวแล้ว',
      ParcelStatus.pickedUp => lao ? 'ສົ່ງມອບແລ້ວ' : 'ส่งมอบแล้ว',
    };
  }

  static ParcelStatus fromApi(String value) => ParcelStatus.values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => ParcelStatus.receivedInThailand,
  );
}

enum ScanMode {
  receive,
  arrive,
  pickup;

  String label(String languageCode) {
    final lao = languageCode == 'lo';
    return switch (this) {
      ScanMode.receive => lao ? 'ຮັບທີ່ໄທ' : 'รับไทย',
      ScanMode.arrive => lao ? 'ເຂົ້າສາງລາວ' : 'ถึงลาว',
      ScanMode.pickup => lao ? 'ສົ່ງມອບ' : 'ส่งมอบ',
    };
  }
}
