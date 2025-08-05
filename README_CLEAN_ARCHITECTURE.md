# Clean Architecture Implementation

This project has been refactored to follow Clean Architecture principles, providing better separation of concerns, testability, and maintainability.

## 📁 Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App constants
│   ├── errors/                     # Error handling
│   ├── network/                    # Network utilities
│   ├── services/                   # Core services (printers, etc.)
│   ├── usecases/                   # Base use case interface
│   └── di/                         # Dependency injection
├── data/                           # Data layer
│   ├── datasources/                # Data sources
│   │   ├── remote/                 # API calls
│   │   └── local/                  # Local storage
│   ├── models/                     # Data models (DTOs)
│   └── repositories/               # Repository implementations
├── domain/                         # Domain layer (Business logic)
│   ├── entities/                   # Business entities
│   ├── repositories/               # Repository interfaces
│   └── usecases/                   # Use cases
└── presentation/                   # Presentation layer
    ├── bloc/                       # State management
    ├── pages/                      # UI screens
    ├── widgets/                    # Reusable widgets
    └── themes/                     # App theming
```

## 🏗️ Architecture Layers

### 1. **Domain Layer** (Innermost)
- **Entities**: Core business objects (User, Product, Invoice)
- **Repository Interfaces**: Abstract contracts for data access
- **Use Cases**: Business logic and rules

### 2. **Data Layer** (Middle)
- **Data Sources**: Remote (API) and Local (Database/Cache) data sources
- **Models**: Data Transfer Objects (DTOs) that extend entities
- **Repository Implementations**: Concrete implementations of repository interfaces

### 3. **Presentation Layer** (Outermost)
- **BLoC**: State management using flutter_bloc
- **Pages**: UI screens and pages
- **Widgets**: Reusable UI components

## 🔧 Key Features

### Error Handling
- **Failure Classes**: Centralized error handling with specific failure types
- **Either Type**: Using `dartz` package for functional error handling
- **Consistent Error Messages**: Mapped failure types to user-friendly messages

### Dependency Injection
- **GetIt**: Service locator for dependency injection
- **Lazy Loading**: Dependencies are created when first accessed
- **Testable**: Easy to mock dependencies for testing

### Network Layer
- **Dio**: HTTP client for API calls
- **Network Info**: Connectivity checking
- **Offline Support**: Cached data when offline

## 📦 Dependencies Added

```yaml
dependencies:
  dartz: ^0.10.1                    # Functional programming
  get_it: ^7.6.7                    # Dependency injection
  dio: ^5.4.3                       # HTTP client
  internet_connection_checker: ^1.0.0+1  # Network connectivity
```

## 🚀 Usage Examples

### Using Use Cases
```dart
// In a BLoC
final result = await loginUseCase(LoginParams(
  email: event.email,
  password: event.password,
));

result.fold(
  (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
  (user) => emit(AuthSuccess(user)),
);
```

### Dependency Injection
```dart
// Register dependencies
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ),
);

// Use dependencies
final authBloc = sl<AuthBloc>();
```

## 🧪 Testing Benefits

- **Unit Testing**: Each layer can be tested independently
- **Mocking**: Easy to mock dependencies using interfaces
- **Isolation**: Business logic is isolated from UI and data concerns

## 🔄 Migration Guide

### From Old Structure to New:
1. **Entities**: Move business objects to `domain/entities/`
2. **Use Cases**: Create use cases in `domain/usecases/`
3. **Repositories**: Define interfaces in `domain/repositories/`
4. **Data Sources**: Implement in `data/datasources/`
5. **BLoC**: Move to `presentation/bloc/`
6. **Pages**: Move to `presentation/pages/`

### Benefits Achieved:
- ✅ **Separation of Concerns**: Each layer has a single responsibility
- ✅ **Testability**: Easy to unit test each component
- ✅ **Maintainability**: Changes in one layer don't affect others
- ✅ **Scalability**: Easy to add new features
- ✅ **Dependency Rule**: Dependencies point inward

## 📝 Next Steps

1. **Complete Repository Implementations**: Implement remaining repositories
2. **Add More Use Cases**: Create use cases for all business operations
3. **Error Handling**: Implement comprehensive error handling
4. **Testing**: Add unit tests for each layer
5. **Documentation**: Add more detailed documentation

## 🔗 Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dartz Package](https://pub.dev/packages/dartz)
- [GetIt Package](https://pub.dev/packages/get_it) 