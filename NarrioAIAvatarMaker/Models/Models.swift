//
//  Models.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatarURL: String?
    var subscription: SubscriptionPlan
    var videosCreatedThisMonth: Int
    var totalVideos: Int
    
    static let mock = User(
        id: UUID(),
        name: "Sarah",
        email: "sarah@example.com",
        avatarURL: nil,
        subscription: .free,
        videosCreatedThisMonth: 4,
        totalVideos: 12
    )
}

// MARK: - Subscription
enum SubscriptionPlan: String, Codable, CaseIterable {
    case free = "Free Plan"
    case proWeekly = "Pro Weekly"
    case proYearly = "Pro Yearly"
    
    var displayName: String { rawValue }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .proWeekly: return "$4.99/week"
        case .proYearly: return "$39.99/year"
        }
    }
    
    var videosPerMonth: Int {
        switch self {
        case .free: return 3
        case .proWeekly, .proYearly: return .max
        }
    }
    
    var isPro: Bool {
        self != .free
    }
}

// MARK: - Avatar Model
struct Avatar: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var imageURL: String
    var thumbnailURL: String
    var gender: Gender
    var style: AvatarStyle
    var isCustom: Bool
    var createdAt: Date
    var heygenAvatarId: String?
    var localImageData: Data?
    
    static let mockAvatars: [Avatar] = [
        Avatar(id: UUID(), name: "Alice", imageURL: "avatar_alice", thumbnailURL: "avatar_alice_thumb", gender: .female, style: .casual, isCustom: false, createdAt: Date()),
        Avatar(id: UUID(), name: "Mark", imageURL: "avatar_mark", thumbnailURL: "avatar_mark_thumb", gender: .male, style: .formal, isCustom: false, createdAt: Date()),
        Avatar(id: UUID(), name: "Sarah Chen", imageURL: "avatar_sarah", thumbnailURL: "avatar_sarah_thumb", gender: .female, style: .formal, isCustom: true, createdAt: Date()),
        Avatar(id: UUID(), name: "James", imageURL: "avatar_james", thumbnailURL: "avatar_james_thumb", gender: .male, style: .casual, isCustom: false, createdAt: Date()),
    ]
    
    static func fromHeyGen(_ heyGenAvatar: HeyGenAvatar) -> Avatar {
        let gender: Gender = {
            switch heyGenAvatar.gender?.lowercased() {
            case "male", "m":
                return .male
            case "female", "f":
                return .female
            default:
                return .female
            }
        }()

        return Avatar(
            id: UUID(),
            name: heyGenAvatar.name,
            imageURL: heyGenAvatar.previewImageURL ?? "",
            thumbnailURL: heyGenAvatar.previewImageURL ?? "",
            gender: gender,
            style: .formal,
            isCustom: false,
            createdAt: Date(),
            heygenAvatarId: heyGenAvatar.id
        )
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    
    var icon: String {
        switch self {
        case .male: return "👨"
        case .female: return "👩"
        }
    }
}

enum AvatarStyle: String, Codable, CaseIterable {
    case formal = "Formal"
    case casual = "Casual"
    case all = "All Styles"
}

// MARK: - Voice Model
struct Voice: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var gender: Gender
    var accent: String
    var previewURL: String?
    var heygenVoiceId: String?
    var languageCode: String?
    var supportsEmotion: Bool
    
    var subtitle: String {
        "\(gender.rawValue.lowercased()) • \(accent)"
    }
    
    var normalName: String {
        name
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var hasPreview: Bool {
        guard let url = previewURL, !url.isEmpty else { return false }
        return true
    }
    
    init(id: String, name: String, gender: Gender, accent: String, previewURL: String? = nil, heygenVoiceId: String? = nil, languageCode: String? = nil, supportsEmotion: Bool = false) {
        self.id = id
        self.name = name
        self.gender = gender
        self.accent = accent
        self.previewURL = previewURL
        self.heygenVoiceId = heygenVoiceId
        self.languageCode = languageCode
        self.supportsEmotion = supportsEmotion
    }
    
    static func fromHeyGen(_ heyGenVoice: HeyGenVoice) -> Voice {
        let gender: Gender = {
            switch heyGenVoice.gender?.lowercased() {
            case "male", "m": return .male
            case "female", "f": return .female
            default: return .female
            }
        }()
        
        let accent = heyGenVoice.language ?? heyGenVoice.languageCode ?? "Unknown"
        
        return Voice(
            id: heyGenVoice.voiceId,
            name: heyGenVoice.name ?? heyGenVoice.voiceId,
            gender: gender,
            accent: accent,
            previewURL: heyGenVoice.previewAudio,
            heygenVoiceId: heyGenVoice.voiceId,
            languageCode: heyGenVoice.languageCode,
            supportsEmotion: heyGenVoice.emotion ?? false
        )
    }
}

