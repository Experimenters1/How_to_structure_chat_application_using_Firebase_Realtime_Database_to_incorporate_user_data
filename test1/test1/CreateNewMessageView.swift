//
//  CreateNewMessageView.swift
//  test1
//
//  Created by Huy Vu on 10/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }
                    
                })
            }
    }
}

struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users){ num in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(num)
                    }label: {
                        HStack {
                            WebImage(url: URL(string: num.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                                                            .stroke(Color(.label), lineWidth: 2)
                                )
                            Text(num.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                       
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
    
                }
            }.navigationTitle("New Messge")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading){
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        }label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    CreateNewMessageView(didSelectNewUser: {user in
        print(user.email)
    })
}
