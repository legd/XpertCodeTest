//
//  AddNewContactView.swift
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

import SwiftUI

struct AddNewContactView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AddNewContactViewModel

    @FocusState private var focusedField: Field?

    private enum Field {
        case firstName, lastName, phone
    }
    
    @State private var avatarURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            avatarView
                                .accessibilityIdentifier("avatarImageView")

                            Button {
                                Task { await self.viewModel.fetchRandomImage() }
                            } label: {
                                if self.viewModel.isLoadingImage {
                                    ProgressView()
                                } else {
                                    Label("Cargar imagen aleatoria", systemImage: "arrow.clockwise")
                                }
                            }
                            .accessibilityIdentifier("randomImageButton")
                            .disabled(viewModel.isLoadingImage)

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                Section("Datos del Contacto") {
                    TextField("Nombre", text: $viewModel.firstName)
                        .accessibilityIdentifier("firstName")
                        .textContentType(.name)
                        .focused($focusedField, equals: .firstName)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .lastName }

                    TextField("Apellido", text: $viewModel.lastName)
                        .accessibilityIdentifier("lastName")
                        .textContentType(.familyName)
                        .focused($focusedField, equals: .phone)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .phone }
                    
                    PhoneNumberField(phoneNumber: $viewModel.phone)
                        .accessibilityIdentifier("phone")
                        .textContentType(.telephoneNumber)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .phone)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Nuevo Contacto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") {
                            viewModel.save()
                        }
                        .accessibilityIdentifier("saveButton")
                        .disabled(!viewModel.canSave)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        if let image = viewModel.profileImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(Circle())
        } else {
            placeholderImage
                .frame(width: 140, height: 140)
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("placeholderImage")
    }
}

#Preview {
    AddNewContactView(viewModel: AddNewContactViewModel(storeManager: CoreDataManager.shared))
}