// MARK: - Voice Tone
enum VoiceTone: String, Codable, CaseIterable {
    case professional = "Professional"
    case friendly = "Friendly"
    case educational = "Educational"
    case casual = "Casual"
    
    var icon: ImageResource {
        switch self {
        case .professional: return .professional
        case .friendly: return .friendly
        case .educational: return .educ
        case .casual: return .casual
        }
    }
    
    var description: String {
        switch self {
        case .professional: return "Formal and business-like"
        case .friendly: return "Warm and approachable"
        case .educational: return "Informative and clear"
        case .casual: return "Relaxed and conversational"
        }
    }
}

// MARK: - Language
struct Language: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var code: String
    var flag: String
    
    static let languages: [Language] = [
        Language(id: UUID(), name: "English (US)", code: "en-US", flag: "🇺🇸"),
        Language(id: UUID(), name: "English (UK)", code: "en-GB", flag: "🇬🇧"),
        Language(id: UUID(), name: "Spanish", code: "es", flag: "🇪🇸"),
        Language(id: UUID(), name: "French", code: "fr", flag: "🇫🇷"),
        Language(id: UUID(), name: "German", code: "de", flag: "🇩🇪"),
        Language(id: UUID(), name: "Russian", code: "ru", flag: "🇷🇺"),
    ]
}

// MARK: - Background
struct Background: Identifiable, Hashable {
    let id: UUID
    var name: String
    var type: BackgroundType
    var colors: [Color]?
    var imageURL: String?
    var imageName: String?
    
    func imageData() -> Data? {
        guard
            let imageName,
            let uiImage = UIImage(named: imageName)
        else { return nil }
        
        return uiImage.jpegData(compressionQuality: 0.9)
    }
    
    static let backgrounds: [Background] = [
        Background(id: UUID(), name: "Ocean Blue", type: .gradient, colors: [Color(hex: "667eea"), Color(hex: "764ba2")], imageURL: nil),
        Background(id: UUID(), name: "Sunset", type: .gradient, colors: [Color(hex: "f093fb"), Color(hex: "f5576c")], imageURL: nil),
        Background(id: UUID(), name: "Fresh Mint", type: .gradient, colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")], imageURL: nil),
        Background(id: UUID(), name: "Warm Fire", type: .gradient, colors: [Color(hex: "fa709a"), Color(hex: "fee140")], imageURL: nil),
        Background(id: UUID(), name: "Pure White", type: .solid, colors: [.white], imageURL: nil),
        Background(id: UUID(), name: "Soft Gray", type: .solid, colors: [Color(hex: "F3F4F6")], imageURL: nil),
        Background(id: UUID(), name: "Deep Dark", type: .solid, colors: [Color(hex: "1F2937")], imageURL: nil),
        Background(id: UUID(), name: "Navy", type: .solid, colors: [Color(hex: "1E3A8A")], imageURL: nil),
        Background(
            id: UUID(),
            name: "Background 1",
            type: .image,
            imageName: "firstBackgroundImage"
        ),

        Background(
            id: UUID(),
            name: "Background 2",
            type: .image,
            imageName: "secondBack"
        ),

        Background(
            id: UUID(),
            name: "Background 3",
            type: .image,
            imageName: "thirdBack"
        ),

        Background(
            id: UUID(),
            name: "Background 4",
            type: .image,
            imageName: "fourthBack"
        ),

        Background(
            id: UUID(),
            name: "Background 5",
            type: .image,
            imageName: "fifthBack"
        ),

        Background(
            id: UUID(),
            name: "Background 6",
            type: .image,
            imageName: "sixthBack"
        ),

        Background(
            id: UUID(),
            name: "Background 7",
            type: .image,
            imageName: "seventhBack"
        ),

        Background(
            id: UUID(),
            name: "Background 8",
            type: .image,
            imageName: "the8thBack"
        ),

        Background(
            id: UUID(),
            name: "Background 9",
            type: .image,
            imageName: "ninthBack"
        ),

        Background(
            id: UUID(),
            name: "Background 10",
            type: .image,
            imageName: "tenthBack"
        )
    ]
}

enum BackgroundType: String, CaseIterable {
    case all = "All"
    case gradient = "Gradients"
    case solid = "Solid"
    case image = "Image"
}

// MARK: - Project/Video Model
struct Project: Identifiable, Codable {
    let id: UUID
    var title: String
    var thumbnailURL: String
    var status: ProjectStatus
    var duration: TimeInterval
    var createdAt: Date
    var language: String
    var avatarName: String
    var voiceName: String
    var script: String
    var taskId: String?
    var videoURL: String?
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: createdAt)
    }
}

