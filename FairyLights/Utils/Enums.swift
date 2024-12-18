import SwiftUI

enum AlertType: Identifiable {
    case newUpdateAvailable(String, URL)
    case upToDate
    case error(String)

    var id: String {
        switch self {
        case .newUpdateAvailable: return "newUpdateAvailable"
        case .upToDate: return "upToDate"
        case .error: return "error"
        }
    }
}
