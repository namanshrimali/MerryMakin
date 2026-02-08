class OtpRequestDTO {
  final String areaCode;
  final String phoneNumber;

  OtpRequestDTO({required this.areaCode, required this.phoneNumber});

  Map<String, dynamic> toMap() {
    return {'areaCode': areaCode, 'phoneNumber': phoneNumber};
  }

  String toString() {
    return 'areaCode: $areaCode, phoneNumber: $phoneNumber';
  }
}