//
//  LoginViewController.swift
//  Step by step
//
//  Created by Troy on 2016/12/30.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData
import FacebookLogin
import FacebookCore
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import AWSDynamoDB
import FacebookLogin
import FacebookCore




class LoginViewController: UIViewController {
    
    enum actionType {
        case login
        case signUp
        case signUpConfirm
        case resetPassword
        case resetConfirm
        case cancelSignUp
        case cancelForgot
        case cancelConfirm
    }
    
    var managedObjectContext:NSManagedObjectContext?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    var action = actionType.login
    var signUpAction = actionType.signUp
    var forgotAction = actionType.resetPassword
    var level:CGFloat = 0
    var thumbnailViewSize = 30
    var thumbnailSize = 23
    var isNew = true
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    let textSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@.-_").inverted
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var AppTitle: UILabel!
    @IBOutlet weak var loginwithLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var wechatLoginButton: UIButton!
    
    
    @IBAction func loginViaFacebook(_ sender: UIButton) {
        LoginManager().logIn([.publicProfile,.email], viewController: self, completion: {(result:LoginResult) in
            if (AccessToken.current != nil) {
                self.fetchUserProfile()
            }
        })
    }
    
    @IBAction func loginViaWechat(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Login via Wechat", message: "Wechat login will be supported soon!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
            return
        }
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        disableButtons()
        startLoadingAnimation()
        switch action {
        case .login:
            handleLogin()
        case .signUp:
            handleSignUp()
        case .signUpConfirm:
            handleSignUpConfirm()
        case .resetPassword:
            handleForgotPassword()
        case .resetConfirm:
            handleNewPassword()
        default:
            break
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        clearText()
        if (forgotAction == .resetPassword) {
            signUpButton.isEnabled = false
            UIView.animate(withDuration: 0.5, animations: {
                self.passwordField.center.x -= self.view.frame.width
                self.passwordField.alpha = 0
                self.actionButton.center.y -= self.level
                self.actionButton.setTitle(NSLocalizedString("Request Reset", comment: ""), for: .normal)
                self.actionButton.backgroundColor = Colors.myOrange
                self.forgotButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
            })
            action = .resetPassword
            forgotAction = .cancelForgot
        } else if (forgotAction == .cancelForgot) {
            signUpButton.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                self.passwordField.center.x += self.view.frame.width
                self.passwordField.alpha = 1
                self.actionButton.center.y += self.level
                self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
                self.actionButton.backgroundColor = Colors.myBlue
                self.forgotButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
            })
            action = .login
            forgotAction = .resetPassword
        } else if (forgotAction == .cancelConfirm) {
            signUpButton.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                self.codeField.center.x += self.view.frame.width
                self.codeField.alpha = 0
                self.usernameField.center.x += self.view.frame.width
                self.usernameField.alpha = 1
                self.passwordField.text = ""
                self.passwordField.placeholder = NSLocalizedString("Password", comment: "")
                self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
                self.actionButton.backgroundColor = Colors.myBlue
                self.forgotButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
            })
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        clearText()
        if (signUpAction == .signUp) {
            forgotButton.isEnabled = false
            emailField.frame = passwordField.frame
            emailField.center.y += level
            emailField.center.x -= self.view.frame.width
            emailField.alpha = 0
            emailField.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.emailField.center.x += self.view.frame.width
                self.emailField.alpha = 1
                self.actionButton.center.y += self.level
                self.actionButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
                self.actionButton.backgroundColor = Colors.myOrange
                self.signUpButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
            })
            action = .signUp
            signUpAction = .cancelSignUp
        } else if (signUpAction == .cancelSignUp) {
            forgotButton.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                self.emailField.center.x -= self.view.frame.width
                self.emailField.alpha = 0
                self.actionButton.center.y -= self.level
                self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
                self.actionButton.backgroundColor = Colors.myBlue
                self.signUpButton.setTitle(NSLocalizedString("New here? Sign up", comment: ""), for: .normal)
            })
            action = .login
            signUpAction = .signUp
        } else if (signUpAction == .cancelConfirm) {
            forgotButton.isEnabled = true
            let alertController = UIAlertController(title: NSLocalizedString("User/Email not confirmed", comment: ""), message: NSLocalizedString("Registration not completed yet, continue?", comment: ""), preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancal", comment: ""), style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            
            let discardAction = UIAlertAction(title:NSLocalizedString("Continue", comment: ""), style: .default) {(action) in
                self.forgotButton.isEnabled = true
                self.action = .login
                self.signUpAction = .signUp
                self.forgotButton.isEnabled = true
                UIView.animate(withDuration: 0.5, animations: {
                    self.codeField.center.x += self.view.frame.width
                    self.codeField.alpha = 0
                    self.passwordField.center.x += self.view.frame.width
                    self.passwordField.alpha = 1
                    if (self.isNew){
                        self.actionButton.center.y -= self.level
                    } else {
                        self.isNew = true
                    }
                    self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
                    self.actionButton.backgroundColor = Colors.myBlue
                    self.signUpButton.setTitle(NSLocalizedString("New here? Sign up", comment: ""), for: .normal)
                })
                
            }
            
            alertController.addAction(discardAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func confirmSignUp() {
        forgotButton.isEnabled = false
        codeField.frame = passwordField.frame
        if (isNew) {
            codeField.center.y += level/2
        }
        codeField.center.x += self.view.frame.width
        codeField.alpha = 0
        codeField.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.passwordField.center.x -= self.view.frame.width
            self.passwordField.alpha = 0
            self.emailField.center.x -= self.view.frame.width
            self.emailField.alpha = 0
            self.codeField.center.x -= self.view.frame.width
            self.codeField.alpha = 1
            self.actionButton.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
            self.actionButton.backgroundColor = Colors.myOrange
            self.signUpButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        })
        action = .signUpConfirm
        signUpAction = .cancelConfirm
    }
    
    func setNewPassword() {
        signUpButton.isEnabled = false
        codeField.frame = usernameField.frame
        codeField.center.x += self.view.frame.width
        codeField.alpha = 0
        codeField.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.usernameField.center.x -= self.view.frame.width
            self.usernameField.alpha = 0
            self.codeField.center.x -= self.view.frame.width
            self.codeField.alpha = 1
            self.passwordField.placeholder = NSLocalizedString("New Password", comment: "")
            self.passwordField.center.x += self.view.frame.width
            self.passwordField.alpha = 1
            self.actionButton.setTitle(NSLocalizedString("Reset Password", comment: ""), for: .normal)
            self.actionButton.center.y += self.level
        })
        action = .resetConfirm
        forgotAction = .cancelConfirm
    }
    
    func completeSignUp() {
        self.forgotButton.isEnabled = true
        action = .login
        signUpAction = .signUp
        UIView.animate(withDuration: 0.5, animations: {
            self.codeField.center.x += self.view.frame.width
            self.codeField.alpha = 0
            self.passwordField.center.x += self.view.frame.width
            self.passwordField.alpha = 1
            if (self.isNew){
                self.actionButton.center.y -= self.level
                self.isNew = true
            }
            self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
            self.actionButton.backgroundColor = Colors.myBlue
            self.signUpButton.setTitle(NSLocalizedString("New here? Sign up", comment: ""), for: .normal)
        })
    }
    
    func completeResetPassword() {
        self.signUpButton.isEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            self.codeField.center.x += self.view.frame.width
            self.codeField.alpha = 0
            self.usernameField.center.x += self.view.frame.width
            self.usernameField.alpha = 1
            self.passwordField.text = ""
            self.actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
            self.actionButton.backgroundColor = Colors.myBlue
            self.forgotButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
        })
        action = .login
        forgotAction = .resetPassword
    }
    
    func restoreLoginView() {
        clearText()
        passwordField.frame = usernameField.frame
        passwordField.center.y += level
        actionButton.frame = passwordField.frame
        actionButton.center.y += level
        actionButton.backgroundColor = Colors.myBlue
        actionButton.setTitle(NSLocalizedString("Log In", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("New here? Sign up", comment: ""), for: .normal)
        forgotButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
        action = .login
        signUpAction = .signUp
        stopLoadingAnimation()
        enableButtons()
    }
    
    func checkText(_ sender: UITextField) {
        guard let inputText = sender.text else { return }
        
        if (inputText.rangeOfCharacter(from: textSet) != nil) {
            sender.text = inputText.substring(to: inputText.index(before: inputText.endIndex))
        }
    }
    
    func clearText() {
        usernameField.text = ""
        passwordField.text = ""
        emailField.text = ""
        codeField.text = ""
    }
    
    func disableButtons(){
        actionButton.isEnabled = false
        signUpButton.isEnabled = false
        forgotButton.isEnabled = false
        facebookLoginButton.isEnabled = false
        wechatLoginButton.isEnabled = false
    }
    
    func enableButtons() {
        actionButton.isEnabled = true
        signUpButton.isEnabled = true
        forgotButton.isEnabled = true
        facebookLoginButton.isEnabled = true
        wechatLoginButton.isEnabled = true
    }
    
    func drawTextFields() {
        usernameField.setBottomBorder()
        passwordField.setBottomBorder()
        emailField.setBottomBorder()
        codeField.setBottomBorder()
        
        let loginUserImageView = UIImageView(image: #imageLiteral(resourceName: "LoginUser"))
        let loginPasswordImageView = UIImageView(image: #imageLiteral(resourceName: "LoginPassword"))
        let loginEmailImageView = UIImageView(image: #imageLiteral(resourceName: "LoginEmail"))
        let loginCodeImageView = UIImageView(image:#imageLiteral(resourceName: "LoginCode"))
        
        loginUserImageView.frame = CGRect(x:0,y:0,width:thumbnailSize,height:thumbnailSize)
        loginPasswordImageView.frame = CGRect(x:0,y:0,width:thumbnailSize-2,height:thumbnailSize-2)
        loginEmailImageView.frame = CGRect(x:0,y:0,width:thumbnailSize-3,height:thumbnailSize-3)
        loginCodeImageView.frame = CGRect(x:0,y:0,width:thumbnailSize-2,height:thumbnailSize-2)
        
        let loginUserView = UIView(frame: CGRect(x:0,y:0,width:thumbnailViewSize,height:thumbnailSize))
        let loginPasswordView = UIView(frame: CGRect(x:0,y:0,width:thumbnailViewSize,height:thumbnailSize-2))
        let loginEmailView = UIView(frame: CGRect(x:0,y:0,width:thumbnailViewSize,height:thumbnailSize-3))
        let loginCodeView = UIView(frame: CGRect(x:0,y:0,width:thumbnailViewSize,height:thumbnailSize-2))
        
        loginUserView.addSubview(loginUserImageView)
        loginPasswordView.addSubview(loginPasswordImageView)
        loginEmailView.addSubview(loginEmailImageView)
        loginCodeView.addSubview(loginCodeImageView)
        
        usernameField.leftViewMode = .always
        passwordField.leftViewMode = .always
        emailField.leftViewMode = .always
        codeField.leftViewMode = .always
        
        usernameField.leftView = loginUserView
        passwordField.leftView = loginPasswordView
        emailField.leftView = loginEmailView
        codeField.leftView = loginCodeView
        
    }
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    func drawUI() {
        drawTextFields()
        level = passwordField.center.y - usernameField.center.y
        actionButton.layer.cornerRadius = 7.0;
        actionButton.clipsToBounds = true
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityIndicator.center = self.view.center
        stopLoadingAnimation()
    }
    
    func checkLoginStatus() {
        print("Checking Login Status")
        
        if (AccessToken.current != nil){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
        
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
    }
    
    func manualLayout() {
        if (Display.typeIsLike == .iphone5) {
            usernameField.frame.size.width = 160
            usernameField.center.x = self.view.frame.width/2
            usernameField.center.y = self.view.frame.height/2 - 30
            passwordField.frame = usernameField.frame
            actionButton.frame = usernameField.frame
            passwordField.center.y += 40
            actionButton.center.y += 90
            actionButton.frame.size.height -= 5
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            
            usernameField.font = UIFont.systemFont(ofSize: 12)
            passwordField.font = UIFont.systemFont(ofSize: 12)
            emailField.font = UIFont.systemFont(ofSize: 12)
            codeField.font = UIFont.systemFont(ofSize: 12)
            thumbnailSize = 21
            thumbnailViewSize = 27
        } else if (Display.typeIsLike == .iphone7plus) {
            usernameField.center.x = self.view.frame.width/2
            usernameField.center.y = self.view.frame.height/2 - 30
            passwordField.frame = usernameField.frame
            actionButton.frame = usernameField.frame
            passwordField.center.y += 55
            actionButton.center.y += 110
        }
        loginwithLabel.sizeToFit()
        loginwithLabel.center.x = self.view.frame.width/2
    }
    
    func launchView() {
        
        if(Display.typeIsLike == .iphone7plus) {
            appIcon.frame.size = CGSize(width: 121, height: 121)
        } else if (Display.typeIsLike == .iphone5) {
            appIcon.frame.size = CGSize(width:94, height:94)
        }
        
        appIcon.center = self.view.center
        emailField.center.x -= self.view.frame.width
        codeField.center.x -= self.view.frame.width
        AppTitle.alpha = 0
        usernameField.alpha = 0
        passwordField.alpha = 0
        actionButton.alpha = 0
        separator1.alpha = 0
        separator2.alpha = 0
        loginwithLabel.alpha = 0
        facebookLoginButton.alpha = 0
        wechatLoginButton.alpha = 0
        forgotButton.alpha = 0
        signUpButton.alpha = 0
        
        
        UIView.animate(withDuration: 2, animations: {
            if (Display.typeIsLike == .iphone5) {
                self.appIcon.center.y -= 160
            } else if (Display.typeIsLike == .iphone7) {
                self.appIcon.center.y -= 180
            } else if (Display.typeIsLike == .iphone7plus) {
                self.appIcon.center.y -= 200
            }
            
        }, completion: {(completed:Bool) in
            UIView.animate(withDuration: 2, animations: {
                self.AppTitle.alpha = 1
                self.usernameField.alpha = 1
                self.passwordField.alpha = 1
                self.actionButton.alpha = 1
                self.separator1.alpha = 1
                self.separator2.alpha = 1
                self.loginwithLabel.alpha = 1
                self.facebookLoginButton.alpha = 1
                self.wechatLoginButton.alpha = 1
                self.forgotButton.alpha = 1
                self.signUpButton.alpha = 1
            })
        })
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        restoreLoginView()
        isNew = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchView()
        checkLoginStatus()
        usernameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        codeField.delegate = self
        usernameField.addTarget(self, action: #selector(checkText), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(checkText), for: .editingChanged)
        emailField.addTarget(self, action: #selector(checkText), for: .editingChanged)
        codeField.addTarget(self, action: #selector(checkText), for: .editingChanged)
        manualLayout()
        drawUI()
        
        if (UserDefaults.standard.integer(forKey: "dailyWalkingGoal") == 0) {
            UserDefaults.standard.set(10000, forKey: "dailyWalkingGoal")
        }
        
        if (UserDefaults.standard.double(forKey: "dailyRunningGoal") == 0.0) {
            UserDefaults.standard.set(5.0, forKey: "dailyRunningGoal")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        
        let baseVC = segue.destination as! UITabBarController
        
        //passing managedObjectContext
        for nVC in (baseVC.viewControllers as? [UINavigationController])! {
            if let mVC = nVC.topViewController as? MeViewController {
                mVC.managedObjectContext = self.managedObjectContext
            }
            
            if let rVC = nVC.topViewController as? RunningViewController{
                rVC.managedObjectContext = self.managedObjectContext
            }
            
            if let sVC = nVC.topViewController as? StepsViewController {
                sVC.managedObjectContext = self.managedObjectContext
            }
            
            if let kVC = nVC.topViewController as? RankingViewController {
                kVC.managedObjectContext = self.managedObjectContext
            }
        }
        
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        print("Logged out")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
