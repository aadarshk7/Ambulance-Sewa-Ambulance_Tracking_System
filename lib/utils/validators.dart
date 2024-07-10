class Validators {
  static bool isValidLicenseNumber(String licenseNumber) {
    RegExp regex = RegExp(r'^\d{2}-\d{2}-\d{7}$');
    return regex.hasMatch(licenseNumber);
  }
}
