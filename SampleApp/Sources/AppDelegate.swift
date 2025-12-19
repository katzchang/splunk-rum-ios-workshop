import UIKit
import SplunkAgent

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var agent: SplunkRum?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Splunk RUM の初期化
        let endpointConfiguration = EndpointConfiguration(
            realm: "jp0",
            rumAccessToken: "hGASAb5jyHYENwoD3NACmA"
        )

        let agentConfiguration = AgentConfiguration(
            endpoint: endpointConfiguration,
            appName: "RUMSampleApp",
            deploymentEnvironment: "lab"
        )
        .globalAttributes(MutableAttributes(dictionary: [
            "enduser.role": .string("workshop_participant"),
            "app.build": .string(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown")
        ]))

        do {
            agent = try SplunkRum.install(with: agentConfiguration)
        } catch {
            print("Unable to start the Splunk agent, error: \(error)")
        }

        // 自動ナビゲーショントラッキングを有効化
        agent?.navigation.preferences.enableAutomatedTracking = true

        // セッションリプレイを開始
        agent?.sessionReplay.start()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}
