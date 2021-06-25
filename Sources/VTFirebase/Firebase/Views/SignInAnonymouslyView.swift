//
//  SignInAnonymouslyView.swift
//  Firebase Auth
//
//  Created by Esben Viskum on 09/06/2021.
//

import SwiftUI

public struct SignInAnonymouslyView: View {
    @State private var showError = false
    @State private var errorString = ""
    
    public var body: some View {
        Button(action: {
            // Sign In Anonymously
            FBAuth.signInAnonymously { (result) in
                switch result {
                case .failure(let error):
                    self.errorString = error.localizedDescription
                    self.showError = true
                case .success(let authDataResult):
                    FBAuth.handleAnonymousSignIn(authDataResult) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success( _):
                            print("Signed in anonymously successfully")
                        }
                    }
                }
            }
            
        }) {
            Text("Sign in Anonymously")
                .frame(width: 200)
                .padding(.vertical, 15)
                .background(Color.green)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error logging in"), message: Text(self.errorString), dismissButton: .default(Text("OK")))
        }

    }

}

struct SignInAnonymouslyView_Previews: PreviewProvider {
    static var previews: some View {
        SignInAnonymouslyView()
    }
}
