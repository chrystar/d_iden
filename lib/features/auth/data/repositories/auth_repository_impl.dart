import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
  }) : _authDataSource = authDataSource;

  @override
  Future<AuthUser> signIn(String email, String password) async {
    return await _authDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AuthUser> signUp(String email, String password) async {
    return await _authDataSource.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return await _authDataSource.isSignedIn();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return await _authDataSource.getCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _authDataSource.forgotPassword(email);
  }

  @override
  Future<void> verifyEmail() async {
    await _authDataSource.verifyEmail();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await _authDataSource.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    await _authDataSource.updatePassword(currentPassword, newPassword);
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    await _authDataSource.updateEmail(newEmail: newEmail, currentPassword: currentPassword);
  }

  @override
  Future<void> deleteAccount(String password) async {
    await _authDataSource.deleteAccount(password);
  }
}
