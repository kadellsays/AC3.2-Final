//
//  ViewController.swift
//  AC3.2-Final
//
//  Created by Jason Gresh on 2/14/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }

   
    //MARK: -Helper Functions
    func showAlertFailure(title: String, error: Error) {
        let alertController = UIAlertController(title: title, message: "\(error)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func movetoFeed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: -Actions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                
                if user != nil {
                    self.movetoFeed()
                    
                } else {
                       self.showAlertFailure(title: "Login Failed!", error: error!)
                    }
                
            })
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                
                if error != nil {
                
                    self.showAlertFailure(title: "Register Failed", error: error!)
                    return
                }
                
                self.movetoFeed()
                
            })
        }
        
    }

}

