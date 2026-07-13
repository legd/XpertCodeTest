//
//  SwiftUIViewFactory.swift
//  XpertCodeTest
//
//  Created by Luis Guzman on 12/7/26.
//

import SwiftUI

@objc protocol AddContactDelegate: AnyObject {
    func didAddContact()
}

@objc final class SwiftUIViewFactory: NSObject {
    @MainActor @objc static func makeAddNewContactViewController(storeManager: CoreDataManager, delegate: AddContactDelegate?) -> UIViewController {
        let viewModel = AddNewContactViewModel(storeManager: storeManager)
        viewModel.delegate = delegate
        let view = AddNewContactView(viewModel: viewModel)
        return UIHostingController(rootView: view)
    }
}
