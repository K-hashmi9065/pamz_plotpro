/// Member sub-type for users with role = member.
enum MemberType {
  customerBuyer('Customer / Buyer', 'customerBuyer'),
  investor('Investor', 'investor'),
  landowner('Landowner', 'landowner');

  final String displayName;
  final String dbValue;

  const MemberType(this.displayName, this.dbValue);

  static MemberType fromDb(String value) {
    switch (value) {
      case 'customerBuyer':
        return MemberType.customerBuyer;
      case 'investor':
        return MemberType.investor;
      case 'landowner':
        return MemberType.landowner;
      default:
        throw ArgumentError('Unknown MemberType: $value');
    }
  }
}

/// Backward compatibility extension
extension MemberTypeX on MemberType {
  static MemberType fromDb(String value) => MemberType.fromDb(value);
}
