//
//  AddContactUITests.swift
//  XpertCodeTestUITests
//
//  Created by Luis Guzman on 12/7/26.
//

import XCTest

@MainActor
final class AddContactUITests: XCTestCase, @unchecked Sendable {

    private var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITest_PresentAddNewContact"]
        app.launch()
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }

    func test_allFormElementsAreVisible() {
        XCTAssertTrue(app.otherElements["placeholderImage"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["saveButton"].exists)
        XCTAssertTrue(app.buttons["cancelButton"].exists)
        XCTAssertTrue(app.textFields["firstName"].exists)
        XCTAssertTrue(app.textFields["lastName"].exists)
        XCTAssertTrue(app.textFields["phone"].exists)
    }

    func test_saveButton_disabledUntilRequiredFieldsAreFilled() {
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertFalse(saveButton.isEnabled)

        app.textFields["firstName"].tap()
        app.textFields["firstName"].typeText("Luis")

        app.textFields["lastName"].tap()
        app.textFields["lastName"].typeText("Guzman")

        app.textFields["phone"].tap()
        app.textFields["phone"].typeText("1234567890")

        // Dismiss the keyboard so the toolbar buttons are hit-testable.
        app.toolbars.buttons.firstMatch.tap()

        XCTAssertTrue(saveButton.isEnabled)
    }

    func test_cancelButton_dismissesScreen() {
        let cancelButton = app.buttons["cancelButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()

        XCTAssertFalse(app.buttons["saveButton"].waitForExistence(timeout: 3))
    }
}
