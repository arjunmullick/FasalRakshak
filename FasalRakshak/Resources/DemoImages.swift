//
//  DemoImages.swift
//  FasalRakshak
//
//  Demo images for testing and demonstration
//

import Foundation
import UIKit

/// Demo images for testing crop disease detection
struct DemoImages {

    /// Sample diseased crop images for demo
    static let sampleDiseases: [DemoImage] = [
        DemoImage(
            name: "Tomato Late Blight",
            cropType: "Tomato",
            description: "Late blight on tomato leaves - brown spots with yellow halos",
            imageName: "demo_tomato_late_blight"
        ),
        DemoImage(
            name: "Wheat Rust",
            cropType: "Wheat",
            description: "Yellow/orange rust pustules on wheat leaves",
            imageName: "demo_wheat_rust"
        ),
        DemoImage(
            name: "Rice Blast",
            cropType: "Rice",
            description: "Diamond-shaped lesions on rice leaves",
            imageName: "demo_rice_blast"
        ),
        DemoImage(
            name: "Potato Early Blight",
            cropType: "Potato",
            description: "Concentric rings on potato leaves",
            imageName: "demo_potato_blight"
        ),
        DemoImage(
            name: "Cotton Leaf Curl",
            cropType: "Cotton",
            description: "Curled and yellowed cotton leaves",
            imageName: "demo_cotton_curl"
        )
    ]

    /// Generate a placeholder image with disease simulation
    static func generatePlaceholderDiseaseImage(for demo: DemoImage) -> UIImage {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background - leaf green
            UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add some "disease" spots - brown/yellow circles
            let spotColors = [
                UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.8),
                UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.7),
                UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 0.9)
            ]

            for i in 0..<15 {
                let x = CGFloat.random(in: 100...700)
                let y = CGFloat.random(in: 100...700)
                let radius = CGFloat.random(in: 20...80)

                spotColors[i % spotColors.count].setFill()
                context.cgContext.fillEllipse(in: CGRect(x: x - radius, y: y - radius,
                                                         width: radius * 2, height: radius * 2))
            }

            // Add label
            let label = demo.name
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -3
            ]

            let text = NSAttributedString(string: label, attributes: attributes)
            let textSize = text.size()
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2,
                                 y: size.height - 100))
        }
    }

    /// Get a demo image (placeholder for now, can be replaced with actual bundled images)
    static func getImage(for demo: DemoImage) -> UIImage {
        // Try to load from assets first
        if let image = UIImage(named: demo.imageName) {
            return image
        }

        // Otherwise generate placeholder
        return generatePlaceholderDiseaseImage(for: demo)
    }
}

/// Demo image metadata
struct DemoImage: Identifiable {
    let id = UUID()
    let name: String
    let cropType: String
    let description: String
    let imageName: String
}
