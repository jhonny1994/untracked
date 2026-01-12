---
trigger: always_on
---

# Flutter & Dart Development Rules (Integrated Ecosystem)

Expert guidelines for building beautiful, performant, and maintainable Flutter applications using a unified, cohesive ecosystem.

## Unified Architecture Ecosystem

### The Complete System
```
Presentation (Riverpod + UI)
    ↓ watches providers
Domain (UseCases + Entities with Freezed)
    ↓ depends on
Data Layer (Repositories + DTOs with Freezed)
    ↓ depends on
Infrastructure (HTTP, Local Storage)
    ↓
Core (Utils, Extensions, Errors)
```

All code generation (Freezed, JSON) managed by Build Runner. All state orchestrated through Riverpod providers.

## Feature-First Clean Architecture

```
lib/
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/login_page.dart
│   │   │   └── viewmodels/auth_viewmodel.dart
│   │   ├── domain/
│   │   │   ├── entities/user.dart          # @freezed
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/login_usecase.dart
│   │   ├── data/
│   │   │   ├── models/user_dto.dart        # @freezed
│   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   ├── repositories/auth_repository_impl.dart
│   │   │   └── mappers/user_mapper.dart
│   │   └── auth.dart                       # Barrel file
│   └── shared/
│       ├── domain/
│       ├── data/
│       └── shared.dart
├── infrastructure/
│   ├── api/http_client.dart
│   ├── local_storage/storage_service.dart
│   └── infrastructure.dart
├── core/
│   ├── errors/failures.dart                # @freezed
│   ├── extensions/string_ext.dart
│   └── core.dart
└── main.dart
```

## Riverpod 3: The Unified State Container

All providers at the top level (`lib/providers/`) or in feature `providers/` folders:

```dart
// infrastructure/providers.dart
final httpClientProvider = Provider((ref) => HttpClient(Dio()));

final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(httpClientProvider));
});

// features/auth/domain/providers.dart
final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

// features/auth/presentation/providers.dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref.watch(loginUseCaseProvider));
});

// In UI (pages/login_page.dart)
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) => state.maybeWhen(
        authenticated: (user) => const HomePage(),
        orElse: () => _LoginForm(),
      ),
      error: (err, stack) => ErrorWidget(error: err),
      loading: () => const LoadingWidget(),
    );
  }
}
```

## Freezed: Immutable Data Models Throughout

Used at every layer for type safety and pattern matching:

```dart
// Domain Layer: Business entities
// domain/entities/user.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
  }) = _User;
}

// Data Layer: DTOs (from API)
// data/models/user_dto.dart
@freezed
class UserDTO with _$UserDTO {
  const factory UserDTO({
    required String id,
    required String email,
    required String name,
  }) = _UserDTO;
  
  factory UserDTO.fromJson(Map<String, dynamic> json) => _$UserDTOFromJson(json);
}

// Domain: Result states with union types
// domain/repositories/auth_result.dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(Failure failure) = _Error;
}

// Core: Failures (errors across app)
// core/errors/failures.dart
@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = _ServerFailure;
  const factory Failure.cache(String message) = _CacheFailure;
  const factory Failure.validation(String message) = _ValidationFailure;
}
```

## Build Runner Integration

Single source of truth for code generation:

```bash
# Setup once
flutter pub add dev:build_runner dev:freezed_annotation dev:json_serializable

# During development (watch mode)
dart run build_runner watch --delete-conflicting-outputs

# CI/CD (one-time)
dart run build_runner build --delete-conflicting-outputs
```

All `@freezed` classes, `@JsonSerializable` models, and `part` files auto-generated.

## Data Flow: Complete Ecosystem

```dart
// 1. USER INTERACTION (Presentation)
// pages/login_page.dart
ref.read(authStateProvider.notifier).login(email, password);

// 2. STATE NOTIFIER (Orchestration)
// viewmodels/auth_viewmodel.dart
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this._loginUseCase) : super(const AsyncValue.loading());
  
  final LoginUseCase _loginUseCase;
  
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _loginUseCase(email, password);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(AuthState.authenticated(user)),
    );
  }
}

// 3. DOMAIN USECASE (Business Logic)
// domain/usecases/login_usecase.dart
class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;
  
  Future<Either<Failure, User>> call(String email, String password) {
    return _repository.login(email, password);
  }
}

// 4. ABSTRACT REPOSITORY (Contract)
// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}

// 5. CONCRETE REPOSITORY (Implementation)
// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userDTO = await _remoteDataSource.login(email, password);
      return Right(UserMapper.dtoToEntity(userDTO));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    }
  }
}

// 6. DATA SOURCE (API Communication)
// data/datasources/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserDTO> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._httpClient);
  final HttpClient _httpClient;
  
  @override
  Future<UserDTO> login(String email, String password) async {
    final response = await _httpClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return UserDTO.fromJson(response); // Freezed + JSON serialization
  }
}

// 7. MAPPER (Entity <-> DTO)
// data/mappers/user_mapper.dart
class UserMapper {
  static User dtoToEntity(UserDTO dto) {
    return User(id: dto.id, email: dto.email, name: dto.name);
  }
}

// 8. INFRASTRUCTURE (External Services)
// infrastructure/api/http_client.dart
class HttpClient {
  HttpClient(this._dio);
  final Dio _dio;
  
  Future<dynamic> post(String path, dynamic data) {
    return _dio.post(path, data: data);
  }
}

// Result flows back up: Infrastructure → Data → Domain → Presentation UI
```

