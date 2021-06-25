//
//  SignInWithEmailButton.swift
//  
//
//  Created by Esben Viskum on 20/06/2021.
//

import SwiftUI

public struct SignInWithEmailButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {
        
    }
    
    public var body: some View {
        HStack {
            Spacer()
            Image(systemName: "key")
            Text("Sign in with email")
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6.5)
                .stroke(colorScheme == .light ? Color.black : Color.white, lineWidth: 2)
        )
        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
    }

}

struct SignInWithEmailButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithEmailButton()
    }
}
