//
//  PhoneNumberField.swift
//  XpertCodeTest
//
//  Created by Luis Guzman on 12/7/26.
//

import SwiftUI

struct PhoneNumberField: View {
    @Binding var phoneNumber: String
    
    var body: some View {
        TextField("123-456-7890", text: $phoneNumber)
            .keyboardType(.numberPad)
            .onChange(of: phoneNumber) { oldValue, newValue in
                phoneNumber = format(newValue)
            }
    }
    
    private func format(_ input: String) -> String {
        // Strip everything except digits
        let digits = input.filter(\.isNumber)
        
        // Limit the numebr to 10 digits
        let limitedDigits = String(digits.prefix(10))
        
        var result = ""
        for (index, character) in limitedDigits.enumerated() {
            if index == 3 || index == 6 {
                result.append("-")
            }
            result.append(character)
        }
        return result
    }
}
