//
//  ARViewModel.swift
//  ARInteriorDesigner
//
//  Created by admin25 on 06/08/25.
//
// In: MVVM/ViewModel/ARViewModel.swift

import Foundation
import Combine
import ARKit

enum ARAction {
    case place(Furniture)
    case removeAll
}

final class ARViewModel: ObservableObject {
    @Published var furnitureCatalog: [Furniture] = []
    @Published var selectedFurniture: Furniture?
    @Published var placementEnabled = false
    @Published var arTrackingState: ARCamera.TrackingState = .notAvailable
    
    var actionStream = PassthroughSubject<ARAction, Never>()
    
    init() {
        self.loadFurnitureCatalog()
    }
    
    func loadFurnitureCatalog() {
        self.furnitureCatalog = [
            Furniture(name: "Basketball", modelName: "ball_basketball_realistic", thumbnail: UIImage(named: "basketball_thumb")!),
            Furniture(name: "Teapot", modelName: "teapot", thumbnail: UIImage(named: "teapot_thumb")!),
            Furniture(name: "Toy Car", modelName: "toy_car", thumbnail: UIImage(named: "toy_car_thumb")!)
        ]
    }
    
    func selectFurniture(_ furniture: Furniture) {
        if self.selectedFurniture == furniture {
            self.selectedFurniture = nil
        } else {
            self.selectedFurniture = furniture
            HapticsManager.shared.triggerSelection()
        }
    }
    
    func placeSelectedItem() {
        guard let furniture = selectedFurniture else { return }
        actionStream.send(.place(furniture))
        HapticsManager.shared.triggerImpact()
    }
    
    func removeAll() {
        actionStream.send(.removeAll)
        HapticsManager.shared.triggerImpact()
    }
}
