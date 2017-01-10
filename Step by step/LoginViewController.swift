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
        UserDefaults.standard.set(4000, forKey: "dailyWalkingGoal")
        UserDefaults.standard.set(5.0, forKey: "dailyRunningGoal")
        print("Fetching profile")
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me",parameters:["fields":"name, email, picture.type(large)"])) { httpResponse, result in
            switch result {
            case .success(let response):
                let results = response.dictionaryValue
                
                if let username = results?["name"] as? String {
                    UserDefaults.standard.set(username, forKey: "username")
                    print(username)
                }
                
                if let userEmail = results?["email"] as? String {
                    UserDefaults.standard.set(userEmail, forKey: "userID")
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
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("User logged out")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
 

}
