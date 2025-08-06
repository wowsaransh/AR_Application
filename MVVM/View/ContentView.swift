

import SwiftUI
import ARKit

struct ContentView: View {
    
    @StateObject private var viewModel = ARViewModel()
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ARStatusView(trackingState: viewModel.arTrackingState)
                Spacer()
                
                if viewModel.selectedFurniture != nil {
                    PlacementView(isEnabled: $viewModel.placementEnabled, viewModel: viewModel, namespace: animation)
                } else {
                    FurnitureCarouselView(
                        furniture: viewModel.furnitureCatalog,
                        selectedFurniture: $viewModel.selectedFurniture,
                        namespace: animation,
                        onTapGesture: { furniture in
                            viewModel.selectFurniture(furniture)
                        }
                    )
                }
            }
        }
    }
}

// NOTE: The other helper views are still here for now.
// If you get errors for them, create separate files for them too using the same steps.

private struct ARStatusView: View {
    let trackingState: ARCamera.TrackingState
    
    var body: some View {
        let status = statusMessage(for: trackingState)
        
        if !status.message.isEmpty {
            Text(status.message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(status.color.opacity(0.8))
                .clipShape(Capsule())
                .animation(.spring(), value: status.message)
                .transition(.opacity.combined(with: .scale))
        }
    }
    
    func statusMessage(for state: ARCamera.TrackingState) -> (message: String, color: Color) {
        switch state {
        case .normal:
            return ("", .clear)
        case .notAvailable:
            return ("AR Not Available", .red)
        case .limited(let reason):
            switch reason {
            case .initializing:
                return ("Move device to scan", .blue)
            case .excessiveMotion:
                return ("Move slower", .yellow)
            case .insufficientFeatures:
                return ("Aim at a textured surface", .yellow)
            default:
                return ("Tracking limited", .yellow)
            }
        }
    }
}

private struct FurnitureCarouselView: View {
    let furniture: [Furniture]
    @Binding var selectedFurniture: Furniture?
    var namespace: Namespace.ID
    var onTapGesture: (Furniture) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(furniture) { item in
                    Image(uiImage: item.thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .matchedGeometryEffect(id: item.id, in: namespace)
                        .onTapGesture {
                            onTapGesture(item)
                        }
                }
            }
            .padding()
        }
    }
}