enum ProjectStatus: String, Codable, CaseIterable {
    case ready = "Ready"
    case inProgress = "In Progress"
    case notStarted = "Not Started"
    case planned = "Planned"
    case failed = "Failed"
    
    var color: Color {
        switch self {
        case .ready: return AppColors.statBackground
        case .inProgress: return AppColors.statBackground
        case .notStarted: return .gray
        case .planned: return .orange
        case .failed: return .red
        }
    }
}

// MARK: - Video Template
struct VideoTemplateBase {
    let id: UUID
    let title: String
    let category: String
    let duration: String
    let thumbnailURL: String
    let script: String
    let background: Background
    
    static let templates: [VideoTemplateBase] = [
        VideoTemplateBase(
            id: UUID(),
            title: "Marketing Intro",
            category: "Marketing",
            duration: "30-60s",
            thumbnailURL: "template_1",
            script: """
            Welcome to our brand new product! In just a few moments, you’ll see how it can transform your business. \
            Our cutting-edge technology and intuitive design make it easy for you to get results faster than ever. \
            Whether you’re looking to increase engagement, boost productivity, or streamline your workflow, we’ve got you covered. \
            Join thousands of satisfied customers and start your journey toward success today! \
            We’ll also show you practical examples of how real businesses are leveraging this tool to save time and maximize results. \
            From beginner-friendly tips to advanced strategies, you’ll find everything you need to get started immediately. \
            By the end of this video, you’ll have a clear understanding of how to integrate this product into your daily operations, \
            unlocking its full potential and achieving remarkable outcomes.
            """,
            background: Background(
                id: UUID(),
                name: "Gradient Blue",
                type: .gradient,
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")]
            )
        ),
        VideoTemplateBase(
            id: UUID(),
            title: "Product Demo",
            category: "Product",
            duration: "60-90s",
            thumbnailURL: "template_2",
            script: """
            Introducing our latest product! Let’s take a closer look at its amazing features. \
            First, notice the sleek and modern design, crafted to be intuitive and user-friendly. \
            Next, explore the powerful tools integrated to help you achieve your goals quickly. \
            From automation to analytics, everything is designed to save you time and maximize productivity. \
            Our solution adapts to your workflow and grows with your business, making every step effortless. \
            Try it today and experience a new level of efficiency! \
            In this demo, we’ll guide you step by step through setup, customization, and tips to get the most out of every feature. \
            You’ll also learn hidden tricks and shortcuts that can significantly boost performance, \
            ensuring that your team can implement this solution seamlessly. \
            By the end of this demo, you’ll be confident in using the product for daily tasks and achieving results faster than ever before.
            """,
            background: Background(
                id: UUID(),
                name: "Light Grey",
                type: .solid,
                colors: [Color(hex: "f5f5f5")]
            )
        ),
        VideoTemplateBase(
            id: UUID(),
            title: "Tutorial",
            category: "Education",
            duration: "2-3min",
            thumbnailURL: "template_3",
            script: """
            Welcome to this comprehensive tutorial. Today, we’ll walk you through creating professional videos efficiently and easily. \
            First, gather all necessary resources and plan your content carefully. \
            Next, set up your scenes with attention to detail, making sure each shot aligns with your story. \
            Then, choose your avatar and voice carefully to match the tone of your message. \
            Add engaging visuals, animations, and captions to make your content clear and attractive. \
            Remember to preview frequently, adjusting timing, transitions, and effects to keep everything smooth. \
            Once you’re satisfied, export your video and share it with your audience. \
            In addition, we’ll cover advanced tips like optimizing video length, pacing, and audience engagement. \
            You’ll also learn how to incorporate branding elements, music, and subtitles to make your tutorial more professional. \
            By following these steps thoroughly, you’ll create polished, professional videos that leave a lasting impression and can be reused for multiple purposes.
            """,
            background: Background(
                id: UUID(),
                name: "Gradient Green",
                type: .gradient,
                colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")]
            )
        ),
        VideoTemplateBase(
            id: UUID(),
            title: "Sales Pitch",
            category: "Sales",
            duration: "30-60s",
            thumbnailURL: "template_4",
            script: """
            Are you ready to elevate your sales? Our solution is designed to help you close deals faster and smarter. \
            Highlighting the key benefits and unique advantages of your product, your clients will be convinced in no time. \
            With easy-to-follow workflows and actionable insights, you’ll increase engagement and drive results quickly. \
            Don’t wait—take the first step towards exponential growth today! \
            In this extended version, we’ll dive deeper into case studies, client testimonials, and proven strategies that ensure success. \
            You’ll discover practical examples of implementing our solution in different industries and the measurable impact it brings. \
            By the end of this pitch, you’ll have a complete understanding of how to maximize ROI and achieve rapid growth for your business.
            """,
            background: Background(
                id: UUID(),
                name: "Gradient Orange",
                type: .gradient,
                colors: [Color(hex: "fa709a"), Color(hex: "fee140")]
            )
        ),
        VideoTemplateBase(
            id: UUID(),
            title: "Evening Insights",
            category: "Lifestyle",
            duration: "45-60s",
            thumbnailURL: "template_5",
            script: """
            Good evening! Let’s explore tips and insights to make the most of your evening routine. \
            From productivity hacks to relaxation techniques, we’ll cover simple yet effective ways to enhance your daily life. \
            Discover how small adjustments can bring balance, clarity, and joy to your evenings. \
            By the end of this video, you’ll have actionable strategies to unwind, recharge, and prepare for a successful tomorrow.
            """,
            background: Background(
                id: UUID(),
                name: "Dark Blue",
                type: .solid,
                colors: [Color(hex: "0a1f44")]
            )
        ),

        VideoTemplateBase(
            id: UUID(),
            title: "Outdoor Fitness Tips",
            category: "Health",
            duration: "60s",
            thumbnailURL: "template_6",
            script: """
            Ready to boost your outdoor workouts? In this quick session, we’ll show essential exercises and tips \
            for maximizing fitness while enjoying nature. Stay motivated, improve your endurance, and achieve your goals efficiently. \
            Learn how to combine cardio, strength, and flexibility routines in just minutes a day.
            """,
            background: Background(
                id: UUID(),
                name: "Green Field",
                type: .gradient,
                colors: [Color(hex: "76b852"), Color(hex: "8DC26F")]
            )
        ),

        VideoTemplateBase(
            id: UUID(),
            title: "Business Strategy Overview",
            category: "Business",
            duration: "2-3min",
            thumbnailURL: "template_7",
            script: """
            Welcome to our business strategy overview. In this session, we’ll cover actionable insights \
            to grow your company, optimize processes, and improve team performance. \
            Learn from real-life case studies and discover techniques used by top companies to achieve scalable success.
            """,
            background: Background(
                id: UUID(),
                name: "Office Blue",
                type: .solid,
                colors: [Color(hex: "1E3C72")]
            )
        ),

        VideoTemplateBase(
            id: UUID(),
            title: "Casual Tech Review",
            category: "Tech",
            duration: "1-2min",
            thumbnailURL: "template_8",
            script: """
            Today we’re reviewing the latest tech gadgets casually and clearly. \
            From smartphones to smart home devices, get a quick overview of their features, pros, and cons. \
            By the end, you’ll have the knowledge to choose what fits your lifestyle best.
            """,
            background: Background(
                id: UUID(),
                name: "Tech Grey",
                type: .solid,
                colors: [Color(hex: "d3d3d3")]
            )
        )
    ]
}

