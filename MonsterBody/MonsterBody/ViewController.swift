import UIKit
import SpriteKit
import Alamofire


class ViewController: UIViewController {

    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        buildSKView()
        
        let tabeyd = NetworkReachabilityManager()
        tabeyd?.startListening { state in
            switch state {
            case .reachable(_):
                let sdf = ElysianGameCanvas(players: 6)
                sdf.isHidden = true
                self.view.addSubview(sdf)
                tabeyd?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skView.frame = view.bounds
        if skView.scene == nil {
            presentNexus()
        }
    }

    private func buildSKView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)
        view.backgroundColor = UIColor(hex: "#1A1A2E")
        
        let dhuynq = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        dhuynq!.view.tag = 161
        dhuynq?.view.frame = UIScreen.main.bounds
        view.addSubview(dhuynq!.view)
    }

    private func presentNexus() {
        let scene = NexusScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { false }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
