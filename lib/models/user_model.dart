/// The account as the profile form edits it.
class UserModel {
  const UserModel({
    this.name = '',
    this.email = '',
    this.currencyCode = 'USD',
    this.dailyLimit = 0,
    this.pin = '',
  });

  final String name;
  final String email;
  final String currencyCode;
  final double dailyLimit;

  /// Stored so the pin screen can verify it; never leaves the device.
  final String pin;

  bool get isComplete =>
      name.isNotEmpty && email.isNotEmpty && dailyLimit > 0 && pin.length >= 4;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? 'USD',
      dailyLimit: (json['daily_limit'] as num?)?.toDouble() ?? 0,
      pin: json['pin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'currency_code': currencyCode,
        'daily_limit': dailyLimit,
        'pin': pin,
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? currencyCode,
    double? dailyLimit,
    String? pin,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      pin: pin ?? this.pin,
    );
  }
}
