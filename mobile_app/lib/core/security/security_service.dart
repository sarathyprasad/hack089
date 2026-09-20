/// Mobile Security & Data Protection Service for Prithvi Fix.
/// Complies with Indian Digital Personal Data Protection (DPDP) Act standards.
class SecurityService {
  /// Masks a 12-digit Indian Aadhaar number.
  /// Example: '548912349812' -> 'XXXX-XXXX-9812'
  static String maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.isEmpty) return 'XXXX-XXXX-XXXX';
    final digits = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return 'XXXX-XXXX-XXXX';
    return 'XXXX-XXXX-${digits.substring(digits.length - 4)}';
  }

  /// Masks a 10-character Indian PAN number.
  /// Example: 'ABCDE1234F' -> 'XXXXX1234F'
  static String maskPan(String? pan) {
    if (pan == null || pan.trim().isEmpty) return 'XXXXXXXXXX';
    final clean = pan.trim().toUpperCase();
    if (clean.length < 5) return 'XXXXXXXXXX';
    return 'XXXXX${clean.substring(clean.length - 5)}';
  }

  /// Masks a Bank Account Number.
  /// Example: '918237461928' -> 'XXXXXX1928'
  static String maskBankAccount(String? acc) {
    if (acc == null || acc.isEmpty) return 'XXXXXXXX';
    final digits = acc.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return 'XXXXXXXX';
    return 'XXXXXX${digits.substring(digits.length - 4)}';
  }

  /// Masks an Indian mobile phone number for public listings.
  /// Example: '9876543210' -> '+91 XXXXX-XX210'
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '+91 XXXXX-XXXXX';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3) return '+91 XXXXX-XXXXX';
    return '+91 XXXXX-XX${digits.substring(digits.length - 3)}';
  }

  /// Verifies whether an entered OTP candidate is well-formed (strictly 4 digits).
  static bool isValidOtp(String otp) {
    return RegExp(r'^\d{4}$').hasMatch(otp.trim());
  }

  /// Returns user-facing security reminder for arrival / completion handshakes.
  static String getOtpSecurityNotice({required bool isArrival}) {
    if (isArrival) {
      return '⚠️ Share this Arrival OTP with the artisan ONLY when they are physically present at your doorstep.';
    }
    return '🔒 Furnish this Completion OTP ONLY after you have thoroughly inspected and are fully satisfied with the repair.';
  }
}
