import UIKit
// TODO: SplunkAgent をインポート

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // TODO: Splunk RUM エージェントのプロパティを追加

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // TODO: Splunk RUM を初期化

        // TODO: 自動ナビゲーショントラッキングを有効化

        // TODO: セッションリプレイを開始

        // TODO: LogCollector を開始

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