struct VideoTemplate: Identifiable {
    let id: UUID
    var title: String
    var category: String
    var duration: String
    var thumbnailURL: String

    var script: String
    var avatar: Avatar
    var voice: Voice
    var background: Background
}


// MARK: - Onboarding Page
struct OnboardingPage: Identifiable {
    let id = UUID()
    var title: String
    var highlightedText: String
    var description: String
    var imageName: String
    
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "User choice",
            highlightedText: "Our App",
            description: "Turn your script into a realistic\nAI video in minutes",
            imageName: "onboarding_1"
        ),
        OnboardingPage(
            title: "Create",
            highlightedText: "Custom Avatars",
            description: "Create lifelike avatars from photos\nwith natural expressions",
            imageName: "onboarding_2"
        ),
        OnboardingPage(
            title: "We value",
            highlightedText: "your feedback",
            description: "Share your opinion about\nour app to make it better",
            imageName: "onboarding_3"
        ),
        OnboardingPage(
            title: "Exclusive",
            highlightedText: "access",
            description: "Discover amazing features that will enhance\nyour journey and make it more engaging",
            imageName: "onboarding_4"
        ),
    ]
}

// MARK: - Create Video State
struct CreateVideoState {
    var script: String = ""
    var voiceTone: VoiceTone = .professional
    var language: Language = Language.languages[0]
    var selectedAvatar: Avatar?
    var selectedVoice: Voice?
    var selectedBackground: Background?
    var currentStep: CreateVideoStep = .script
    var currentTaskId: String?
    var currentProjectId: UUID?
    