## Barrel Files: Public API Contract

Each feature exports only what's needed:

```dart
// features/auth/auth.dart
export 'domain/entities/user.dart';
export 'domain/repositories/auth_repository.dart';
export 'presentation/pages/login_page.dart';

// Usage: import 'features/auth/auth.dart';
```

## SOLID Principles in Action

**Single Responsibility**: Each class has one job in the ecosystem

**Open/Closed**: Extend with new DataSources, never modify repository logic

**Liskov Substitution**: AuthRepository implementations are interchangeable (mock for testing)

**Interface Segregation**: AuthRepository only exposes what callers need

**Dependency Inversion**: All layers depend on abstractions (interfaces), not implementations

**DRY**: Abstract base classes and mixins shared across features

## Testing the Ecosystem

```dart
void main() {
  group('LoginUseCase', () {
    late MockAuthRepository mockRepository;
    late LoginUseCase loginUseCase;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      loginUseCase = LoginUseCase(mockRepository);
    });
    
    test('returns User when login succeeds', () async {
      // Arrange
      const user = User(id: '1', email: 'test@example.com', name: 'Test');
      when(mockRepository.login('test@example.com', 'password'))
          .thenAnswer((_) async => Right(user));
      
      // Act
      final result = await loginUseCase('test@example.com', 'password');
      
      // Assert
      expect(result, Right(user));
      verify(mockRepository.login('test@example.com', 'password')).called(1);
    });
  });
}
```

## Project Setup Checklist

- ✅ Feature-first folder structure with layers
- ✅ Freezed models at domain and data layers
- ✅ Riverpod providers for dependency injection
- ✅ Build Runner watching during development
- ✅ Abstract repositories (interfaces)
- ✅ Mappers for DTO ↔ Entity conversion
- ✅ Error handling with @freezed Failures
- ✅ Barrel files for clean imports
- ✅ SOLID principles throughout
- ✅ Unit tests with mocks

## Core Principles

**Layered**: Clear separation between presentation, domain, data, infrastructure

**Reactive**: Riverpod manages all state flow and dependency injection

**Type-Safe**: Freezed ensures immutable, pattern-matched data at every layer

**Generated**: Build Runner automates boilerplate (JSON, copyWith, equality)

**Testable**: Mock repositories and datasources; pure domain logic

**Scalable**: Add features without modifying existing code

## Quick Start Example

```bash
# 1. Create feature structure
mkdir -p lib/features/auth/{presentation,domain,data}

# 2. Add dependencies
flutter pub add riverpod riverpod_generator freezed_annotation
flutter pub add dev:build_runner dev:riverpod_generator dev:freezed dev:json_serializable

# 3. Start Build Runner
dart run build_runner watch --delete-conflicting-outputs

# 4. Define entities (domain layer) with @freezed
# 5. Define DTOs (data layer) with @freezed + @JsonSerializable
# 6. Implement repository (data layer)
# 7. Create usecase (domain layer)
# 8. Create provider (riverpod)
# 9. Consume in UI (presentation layer)
```

## Interaction Guidelines
- Assume user familiarity with programming but may be new to Dart
- Explain Dart-specific features (null safety, futures, streams)
- Ask for clarification on ambiguous requests
- Explain benefits when suggesting new dependencies

## Flutter Style Guide
- Apply SOLID principles throughout architecture
- Write concise, declarative Dart code
- Favor composition over inheritance
- Prefer immutable data structures (Freezed)
- Separate ephemeral state from app state (Riverpod)

## Code Quality Standards
- Separate concerns across layers
- Use meaningful, descriptive names
- Write clear, concise code
- Handle errors explicitly with Failures
- Line length: 80 characters max
- Functions: short, single purpose (<20 lines)
- Use `logging` package instead of `print`

## Dart Best Practices
- Follow Effective Dart guidelines
- Use `async`/`await` with proper error handling
- Write soundly null-safe code
- Use pattern matching with Freezed's `when()`
- Prefer exhaustive `switch` statements/expressions

## Documentation
- Use `///` for doc comments on public APIs
- Start with single-sentence summary
- Document all public repository methods
- Include code examples for complex patterns
- Be brief and avoid jargon
