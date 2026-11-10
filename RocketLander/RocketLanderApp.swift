import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct RocketLanderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    requestTrackingPermission()
                }
        }
    }

    private func requestTrackingPermission() {
        #if DEBUG
        if DebugLaunch.isScripted { return }
        #endif
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                #if DEBUG
                print("Tracking authorization status: \(status.rawValue)")
                #endif
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}

#if DEBUG
// MARK: - Debug Launch Arguments
// Used by Scripts/ci_screenshots.sh to open a screen directly and fly hands-free.
//   -screen menu|hangar|game   -mode classic|campaign|daily   -level N   -autopilot
enum DebugLaunch {
    private static let args = ProcessInfo.processInfo.arguments

    static func value(_ key: String) -> String? {
        guard let i = args.firstIndex(of: key), i + 1 < args.count else { return nil }
        return args[i + 1]
    }

    static var isScripted: Bool { value("-screen") != nil }
    static var autopilot: Bool { args.contains("-autopilot") }
}
#endif
