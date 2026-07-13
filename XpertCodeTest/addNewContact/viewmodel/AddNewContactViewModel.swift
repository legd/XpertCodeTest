//
//  AddNewContactViewModel.swift
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

import Foundation
import Combine
import UIKit

enum AddContactImageError: LocalizedError {
    case invalidURL
    case noResult
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not build the request URL."
        case .noResult:
            return "The service returned no results."
        case .invalidImageData:
            return "The downloaded image data was invalid."
        }
    }
}

/// A tiny protocol around URLSession so tests can inject a fake network layer.
protocol AddContactImageFetching: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: AddContactImageFetching {}

@MainActor
final class AddNewContactViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published private(set) var profileImage: UIImage?
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoadingImage: Bool = false
    private let session: AddContactImageFetching = URLSession.shared
    private let randomUserEndpoint = URL(string: "https://randomuser.me/api/")!
    private var contactImageURL = ""

    weak var delegate: AddContactDelegate?
    private let storeManager: CoreDataManager

    init(storeManager: CoreDataManager) {
        self.storeManager = storeManager
    }

    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty && !lastName.trimmingCharacters(in: .whitespaces).isEmpty && !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil

        storeManager.createContact(withFirstName: firstName, lastName: lastName, phone: phone, imageURL: contactImageURL) { [weak self] result, error in
            guard let self else { return }
            self.isSaving = false
            
            if let error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.delegate?.didAddContact()
        }
    }
    
    func fetchRandomImage() async {
        isLoadingImage = true
        errorMessage = nil
        defer { isLoadingImage = false }

        do {
            let (data, _) = try await session.data(from: randomUserEndpoint)
            let decoded = try JSONDecoder().decode(RandomUserResponse.self, from: data)

            guard let result = decoded.results.first,
                  let imageURL = URL(string: result.picture.large) else {
                throw AddContactImageError.noResult
            }

            let (imageData, _) = try await session.data(from: imageURL)

            guard let image = UIImage(data: imageData) else {
                throw AddContactImageError.invalidImageData
            }
            
            self.contactImageURL = imageURL.absoluteString
            profileImage = image
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not load a random photo."
        }
    }
}
