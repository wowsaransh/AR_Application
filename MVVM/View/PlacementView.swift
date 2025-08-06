//
//  PlacementView.swift
//  ARInteriorDesigner
//
//  Created by admin25 on 06/08/25.
//


import SwiftUI

struct PlacementView: View {
    @Binding var isEnabled: Bool
    var viewModel: ARViewModel
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        viewModel.removeAll()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.selectFurniture(viewModel.selectedFurniture!)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            if let furniture = viewModel.selectedFurniture {
                Image(uiImage: furniture.thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .matchedGeometryEffect(id: furniture.id, in: namespace)
            }
            
            Button {
                viewModel.placeSelectedItem()
            } label: {
                Text("Place")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(isEnabled ? Color.blue : Color.gray)
                    .clipShape(Capsule())
                    .scaleEffect(isEnabled ? 1.0 : 0.95)
            }
            .disabled(!isEnabled)
            .padding(.bottom, 20)
        }
        .frame(maxHeight: 250)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: isEnabled)
    }
}
