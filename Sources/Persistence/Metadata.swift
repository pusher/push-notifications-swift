import Foundation

public struct Metadata: Equatable, Codable {
    let sdkVersion: String?
    let iosVersion: String?
    let macosVersion: String?
    
    internal static var current: Metadata = {
        let sdkVersion = SDK.version
        let systemVersion = SystemVersion.version

        #if os(iOS)
        return Metadata(sdkVersion: sdkVersion, iosVersion: systemVersion, macosVersion: nil)
        #elseif os(OSX)
        return Metadata(sdkVersion: sdkVersion, iosVersion: nil, macosVersion: systemVersion)
        #endif
    }()
}
