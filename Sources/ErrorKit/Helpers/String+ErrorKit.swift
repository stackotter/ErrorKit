import Foundation

extension String {
   #if canImport(CryptoKit)
   /// Used to locate the resource bundle of the framework/module that contains
   /// this type (mirrors SwiftPM's generated `Bundle.module` implementation).
   private final class BundleFinder {}

   /// The resource bundle that SwiftPM generates for ErrorKit, if it can be
   /// found at runtime.
   ///
   /// `Bundle.module` traps when the bundle is missing, which happens whenever
   /// ErrorKit is linked into an executable that is distributed without its
   /// resource bundle (for example a standalone CLI copied out of the build
   /// products directory). Resolving the bundle ourselves lets us fall back to
   /// the English translations provided at the call sites instead of crashing.
   private static let resourceBundle: Bundle? = {
      // This implementation was taken from https://github.com/yonaskolb/XcodeGen/blob/783a19e863ff906e042d061aa0a1d569d3c52ffa/Sources/XcodeGenKit/SettingsBuilder.swift#L273

      let bundleName = "ErrorKit_ErrorKit"

      let overrides: [URL]
      #if DEBUG
      // Set by SwiftPM/Xcode when running tests (mirrors the generated
      // `Bundle.module` accessor).
      if let override = ProcessInfo.processInfo.environment[
         "PACKAGE_RESOURCE_BUNDLE_PATH"
      ] ?? ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_URL"] {
         overrides = [URL(fileURLWithPath: override)]
      } else {
         overrides = []
      }
      #else
      overrides = []
      #endif

      let candidates = overrides + [
         // Bundle should be present here when the package is linked into an app.
         Bundle.main.resourceURL,
         // Bundle should be present here when the package is linked into a framework.
         Bundle(for: BundleFinder.self).resourceURL,
         // For command-line tools.
         Bundle.main.bundleURL,
      ].compactMap { $0 }

      for candidate in candidates {
         let url = candidate.appendingPathComponent("\(bundleName).bundle")
         if let bundle = Bundle(url: url) {
            return bundle
         }
      }

      return nil
   }()

   // On Apple platforms, use the older localization API with the module's
   // resource bundle when it's available.
   //
   // `String.LocalizationValue` (and `String(localized:)`) require macOS 12,
   // but ErrorKit supports macOS 10.15, so this uses `NSLocalizedString`. When
   // the resource bundle is missing (e.g. a standalone binary that wasn't
   // distributed with it) the English default is used instead of crashing.
   static func localized(key: StaticString, defaultValue: String) -> String {
      return NSLocalizedString(
         key.description,
         tableName: nil,
         bundle: resourceBundle ?? .main,
         value: defaultValue,
         comment: defaultValue
      )
   }
   #else
   // On non-Apple platforms, just return the default value (the English translation)
   static func localized(key: StaticString, defaultValue: String) -> String {
      return defaultValue
   }
   #endif
}

extension String.StringInterpolation {
   /// Interpolates an error using its user-friendly message.
   ///
   /// Uses ``ErrorKit.userFriendlyMessage(for:)`` to provide clear, actionable error descriptions
   /// suitable for displaying to users. For nested errors, returns the message from the root cause.
   ///
   /// ```swift
   /// showAlert("Operation failed: \(error)")
   /// ```
   ///
   /// - Parameter error: The error to interpolate using its user-friendly message
   mutating public func appendInterpolation(_ error: some Error) {
      self.appendInterpolation(ErrorKit.userFriendlyMessage(for: error))
   }

   /// Interpolates an error using its complete chain description for debugging.
   ///
   /// Uses ``ErrorKit.errorChainDescription(for:)`` to show the full error hierarchy,
   /// type information, and nested structure. Ideal for logging and debugging.
   ///
   /// ```swift
   /// print("Operation failed with:\n\(chain: error)")
   /// // Operation failed with:
   /// // DatabaseError
   /// // └─ FileError
   /// //    └─ PermissionError.denied(permission: "~/Downloads/Profile.png")
   /// //       └─ userFriendlyMessage: "Access to ~/Downloads/Profile.png was declined..."
   /// ```
   ///
   /// - Parameter error: The error to interpolate using its complete chain description
   mutating public func appendInterpolation(chain error: some Error) {
      self.appendInterpolation(ErrorKit.errorChainDescription(for: error))
   }

   /// Interpolates an error using its complete chain description for debugging.
   ///
   /// Uses ``ErrorKit.errorChainDescription(for:)`` to show the full error hierarchy,
   /// type information, and nested structure. Ideal for logging and debugging.
   ///
   /// ```swift
   /// print("Operation failed with:\n\(chain: error)")
   /// // Operation failed with:
   /// // DatabaseError
   /// // └─ FileError
   /// //    └─ PermissionError.denied(permission: "~/Downloads/Profile.png")
   /// //       └─ userFriendlyMessage: "Access to ~/Downloads/Profile.png was declined..."
   /// ```
   ///
   /// - Parameter error: The error to interpolate using its complete chain description
   ///
   /// - NOTE: Alias for ``appendInterpolation(chain:)``.
   mutating public func appendInterpolation(debug error: some Error) {
      self.appendInterpolation(chain: error)
   }
}
