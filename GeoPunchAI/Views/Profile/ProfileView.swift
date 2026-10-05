import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var updatedName = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Profile Image Section
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 110, height: 110)
                                    .foregroundColor(.blue.opacity(0.8))
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        
                        Text(authManager.currentUserData?.name ?? "Employee Name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUserData?.email ?? "user@email.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Details Cards
                    VStack(spacing: 16) {
                        
                        // Edit Name Field
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            if isEditing {
                                TextField("Full Name", text: $updatedName)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Full Name")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(authManager.currentUserData?.name ?? "Sahil Khan")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if isEditing {
                                    // Save changes logic
                                    isEditing = false
                                } else {
                                    updatedName = authManager.currentUserData?.name ?? ""
                                    isEditing = true
                                }
                            }) {
                                Text(isEditing ? "Save" : "Edit")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        
                        // Role Field
                        HStack {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Designation / Role")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(authManager.currentUserRole.rawValue.capitalized)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Logout Button
                    Button(action: {
                        try? authManager.logout()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout Session")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}
