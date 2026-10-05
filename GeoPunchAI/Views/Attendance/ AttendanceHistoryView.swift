import SwiftUI
import FirebaseFirestore

struct AttendanceHistoryView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var attendanceLogs: [AttendanceRecord] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading attendance history...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            fetchHistoryLogs()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if attendanceLogs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Attendance Logs Found")
                            .font(.headline)
                        Text("Your shift history will appear here once you punch in.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(attendanceLogs) { record in
                            AttendanceLogRow(record: record)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        fetchHistoryLogs()
                    }
                }
            }
            .navigationTitle("Attendance History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchHistoryLogs()
            }
        }
    }
    
    private func fetchHistoryLogs() {
        guard let userId = authManager.currentUserData?.id else {
            self.errorMessage = "User not authenticated."
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        db.collection("attendance_logs")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Failed to load logs: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.attendanceLogs = []
                        return
                    }
                    
                    self.attendanceLogs = documents.compactMap { doc -> AttendanceRecord? in
                        let data = doc.data()
                        let id = doc.documentID
                        let userName = data["userName"] as? String ?? "Employee"
                        
                        let checkInTimestamp = data["checkInTime"] as? Timestamp
                        let checkInTime = checkInTimestamp?.dateValue() ?? Date()
                        
                        let checkOutTimestamp = data["checkOutTime"] as? Timestamp
                        let checkOutTime = checkOutTimestamp?.dateValue()
                        
                        let status = data["status"] as? String ?? "ACTIVE"
                        let isWithinGeofence = data["isWithinGeofence"] as? Bool ?? true
                        
                        let latitude = data["latitude"] as? Double ?? 0.0
                        let longitude = data["longitude"] as? Double ?? 0.0
                        
                        // Calculated TimeInterval with unwrapped non-optional value
                        let totalHours: TimeInterval = {
                            if let storedHours = data["totalHours"] as? Double {
                                return storedHours
                            } else if let checkOut = checkOutTime {
                                return checkOut.timeIntervalSince(checkInTime) / 3600.0
                            }
                            return 0.0
                        }()
                        
                        // Parameter order matched exactly with struct definition
                        return AttendanceRecord(
                            id: id,
                            userId: userId,
                            userName: userName,
                            checkInTime: checkInTime,
                            checkOutTime: checkOutTime,
                            totalHours: totalHours,
                            latitude: latitude,
                            longitude: longitude,
                            isWithinGeofence: isWithinGeofence,
                            status: status
                        )
                    }.sorted(by: { $0.checkInTime > $1.checkInTime })
                }
            }
    }
}

// MARK: - Individual Row Component
private struct AttendanceLogRow: View {
    let record: AttendanceRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Date & Status Badge
            HStack {
                Text(record.checkInTime, style: .date)
                    .font(.headline)
                
                Spacer()
                
                Text(record.status)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Divider()
            
            // Timestamps Layout
            HStack(spacing: 20) {
                // Check-in
                VStack(alignment: .leading, spacing: 4) {
                    Label("Check In", systemImage: "arrow.right.to.line.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text(record.checkInTime, style: .time)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Check-out
                VStack(alignment: .trailing, spacing: 4) {
                    Label("Check Out", systemImage: "arrow.left.to.line.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if let checkOut = record.checkOutTime {
                        Text(checkOut, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Text("In Progress")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Total Hours Footer
            if let hours = record.totalHours, hours > 0 {
                HStack {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "Total Hours: %.2f hrs", hours))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var statusColor: Color {
        switch record.status {
        case "COMPLETED":
            return .green
        case "ACTIVE":
            return .blue
        default:
            return .gray
        }
    }
}
