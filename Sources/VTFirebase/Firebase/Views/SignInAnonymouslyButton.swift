//
//  SignInAnonymouslyButton.swift
//  
//
//  Created by Esben Viskum on 21/06/2021.
//

import SwiftUI

struct SignInAnonymouslyButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {
        
    }
    
    public var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.crop.circle.badge.questionmark")
            Text("Sign in anonymously")
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

struct SignInAnonymouslyButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInAnonymouslyButton()
    }
}
