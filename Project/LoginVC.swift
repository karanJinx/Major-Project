//
//  ViewController.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 04/09/23.
//

import UIKit

struct LoginResponseModal: Decodable {
    var status: String?
    var data: LoginResponseDataModal?
    var message: String?
}
struct LoginResponseDataModal: Decodable {
    var token: String?
    var isNewUser: String?
    var userId: Int?
    var firstTimeLogin: String?
    var userRole: String?
    var fullName: String?
    var adminFlag: String?
    var supervisorFlag: String?
    var clinicianId: Int?
    var physicianId: Int?
    var userTimeZone: String?
    var screenNavigation: String?
    var rpmEnrolled: String?
    var timeoutValue: Double?
    var patientCommuntionFlag: String?
    var isShowPhysicianContactFlag: String?
    var isShowClinicianContactFlag: String?
    var isAllowManualVital: String?
    var patientEnrolledDate: String?
    var defaultProduct: String?
    var enrolledProducts : [EnrolledProductsModal]?
}
struct EnrolledProductsModal: Decodable {
    var productCode : String?
    var productDescription : String?
    var productEnrolledDate : String?
}

//struct LoginWebResponseModal: Codable {
//    var userRole : String?
//    var screenNavigation : String?
//    var token : String?
//    var firstTimeLogin : String?
//    var isNewUser : String?
//    var status : String?
//}

class LoginVC: UIViewController, UITextFieldDelegate {
    //MARK: - IBOUTLET
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    //MARK: - Properties
    let apiManager = APIManager.shared
    /// a loader overView on top of the view,(1)assinged instance uiview,(2)createdView ,which is actual overlay view.(3)setting autocontraint to false,(4)settign bacgroundcolor to back opacity 20(5)view is Initially hidden
    let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(20.0) // Semi-transparent background
        view.isHidden = true // Initially hidden
        
        // Create and customize the "Loading" label
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingLabel)
        
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor,constant: -20).isActive = true
        
        return view
    }()
    
    //used to set the height and width of the overlay view
    let loaderSize:CGFloat = 100.0
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    //MARK: - OverrideViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    //MARK: - InitialSetUp
    func initialSetup(){
        setPropertiesForTextField(textField: emailTextField)
        setPropertiesForTextField(textField: passwordTextField)
        
        emailTextField.text = "mobileteam"
        passwordTextField.text = "Humworld@1"
        
        // Add overlay view
        view.addSubview(overlayView)
        overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        overlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        overlayView.widthAnchor.constraint(equalToConstant: loaderSize).isActive = true
        overlayView.heightAnchor.constraint(equalToConstant: loaderSize).isActive = true
        overlayView.layer.cornerRadius = 10
        
        // Add activity indicator
        overlayView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
    }
    //MARK: - setPropertiesForTextField
    func setPropertiesForTextField(textField: UITextField, keyBoardType: UIKeyboardType = .asciiCapable) {
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = keyBoardType
    }
    
    //MARK: - ShowLoader
    func showLoader() {
        DispatchQueue.main.async {
            self.overlayView.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    //MARK: - HideLoader
    func hideLoader() {
        DispatchQueue.main.async {
            self.overlayView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - TextfieldShould|Return
    /// KeyBoard disappers when we click the Return button
    /// - Parameter textField: email and password field
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - ShowAlertToValidateTextFields
    /// Showing alert when the textField(username or password) is empty
    /// - Parameter message: What message to show to the user
    func alert(message: String) {
        let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    //MARK: - IBAction
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        let trimmedUserName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUserName.isEmpty {
            alert(message: "UserName is Empty.")
        }else if trimmedUserName.count < 8 {
            alert(message: "UserName cannot be Less than 8 Characters")
        }else if trimmedUserName.count > 25 {
            alert(message: "UserName Cannot be Greater than 25 Characters")
        }else if trimmedPassword.isEmpty {
            alert(message: "Password is Empty.")
        }else if trimmedPassword.count < 8 {
            alert(message: "Password cannot be Less than 8 Characters")
        }else if trimmedPassword.count > 20 {
            alert(message: "Password Cannot be Greater than 20 Characters")
        }
        else{
            loginServiceCall()
        }
        
        //MARK: - LoginServiceCall
        func loginServiceCall() {
            showLoader()
            let loginURL = APIHelper.share.baseURL + "login"
            let loginParam = ["username" : trimmedUserName, "password" : trimmedPassword]
            
            //result is of type Result<Data, Error>, where Data represents the data received from the network request, and Error represents any potential errors.
            apiManager.APIHelper(url: loginURL, params: loginParam, method: .post , headers: nil, requestBody: nil, completion: { result in
                self.hideLoader()
                switch result {
                case .success(let data):
                    loginSuccessHandling(data: data)
                    
                case .failure(let error):
                    print("Error \(error)")
                }
            }
            )
        }
        
        //MARK: - LoginSuccessHandling
        func loginSuccessHandling(data: Data) {
            do {
                //If the network request is successful (i.e., .success), you proceed to decode the data received from the server.
                let decoded = try JSONDecoder().decode(LoginResponseModal.self, from: data)
                //You're using JSONDecoder to decode the received data into an instance of a LoginResponseModal object. This is typically done to parse and work with the response data in a structured format.
                if decoded.status == "success" {
                    print("the data is \(data)")
                    print("the token is \(decoded.data?.token ?? "")")
                    Details.token = decoded.data?.token
                    DispatchQueue.main.async {
                        let myTabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                        myTabBar.modalPresentationStyle = .overCurrentContext
                        self.present(myTabBar, animated: true)
                    }
                }
                else if decoded.status == "failure" {
                    let alert = UIAlertController(title: "Alert", message: "server is Busy", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
                else {
                    DispatchQueue.main.async {
                        let message = decoded.message
                        let alert = UIAlertController(title: "Alert", message: (message), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                        //                                let message = decoded.status
                        //                                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                        //                                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        //                                self.present(alert, animated: true)
                    }
                }
            }
            catch {
                print("Error: try \(error.localizedDescription)")
                DispatchQueue.main.async {
                    //Build (503 error)
                    let alert = UIAlertController(title: "Alert", message: "Please try again after sometime.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}


