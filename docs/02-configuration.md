# 各種設定

**所要時間:** 約30分

このセクションでは、Splunk RUM iOS SDK の各種設定オプションを調整し、計測精度や収集データをカスタマイズする方法を学びます。

---

## 1. セッションサンプリング比率の設定

### 1.1 sessionSamplingRatio とは

`sessionSamplingRatio` は、RUM データを収集するセッションの割合を指定するパラメータです。セッション開始時に確率的に判定され、収集対象となったセッションのみがデータを送信します。

| 値 | 説明 |
|----|------|
| `1.0` | 全セッションを収集（100%）- デフォルト |
| `0.5` | 50% のセッションを収集 |
| `0.1` | 10% のセッションを収集 |
| `0.0` | 収集しない（0%） |

**使用シーン:**
- **開発環境**: `1.0` で全セッションのデータを確認
- **本番環境**: ユーザー数が多い場合、コスト最適化のために値を下げる

### 1.2 設定方法

`AppDelegate.swift` の `AgentConfiguration` に `sessionSamplingRatio` を追加します。

```swift
let agentConfiguration = AgentConfiguration(
    endpoint: endpointConfiguration,
    appName: "RUMSampleApp",
    deploymentEnvironment: "lab",
    sessionSamplingRatio: 1.0  // 100% のセッションを収集
)
```

### 1.3 動作確認

1. `sessionSamplingRatio` を `0.0` に設定してビルド
2. アプリを操作
3. Splunk RUM でデータが**表示されない**ことを確認
4. `sessionSamplingRatio` を `1.0` に戻す

> **Note:** ワークショップでは全セッションのデータを確認したいため、`1.0` のままにしておきましょう。

---

## 2. グローバル属性の設定

### 2.1 グローバル属性とは

グローバル属性は、すべてのテレメトリデータに自動的に付与されるカスタム属性です。ユーザー情報やアプリのバージョン情報など、分析に役立つメタデータを追加できます。

OpenTelemetry の仕様に基づき、以下のような標準属性が推奨されています：
- `enduser.id` - ユーザー識別子
- `enduser.role` - ユーザーロール

### 2.2 設定方法

`AppDelegate.swift` の `AgentConfiguration` に `.globalAttributes()` メソッドでグローバル属性を追加します。

```swift
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
            realm: "<YOUR_REALM>",
            rumAccessToken: "<YOUR_RUM_ACCESS_TOKEN>"
        )

        let agentConfiguration = AgentConfiguration(
            endpoint: endpointConfiguration,
            appName: "RUMSampleApp",
            deploymentEnvironment: "lab"
        )
        .globalAttributes(MutableAttributes(dictionary: [
            "enduser.role": .string("workshop_participant"),
            "custom.workshop_id": .string("2025-01")
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

    // ... 既存のコード ...
}
```

### 2.3 MutableAttributes の型

`MutableAttributes` では以下の型を使用できます：

| 型 | 例 |
|----|-----|
| `.string("value")` | 文字列 |
| `.int(123)` | 整数 |
| `.double(3.14)` | 小数 |
| `.bool(true)` | 真偽値 |

### 2.4 初期化後に属性を追加する

ログイン後にユーザーIDを設定するなど、SDK 初期化後に動的に属性を追加することもできます。詳細は公式ドキュメントの「[Add identification metadata after initialization](https://help.splunk.com/en/splunk-observability-cloud/manage-data/instrument-front-end-applications/instrument-mobile-and-web-applications-for-splunk-rum/instrument-ios-applications-for-splunk-rum/splunk-rum-ios-agent-version-2.0.0-and-above/manually-instrument-ios-applications)」を参照してください。

### 2.5 Splunk RUM での確認

1. アプリをビルド＆実行
2. いくつかの画面を操作
3. Splunk Observability Cloud で **RUM** → **Sessions** を開く
4. セッションを選択し、属性に以下が表示されることを確認：
   - `enduser.role`
   - `custom.workshop_id`

> **Note:** `app.build_id` などの標準属性は SDK が自動的に収集します。グローバル属性には、ビジネスロジックに関連するカスタム情報を追加しましょう。

---

## 3. その他の設定

このワークショップでは基本的な設定のみを紹介しましたが、Splunk RUM iOS SDK には他にも多くの設定オプションがあります。

詳細は公式ドキュメントを参照してください：
- [Configure the Splunk RUM iOS agent](https://help.splunk.com/en/splunk-observability-cloud/manage-data/instrument-front-end-applications/instrument-mobile-and-web-applications-for-splunk-rum/instrument-ios-applications-for-splunk-rum/splunk-rum-ios-agent-version-2.0.0-and-above/configure-the-splunk-rum-ios-agent)

---

## 4. トラブルシューティング

### グローバル属性が表示されない場合

1. 属性名に特殊文字が含まれていないか確認
2. 値が `nil` になっていないか確認
3. SDK の初期化が完了してから属性を設定しているか確認

### sessionSamplingRatio の変更が反映されない場合

1. アプリを完全に終了して再起動
2. シミュレーターをリセット（**Device** → **Erase All Content and Settings**）

---

## 確認チェックリスト

次のセクションに進む前に、以下を確認してください：

- [ ] sessionSamplingRatio の設定方法を理解した
- [ ] グローバル属性を追加した
- [ ] Splunk RUM でグローバル属性が表示されることを確認した

すべて確認できたら、次のセクション「手動計装」に進みましょう。

---

**前のセクション:** [自動計装](./01-auto-instrumentation.md)

**次のセクション:** [手動計装](./03-manual-instrumentation.md)
