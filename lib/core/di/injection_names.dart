/// Constants for named dependency injection with GetIt
///
/// Using string-based instance names instead of type-based lookup
/// to avoid issues with Flutter web minification where class names
/// get shortened (e.g., CreateCharacter -> aOT)
class InjectionNames {
  // Prevent instantiation
  InjectionNames._();

  // Use cases
  static const createCharacter = 'CreateCharacter';
  static const getPlayerCharacter = 'GetPlayerCharacter';
  static const allocateStatPoints = 'AllocateStatPoints';

  // Repositories
  static const characterRepository = 'CharacterRepository';

  // Core
  static const logger = 'Logger';
}
