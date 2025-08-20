//
//  ThumbCache.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-08-09.
//

import UIKit

actor Thumbnailer {
    static let shared = Thumbnailer()
    private var inflight: [String: Task<UIImage?, Never>] = [:]

    func image(url: URL, size: CGSize, scale: CGFloat) async -> UIImage? {
        
        let key = "\(url.path)#\(Int(size.width*scale))x\(Int(size.height*scale))"
        if let existing = inflight[key] { return await existing.value }

        let task = Task(priority: .userInitiated) { () -> UIImage? in
            downsampleImage(at: url, to: size, scale: scale)
        }
        inflight[key] = task
        let result = await task.value
        inflight[key] = nil
        return result
    }
}
