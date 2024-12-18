import Foundation
import AppKit

struct GitHubRelease: Decodable {
    let tagName: String
    let assets: [Asset]
    
    private enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case assets
    }
    
    struct Asset: Decodable {
        let browserDownloadURL: URL
        
        private enum CodingKeys: String, CodingKey {
            case browserDownloadURL = "browser_download_url"
        }
    }
}

// Async function to fetch the latest release information from GitHub
func fetchLatestRelease() async throws -> (String, URL) {
    let url = URL(string: "https://api.github.com/repos/chippokiddo/FairyLights/releases/latest")!
    var request = URLRequest(url: url)
    request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    
    // Perform the network request
    let (data, _) = try await URLSession.shared.data(for: request)
    
    // Decode the JSON response
    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
    
    // Check if there are assets available
    guard let downloadURL = release.assets.first?.browserDownloadURL else {
        throw NSError(domain: "GitHubReleaseError", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "No assets available in the latest release on GitHub."
        ])
    }
    
    return (release.tagName, downloadURL)
}
