//
//  LoginViewController.swift
//  Step by step
//
//  Created by Troy on 2016/12/30.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import CoreData

class LoginViewController: UIViewController,LoginButtonDelegate {

    var managedObjectContext:NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [.publicProfile,.email])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (AccessToken.current != nil){
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    func fetchUserProfile() {
        print("Fetching profile")
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me",parameters:["fields":"name, email, picture.type(large)"])) { httpResponse, result in
            switch result {
            case .success(let response):
                let results = response.dictionaryValue
                
                if let userName = results?["name"] as? String {
                    UserDefaults.standard.set(userName, forKey: "userName")
                    print(userName)
                }
                
                if let userEmail = results?["email"] as? String {
                    UserDefaults.standard.set(userEmail, forKey: "userEmail")
                    print(userEmail)
                }
                
                if let picture = results?["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary{
                    let url = data["url"] as! String
                    
                    let avatarData = try? Data(contentsOf: URL(string: url)!)
                    if let userAvatar = UIImage(data: avatarData!) {
                        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let imagePath = documentPath.appendingPathComponent("userAvatar.png")
                    
                        let userAvatarData = UIImagePNGRepresentation(userAvatar)
                        try? userAvatarData?.write(to: imagePath, options: .atomic)
                    }
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
        
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("User logged in")
        fetchUserProfile()
        performSegue(withIdentifier: "toMain", sender: self)
        //TODO:check server to retrive Running Activities
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("User logged out")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let baseVC = segue.destination as! UITabBarController
        
        for nVC in (baseVC.viewControllers as? [UINavigationController])! {
            if let rVC = nVC.topViewController as? RunningViewController{
                rVC.managedObjectContext = self.managedObjectContext
            }
            
            if let mVC = nVC.topViewController as? MeViewController {
                mVC.managedObjectContext = self.managedObjectContext
            }
        }

    }
 

}
