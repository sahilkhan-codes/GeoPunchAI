import SwiftUI
import FirebaseFirestore

struct AttendanceLogsView: View {
    @State private var logs: [AttendanceRecord] = []
    @State private var isLoading = true
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    if isLoading {
                        ProgressView("Fetching attendance logs...")
                            .padding()
                    } else if logs.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No attendance records found.")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        List(logs) { record in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.userName)
                                        .font(.headline)
                                    Spacer()
                                    Text(record.status)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(record.status == "ACTIVE" ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                                        .foregroundColor(record.status == "ACTIVE" ? .green : .blue)
                                        .clipShape(Capsule())
                                }
                                
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                        .foregroundColor(.green)
                                    Text("In: \(formatDate(record.checkInTime))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let checkOut = record.checkOutTime {
                                    HStack {
                                        Image(systemName: "arrow.up.circle")
                                            .foregroundColor(.red)
                                        Text("Out: \(formatDate(checkOut))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Attendance Logs")
            .onAppear {
                fetchLogs()
            }
        }
    }
    
    private func fetchLogs() {
        db.collection("attendance_logs")
            .order(by: "checkInTime", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let documents = snapshot?.documents {
                        self.logs = documents.compactMap { doc in
                            try? doc.data(as: AttendanceRecord.self)
                        }
                    }
                }
            }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
