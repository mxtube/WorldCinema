//
//  SignIn.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 25.04.2022.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class SignIn: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let userDefault = UserDefaults.standard
    var auth: Auth!
    
    override func viewWillAppear(_ animated: Bool) {
        email.text = "vasya@mail.com"
        password.text = "qwerty"
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        guard isEmailValid() && isPasswordValid() else { return }
        guard isEmailCorrect() else { return }
        requestApi(inputEmail: email.text!, inputPassword: password.text!)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    
    private func isEmailValid() -> Bool {
        guard email.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поле электронная почта")
        return false
    }
    
    private func isEmailCorrect() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", regEx)
        guard !emailPred.evaluate(with: email.text) else { return true }
        showAlert(withText: "Адрес электронной почты не корректный")
        return false
    }
    
    private func isPasswordValid() -> Bool {
        guard password.text!.isEmpty else { return true }
        showAlert(withText: "Заполните поля пароль")
        return false
    }
    
    func requestApi(inputEmail: String, inputPassword: String) {
        
        auth = Auth(email: inputEmail, password: inputPassword)
        
        let body: [String: String] = [
            "email": auth.email,
            "password": auth.password,
        ]
        
        AF.request(AppDelegate().baseUrl + "auth/login", method: .post, parameters: body, encoding: JSONEncoding.default).response(completionHandler: { [self] response in
            switch response.result {
            case .success(let value):
                parseJSON(in: value!)
            case .failure(let error):
                showAlert(withText: error.localizedDescription)
            }
        })
    }
    
    private func parseJSON(in json: Data) {
        let parse = JSON(json)
        let jsonToken = parse["token"].intValue
        userDefault.set(jsonToken, forKey: "token")
        let saveToken = userDefault.integer(forKey: "token")
        print("Save token: \(saveToken)")
        guard saveToken != 0 else { return }
        self.performSegue(withIdentifier: "mainSegue", sender: nil)
    }
    
    private func showAlert(withText message: String) {
        let alertController = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
}
