import Foundation
import FirebaseFirestore

struct AttendanceRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userEmail: String
    var timestamp: Date?
    var status: String
    var verificationMethod: String
}
