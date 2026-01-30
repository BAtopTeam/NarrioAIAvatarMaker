//
//  VideoDownloader.swift
//  SynthesiaAI
//
//  Created by b on 26.01.2026.
//

import Foundation
import Photos

enum VideoDownloadTarget {
    case gallery
    case files
}

final class VideoDownloader {

    static func download(
        from urlString: String,
        fileName: String,
        target: VideoDownloadTarget,
        completion: @escaping (URL?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let safeURL = caches.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: safeURL.path) {
                    try FileManager.default.removeItem(at: safeURL)
                }
                try FileManager.default.copyItem(at: tempURL, to: safeURL)
            } catch {
                print("Error copying file to safe location: \(error)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            switch target {
            case .gallery:
                saveToGallery(videoURL: safeURL) { success in
                    DispatchQueue.main.async { completion(success ? safeURL : nil) }
                }
            case .files:
                let exportedURL = moveToDocuments(tempURL: tempURL, fileName: fileName)
                DispatchQueue.main.async { completion(exportedURL) }
            }

        }.resume()
    }
}

// MARK: - Helpers
private extension VideoDownloader {

    static func moveToDocuments(tempURL: URL, fileName: String) -> URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documents.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: tempURL, to: destination)
            return destination
        } catch {
            print("Error copying file to documents: \(error)")
            return nil
        }
    }
    
    static func saveToGallery(videoURL: URL, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }, completionHandler: { success, error in
                if let error = error {
                    print("Error saving video to gallery: \(error)")
                }
                DispatchQueue.main.async { completion(success) }
            })
        }
    }
}
