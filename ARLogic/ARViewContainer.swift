import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics])
        
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
        }
        
        func subscribeToActionStream() {
            viewModel.actionStream
                .sink { [weak self] action in
                    switch action {
                    case .place(let furniture):
                        self?.placeObject(furniture)
                    case .removeAll:
                        self?.arView?.scene.anchors.removeAll()
                    }
                }
                .store(in: &cancellables)
        }
        
        func placeObject(_ furniture: Furniture) {
            guard let arView = self.arView else { return }
            
            let raycast = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = raycast.first {
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                
                ModelEntity.loadModelAsync(named: furniture.modelName)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { _ in }, receiveValue: { modelEntity in
                        modelEntity.generateCollisionShapes(recursive: true)
                        arView.installGestures([.translation, .rotation], for: modelEntity)
                        anchor.addChild(modelEntity)
                        arView.scene.addAnchor(anchor)
                    })
                    .store(in: &self.cancellables)
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            DispatchQueue.main.async {
                self.viewModel.arTrackingState = frame.camera.trackingState
                
                if let arView = self.arView, self.viewModel.selectedFurniture != nil {
                    let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
                    self.viewModel.placementEnabled = !results.isEmpty
                } else {
                    self.viewModel.placementEnabled = false
                }
            }
        }
    }
}
