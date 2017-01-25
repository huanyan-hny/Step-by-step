//
//  SignInViewControllerExtensions.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.8
//
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import FacebookLogin
import FacebookCore
import AWSDynamoDB
import AWSS3


// Extension containing methods which call different operations on Cognito User Pools (Sign In, Sign Up, Forgot Password)
extension LoginViewController {
    
    func handleLogin() {
        let signInProvider = AWSCognitoUserPoolsSignInProvider.sharedInstance()
        signInProvider.setInteractiveAuthDelegate(self)
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {(result: Any?, error: Error?) ->
            Void in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.enableButtons()
                if (error != nil) {
                    let alertController = UIAlertController(title: NSLocalizedString("Unknown error", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if let userID = AWSIdentityManager.defaultIdentityManager().userName {
                        UserDefaults.standard.set(userID, forKey: "userID")
                        self.objectMapper.load(User.classForCoder(), hashKey: userID, rangeKey: nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                            if (task.error != nil) {
                                let alertController = UIAlertController(title: NSLocalizedString("Unknown error", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                    return
                                }
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                            if (task.result != nil) {
                                DispatchQueue.main.async {
                                    let user = task.result as! User
                                    UserDefaults.standard.set(user._name, forKey: "username")
                                    UserDefaults.standard.set(user._signature, forKey: "signature")
                                    self.performSegue(withIdentifier: "toMain", sender: self)
                                }
                            } else if (task.result == nil) {
                                let newUser = User()
                                newUser?._userId = userID
                                newUser?._totalRunningDistance = 0
                                newUser?._name = userID
                                newUser?._signature = " "
                                self.objectMapper.save(newUser!)
                                DispatchQueue.main.async {
                                    UserDefaults.standard.set(userID, forKey:"username")
                                    UserDefaults.standard.set(" ", forKey:"signature")
                                    self.performSegue(withIdentifier: "toMain", sender: self)
                                }
                            }
                            return nil
                        })
                    }
                }
            }
        })
    }
    
    func handleSignUp() {
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        guard let usernameValue = self.usernameField.text, !usernameValue.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Missing Username", message: "Please enter username", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard let passwordValue = self.passwordField.text,!passwordValue.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Missing Password", message: "Please enter password", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
            
        }
        
        
        guard let emailValue = self.emailField.text, !emailValue.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Missing Email", message: "Please enter Email", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let email = AWSCognitoIdentityUserAttributeType()!
        email.name = "email"
        email.value = emailValue
        attributes.append(email)
        
        if (passwordValue.characters.count<6) {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Password too short", message: "The length of password must be at least 6", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        signUp(usernameValue: usernameValue, passwordValue: passwordValue, attributes: attributes)
        
    }
    
    func signUp(usernameValue:String, passwordValue:String, attributes:[AWSCognitoIdentityUserAttributeType]) {
        self.pool?.signUp(usernameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continue(with: AWSExecutor.default(), with: {(task: AWSTask) -> Any? in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.enableButtons()
                if (task.error != nil) {
                    let alertController = UIAlertController(title: "Error", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                if (task.exception != nil) {
                    let alertController = UIAlertController(title: "Error", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                if (task.result != nil) {
                    let response = task.result! as AWSCognitoIdentityUserPoolSignUpResponse
                    if (response.user.confirmedStatus != .confirmed) {
                        self.user = self.pool?.getUser(self.usernameField.text!)
                        self.confirmSignUp()
                    } else {
                        self.restoreLoginView()
                    }
                    
                }
            }
            
            return nil
        })
    }
    
    
    func handleSignUpConfirm() {
        guard let confirmationCodeValue = self.codeField.text,!confirmationCodeValue.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Missing Confirmation Code", message: "Please enter the confirmation code received", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.user?.confirmSignUp(confirmationCodeValue, forceAliasCreation: true).continue(with: AWSExecutor.default(), with: {(task: AWSTask) -> Any? in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.enableButtons()
                self.forgotButton.isEnabled = false
                if (task.error != nil || task.exception != nil) {
                    let alertController = UIAlertController(title: "Error", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if (self.isNew) {
                        if let userID = self.user?.username {
                            let newUser = User()
                            newUser?._userId = userID
                            newUser?._totalRunningDistance = 0
                            newUser?._name = userID
                            newUser?._signature = " "
                            
                            self.objectMapper.save(newUser!, completionHandler: {(error: Error?) -> Void in
                                DispatchQueue.main.async {
                                    UserDefaults.standard.set(true, forKey: "appear")
                                    let alertController = UIAlertController(title: "Registration completed", message: "Please log in with your new account", preferredStyle: .alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                        self.completeSignUp()
                                        return
                                    }
                                    
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            })
                        }
                    } else {
                        self.user?.verifyAttribute("email", code: confirmationCodeValue)
                        self.completeSignUp()
                    }
                    
                }
            }
            return nil
        })
        
    }
    func handleForgotPassword() {
        self.stopLoadingAnimation()
        self.enableButtons()
        self.signUpButton.isEnabled = false
        
        guard let usernameValue = self.usernameField.text, !usernameValue.isEmpty else {
            
            let alertController = UIAlertController(title: "Missing Username", message: "Please enter username", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        self.user = self.pool?.getUser(usernameValue)
        self.user?.forgotPassword().continue(with: AWSExecutor.default(), with: {(task:AWSTask) -> Any? in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    let alertController = UIAlertController(title: "User not found", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.exception != nil) {
                    let alertController = UIAlertController(title: "Error", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.setNewPassword()
                }
                
            }
            return nil
        })
    }
    
    func handleNewPassword() {
        guard let confirmationCodeValue = self.codeField.text, !confirmationCodeValue.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            self.signUpButton.isEnabled = false
            let alertController = UIAlertController(title: "Missing Confirmation Code", message: "Please enter the confirmation code received", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let newPassword = self.passwordField.text, !newPassword.isEmpty else {
            self.stopLoadingAnimation()
            self.enableButtons()
            let alertController = UIAlertController(title: "Missing New Password", message: "Please enter a new password", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.user?.confirmForgotPassword(confirmationCodeValue, password: newPassword).continue(with: AWSExecutor.default(), with: {(task:AWSTask) -> Any? in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.enableButtons()
                self.signUpButton.isEnabled = false
                if (task.error != nil) {
                    let alertController = UIAlertController(title: "Error (Wrong code?)", message: "Please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Reset successful", message: "Your password has been successfully reset", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        self.completeResetPassword()
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            return nil
        })
        
    }
}

// Extension to adopt the `AWSCognitoIdentityInteractiveAuthenticationDelegate` protocol
extension LoginViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    // this function handles the UI setup for initial login screen, in our case, since we are already on the login screen, we just return the View Controller instance
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
    
}

// Extension to adopt the `AWSCognitoIdentityPasswordAuthentication` protocol
extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let error = error as? NSError{
            
            let errorType = error.userInfo["__type"]! as! String
            
            if (errorType=="UserNotConfirmedException") {
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    self.enableButtons()
                    let alertController = UIAlertController(title: "Error", message: "User not confirmed, please check your email and confirm", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        self.user = self.pool?.getUser(self.usernameField.text!)
                        self.disableButtons()
                        self.startLoadingAnimation()
                        self.user?.resendConfirmationCode().continue(with: AWSExecutor.default(), with: {(task:AWSTask) -> Any? in
                            DispatchQueue.main.async{
                                self.stopLoadingAnimation()
                                self.enableButtons()
                                if (task.error != nil || task.exception != nil) {
                                    let alertController = UIAlertController(title: "Error", message: "An error happen, please check your input and try again later", preferredStyle: .alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                        self.restoreLoginView()
                                        return
                                    }
                                    
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    self.isNew = false
                                    self.confirmSignUp()
                                }
                            }
                            return nil
                        })
                        
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    self.enableButtons()
                    let alertController = UIAlertController(title: "Error", message: "Incorrect username/password, please check your input and try again", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            
        }
    }
    
}

// Extension to adopt the `AWSCognitoUserPoolsSignInHandler` protocol
extension LoginViewController: AWSCognitoUserPoolsSignInHandler {
    func handleUserPoolSignInFlowStart() {
        // check if both username and password fields are provided
        guard let username = self.usernameField.text, !username.isEmpty,
            let password = self.passwordField.text, !password.isEmpty
            else {
                DispatchQueue.main.async{
                    self.stopLoadingAnimation()
                    self.enableButtons()
                    let alertController = UIAlertController(title: "Missing Username/Password", message: "Please enter a valid Username/Password", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
        }
        // set the task completion result as an object of AWSCognitoIdentityPasswordAuthenticationDetails with username and password that the app user provides
        self.passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: username, password: password))
    }
}



//Extension to fetch Facebook profile
extension LoginViewController {
    func fetchUserProfile() {
        
        let userID = AccessToken.current!.userId!
        UserDefaults.standard.set(userID, forKey: "userID")
        
        
        print("Fetching profile")
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me",parameters:["fields":"name, email, picture.type(large)"])) { httpResponse, result in
            switch result {
            case .success(let response):
                self.objectMapper.load(User.classForCoder(), hashKey:userID, rangeKey:nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let avatarPath = documentPath.appendingPathComponent(userID)
                    
                    if (task.result == nil) {
                        UserDefaults.standard.set("Step by step", forKey: "username")
                        UserDefaults.standard.set(" ", forKey: "signature")
                        UserDefaults.standard.set(true, forKey: "appear")
                        
                        let results = response.dictionaryValue
                        
                        if let username = results?["name"] as? String {
                            UserDefaults.standard.set(username, forKey: "username")
                            print(username)
                        }
                        
                        
                        if let picture = results?["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary{
                            let url = data["url"] as! String
                            
                            let avatarData = try? Data(contentsOf: URL(string: url)!)
                            if let userAvatar = UIImage(data: avatarData!) {
                                let userAvatarData = UIImageJPEGRepresentation(userAvatar, 1.0)
                                try? userAvatarData?.write(to: avatarPath, options: .atomic)
                            }
                        }
                        
                        
                        let S3BucketName = "stepbystep-userfiles-mobilehub-138898687"
                        let uploadRequest = AWSS3TransferManagerUploadRequest()
                        uploadRequest?.body = avatarPath
                        uploadRequest?.key = "public/avatars/" + userID
                        uploadRequest?.contentType = "image/jpeg"
                        uploadRequest?.bucket = S3BucketName
                        let manager = AWSS3TransferManager.default()
                        manager?.upload(uploadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                            if (task.error != nil) {
                                let alertController = UIAlertController(title: NSLocalizedString("Fail to login", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                    return
                                }
                                
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                            return nil
                        })
                        
                        let newUser = User()
                        newUser?._name = UserDefaults.standard.string(forKey: "username")
                        newUser?._signature = " "
                        newUser?._totalRunningDistance = 0
                        newUser?._userId = userID
                        
                        self.objectMapper.save(newUser!, completionHandler: {(error: Error?) -> Void in
                            if (error != nil) {
                                let alertController = UIAlertController(title: NSLocalizedString("Fail to login", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                    return
                                }
                                
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toMain", sender: self)
                                }
                            }
                        })
                        
                    } else {
                        let user = task.result as! User
                        UserDefaults.standard.set(user._name, forKey: "username")
                        UserDefaults.standard.set(user._signature, forKey: "signature")
                        
                        let avatarExists = (try? avatarPath.checkResourceIsReachable()) ?? false
                        
                        if (!avatarExists) {
                            let downloadRequest = AWSS3TransferManagerDownloadRequest()
                            downloadRequest?.bucket = "stepbystep-userfiles-mobilehub-138898687"
                            downloadRequest?.key = "public/avatars/" + userID
                            downloadRequest?.downloadingFileURL = avatarPath
                            let manager = AWSS3TransferManager.default()
                            manager?.download(downloadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toMain", sender: self)
                                }
                                return nil
                            })
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "toMain", sender: self)
                            }
                        }
                    }
                    return nil
                })
                
            case .failed(let error):
                print(error)
                DispatchQueue.main.async{
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to login", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(error.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        connection.start()
        
    }
}

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return pressed")
        textField.resignFirstResponder()
        return false
    }
}
