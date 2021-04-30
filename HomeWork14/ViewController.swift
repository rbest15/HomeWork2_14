import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lastScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func playPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        vc.delegate = self
        show(vc, sender: nil)
    }
}

