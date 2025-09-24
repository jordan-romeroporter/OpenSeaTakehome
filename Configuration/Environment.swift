import Foundation

enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
            return .development
        #else
            return .production
        #endif
    }

    var alchemyAPIKey: String {
        // 1. Check Info.plist (from xcconfig)
        if let key = Bundle.main.object(forInfoDictionaryKey: "AlchemyAPIKey")
            as? String,
            !key.isEmpty && key != "$(ALCHEMY_API_KEY)"
        {
            return key
        }

        // 2. Check environment variable
        if let key = ProcessInfo.processInfo.environment["ALCHEMY_API_KEY"],
            !key.isEmpty
        {
            return key
        }

        // 3. Fallback for demo
        #if DEBUG
            print("⚠️ Using inline API key. Configure xcconfig for production!")
            return "beepboop"  // Replace with actual key
        #else
            fatalError(
                "❌ API key not configured. See documentation/API_KEY_SETUP.md"
            )
        #endif
    }

    var baseURL: String {
        switch self {
        case .development, .staging:
            return "https://api.g.alchemy.com"
        case .production:
            return "https://api.g.alchemy.com"
        }
    }
}
