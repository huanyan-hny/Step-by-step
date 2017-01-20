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


class SettingViewController: UITableViewController {

    var fieldType = TextFieldType.unknown
    var maxTextLength = 15
    
    func logout() {
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {(result:Any?,error:Error?) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        let alertController = UIAlertController(title: "Error", message: "Error logging out, please try again", preferredStyle: .alert)
                        
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
        }
        if (AccessToken.current != nil){
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
        } else if (indexPath == [3,0]) {
            let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)  {(action) in
                return
            }
            
            alertController.addAction(cancelAction)
            
            let logoutAction = UIAlertAction(title:"Log out", style:.destructive) {(action) in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings";
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor.lightGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingTextFieldController {
            destination.fieldType = self.fieldType
            destination.maxTextLength = self.maxTextLength
        }
    }
}
