import '../models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> signUp(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<AuthUser?> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> verifyEmail();
  Future<void> updateProfile({String? displayName, String? photoUrl});
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> updateEmail({required String newEmail, required String currentPassword});
  Future<void> deleteAccount(String password);
}
