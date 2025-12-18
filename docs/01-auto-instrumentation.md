# 自動計装

**所要時間:** 約30分

このセクションでは、Splunk RUM iOS SDK をサンプルアプリに組み込み、自動計装を有効にします。

---

## 1. RUM アクセストークンの発行

Splunk Observability Cloud でアクセストークンを発行します。

### 1.1 トークンの作成

1. [Splunk Observability Cloud](https://app.jp0.signalfx.com/) にログイン
2. 左下の **Settings**（歯車アイコン）をクリック
3. **Access Tokens** を選択
4. **+ New Token** をクリック
5. 以下を設定：
   - **Name**: `ios-rum-workshop`（任意の名前）
   - **Authorization Scope**: `RUM` にチェック
6. **Create** をクリック

### 1.2 トークンの確認

作成したトークンをクリックして、トークン文字列を確認します。

> **重要:** このトークンは後で使用するので、コピーしておいてください。

### 1.3 Realm の確認

Splunk Observability Cloud の URL から Realm を確認します。

| URL | Realm |
|-----|-------|
| `app.jp0.signalfx.com` | `jp0` |
| `app.us1.signalfx.com` | `us1` |
| `app.eu0.signalfx.com` | `eu0` |

---

## 2. SDK のインストール

Swift Package Manager を使用して Splunk RUM iOS SDK をインストールします。

### 2.1 パッケージの追加

1. Xcode で `RUMSampleApp.xcodeproj` を開く
2. メニューから **File** → **Add Package Dependencies...** を選択
3. 検索欄に以下の URL を入力：
   ```
   https://github.com/signalfx/splunk-otel-ios
   ```
4. **Add Package** をクリック
5. `SplunkAgent` パッケージを選択し、**Add Package** をクリック

### 2.2 パッケージの確認

左側のプロジェクトナビゲーターに **Package Dependencies** が追加され、`SplunkAgent` が表示されていることを確認します。

---

## 3. SDK の初期化

アプリ起動時に Splunk RUM を初期化するコードを追加します。

### 3.1 AppDelegate.swift の編集

`SampleApp/Sources/AppDelegate.swift` を開き、以下のように編集します：

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

### 3.2 設定値の置き換え

以下の値を実際の値に置き換えてください：

| プレースホルダー | 説明 | 例 |
|-----------------|------|-----|
| `<YOUR_REALM>` | Splunk の Realm | `jp0` |
| `<YOUR_RUM_ACCESS_TOKEN>` | 発行したアクセストークン | `xxxxx...` |

---

## 4. ビルドと動作確認

### 4.1 アプリのビルド

1. **Cmd + R** でビルド＆実行
2. シミュレーターでアプリが起動することを確認
3. ログイン → ホーム → 各画面を操作

### 4.2 Splunk でデータを確認

1. [Splunk Observability Cloud](https://app.jp0.signalfx.com/) にアクセス
2. 左メニューから **RUM** を選択
3. **App** ドロップダウンで `RUMSampleApp` を選択
4. データが表示されることを確認

> **Note:** データが表示されるまで数分かかる場合があります。

---

## 5. 自動計装で取得されるデータ

SDK を組み込むだけで、以下のデータが自動的に収集されます：

| データ種別 | 説明 |
|-----------|------|
| **App Launch** | アプリのローンチ数 |
| **Crashes** | クラッシュレポート |
| **Network Requests** | HTTP リクエストのレイテンシ・ステータス |
| **Session Traces** | 各セッションのトレース情報 |
| **Session Replay** | セッションリプレイ（画面操作の録画） |

> **Note:** App Errors（アプリ内で発生したエラー）は自動では収集されません。エラーを Splunk RUM にレポートするには、カスタム計装が必要です。詳細は「[手動計装](./03-manual-instrumentation.md)」セクションで説明します。

### 5.1 確認してみよう

以下の操作を行い、Splunk RUM でデータが記録されることを確認しましょう：

1. **ネットワーク**: RUM テスト画面で以下のボタンをタップし、HTTP リクエストが記録されることを確認
   - 「200 OK」- 正常なレスポンス
   - 「400 Bad Request」- クライアントエラー
   - 「500 Server Error」- サーバーエラー
   - 「商品一覧 (API)」- 商品データの取得
2. **クラッシュ**: RUM テスト画面で「クラッシュさせる」をタップ（シミュレーターから直接起動した状態で）
3. **セッションリプレイ**: Splunk RUM の Session Replay で操作内容を確認

> **Note:** HTTP リクエストは API サーバー（localhost:3000）に送信されます。API サーバーが起動していない場合、リクエストは失敗します。

---

## 6. トラブルシューティング

### ビルドエラーが発生する場合

1. **File** → **Packages** → **Reset Package Caches** を実行
2. **Product** → **Clean Build Folder** を実行
3. 再度ビルド

### データが表示されない場合

1. トークンと Realm が正しいか確認
2. シミュレーターがインターネットに接続されているか確認
3. 数分待ってからページをリロード

---

## 確認チェックリスト

次のセクションに進む前に、以下を確認してください：

- [ ] RUM アクセストークンを発行した
- [ ] SDK をプロジェクトに追加した
- [ ] AppDelegate.swift に初期化コードを追加した
- [ ] Splunk RUM でアプリのデータが表示された

すべて確認できたら、次のセクション「各種設定」に進みましょう。

---

**前のセクション:** [準備](./00-preparation.md)

**次のセクション:** [各種設定](./02-configuration.md)
