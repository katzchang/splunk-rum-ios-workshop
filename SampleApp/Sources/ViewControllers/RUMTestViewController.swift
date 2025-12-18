import UIKit

class RUMTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RUM テスト"
    }

    // MARK: - Error

    @IBAction func reportErrorButtonTapped(_ sender: UIButton) {
        let error = NSError(
            domain: "com.example.RUMSampleApp",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "テスト用のエラーが発生しました"]
        )
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

    // MARK: - Log

    @IBAction func logButtonTapped(_ sender: UIButton) {
        let timestamp = Date()
        let message = "RUM テストログ: \(timestamp)"
        NSLog(message)
        print("Print: \(message)")
        showAlert(title: "ログ出力", message: "NSLogとprintでログを出力しました\n\nコンソールを確認してください")
    }

    // MARK: - HTTP Requests

    private let baseURL = "http://localhost:4200"

    @IBAction func request200ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(baseURL)/api/test/200", expectedStatus: 200)
    }

    @IBAction func request400ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(baseURL)/api/test/400", expectedStatus: 400)
    }

    @IBAction func request500ButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(baseURL)/api/test/500", expectedStatus: 500)
    }

    @IBAction func requestProductsButtonTapped(_ sender: UIButton) {
        makeRequest(to: "\(baseURL)/api/products", expectedStatus: 200)
    }

    private func makeRequest(to urlString: String, expectedStatus: Int, timeout: TimeInterval = 30) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "リクエストエラー", message: error.localizedDescription)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    self?.showAlert(
                        title: "レスポンス受信",
                        message: "ステータスコード: \(httpResponse.statusCode)"
                    )
                }
            }
        }
        task.resume()

        showAlert(title: "リクエスト送信", message: "HTTPリクエストを送信しました\n期待するステータス: \(expectedStatus)")
    }

    // MARK: - Helper

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
