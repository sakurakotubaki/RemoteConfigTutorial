import SwiftUI
import FirebaseRemoteConfigInternal
import FirebaseCore

class RemoteConfigManager: ObservableObject {
    private var remoteConfig: RemoteConfig
    @Published var forceUpdateRequired = false
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For testing, set to a higher value in production
        remoteConfig.configSettings = settings
        
        fetchRemoteConfig()
    }
    
    func fetchRemoteConfig() {
        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                self?.remoteConfig.activate { _, error in
                    self?.checkForceUpdate()
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func checkForceUpdate() {
        let forceUpdate = remoteConfig.configValue(forKey: "force_update_required").boolValue
        let requiredVersion = remoteConfig.configValue(forKey: "force_update_current_version").stringValue ?? ""
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        if forceUpdate && isVersionLower(current: currentVersion, required: requiredVersion) {
            DispatchQueue.main.async {
                self.forceUpdateRequired = true
            }
        }
    }
    
    private func isVersionLower(current: String, required: String) -> Bool {
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let requiredParts = required.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(currentParts.count, requiredParts.count) {
            let currentPart = i < currentParts.count ? currentParts[i] : 0
            let requiredPart = i < requiredParts.count ? requiredParts[i] : 0
            
            if currentPart < requiredPart {
                return true
            } else if currentPart > requiredPart {
                return false
            }
        }
        
        return false
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct RemoteConfigTutorialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var remoteConfigManager = RemoteConfigManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(remoteConfigManager)
        }
    }
}
