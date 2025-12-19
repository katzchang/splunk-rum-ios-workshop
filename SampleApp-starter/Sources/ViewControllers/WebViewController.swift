import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // Angular app URL - update this to your local or deployed Angular app
    private let angularAppURL = "http://localhost:4200"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "商品一覧"
        setupWebView()
        loadAngularApp()
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

    private func loadAngularApp() {
        guard let url = URL(string: angularAppURL) else {
            showError("無効なURLです")
            return
        }

        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        webView.reload()
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError("ページの読み込みに失敗しました: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError("接続できませんでした。Angularアプリが起動しているか確認してください。")
    }
}
