//
//  APIModels.swift
//  SynthesiaAI
//

import Foundation

enum APIConfig {
    static let baseURL = "https://api.synthia.pro"
    static let apiKey = "3gonPzWKtHxP9liEZDG5YFQRAuinLZQS2ZedvVQmyl9QVVj954jssNYC6EfjYnXx"
}

struct ServerStatusResponse: Codable {
    let status: String
}

struct TaskResponse: Codable {
    let taskId: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
    }
}

struct TaskStatusResponse: Codable {
    let status: TaskStatus
    let type: String?
    let imagePath: String?
    let videoUrl: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case type
        case imagePath = "image_path"
        case videoUrl = "video_url"
        case error
    }
}

enum TaskStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = TaskStatus(rawValue: value) ?? .unknown
    }
}

struct AvatarCreateRequest {
    let prompt: String
    let goFast: Bool
    
    func toFormData() -> [String: String] {
        return [
            "prompt": prompt,
            "go_fast": goFast ? "true" : "false"
        ]
    }
}

struct HeyGenTaskWrapper<T: Decodable>: Decodable {
    let answer: HeyGenTaskAnswer<T>
}

struct HeyGenTaskAnswer<T: Decodable>: Decodable {
    let status: String
    let result: T
}

struct HeyGenAvatar: Decodable, Identifiable {
    let id: String
    let name: String
    let gender: String?
    let premium: Int
    let previewImageURL: String?
    let previewVideoURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "avatar_id"
        case name = "avatar_name"
        case gender
        case premium
        case previewImageURL = "preview_image_url"
        case previewVideoURL = "preview_video_url"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        gender = try c.decodeIfPresent(String.self, forKey: .gender)
        if let intPremium = try? c.decode(Int.self, forKey: .premium) {
            premium = intPremium
        } else if let boolPremium = try? c.decode(Bool.self, forKey: .premium) {
            premium = boolPremium ? 1 : 0
        } else {
            premium = 0
        }
        previewImageURL = try c.decodeIfPresent(String.self, forKey: .previewImageURL)
        previewVideoURL = try c.decodeIfPresent(String.self, forKey: .previewVideoURL)
    }
}

struct HeyGenVoice: Codable, Identifiable {
    let voiceId: String
    let name: String?
    let language: String?
    let languageCode: String?
    let gender: String?
    let previewAudio: String?
    let supportPause: Bool?
    let emotion: Bool?
    
    var id: String { voiceId }
    
    enum CodingKeys: String, CodingKey {
        case voiceId = "voice_id"
        case name
        case language
        case languageCode = "language_code"
        case gender
        case previewAudio = "preview_audio"
        case supportPause = "support_pause"
        case emotion
    }
}

struct HeyGenVoicesResponse: Codable {
    let answer: Answer
    
    struct Answer: Codable {
        let status: String
        let result: [HeyGenVoice]
    }
}

struct VideoFromPresetsRequest {
    let width: Int
    let height: Int
    let avatarId: String
    let voiceId: String?
    let inputText: String?
    let audioFile: Data?
    let audioFileName: String?
    let speed: Double?
    let pitch: Int?
    let emotion: VoiceEmotion?
    let locale: String?
    let backgroundColor: String?
    let backgroundImage: Data?
    let backgroundImageName: String?
    
    func toFormData() -> [String: String] {
        var data: [String: String] = [
            "width": "\(width)",
            "height": "\(height)",
            "avatar_id": avatarId
        ]
        
        if let voiceId = voiceId {
            data["voice_id"] = voiceId
        }
        if let inputText = inputText {
            data["input_text"] = inputText
        }
        if let speed = speed {
            data["speed"] = "\(speed)"
        }
        if let pitch = pitch {
            data["pitch"] = "\(pitch)"
        }
        if let emotion = emotion {
            data["emotion"] = emotion.rawValue
        }
        if let locale = locale {
            data["locale"] = locale
        }
        if let backgroundColor = backgroundColor {
            data["background_color"] = backgroundColor
        }
        
        return data
    }
}

struct VideoFromImagesRequest {
    let width: Int
    let height: Int
    let avatarImage: Data
    let avatarImageName: String
    let voiceId: String?
    let inputText: String?
    let audioFile: Data?
    let audioFileName: String?
    let speed: Double?
    let pitch: Int?
    let emotion: VoiceEmotion?
    let locale: String?
    let backgroundColor: String?
    let backgroundImage: Data?
    let backgroundImageName: String?
    
    func toFormData() -> [String: String] {
        var data: [String: String] = [
            "width": "\(width)",
            "height": "\(height)"
        ]
        
        if let voiceId = voiceId {
            data["voice_id"] = voiceId
        }
        if let inputText = inputText {
            data["input_text"] = inputText
        }
        if let speed = speed {
            data["speed"] = "\(speed)"
        }
        if let pitch = pitch {
            data["pitch"] = "\(pitch)"
        }
        if let emotion = emotion {
            data["emotion"] = emotion.rawValue
        }
        if let locale = locale {
            data["locale"] = locale
        }
        if let backgroundColor = backgroundColor {
            data["background_color"] = backgroundColor
        }
        
        return data
    }
}

enum VoiceEmotion: String, Codable, CaseIterable {
    case excited = "Excited"
    case friendly = "Friendly"
    case serious = "Serious"
    case soothing = "Soothing"
    case broadcaster = "Broadcaster"
}

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case networkError(Error)
    case unauthorized
    case taskFailed(String)
    case fileNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Check your API key."
        case .taskFailed(let message):
            return "Task failed: \(message)"
        case .fileNotFound(let message):
            return "File failed: \(message)"
        }
    }
}

struct VideoDimensions {
    let width: Int
    let height: Int
    
    static let landscape = VideoDimensions(width: 1920, height: 1080)
    static let portrait = VideoDimensions(width: 1080, height: 1920)
    static let square = VideoDimensions(width: 1080, height: 1080)
    static let hdPortrait = VideoDimensions(width: 1280, height: 720)
}

// MARK: - Task Result Response

struct TaskResultResponse: Decodable {
    let status: String
    let type: String
    let stage: String
    let result: ResultContainer
}

struct ResultContainer: Decodable {
    let message: String
    let code: Int
    let data: VideoResultData
}

struct VideoResultData: Decodable {
    let id: String
    let status: String
    let video_url: String
    let thumbnail_url: String?
    let gif_url: String?
    let duration: Double?
    let error: String?
}
