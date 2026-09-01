import Foundation
import FirebaseFirestore

struct AttendanceRecord: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let checkInTime: Date
    var checkOutTime: Date?
    var totalHours: TimeInterval?
    let latitude: Double
    let longitude: Double
    let isWithinGeofence: Bool
    let status: String // "ACTIVE" or "COMPLETED"
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userName
        case checkInTime
        case checkOutTime
        case totalHours
        case latitude
        case longitude
        case isWithinGeofence
        case status
    }
}
