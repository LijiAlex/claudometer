import Foundation

func parseAccessToken(from data: Data) -> String? {
    guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let oauth = obj["claudeAiOauth"] as? [String: Any],
          let token = oauth["accessToken"] as? String,
          !token.isEmpty
    else { return nil }
    return token
}
