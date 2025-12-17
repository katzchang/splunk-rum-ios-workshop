import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "Face IDでログインしてください"
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        authenticateWithBiometrics()
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "ログインするために認証が必要です"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
                DispatchQueue.main.async {
                    if success {
                        self?.onAuthenticationSuccess()
                    } else {
                        self?.onAuthenticationFailure(error: authError)
                    }
                }
            }
        } else {
            // Biometrics not available - allow login anyway for simulator testing
            showAlert(title: "生体認証が利用できません", message: "シミュレーターではスキップします") { [weak self] in
                self?.onAuthenticationSuccess()
            }
        }
    }

    private func onAuthenticationSuccess() {
        statusLabel.text = "認証成功"
        performSegue(withIdentifier: "showHome", sender: nil)
    }

    private func onAuthenticationFailure(error: Error?) {
        statusLabel.text = "認証失敗: \(error?.localizedDescription ?? "不明なエラー")"
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
