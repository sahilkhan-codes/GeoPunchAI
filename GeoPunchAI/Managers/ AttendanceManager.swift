import Foundation
import FirebaseFirestore
import CoreLocation

class AttendanceManager: ObservableObject {
    static let shared = AttendanceManager()
    private let db = Firestore.firestore()
    
    @Published var activeRecord: AttendanceRecord?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // 1. Punch In Action
    func punchIn(userId: String, userName: String, location: CLLocationCoordinate2D?, isInside: Bool, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        let newRecord = AttendanceRecord(
            userId: userId,
            userName: userName,
            checkInTime: Date(),
            checkOutTime: nil,
            totalHours: nil,
            latitude: location?.latitude ?? 0.0,
            longitude: location?.longitude ?? 0.0,
            isWithinGeofence: isInside,
            status: "ACTIVE"
        )
        
        do {
            let docRef = db.collection("attendance_logs").document()
            
            try docRef.setData(from: newRecord) { error in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    if let error = error {
                        self.errorMessage = "Failed to punch in: \(error.localizedDescription)"
                        completion(false)
                    } else {
                        var savedRecord = newRecord
                        savedRecord.id = docRef.documentID
                        self.activeRecord = savedRecord
                        completion(true)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    // 2. Punch Out Action
    func punchOut(recordId: String, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        let checkOutDate = Date()
        
        db.collection("attendance_logs").document(recordId).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, var record = try? snapshot.data(as: AttendanceRecord.self) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Record not found."
                    completion(false)
                }
                return
            }
            
            let duration = checkOutDate.timeIntervalSince(record.checkInTime)
            
            self.db.collection("attendance_logs").document(recordId).updateData([
                "checkOutTime": Timestamp(date: checkOutDate),
                "totalHours": duration,
                "status": "COMPLETED"
            ]) { err in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    if let err = err {
                        self.errorMessage = "Failed to punch out: \(err.localizedDescription)"
                        completion(false)
                    } else {
                        self.activeRecord = nil
                        completion(true)
                    }
                }
            }
        }
    }
    
    // 3. Fetch Active Shift for Current User
    func fetchActiveShift(userId: String) {
        db.collection("attendance_logs")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "ACTIVE")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents, let doc = documents.first {
                    DispatchQueue.main.async {
                        self.activeRecord = try? doc.data(as: AttendanceRecord.self)
                    }
                }
            }
    }
}
