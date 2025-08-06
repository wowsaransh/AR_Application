import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        context.coordinator.subscribeToActionStream()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: self.viewModel)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var viewModel: ARViewModel
        private var cancellables = Set<AnyCancellable>()
        
        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func subscribeToActionStream() {
            viewModel.actionStream.sink { [weak self] action in
                switch action {
                case .place(let furniture):
                    print("✅ COORDINATOR: Received 'place' action for \(furniture.name).")
                    self?.placeObject(furniture)
                case .removeAll:
                    self?.arView?.scene.anchors.removeAll()
                }
            }.store(in: &cancellables)
        }
        
        func placeObject(_ furniture: Furniture) {
            guard let arView = self.arView else {
                print("❌ PLACE_OBJECT: ARView is nil. Cannot proceed.")
                return
            }
            
            print("➡️ PLACE_OBJECT: Starting raycast from screen center...")
            let raycast = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = raycast.first {
                print("✅ RAYCAST: Succeeded. Found a surface.")
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                
                print("➡️ MODEL: Attempting to load '\(furniture.modelName).usdz'...")
                ModelEntity.loadModelAsync(named: furniture.modelName)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { loadCompletion in
                        if case .failure(let error) = loadCompletion {
                            print("❌ MODEL_ERROR: Failed to load model. Error: \(error.localizedDescription)")
                        }
                    }, receiveValue: { modelEntity in
                        print("✅ MODEL: Successfully loaded.")
                        modelEntity.generateCollisionShapes(recursive: true)
                        arView.installGestures([.translation, .rotation], for: modelEntity)
                        anchor.addChild(modelEntity)
                        arView.scene.addAnchor(anchor)
                        print("✅✅✅ PLACEMENT COMPLETE: Object added to the scene.")
                    }).store(in: &self.cancellables)
            } else {
                print("❌ RAYCAST: Failed. Could not find a surface at the moment of tapping.")
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            if self.viewModel.selectedFurniture != nil {
                DispatchQueue.main.async {
                    self.viewModel.placementEnabled = !self.arView!.raycast(from: self.arView!.center, allowing: .estimatedPlane, alignment: .horizontal).isEmpty
                }
            }
        }
    }
}
