import UIKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var redFireButton: UIButton!
    @IBOutlet weak var blueFireButton: UIButton!
    @IBOutlet weak var greenFireButton: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var score = 0
    var time = 30
    
    var delegate : ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        addNodes(100)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
            if self.time > 0 {
                self.time -= 1
                self.timeLabel.text = String(self.time)
            } else {
                self.dismiss(animated: true) {
                    self.delegate?.lastScoreLabel.text = String("Last score: \(self.score)")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let conf = ARWorldTrackingConfiguration()
        sceneView.session.run(conf)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.lastScoreLabel.text = String("Last score: \(self.score)")
        sceneView.session.pause()
    }

    func uiSetup(){
        self.scoreLabel.text = String(self.score)
        self.timeLabel.text = String(self.time)
        self.scoreView.layer.cornerRadius = 10
        self.timeView.layer.cornerRadius = 10
        redFireButton.layer.cornerRadius = 10
        blueFireButton.layer.cornerRadius = 10
        greenFireButton.layer.cornerRadius = 10
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    @IBAction func redFireButtonPressed(_ sender: Any) {
        fireMissleBall(color: .red)
    }
    @IBAction func blueFireButtonPressed(_ sender: Any) {
        fireMissleBall(color: .blue)
    }
    @IBAction func greenFireButtonPressed(_ sender: Any) {
        fireMissleBall(color: .green)
    }
    
    func addNodes(_ count: Int) {
        var index = 0
        for _ in 0...count {
            var node = SCNNode()

            if index == 0 {
                let scene = SCNScene(named: "ballR.dae")
                node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
                node.scale = SCNVector3(0.2, 0.2, 0.2)
                node.name = "red"
                index = 1
            } else if index == 1 {
                let scene = SCNScene(named: "ballB.dae")
                node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
                node.scale = SCNVector3(0.2, 0.2, 0.2)
                node.name = "blue"
                index = 2
            } else if index == 2 {
                let scene = SCNScene(named: "ballG.dae")
                node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
                node.scale = SCNVector3(0.2, 0.2, 0.2)
                node.name = "green"
                index = 0
            }
            
            let action = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let foreverAction = SCNAction.repeatForever(action)
            node.runAction(foreverAction)
            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            node.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
            node.physicsBody?.contactTestBitMask = CollisionCategory.missleCategory.rawValue
            
            node.position = SCNVector3(randomFloat(min: -10, max: 10), randomFloat(min: -4, max: 5), randomFloat(min: -10, max: 10))
            
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func createMissleBall(color: BallType) -> SCNNode {
       var node = SCNNode()
        
        switch color {
        case .red:
            let scene = SCNScene(named: "ballR.dae")
            node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
            node.scale = SCNVector3(0.2, 0.2, 0.2)
            node.name = "red"
        case .blue:
            let scene = SCNScene(named: "ballB.dae")
            node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
            node.scale = SCNVector3(0.2, 0.2, 0.2)
            node.name = "blue"
        case .green:
            let scene = SCNScene(named: "ballG.dae")
            node = (scene?.rootNode.childNode(withName: "ball", recursively: true))!
            node.scale = SCNVector3(0.2, 0.2, 0.2)
            node.name = "green"
        }
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        
        node.physicsBody?.categoryBitMask = CollisionCategory.missleCategory.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        
        return node
    }
    
    func fireMissleBall(color: BallType) {
        var node = SCNNode()
        
        node = createMissleBall(color: color)
        
        let (direction, position) = self.getUserVector()
        
        node.position = position
        let nodeDirect = SCNVector3(direction.x * 4, direction.y * 4, direction.z * 4)
        node.physicsBody?.applyForce(nodeDirect, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    

    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print(contact.nodeA.name, contact.nodeB.name)
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
            
            if contact.nodeA.name == contact.nodeB.name {
                let exposion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)
                contact.nodeB.addParticleSystem(exposion!)
                DispatchQueue.main.async {
                    contact.nodeA.removeFromParentNode()
                    contact.nodeB.removeFromParentNode()
                    self.score += 1
                    self.scoreLabel.text = String(self.score)
                }
            } else {
                let exposion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)
                contact.nodeB.addParticleSystem(exposion!)
                DispatchQueue.main.async {
                    contact.nodeB.removeFromParentNode()
                    self.score -= 1
                    self.scoreLabel.text = String(self.score)
                }
            }

        }
    }

}

enum BallType {
    case red
    case green
    case blue
}

