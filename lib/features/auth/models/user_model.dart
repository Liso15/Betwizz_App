// Placeholder for a more detailed User model
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
  });

  // For equatability and easy debugging
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }
}
