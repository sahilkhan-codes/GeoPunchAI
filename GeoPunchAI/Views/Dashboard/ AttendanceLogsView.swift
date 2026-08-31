//
//   AttendanceLogsView.swift
//  GeoPunchAI
import SwiftUI
import FirebaseFirestore

struct AttendanceLogsView: View {
    @State private var logs: [AttendanceRecord] = []
    @State private var isLoading = true
    private var db = Firestore.firestore()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Fetching attendance logs...")
            } else if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.plaintext")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No attendance records found.")
                        .foregroundColor(.secondary)
                }
            } else {
                List(logs) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(record.userEmail)
                                .font(.headline)
                            Spacer()
                            Text(record.status)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                        }
                        
                        HStack {
                            Label(record.verificationMethod, systemImage: "checkmark.shield")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if let date = record.timestamp {
                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Attendance Logs")
        .onAppear {
            fetchLiveAttendanceLogs()
        }
    }
    
    // Realtime listener from Firestore
    private func fetchLiveAttendanceLogs() {
        db.collection("attendance_logs")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching logs: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.logs = documents.compactMap { doc -> AttendanceRecord? in
                    try? doc.data(as: AttendanceRecord.self)
                }
            }
    }
}
