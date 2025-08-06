//
//  Furniture.swift
//  ARInteriorDesigner
//
//  Created by admin25 on 06/08/25.


import Foundation
import UIKit

struct Furniture: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let modelName: String 
    let thumbnail: UIImage
}
