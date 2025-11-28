//
//  SignUpViewController.swift
//  PlanYourTrip
//
//  Created by Mananas on 25/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController
{
    /**/
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var scGender: UISegmentedControl!
    @IBOutlet weak var dpDateOfBirth: UIDatePicker!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRepeatPass: UITextField!
    
    /**/
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Calcula la fecha máxima permitida (hoy - 18 años) */
        let calendar = Calendar.current
        let today = Date()
        if let maxDate = calendar.date(byAdding: .year, value: -18, to: today) {
            dpDateOfBirth.maximumDate = maxDate
        }
        
    }
    

    /**/
    @IBAction func signUp(_ sender: Any)
    {
        if (!validateData())
        {
            return
        }
        
        let firstName = tfFirstName.text ?? ""
        let lastName = tfLastName.text ?? ""
        let gender = scGender.selectedSegmentIndex
        let dateBirth = dpDateOfBirth.date
        let email = tfUserName.text ?? ""
        let password = tfPassword.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            let userId = authResult!.user.uid
            
            let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, gender: gender, dateBirth: dateBirth.millisecondsSince1970)
            
            do {
                let db = Firestore.firestore()
                try db.collection("Users").document(userId).setData(from: user)
            } catch let error {
                print("Error writing user to Firestore: \(error)")
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            print("User created account successfully")
            self.showMessage(title: "Create account", message: "Account created successfully")
        }
    }

    
    /**/
    func validateData() -> Bool {
        if tfFirstName.text?.isEmpty ?? true {
            showMessage(message: "You must enter a first name")
            return false
        }
        if tfLastName.text?.isEmpty ?? true {
            showMessage(message: "You must enter a last name")
            return false
        }
        if tfPassword.text != tfRepeatPass.text {
            showMessage(message: "Password do not match repeat password")
            return false
        }
        return true
    }
    
    
}
