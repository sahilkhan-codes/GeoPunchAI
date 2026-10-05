import Foundation
import SwiftUI

// MARK: - Offline Punch Model
struct OfflinePunchRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let isFaceVerified: Bool
    var syncStatus: SyncStatus
    
    enum SyncStatus: String, Codable {
        case pending = "Pending Sync"
        case synced = "Synced"
        case failed = "Sync Failed"
    }
}

// MARK: - Local Cache Manager
class LocalCacheManager: ObservableObject {
    static let shared = LocalCacheManager()
    
    @Published var cachedPunches: [OfflinePunchRecord] = []
    private let cacheKey = "GeoPunchAI_Offline_Punches"
    
    init() {
        loadCachedPunches()
    }
    
    func savePunchLocally(lat: Double, lon: Double, faceVerified: Bool) {
        let newRecord = OfflinePunchRecord(
            id: UUID(),
            timestamp: Date(),
            latitude: lat,
            longitude: lon,
            isFaceVerified: faceVerified,
            syncStatus: .pending
        )
        cachedPunches.append(newRecord)
        persistToUserDefaults()
    }
    
    func markAsSynced(id: UUID) {
        if let index = cachedPunches.firstIndex(where: { $0.id == id }) {
            cachedPunches[index].syncStatus = .synced
            persistToUserDefaults()
        }
    }
    
    private func persistToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(cachedPunches) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    private func loadCachedPunches() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([OfflinePunchRecord].self, from: data) {
            self.cachedPunches = decoded
        }
    }
}

// MARK: - Reusable UI Status Badge
struct StatusTagView: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
