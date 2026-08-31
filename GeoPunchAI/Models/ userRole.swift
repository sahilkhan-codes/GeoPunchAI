import Foundation

enum UserRole: String, Codable {
    case admin = "admin"
    case employee = "employee"
}

struct AppUser: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var role: UserRole
    var geofenceId: String?
    var faceEmbedding: [Float]?
}
