//
//  SettingViewController.swift
//  Step by step
//
//  Created by Troy on 2016/12/27.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import FacebookLogin
import FacebookCore
import SafariServices

class SettingViewController: UITableViewController, SFSafariViewControllerDelegate{

    var fieldType = TextFieldType.unknown
    var maxTextLength = 15
    
    func logout() {
        if (AWSGoogleSignInProvider.sharedInstance().isLoggedIn){
            AWSGoogleSignInProvider.sharedInstance().logout()
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        } else if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {(result:Any?,error:Error?) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                            return
                        }
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                    }
                }
            })
        } else if (AccessToken.current != nil){
            LoginManager().logOut()
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath == [0,0]) {
            fieldType = .username
            maxTextLength = 15
            performSegue(withIdentifier: "changeProfile", sender: self)
        } else if (indexPath == [0,1]) {
            fieldType = .signature
            maxTextLength = 30
            performSegue(withIdentifier: "changeProfile", sender: self)
        } else if (indexPath == [2,1]) {
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: "https://huanyan-hny.github.io/Step-by-step/")!)
                self.present(safariVC, animated: true, completion: nil)
                safariVC.delegate = self
                UIApplication.shared.setStatusBarStyle(.default, animated: false)
            } else {
                UIApplication.shared.openURL(URL(string: "https://huanyan-hny.github.io/Step-by-step/")!)
            }
        } else if (indexPath == [2,2]) {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/1179166655")!)
        } else if (indexPath == [3,0]) {
            let alertController = UIAlertController(title: NSLocalizedString("Log out", comment: ""), message: NSLocalizedString("Are you sure you want to log out?", comment: ""), preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            
            let logoutAction = UIAlertAction(title:NSLocalizedString("Log out", comment: ""), style:.destructive) {(action) in
                DispatchQueue.main.async {
                    self.logout()
                }
                
            }
            
            alertController.addAction(logoutAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (Display.typeIsLike == .iphone5) {
            return 37
        } else if (Display.typeIsLike == .iphone7) {
            return 45
        } else if (Display.typeIsLike == .iphone7plus) {
            return 50
        }
        return 45
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Settings", comment: "");
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = Colors.myBlue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingTextFieldController {
            destination.fieldType = self.fieldType
            destination.maxTextLength = self.maxTextLength
        }
    }
}

