//
//  APIService.swift
//  SynthesiaAI
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class APIService: ObservableObject {

    static let shared = APIService()

    private let session: URLSession
    private let baseURL: String
    private let apiKey: String

    @Published var isLoading = false
    @Published var lastError: APIError?

    init(
        baseURL: String = APIConfig.baseURL,
        apiKey: String = APIConfig.apiKey
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)

        print("🟢 APIService init | baseURL = \(baseURL)")
    }

    private var defaultHeaders: [String: String] {
        [
            "X-Api-Key": apiKey,
            "Accept": "application/json"
        ]
    }

    // MARK: - Server

    func checkServerStatus() async throws -> Bool {
        print("➡️ checkServerStatus")
        let response: ServerStatusResponse = try await get(endpoint: "/status")
        print("⬅️ server status = \(response.status)")
        return response.status == "running"
    }

    // MARK: - Avatar

    func createAvatarFromPrompt(prompt: String, goFast: Bool = true) async throws -> String {
        print("➡️ createAvatarFromPrompt | goFast=\(goFast)")
        let formData = AvatarCreateRequest(prompt: prompt, goFast: goFast).toFormData()
        let response: TaskResponse = try await postFormData(
            endpoint: "/avatar/create",
            formData: formData
        )
        print("⬅️ avatar taskId = \(response.taskId)")
        return response.taskId
    }
    
    func getAllAvatarPresets() async throws -> [HeyGenAvatar] {
        print("➡️ getAllAvatarPresets")

        let task: TaskResponse = try await post(endpoint: "/heygen/all_avatars")
        print("🆔 avatars taskId = \(task.taskId)")

        _ = try await waitForTaskCompletion(taskId: task.taskId)

        let data = try await getTaskResult(taskId: task.taskId)
        print("📦 avatars result bytes = \(data.count)")

        let decoded = try JSONDecoder().decode(
            HeyGenTaskWrapper<[HeyGenAvatar]>.self,
            from: data
        )

        let avatars = decoded.answer.result
        print("⬅️ avatars count = \(avatars.count)")

        return avatars
    }

    func getAllVoices() async throws -> [HeyGenVoice] {
        print("➡️ getAllVoices")

        let task: TaskResponse = try await post(endpoint: "/heygen/all_voices")
        print("🆔 voices taskId = \(task.taskId)")

        _ = try await waitForTaskCompletion(taskId: task.taskId)

        let data = try await getTaskResult(taskId: task.taskId)
        print("📦 voices result bytes = \(data.count)")

        let decoded = try JSONDecoder().decode(HeyGenVoicesResponse.self, from: data)
        print("⬅️ voices count = \(decoded.answer.result.count)")
        return decoded.answer.result
    }

    // MARK: - Video

    func createVideoFromPreset(request: VideoFromPresetsRequest) async throws -> String {
        print("➡️ createVideoFromPreset")

        let formData = request.toFormData()
        var files: [(String, Data, String)] = []

        if let audio = request.audioFile, let name = request.audioFileName {
            print("🎵 audio file = \(name), \(audio.count) bytes")
            files.append(("audio_file", audio, name))
        }
        if let bg = request.backgroundImage, let name = request.backgroundImageName {
            print("🖼 background image = \(name), \(bg.count) bytes")
            files.append(("background_image", bg, name))
        }

        let response: TaskResponse = try await postMultipartFormData(
            endpoint: "/heygen/create_from_presets",
            formData: formData,
            files: files
        )

        print("⬅️ video taskId = \(response.taskId)")
        return response.taskId
    }

    func createVideoFromImage(request: VideoFromImagesRequest) async throws -> String {
        print("➡️ createVideoFromImage")

        let formData = request.toFormData()
        var files: [(String, Data, String)] = [
            ("avatar_image", request.avatarImage, request.avatarImageName)
        ]

        print("🧍 avatar image = \(request.avatarImageName), \(request.avatarImage.count) bytes")

        if let audio = request.audioFile, let name = request.audioFileName {
            print("🎵 audio file = \(name), \(audio.count) bytes")
            files.append(("audio_file", audio, name))
        }
        if let bg = request.backgroundImage, let name = request.backgroundImageName {
            print("🖼 background image = \(name), \(bg.count) bytes")
            files.append(("background_image", bg, name))
        }

        let response: TaskResponse = try await postMultipartFormData(
            endpoint: "/heygen/create_from_images",
            formData: formData,
            files: files
        )

        print("⬅️ video taskId = \(response.taskId)")
        return response.taskId
    }
    
    private func postFormData<T: Decodable>(
        endpoint: String,
        formData: [String: String]
    ) async throws -> T {

        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = createFormDataBody(
            formData: formData,
            boundary: boundary
        )

        return try await performRequest(request)
    }

    private func postMultipartFormData<T: Decodable>(
        endpoint: String,
        formData: [String: String],
        files: [(fieldName: String, data: Data, fileName: String)]
    ) async throws -> T {

        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = createMultipartBody(
            formData: formData,
            files: files,
            boundary: boundary
        )

        return try await performRequest(request)
    }

    // MARK: - Task Status

    func getTaskStatus(taskId: String) async throws -> TaskStatusResponse {
        print("➡️ getTaskStatus | \(taskId)")
        let status: TaskStatusResponse = try await get(endpoint: "/task/status/\(taskId)")
        print("⬅️ task status = \(status.status)")
        if let error = status.error {
            print("🚫 Error: \(error)")
        }
        return status
    }

    func getTaskResult(taskId: String) async throws -> Data {
        print("➡️ getTaskResult | \(taskId)")

        guard let url = URL(string: "\(baseURL)/task/result/\(taskId)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        defaultHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError())
        }

        print("⬅️ result HTTP \(http.statusCode), bytes=\(data.count)")

        guard http.statusCode == 200 else {
            throw APIError.serverError("Failed to download task result")
        }

        return data
    }

    // MARK: - SAFE POLLING

    func waitForTaskCompletion(
        taskId: String,
        timeout: TimeInterval = 600,
        progressHandler: ((TaskStatusResponse) -> Void)? = nil
    ) async throws -> TaskStatusResponse {

        print("🔄 polling start | taskId=\(taskId)")

        let start = Date()
        var lastStatus: TaskStatus?

        while Date().timeIntervalSince(start) < timeout {

            try Task.checkCancellation()

            let status = try await getTaskStatus(taskId: taskId)
            progressHandler?(status)

            if status.status != lastStatus {
                print("📡 status changed → \(status.status)")
                lastStatus = status.status
            }

            switch status.status {
            case .completed:
                print("✅ task completed")
                return status

            case .failed:
                print("❌ task failed")
                throw APIError.taskFailed(status.error ?? "Unknown error")

            case .pending, .processing, .unknown:
                let elapsed = Date().timeIntervalSince(start)
                let delay: TimeInterval = elapsed < 30 ? 4 : elapsed < 120 ? 6 : 10
                print("⏳ sleep \(delay)s")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        print("⏰ polling timeout")
        throw APIError.taskFailed("Task timed out after \(timeout) seconds")
    }

    // MARK: - Networking Core

    private func get<T: Decodable>(endpoint: String) async throws -> T {
        print("➡️ GET \(endpoint)")
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        defaultHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        return try await performRequest(request)
    }

    private func post<T: Decodable>(
        endpoint: String,
        body: Encodable? = nil
    ) async throws -> T {

        print("➡️ POST \(endpoint)")
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }

        return try await performRequest(request)
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {

        isLoading = true
        defer { isLoading = false }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError())
        }

        print("⬅️ HTTP \(http.statusCode)")

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }

        if http.statusCode >= 400 {
            throw APIError.serverError(
                String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            )
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Multipart helpers

    private func createFormDataBody(
        formData: [String: String],
        boundary: String
    ) -> Data {

        var body = Data()

        for (key, value) in formData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                    .data(using: .utf8)!
            )
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    private func createMultipartBody(
        formData: [String: String],
        files: [(fieldName: String, data: Data, fileName: String)],
        boundary: String
    ) -> Data {

        var body = Data()

        for (key, value) in formData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                    .data(using: .utf8)!
            )
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        for file in files {
            let mime = mimeTypeForPath(file.fileName)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n"
                    .data(using: .utf8)!
            )
            body.append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    private func mimeTypeForPath(_ path: String) -> String {
        switch (path as NSString).pathExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "mp4": return "video/mp4"
        default: return "application/octet-stream"
        }
    }

    func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError("Failed to download image")
        }

        return data
    }
}



