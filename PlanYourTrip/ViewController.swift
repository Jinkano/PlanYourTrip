//
//  ViewController.swift
//  PlanYourTrip
//
//  Created by Mananas on 21/11/25.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController
{
    /**/
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    /**/
    
    @IBAction func singUp(_ sender: Any)
    {
        //
        let email = tfUsername.text ?? ""
        let password = tfPassword.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          //
            if let error = error
            {
                print(error.localizedDescription)
                return
            }
            
            print("Usuario registrado")
            
        }
    }
    
    @IBAction func signIn(_ sender: Any)
    {
        //
        let email = tfUsername.text ?? ""
        let password = tfPassword.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
          //
            if let error = error
            {
                print(error.localizedDescription)
                return
            }
            
            print("Ingreso autoriazado")
        }
    }
    
    
}

