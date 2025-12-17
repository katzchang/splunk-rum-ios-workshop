# ワークショップ設計方針

## 概要

Splunk RUM for iOS のハンズオンワークショップ用コンテンツ

- **ターゲット**: 既存アプリへのRUM導入を検討している開発者
- **所要時間**: 約1時間45分（準備15分 + 本編90分）

---

## サンプルアプリ仕様

### 技術スタック

| 項目 | 選択 | 理由 |
|------|------|------|
| UIフレームワーク | UIKit | 既存アプリの大多数がUIKitベース |
| UI構築 | Storyboard | 既存アプリで最も普及、視覚的にわかりやすい |
| パッケージ管理 | Swift Package Manager (SPM) | 現在の推奨方式 |
| 対象iOS | iOS 15+ | Splunk RUM SDK要件に合わせる |

### アプリ構成

```
┌──────────────────────────────────────┐
│  iOS App (UIKit + Storyboard)        │
│                                      │
│  ├─ ログイン画面                      │
│  │    └─ Face ID 認証                │
│  │                                   │
│  ├─ ホーム画面                        │
│  │    ├─ カメラ起動ボタン             │
│  │    └─ WebView へ遷移ボタン         │
│  │                                   │
│  ├─ カメラ画面                        │
│  │    └─ 写真撮影                     │
│  │                                   │
│  └─ WebView画面                       │
│       └─ Angular SPA（商品一覧など）  │
│                                      │
└──────────────────────────────────────┘
```

### 使用フレームワーク

- `LocalAuthentication` - Face ID / Touch ID
- `AVFoundation` or `UIImagePickerController` - カメラ
- `WebKit` - WKWebView

### RUM学習ポイント

| 機能 | RUMで計測できること |
|------|---------------------|
| Face ID | 認証成功/失敗のカスタムイベント |
| カメラ | 起動時間、撮影イベント、権限エラー |
| WebView | 画面遷移、読み込み時間 |
| 画面遷移 | View tracking（自動計装） |

---

## WebView内 Angularアプリ

- 新規構築
- シンプルな商品一覧・詳細画面
- Browser RUM は組み込みなし（iOS RUMに集中）

---

## ディレクトリ構成（予定）

```
splunk-rum-ios-workshop/
├── agenda.md                 # アジェンダ
├── DESIGN.md                 # 本ファイル（設計方針）
├── docs/                     # ワークショップテキスト
│   ├── 00-preparation.md
│   ├── 01-auto-instrumentation.md
│   ├── 02-configuration.md
│   └── 03-manual-instrumentation.md
├── SampleApp/                # iOSサンプルアプリ
│   └── (Xcodeプロジェクト)
└── angular-app/              # WebView用Angularアプリ
    └── (Angularプロジェクト)
```

---

## 作成タスク

1. [ ] iOSサンプルアプリのプロジェクト作成
2. [ ] Angularアプリの作成
3. [ ] ワークショップテキストの作成

---

## 参考リンク

- GitHub: https://github.com/signalfx/splunk-otel-ios
- Splunk ドキュメント: https://docs.splunk.com/observability/en/rum/rum-instrumentation/rum-mobile-ios.html
