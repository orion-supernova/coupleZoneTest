//
//  SignInWithAppleHelper.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 28.10.2023.
//

import UIKit
import CryptoKit
import AuthenticationServices

class SignInWithAppleHelper: NSObject  {
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    private var completionHandler: ((Result<SignInWithAppleCredentials, Error>) -> Void)?

    init(currentNonce: String? = nil) { }

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
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
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

extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
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
                AppGlobal.shared.appleCredentialUserFullName = appleIDCredential.fullName
//                completion(.success(credentials))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

    func loginWithCredentials(idToken: String, nonce: String) async throws {
        let credentials = SignInWithAppleCredentials(idToken: idToken, nonce: nonce)
        do {
            try await SensitiveData.supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: credentials.idToken, nonce: credentials.nonce))
        } catch {
            //
        }
    }
}

extension SignInWithAppleHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        guard let topController = rootViewController?.topController else { return .init() }
        return topController.view.window!
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}

extension SignInWithAppleHelper {
    struct SignInWithAppleCredentials {
        let idToken: String
        let nonce: String
    }
}

