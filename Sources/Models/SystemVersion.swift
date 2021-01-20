import Foundation

struct SystemVersion {
    static var version: String {
        let operatingSystemVersion = ProcessInfo().operatingSystemVersion
        let majorVersion = operatingSystemVersion.majorVersion
        let minorVersion = operatingSystemVersion.minorVersion
        let patchVersion = operatingSystemVersion.patchVersion

        return "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}
