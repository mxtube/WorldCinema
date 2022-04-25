//
//  ViewController.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 24.04.2022.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUp: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    
    let userDefault = UserDefaults.standard
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault.set(true, forKey: "wasLaunched")
        
        // For test
         firstName.text = "Владимир"
         lastName.text = "Красноушко"
         email.text = "tsar@dvorec.ru"
         password.text = "IamTsar"
         rePassword.text = "IamTsar"
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        guard isFirstNameValid() && isLastNameValid() && isEmailValid() && isPasswordValid() && isEmailCorrect() && isPasswordEqual() else { return }
        requestApi()
    }
    
    private func isFirstNameValid() -> Bool {
        guard firstName.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поле имя")
        return false
    }
    
    private func isLastNameValid() -> Bool {
        guard lastName.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поле фамилия")
        return false
    }
    
    private func isEmailValid() -> Bool {
        guard email.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поле электронная почта")
        return false
    }
    
    private func isPasswordValid() -> Bool {
        guard password.text!.isEmpty || rePassword.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поля пароль")
        return false
    }
    
    private func isEmailCorrect() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", regEx)
        guard !emailPred.evaluate(with: email.text) else { return true }
        showAlert(withText: "Адрес электронной почты не корректный")
        return false
    }
    
    private func isPasswordEqual() -> Bool {
        guard password.text != rePassword.text else { return true }
        showAlert(withText: "Введеные пароли не совпадают")
        return false
    }
    
    private func requestApi() {
        
        user = User(
            firstName: firstName.text!,
            lastName: lastName.text!,
            email: firstName.text!,
            password: password.text!)
        
        let body: [String: String] = [
            "email": user.email,
            "password": user.password,
            "firstName": user.firstName,
            "lastName": user.lastName
        ]
        
        AF.request(AppDelegate().baseUrl + "auth/register", method: .post, parameters: body, encoding: JSONEncoding.default).responseString(completionHandler: { response in
            switch response.response?.statusCode {
            case 201:
                self.performSegue(withIdentifier: "signInSegue", sender: SignIn().signInAction(_:))
            case 404:
                self.showAlert(withText: response.error!.localizedDescription)
            case .none:
                print("error")
            case .some(_):
                print("error")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInSegue" {
            if let vc = segue.destination as! SignIn? {
                vc.requestApi(inputEmail: user.email, inputPassword: user.password)
            }
        }
    }
    
    private func showAlert(withText message: String) {
        let alertController = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
}

