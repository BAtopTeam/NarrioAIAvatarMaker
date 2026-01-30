//
//  ImageCache.swift
//  SynthesiaAI
//
//  Created by b on 23.01.2026.
//

import UIKit
import CryptoKit

final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 200
    }
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

final class DiskImageCache {
    static let shared = DiskImageCache()
    
    private let folderURL: URL
    
    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        folderURL = caches.appendingPathComponent("ImageCache", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true
            )
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        let url = fileURL(forKey: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    func save(_ image: UIImage, forKey key: String) {
        let url = fileURL(forKey: key)
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        try? data.write(to: url, options: .atomic)
    }
    
    private func fileURL(forKey key: String) -> URL {
        folderURL.appendingPathComponent(key.sha256)
    }
}

extension String {
    var sha256: String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
