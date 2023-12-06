//
//  AuthManager.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 28.10.2023.
//

import Foundation
import Supabase
import CryptoKit
import AuthenticationServices
import OneSignalFramework

class AuthManager: NSObject {

    // MARK: - Shared Instance
    static let shared = AuthManager()

    func signOut(completion: @escaping (Result<Void, Error>)-> Void) {
        Task {
            do {
                try await SensitiveData.supabase.auth.signOut()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }


    // MARK: - Sign In With Apple Flow
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    private var completionHandler: ((Result<SignInWithAppleCredentials, Error>) -> Void)?

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    func startSignInWithAppleFlow(completion: @escaping (Result<SignInWithAppleCredentials, Error>) -> Void) {
        let rootViewController = UIApplication.shared.keyWindoww?.rootViewController
        guard let topController = rootViewController?.topController else { return }

        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topController
        authorizationController.performRequests()
    }

}
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let rootViewController = UIApplication.shared.keyWindoww?.rootViewController
        guard let topController = rootViewController?.topController else { return .init() }
        return topController.view.window!
    }
}

extension AuthManager {
    struct SignInWithAppleCredentials {
        let idToken: String
        let nonce: String
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce, let completion = completionHandler else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            Task {
                let credentials = SignInWithAppleCredentials(idToken: idTokenString, nonce: nonce)
                try await loginWithCredentials(idToken: credentials.idToken, nonce: credentials.nonce)
                if AppGlobal.shared.appleCredentialUserFullName == nil {
                    AppGlobal.shared.appleCredentialUserFullName = appleIDCredential.fullName
                }
                try await setUserToSupabaseIfNeeded()
                try await addOneSignalSubscriptionIDToSupabaseIfNeeded()
                print("DEBUG: -----", appleIDCredential)
                completion(.success(credentials))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        guard let completion = completionHandler else { return }
        print("Sign in with Apple errored: \(error)")
        completion(.failure(error))
    }

    private func loginWithCredentials(idToken: String, nonce: String) async throws {
        guard let completion = completionHandler else { return }
        let credentials = SignInWithAppleCredentials(idToken: idToken, nonce: nonce)
        do {
            let session = try await SensitiveData.supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: credentials.idToken, nonce: credentials.nonce))
            AppGlobal.shared.user = session.user
        } catch {
            completion(.failure(error))
        }
    }
}
// MARK: - End of Apple Flow


extension AuthManager {
    // MARK: - Public Methods
    func getUsernameIfExists() async -> String? {
        do {
            guard let userEmail = AppGlobal.shared.user?.email else { return nil }
            let data = try await SensitiveData.supabase.database.from("users").select("*", head: false).eq("email", value: userEmail).execute().data
            let stringData = String(data: data, encoding: .utf8)
            guard let userDict = stringData?.convertStringToDictionary() else { return nil }
            let username = userDict["username"] as? String ?? ""
            return username
        } catch  {
            return nil
        }
    }

    // MARK: - Private Methods
    private func setUserToSupabaseIfNeeded() async throws {
        let usernameExists = await getUsernameIfExists()
        guard usernameExists == nil else {
            AppGlobal.shared.username = usernameExists
            print("User Exists")
            return
        }
        guard let user = AppGlobal.shared.user else { return }
        let userID = user.id.uuidString
        let username = AppGlobal.shared.appleCredentialUserFullName?.givenName ?? "Anonymous"
        let dict = ["userID": userID, "username": username, "email": user.email]
        try await SensitiveData.supabase.database.from("users").upsert(dict).execute()
        AppGlobal.shared.username = username
    }
    private func addOneSignalSubscriptionIDToSupabaseIfNeeded() async throws {
        guard var pushIDArray = await getSubscriptionIDsIfExists() else { return }
        if pushIDArray.isEmpty {
            pushIDArray = [OneSignal.User.pushSubscription.id ?? ""]
        } else {
            let currentDevicePushID = OneSignal.User.pushSubscription.id ?? ""
            var pushIDExists = false
            for item in pushIDArray {
                if item == currentDevicePushID {
                    pushIDExists = true
                    print("Push ID for current Device Exists")
                }
            }
            if pushIDExists == false {
                pushIDArray.append(OneSignal.User.pushSubscription.id ?? "")
            }
        }
        guard let user = AppGlobal.shared.user else { return }
        let userID = user.id.uuidString
        try await SensitiveData.supabase.database.from("users").update(["pushSubscriptionIDs": pushIDArray]).eq("userID", value: userID).execute()
    }
    private func getSubscriptionIDsIfExists() async -> [String]? {
        do {
            guard let userEmail = AppGlobal.shared.user?.email else { return nil }
            let data = try await SensitiveData.supabase.database.from("users").select("*", head: false).eq("email", value: userEmail).execute().data
            let stringData = String(data: data, encoding: .utf8)
            guard let userDict = stringData?.convertStringToDictionary() else { return nil }
            let pushIDs = userDict["pushSubscriptionIDs"] as? [String] ?? []
            return pushIDs
        } catch  {
            return nil
        }
    }
}
