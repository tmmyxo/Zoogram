//
//  Extensions.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 18.01.2022.
//

import UIKit
import SwiftUI

extension UIDevice {
    var hasNotch: Bool {
            if #available(iOS 13.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                guard let window = windowScene?.windows.first else { return false }
                
                return window.safeAreaInsets.top > 20
            }
            
            if #available(iOS 11.0, *) {
                let top = UIApplication.shared.windows[0].safeAreaInsets.top
                return top > 20
            } else {
                // Fallback on earlier versions
                return false
            }
        }
}

extension Encodable {
    var dictionary: [String : Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)).flatMap { $0 as? [String: Any]}
    }
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard #available(iOS 13.0, *), let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}

public extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

extension String {
    func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: ".", with: "-")
    }
}

extension UITableView {
    
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        self.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
}

extension UINavigationBar {
    func configureNavigationBarColor(with color: UIColor) {
        let appearence = UINavigationBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.backgroundColor = color
        appearence.shadowColor = .clear
        if color == .black {
            appearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        self.standardAppearance = appearence
        self.scrollEdgeAppearance = appearence
    }
}

extension UITabBar {
    func configureTabBarColor(with color: UIColor) {
        let appearence = UITabBarAppearance()
        appearence.configureWithDefaultBackground()
        appearence.backgroundColor = color
        appearence.shadowColor = .clear
        self.standardAppearance = appearence
        self.scrollEdgeAppearance = appearence
    }
}

extension UIImageView {
    func getOnlyVisiblePartOfImage(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        image.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}

extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }

        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)

        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
    
    func compressed() -> UIImage? {
        let originalImageSize = NSData(data: self.jpegData(compressionQuality: 1)!).count
        print("Original image size in KB: %f", Double(originalImageSize).rounded())
        let jpegData = self.jpegData(compressionQuality: 1)
        print("Compressed image size in KB: %f", Double(jpegData!.count).rounded())
        let compressedImage = UIImage(data: jpegData!)
        return compressedImage
    }
}

#if DEBUG
///Preview UI built with UIKit
@available(iOS 13, *)
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        
        
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

