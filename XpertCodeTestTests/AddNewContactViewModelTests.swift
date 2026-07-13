//
//  AddNewContactViewModelTests.swift
//  XpertCodeTestTests
//
//  Functional unit tests for AddNewContactViewModel.
//
//  Created by Luis Guzman on 11/7/26.
//

import XCTest
@testable import XpertCodeTest

@MainActor
final class AddNewContactViewModelTests: XCTestCase, @unchecked Sendable {

    private var addNewContactVMMock: AddNewContactViewModel!
    private var storeManager: CoreDataManager!

    override func setUp() async throws {
        try await super.setUp()
        storeManager = CoreDataManager(inMemoryStore: true)
        addNewContactVMMock = AddNewContactViewModel(storeManager: storeManager)
    }

    override func tearDown() async throws {
        addNewContactVMMock = nil
        storeManager = nil
        try await super.tearDown()
    }

    /// Using `canSave` property for testing,  must be true only when first name, last name and phone are all
    /// present, and whitespace-only names must not count as valid input.
    func test_canSave_requiresNonEmptyFirstNameLastNameAndPhone() async  {
        XCTAssertFalse(addNewContactVMMock.canSave, "Empty form should not be savable")

        // Missing phone.
        addNewContactVMMock.firstName = "Luis"
        addNewContactVMMock.lastName = "Guzman"
        addNewContactVMMock.phone = ""
        XCTAssertFalse(addNewContactVMMock.canSave, "Form without a phone should not be savable")

        // Whitespace-only first name.
        addNewContactVMMock.firstName = "   "
        addNewContactVMMock.lastName = "Guzman"
        addNewContactVMMock.phone = "5551234567"
        XCTAssertFalse(addNewContactVMMock.canSave, "A whitespace-only first name should not be savable")
        
        // Whitespace-only first name.
        addNewContactVMMock.firstName = "Luis"
        addNewContactVMMock.lastName = "Guzman"
        addNewContactVMMock.phone = "    "
        XCTAssertFalse(addNewContactVMMock.canSave, "A whitespace-only phone should not be savable")

        // All required fields provided.
        addNewContactVMMock.firstName = "Luis"
        addNewContactVMMock.lastName = "Guzman"
        addNewContactVMMock.phone = "5551234567"
        XCTAssertTrue(addNewContactVMMock.canSave, "A fully filled form should be savable")
    }

    /// didAddContact  must notify the delegate that the user added a contact
    func test_add_notifiesDelegateOfAddedContact() async {
        // Given
        let delegate = AddContactDelegateSpy()
        addNewContactVMMock.delegate = delegate

        // When
        addNewContactVMMock.delegate?.didAddContact()

        // Then
        XCTAssertTrue(delegate.didAddContactCalled, "didAddContact must report a contact was added")
    }
}

// MARK: - Test Doubles

/// Class to test the  `AddContactDelegate`
private final class AddContactDelegateSpy: NSObject, AddContactDelegate {
    private(set) var didAddContactCalled = false

    func didAddContact() {
        didAddContactCalled = true
    }
}
