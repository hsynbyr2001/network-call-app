//
//  ContentView.swift
//  network-call-app
//
//  Created by Hüseyin  Bayır on 28.01.2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "Bio Placeholder")
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser(userName: "hsynbyr2001")
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid Response")
            } catch GHError.invalidData {
                print("Invalid Data")
            } catch {
                print("Unexpected Error")
            }
        }
    }
    
    // Network call function
    func getUser(userName: String) async throws -> GitHubUser {
        // endpoint
        let endPoint = "https://api.github.com/users/" + userName
        
        // url
        guard let url = URL(string: endPoint) else { throw GHError.invalidURL  }
        
        // GET data with response
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // URL Response
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }
        
        // Fill data to object model
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

// Github user object
struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

