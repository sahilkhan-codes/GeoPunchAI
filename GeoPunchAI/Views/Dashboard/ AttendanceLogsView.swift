import SwiftUI
import FirebaseFirestore

// MARK: - Attendance Log Data Model
struct AttendanceLogItem: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let checkInTime: Date
    let checkOutTime: Date?
    let totalHours: Double?
    let latitude: Double
    let longitude: Double
    let isWithinGeofence: Bool
    let status: String // "ACTIVE" or "COMPLETED"
    
    var formattedCheckIn: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: checkInTime)
    }
    
    var formattedCheckOut: String {
        guard let checkOut = checkOutTime else { return "In Progress" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: checkOut)
    }
    
    var formattedDuration: String {
        guard let hours = totalHours else { return "--" }
        let totalMinutes = Int(hours / 60)
        let hrs = totalMinutes / 60
        let mins = totalMinutes % 60
        return "\(hrs)h \(mins)m"
    }
}

// MARK: - Main Attendance Logs View
struct AttendanceLogsView: View {
    @StateObject private var viewModel = AttendanceLogsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Header
                HStack(spacing: 16) {
                    SummaryCard(
                        title: "Total Logs",
                        value: "\(viewModel.logs.count)",
                        icon: "doc.text.fill",
                        color: .blue
                    )
                    SummaryCard(
                        title: "Active Now",
                        value: "\(viewModel.activeCount)",
                        icon: "person.badge.clock.fill",
                        color: .green
                    )
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Real-time Logs List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading attendance logs...")
                    Spacer()
                } else if viewModel.logs.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No attendance records found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.logs) { log in
                            AttendanceLogRow(log: log)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        viewModel.startListening()
                    }
                }
            }
            .navigationTitle("Attendance Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.startListening()
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
}

// MARK: - Summary Card Component
private struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Single Log Row Component
private struct AttendanceLogRow: View {
    let log: AttendanceLogItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.userName)
                    .font(.headline)
                
                Spacer()
                
                // Status Badge
                Text(log.status == "ACTIVE" ? "ACTIVE SHIFT" : "COMPLETED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.status == "ACTIVE" ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .foregroundColor(log.status == "ACTIVE" ? .green : .gray)
                    .cornerRadius(6)
            }
            
            HStack {
                Label(log.formattedCheckIn, systemImage: "arrow.right.to.line.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Label(log.formattedCheckOut, systemImage: "arrow.left.to.line.circle.fill")
                    .font(.caption)
                    .foregroundColor(log.checkOutTime == nil ? .orange : .red)
            }
            
            HStack {
                // Geofence status tag
                Label(
                    log.isWithinGeofence ? "In Geofence" : "Outside Geofence",
                    systemImage: log.isWithinGeofence ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                )
                .font(.caption2)
                .foregroundColor(log.isWithinGeofence ? .blue : .red)
                
                Spacer()
                
                if log.totalHours != nil {
                    Text("Duration: \(log.formattedDuration)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ViewModel (Real-Time Firestore Sync)
class AttendanceLogsViewModel: ObservableObject {
    @Published var logs: [AttendanceLogItem] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var activeCount: Int {
        logs.filter { $0.status == "ACTIVE" }.count
    }
    
    func startListening() {
        isLoading = true
        listener?.remove()
        
        listener = db.collection("attendance_logs")
            .order(by: "checkInTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.logs = []
                        return
                    }
                    
                    self.logs = documents.compactMap { doc in
                        try? doc.data(as: AttendanceLogItem.self)
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}
