//
//  HomeView.swift
//  Firebase Auth
//
//  Created by Esben Viskum on 08/06/2021.
//

import SwiftUI
import Firebase

public struct HomeView: View {
    @EnvironmentObject var fbVM: FBViewModel
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Logged in as \(fbVM.user?.displayName ?? "no name")")
                    .navigationBarTitle("Firebase Login")
                    .navigationBarItems(trailing: Button("Log Out") {
                        // self.userInfo.isUserAuthenticated = .signedOut
                        FBAuth.logout { (result) in
                            print("Logged out")
                        }
                    })
//                    .navigationBarItems(leading: Button("List providers") {
                        // self.userInfo.isUserAuthenticated = .signedOut
//                        for provider in userInfo.providerIds! {
//                            print(provider)
//                        }
//                        print(userInfo.signedInWith!.providerSignInString)
//                    })
//                    .onAppear {
//                        guard let uid = Auth.auth().currentUser?.uid else {
//                            return
//                        }
//                        FBFirestore.retrieveFBUser(uid: uid) { (result) in
//                            switch result {
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                                // Display Alert
//                            case .success(let user):
//                                self.userInfo.user = user
//                            }
//                        }
//
//                    }
                LoginView()
                
//                LinkWithAppleView()
//                    .frame(width: 200, height: 50)
                
                Text(Auth.auth().currentUser?.isAnonymous ?? true ? "Anonymous user" : "Linked user")
                
                
            }

        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
