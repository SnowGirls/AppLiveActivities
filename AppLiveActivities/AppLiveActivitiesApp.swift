import SwiftUI
import QiBackgroundRunning

@main
struct AppLiveActivitiesApp: App {
    
    @UIApplicationDelegateAdaptor(AppLiveActivitiesDelegate.self) var appDelegate
    
    static var deviceToken: String = ""
    
    init() {
        registerNotifications()
    }
    
    func registerNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("Error on requestAuthorization: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppContentView().onOpenURL { url in
                print("OpenURL: \(url)")
                guard let url = URLComponents(string: url.absoluteString) else { return }
                if let courierNumber = url.queryItems?.first(where: { $0.name == "CourierNumber" })?.value {
                    // call courier
                }
            }
        }
    }
    
}


class AppLiveActivitiesDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        QiBGRunningManager.instance().aliveTimeInterval = 180
        QiBGRunningManager.instance().registerAppLifeCycleNotification()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        AppLiveActivitiesApp.deviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register remote notifications: \(error)")
    }
}
