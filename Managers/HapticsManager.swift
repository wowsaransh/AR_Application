//
//  HapticsManager.swift
//  ARInteriorDesigner
//
//  Created by admin25 on 06/08/25.
//
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private init() {}
    
    func triggerSelection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
    
    func triggerImpact() {
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    }
}
