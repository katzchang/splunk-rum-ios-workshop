import UIKit
import SplunkAgent
import OpenTelemetryApi

class RUMTestViewController: UIViewController {

    // MARK: - Masking Demo
    @IBOutlet weak var maskedLabel: UILabel!
    @IBOutlet weak var normalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RUM テスト"

        // マスキングのデモ: この要素はSession Replayでマスクされる
        maskedLabel.srSensitive = true
    }

    // MARK: - Error

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

    // MARK: - Crash

    @IBAction func crashButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "クラッシュ確認",
            message: "アプリをクラッシュさせます。よろしいですか？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "クラッシュ", style: .destructive) { _ in
            fatalError("テスト用のクラッシュです")
        })
        present(alert, animated: true)
    }

    // MARK: - Custom Event

    @IBAction func logButtonTapped(_ sender: UIButton) {
        // カスタムイベントをトラッキング
        if let agent = (UIApplication.shared.delegate as? AppDelegate)?.agent {
            let attrs = MutableAttributes()
            attrs["button.name"] = .string("log_button")
            attrs["screen.name"] = .string("RUMTestViewController")
            attrs["timestamp"] = .string(ISO8601DateFormatter().string(from: Date()))
            agent.customTracking.trackCustomEvent("button_tapped", attrs)
        }

        showAlert(title: "ログ出力", message: "カスタムイベントを Splunk RUM に送信しました")
    }

    // MARK: - Custom Span

    @IBAction func runAnalysisButtonTapped(_ sender: UIButton) {
        let tracer = OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: "RUMSampleApp",
            instrumentationVersion: "1.0.0"
        )

        // スパンを開始
        let span = tracer.spanBuilder(spanName: "run_analysis").startSpan()
        span.setAttribute(key: "analysis.type", value: "demo")

        // ランダムなレイテンシ（1〜5秒）
        let latency = Double.random(in: 1.0...5.0)
        // 25% の確率でエラー
        let shouldFail = Double.random(in: 0...1) < 0.25

        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: latency)

            DispatchQueue.main.async {
                span.setAttribute(key: "analysis.duration_seconds", value: latency)

                if shouldFail {
                    span.status = .error(description: "Analysis failed due to random error")
                    span.setAttribute(key: "error", value: true)
                    span.end()
                    self.showAlert(
                        title: "分析エラー",
                        message: String(format: "処理時間: %.1f秒\nエラーが発生しました", latency)
                    )
                } else {
                    span.status = .ok
                    span.end()
                    self.showAlert(
                        title: "分析完了",
                        message: String(format: "処理時間: %.1f秒\n正常に完了しました", latency)
                    )
                }
            }
        }
    }

    // MARK: - HTTP Requests

    private let apiBaseURL = "http://localhost:3000"

    @IBAction func request200ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(apiBaseURL)/api/test/200")
    }

    @IBAction func request400ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(apiBaseURL)/api/test/400")
    }

    @IBAction func request500ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(apiBaseURL)/api/test/500")
    }

    @IBAction func requestProductsButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(apiBaseURL)/api/products")
    }

    private func makeRequest(to urlString: String, timeout: TimeInterval = 30) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    self?.showAlert(
                        title: "レスポンス",
                        message: "ステータスコード: \(httpResponse.statusCode)"
                    )
                }
            }
        }
        task.resume()
    }

    // MARK: - Helper

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
