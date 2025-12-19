# 手動計装

**所要時間:** 約30分

このセクションでは、Splunk RUM iOS SDK を使用して、アプリ内部でカスタム計測を追加する方法を学びます。

---

## 1. エラーのトラッキング

### 1.1 trackError とは

自動計装ではアプリのクラッシュは自動的に収集されますが、try-catch でハンドリングしたエラーは自動では収集されません。

`trackError` メソッドを使用することで、これらのエラーを Splunk RUM にレポートできます。

### 1.2 実装方法

`RUMTestViewController.swift` の冒頭に `import SplunkAgent` を追加し、`reportErrorButtonTapped` メソッドにエラートラッキングを実装します。

```swift
import UIKit
import SplunkAgent

class RUMTestViewController: UIViewController {
    // ...

    @IBAction func reportErrorButtonTapped(_ sender: UIButton) {
        let error = NSError(
            domain: "com.example.RUMSampleApp",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "テスト用のエラーが発生しました"]
        )

        // Splunk RUM にエラーをトラッキング
        if let agent = (UIApplication.shared.delegate as? AppDelegate)?.agent {
            let attrs = MutableAttributes()
            attrs["ErrorDomain"] = .string("com.example.RUMSampleApp")
            attrs["ErrorCode"] = .int(1001)
            attrs["Description"] = .string("テスト用のエラーが発生しました")
            agent.customTracking.trackError(error, attrs)
        }
    }
}
```

### 1.3 動作確認

1. アプリをビルド＆実行
2. RUM テスト画面で「エラーを送信」をタップ
3. Splunk Observability Cloud で **RUM** → **App Errors** を確認
4. レポートしたエラーが表示されることを確認

---

## 2. カスタムイベントの追加

### 2.1 trackCustomEvent とは

カスタムイベントは、アプリ内の特定のアクションやビジネスロジックを記録するための機能です。

**活用例:**
- ボタンのタップ
- 機能の使用開始/完了
- ビジネス上の重要なアクション（購入、登録など）

### 2.2 実装方法

`RUMTestViewController.swift` の「ログを出力」ボタンに実装されています。

```swift
@IBAction func logButtonTapped(_ sender: UIButton) {
    // カスタムイベントをトラッキング
    if let agent = (UIApplication.shared.delegate as? AppDelegate)?.agent {
        let attrs = MutableAttributes()
        attrs["button.name"] = .string("log_button")
        attrs["screen.name"] = .string("RUMTestViewController")
        attrs["timestamp"] = .string(ISO8601DateFormatter().string(from: Date()))
        agent.customTracking.trackCustomEvent("button_tapped", attrs)
    }
}
```

### 2.3 動作確認

1. アプリをビルド＆実行
2. RUM テスト画面で「ログを出力」ボタンをタップ
3. Splunk RUM の **Sessions** でセッションを選択
4. イベント一覧に `button_tapped` が表示されることを確認

---

## 3. カスタムスパンの追加

### 3.1 スパンとは

スパンは、処理の開始から終了までの時間を計測する単位です。API 呼び出しや重い処理のパフォーマンスを測定するのに使用します。

### 3.2 実装方法

OpenTelemetry Swift API を使用してカスタムスパンを作成します。

```swift
import OpenTelemetryApi

@IBAction func createCustomSpanButtonTapped(_ sender: UIButton) {
    let tracer = OpenTelemetry.instance.tracerProvider.get(
        instrumentationName: "RUMSampleApp",
        instrumentationVersion: "1.0.0"
    )

    // スパンを開始
    let span = tracer.spanBuilder(spanName: "heavy_processing").startSpan()

    // 重い処理をシミュレート
    DispatchQueue.global().async {
        Thread.sleep(forTimeInterval: 2.0)

        DispatchQueue.main.async {
            // スパンに属性を追加
            span.setAttribute(key: "processing.type", value: "simulation")
            span.setAttribute(key: "processing.items", value: 100)

            // スパンを終了
            span.end()

            self.showAlert(title: "スパン完了", message: "カスタムスパン（2秒）を記録しました")
        }
    }
}
```

### 3.3 動作確認

1. アプリをビルド＆実行
2. RUM テスト画面でスパン作成ボタンをタップ
3. 2秒後に完了メッセージが表示される
4. Splunk RUM の **Sessions** → **Traces** でスパンを確認
5. `heavy_processing` スパンが約2秒で記録されていることを確認

---

## 4. ログの収集（Splunk HEC）

### 4.1 LogCollector とは

`LogCollector` は、アプリ内の `NSLog` 出力をキャプチャして Splunk HTTP Event Collector (HEC) に送信するユーティリティです。

stderr をフックすることで、`NSLog` や `print` の出力を自動的に収集し、Splunk に転送します。

### 4.2 設定方法

1. **Info.plist に HEC 設定を追加**

   ```xml
   <key>SplunkHECURL</key>
   <string>https://your-splunk-instance:8088/services/collector/event</string>
   <key>SplunkHECToken</key>
   <string>your-hec-token</string>
   ```

2. **AppDelegate で初期化**（サンプルアプリでは設定済み）

   ```swift
   // LogCollector を開始（NSLog を Splunk HEC に送信）
   LogCollector.shared.start()
   ```

### 4.3 動作確認

1. Info.plist に HEC の URL とトークンを設定
2. アプリをビルド＆実行
3. `NSLog` を出力するコードを実行（例：RUM テスト画面の各ボタン）
4. Splunk で `sourcetype="ios_app_log"` を検索してログが表示されることを確認

> **Note:** HEC が設定されていない場合、LogCollector は起動時に警告を出力して何もしません。

---

## 5. その他の手動計装

このワークショップでは基本的な手動計装のみを紹介しましたが、他にも以下のような機能があります：

- **スパンのフィルタリング** - PII（個人情報）を含むスパンの削除や編集
- **ネットワークリクエストのカスタマイズ** - 特定のリクエストの除外

詳細は公式ドキュメントを参照してください：
- [Manually instrument iOS applications](https://help.splunk.com/en/splunk-observability-cloud/manage-data/instrument-front-end-applications/instrument-mobile-and-web-applications-for-splunk-rum/instrument-ios-applications-for-splunk-rum/splunk-rum-ios-agent-version-2.0.0-and-above/manually-instrument-ios-applications)

---

## 6. トラブルシューティング

### エラーやイベントが表示されない場合

1. SDK が正しく初期化されているか確認
2. `agent` が `nil` になっていないか確認
3. 数分待ってから Splunk RUM をリロード

### スパンの所要時間が正しくない場合

1. `span.end()` が正しいタイミングで呼ばれているか確認
2. 非同期処理の場合、完了コールバック内で `end()` を呼ぶ

### LogCollector でログが送信されない場合

1. Info.plist に `SplunkHECURL` と `SplunkHECToken` が正しく設定されているか確認
2. HEC エンドポイントがアクセス可能か確認
3. Xcode コンソールに LogCollector の警告メッセージが出ていないか確認

---

## 確認チェックリスト

ワークショップ完了前に、以下を確認してください：

- [ ] エラートラッキングを実装し、Splunk RUM で確認した
- [ ] カスタムイベントを実装し、Splunk RUM で確認した
- [ ] カスタムスパンを実装し、Splunk RUM で確認した
- [ ] （オプション）LogCollector を設定し、Splunk でログを確認した

おめでとうございます！Splunk RUM iOS SDK のワークショップが完了しました。

---

**前のセクション:** [各種設定](./02-configuration.md)

**トップに戻る:** [準備](./00-preparation.md)