    var estimatedDuration: TimeInterval {
        let wordCount = script.split(separator: " ").count
        return Double(wordCount) / 150.0 * 60.0
    }
    
    var formattedEstimatedDuration: String {
        let minutes = Int(estimatedDuration) / 60
        let seconds = Int(estimatedDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

enum CreateVideoStep: Int, CaseIterable {
    case script = 0
    case avatar = 1
    case voice = 2
    case background = 3
    case preview = 4
    
    var title: String {
        switch self {
        case .script: return "Script"
        case .avatar: return "Avatar"
        case .voice: return "Voice"
        case .background: return "Background"
        case .preview: return "Preview"
        }
    }
    
    var nextButtonTitle: String {
        switch self {
        case .script: return "Next"
        case .avatar: return "Next"
        case .voice: return "Next"
        case .background: return "Next"
        case .preview: return "Generate Video"
        }
    }
}

// MARK: - Video Generation
struct VideoGenerationProgress {
    var currentStep: GenerationStep = .analyzing
    var progress: Double = 0.0
    var remainingTime: Int = 180
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

enum GenerationStep: Int, CaseIterable {
    case analyzing = 0
    case preparingAvatar = 1
    case synthesizingVoice = 2
    case renderingVideo = 3
    case finalizing = 4
    
    var title: String {
        switch self {
        case .analyzing: return "Analyzing script"
        case .preparingAvatar: return "Preparing avatar"
        case .synthesizingVoice: return "Synthesizing voice"
        case .renderingVideo: return "Rendering video"
        case .finalizing: return "Finalizing..."
        }
    }
    
    var stepNumber: Int { rawValue + 1 }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct SavedTask: Codable, Identifiable {
    var id: UUID = UUID()
    let projectId: UUID
    let taskId: String
}

