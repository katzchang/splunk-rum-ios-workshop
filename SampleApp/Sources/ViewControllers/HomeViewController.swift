import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = "ようこそ！"
        navigationItem.hidesBackButton = true
    }

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showCamera", sender: nil)
    }

    @IBAction func webViewButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showWebView", sender: nil)
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
