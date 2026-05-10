/// A protocol for mapping domain-specific errors to user-friendly messages.
///
/// `ErrorMapper` allows users to extend ErrorKit's error mapping capabilities by providing custom mappings for errors from specific frameworks, libraries, or domains.
///
/// # Overview
/// ErrorKit comes with built-in mappers for Foundation, CoreData, and MapKit errors.
/// You can add your own mappers for other frameworks or custom error types using the ``ErrorKit/registerMapper(_:)`` function.
/// ErrorKit will query all registered mappers in reverse order until one returns a non-nil result. This means, the last added mapper takes precedence.
///
/// # Example Implementation
/// ```swift
/// enum FirebaseErrorMapper: ErrorMapper {
///     static func userFriendlyMessage(for error: Error) -> String? {
///         switch error {
///         case let authError as AuthErrorCode:
///             switch authError.code {
///             case .wrongPassword:
///                 return String(localized: "The password is incorrect. Please try again.")
///             case .userNotFound:
///                 return String(localized: "No account found with this email address.")
///             default:
///                 return nil
///             }
///
///         case let firestoreError as FirestoreErrorCode.Code:
///             switch firestoreError {
///             case .permissionDenied:
///                 return String(localized: "You don't have permission to access this data.")
///             case .unavailable:
///                 return String(localized: "The service is temporarily unavailable. Please try again later.")
///             default:
///                 return nil
///             }
///
///         case let storageError as StorageErrorCode:
///             switch storageError {
///             case .objectNotFound:
///                 return String(localized: "The requested file could not be found.")
///             case .quotaExceeded:
///                 return String(localized: "Storage quota exceeded. Please try again later.")
///             default:
///                 return nil
///             }
///
///         default:
///             return nil
///         }
///     }
/// }
///
/// // Register during app initialization
/// ErrorKit.registerMapper(FirebaseErrorMapper.self)
/// ```
///
/// Your mapper will be called automatically when using ``ErrorKit/userFriendlyMessage(for:)``:
/// ```swift
/// do {
///     let user = try await Auth.auth().signIn(withEmail: email, password: password)
/// } catch {
///     let message = ErrorKit.userFriendlyMessage(for: error)
///     // Message will be generated from FirebaseErrorMapper for Auth/Firestore/Storage errors
/// }
/// ```
public protocol ErrorMapper: Sendable {
   /// Maps a given error to a user-friendly message if possible.
   ///
   /// This function is called by ErrorKit when attempting to generate a user-friendly error message.
   /// It should check if the error is of a type it can handle and return an appropriate message, or return nil to allow other mappers to process the error.
   ///
   /// # Implementation Guidelines
   /// - Return nil for errors your mapper doesn't handle
   /// - Always use String(localized:) for message localization
   /// - Keep messages clear, actionable, and non-technical
   /// - Avoid revealing sensitive information
   /// - Consider the user experience when crafting messages
   ///
   /// # Example
   /// ```swift
   /// static func userFriendlyMessage(for error: Error) -> String? {
   ///     switch error {
   ///     case let databaseError as DatabaseLibraryError:
   ///         switch databaseError {
   ///         case .connectionTimeout:
   ///             return String(localized: "Database connection timed out. Please try again.")
   ///         case .queryExecution:
   ///             return String(localized: "Database query failed. Please contact support.")
   ///         default:
   ///             return nil
   ///         }
   ///     default:
   ///         return nil
   ///     }
   /// }
   /// ```
   ///
   /// - Note: Any error cases you don't provide a return value for will simply keep their original message. So only override the unclear ones or those that are not localized or you want other kinds of improvements for. No need to handle all possible cases just for the sake of it.
   ///
   /// - Parameter error: The error to potentially map to a user-friendly message
   /// - Returns: A user-friendly message if this mapper can handle the error, or nil otherwise
   static func userFriendlyMessage(for error: Error) -> String?
}
