import SwiftUI
import UIKit
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

struct GIFView: UIViewRepresentable {
    private let name: String
    @EnvironmentObject private var appearanceManager: AppearanceManager

    init(name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let gifImageView = UIImageView()
        gifImageView.contentMode = .scaleAspectFit
        gifImageView.clipsToBounds = true
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gifImageView)
        
        NSLayoutConstraint.activate([
            gifImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            gifImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            gifImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gifImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Load the GIF immediately
        gifImageView.loadGif(name: name, colorScheme: appearanceManager.isDarkMode ? .dark : .light)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update GIF based on the current color scheme
        if let gifImageView = uiView.subviews.first as? UIImageView {
            gifImageView.loadGif(name: name, colorScheme: appearanceManager.isDarkMode ? .dark : .light)
        }
    }
}

extension UIImageView {
    public func loadGif(name: String, colorScheme: ColorScheme) {
        DispatchQueue.global().async {
            if let image = UIImage.gif(name: name, colorScheme: colorScheme) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

extension UIImage {
    public class func gif(name: String, colorScheme: ColorScheme) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            print("This image named \"\(name)\" does not exist or could not be loaded!")
            return nil
        }

        return gif(source: source, colorScheme: colorScheme)
    }

    private class func gif(source: CGImageSource, colorScheme: ColorScheme) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var duration = 0.0

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            duration += UIImage.delayForImageAtIndex(i, source: source)
        }

        let processedImages = images.map { image -> CGImage in
            let ciImage = CIImage(cgImage: image)
            let colorInversionFilter = CIFilter.colorInvert()
            colorInversionFilter.inputImage = ciImage

            let context = CIContext()
            let outputImage = colorScheme == .dark ? colorInversionFilter.outputImage : ciImage
            return context.createCGImage(outputImage!, from: outputImage!.extent)!
        }

        let frames = UIImage.animatedImageWithImages(processedImages, duration: duration)
        return frames
    }

    private class func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> Double {
        var delay = 0.01

        if let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as NSDictionary?,
           let gifProperties = cfProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
           let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
            delay = delayTime
        }

        if delay < 0.01 {
            delay = 0.01
        }

        return delay
    }

    private class func animatedImageWithImages(_ images: [CGImage], duration: Double) -> UIImage? {
        let frames = images.map { UIImage(cgImage: $0) }
        return UIImage.animatedImage(with: frames, duration: duration)
    }
}
