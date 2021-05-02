import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lastScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func playPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "cameraVC") as! CameraViewController
        present(vc, animated: true, completion: nil)
    }
}

