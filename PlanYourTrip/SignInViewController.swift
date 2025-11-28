//
//  ViewController.swift
//  PlanYourTrip
//
//  Created by Mananas on 21/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

class SignInViewController: UIViewController
{
    /**/
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "NavigateToHome", sender: nil)
        }
    }


    /**/
    @IBAction func signIn(_ sender: Any)
    {
        let email = tfUsername.text ?? ""
        let password = tfPassword.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            print("User signed in successfully")
            
            /* Si las credenciales son correctas mostramos el ViewController.
             * El 'segue' se llama "NavigateToHome" que se le asigna en el inspector de atributos.
             */
            self.performSegue(withIdentifier: "NavigateToHome", sender: nil)
        }
    }
    
    /**/
    
    @IBAction func signInWithGoogle(_ sender: Any)
    {
        //
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                showMessage(message: error!.localizedDescription)
                return
            }

            guard let googleUser = result?.user, let idToken = googleUser.idToken?.tokenString else {
                showMessage(message: "Unxpected error has occurred.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [unowned self] authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.showMessage(message: error.localizedDescription)
                    return
                }
                
                print("User signed in successfully")
                
                Task {
                    let userId = authResult!.user.uid
                    
                    let db = Firestore.firestore()
                    let docReference = db.collection("Users").document(userId)
                    
                    do {
                        let document = try await docReference.getDocument()
                        if !document.exists {
                            let email = googleUser.profile?.email ?? authResult!.user.email!
                            let firstName = googleUser.profile?.givenName ?? ""
                            let lastName = googleUser.profile?.familyName ?? ""
                            let gender = 2
                            
                            let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, gender: gender, dateBirth: nil)
                            DispatchQueue.main.async {
                                do {
                                    let db = Firestore.firestore()
                                    try db.collection("Users").document(userId).setData(from: user)
                                } catch let error {
                                   print("Error writing user to Firestore: \(error)")
                                   DispatchQueue.main.async {
                                       self.showMessage(message: error.localizedDescription)
                                   }
                                   return
                               }
                            }
                        }
                    } catch let error {
                        print("Error writing user to Firestore: \(error)")
                        DispatchQueue.main.async {
                            self.showMessage(message: error.localizedDescription)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "NavigateToHome", sender: nil)
                    }
                }
            }
        }
    }
    
    
    /**/
    @IBAction func resetPassword(_ sender: Any)
    {
        let email = tfUsername.text ?? ""
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            self.showMessage(message: "We sent you an email for reset your password")
        }
    }
    
    
}
