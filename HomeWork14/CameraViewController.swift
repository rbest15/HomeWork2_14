import UIKit
import SceneKit
import ARKit

class CameraViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var debugSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crossImageView.center = self.view.center
        distLabel.layer.cornerRadius = 20
        distLabel.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let conf = ARWorldTrackingConfiguration()
        sceneView.session.run(conf)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = (touches.first?.location(in: self.view))!
        UIView.animate(withDuration: 0.5) {
            self.crossImageView.center = point
        }
        let result = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry, .featurePoint])
        guard let distance = result.first?.distance else { return }
        self.distLabel.text = "\(String(format: "%.2f", distance * 100)) sm"
    }
    
    
    @IBAction func debugSwitchChanged(_ sender: Any) {
        if debugSwitch.isOn {
            sceneView.showsStatistics = true
            sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        } else {
            sceneView.showsStatistics = false
            sceneView.debugOptions.remove(SCNDebugOptions.showFeaturePoints)
        }
    }
}
