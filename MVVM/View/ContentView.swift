import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject private var viewModel = ARViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            if self.viewModel.selectedFurniture == nil {
                // MARK: - Furniture Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(viewModel.furnitureCatalog) { furniture in
                            Button {
                                print("➡️ UI: Selected '\(furniture.name)'.")
                                self.viewModel.selectFurniture(furniture)
                            } label: {
                                Image(uiImage: furniture.thumbnail)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .aspectRatio(1/1, contentMode: .fit)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.35))
                .cornerRadius(15)
                .padding()
                
            } else {
                // MARK: - Placement Controls
                HStack(spacing: 20) {
                    Button {
                        print("➡️ UI: Deselected item.")
                        self.viewModel.selectFurniture(nil)
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(30)
                    }
                    
                    Button {
                        print("➡️ UI: 'Place' button tapped.")
                        self.viewModel.placeSelectedItem()
                    } label: {
                        Text("Place")
                            .font(.system(.title, design: .rounded).bold())
                            .frame(width: 140, height: 60)
                            .foregroundColor(.white)
                            .background(self.viewModel.placementEnabled ? Color.blue : Color.gray)
                            .cornerRadius(30)
                    }
                    .disabled(!self.viewModel.placementEnabled)
                }
                .padding(.bottom, 30)
            }
        }
    }
}
