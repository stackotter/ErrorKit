// swift-tools-version:5.9
import PackageDescription

let package = Package(
   name: "ErrorKit",
   defaultLocalization: "en",
   platforms: [.macOS(.v10_15), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
   products: [.library(name: "ErrorKit", targets: ["ErrorKit"])],
   dependencies: [
      // CryptoKit is not available on Linux, so we need Swift Crypto
      .package(url: "https://github.com/rarestype/h", from: "1.0.0"),
   ],
   targets: [
      .target(
         name: "ErrorKit",
         dependencies: [
            .product(
               name: "SHA2",
               package: "h"
            ),
         ],
         resources: [
            .process("Resources/Localizable.xcstrings"),
            .process("Resources/PrivacyInfo.xcprivacy"),
         ]
      ),
      .testTarget(name: "ErrorKitTests", dependencies: ["ErrorKit"]),
   ]
)
