// Deprecated: AuthService removed — use `ApiProvider` / `PibroRepository` instead.
//
// This file remains as a stub to prevent accidental runtime import errors
// while the codebase migrates. Do NOT use this class; it will throw when
// instantiated. Prefer using `PibroRepository` (backed by `ApiProvider`) or
// inject a repository implementation via constructor for testability.
@Deprecated('AuthService removed — use ApiProvider / PibroRepository instead')
class AuthService {
  AuthService() {
    throw UnsupportedError(
        'AuthService has been removed. Use ApiProvider / PibroRepository instead.');
  }
}
