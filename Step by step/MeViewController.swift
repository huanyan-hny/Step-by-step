//
//  MeViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/29.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData



class MeViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    var managedObjectContext:NSManagedObjectContext?
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userAvatar: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Change your profile image", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let changeAction = UIAlertAction(title: "Choose from photo library", style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(changeAction)
        
        self.navigationController?.present(alertController, animated: true,completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            userAvatar.imageView?.contentMode = .scaleAspectFill
            userAvatar.setImage(pickedImage, for: .normal)
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imagePath = documentPath.appendingPathComponent("userAvatar.png")
            let userAvatarData = UIImagePNGRepresentation(pickedImage)
            try? userAvatarData?.write(to: imagePath, options: .atomic)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        viewController.navigationController?.navigationBar.tintColor = UIColor.white
        viewController.navigationController?.navigationBar.barTintColor = UIColor(red:49.0/255.0, green: 168.0/255.0, blue: 213.0/255.0, alpha:1.0)
        viewController.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row==0) {
            return 154*(self.tableView.frame.height-self.tabBarController!.tabBar.frame.height)/554
        } else {
            return 100*(self.tableView.frame.height-self.tabBarController!.tabBar.frame.height)/554
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userAvatar.imageView?.contentMode = .scaleAspectFill
        userAvatar.layer.cornerRadius = userAvatar.frame.width/2
        userAvatar.clipsToBounds = true
        userAvatar.layer.borderWidth = 3
        userAvatar.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView();
        self.navigationItem.title = "Me";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        imagePicker.delegate = self
        
        if let name = UserDefaults.standard.string(forKey: "userName") {
            userName.text = name
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let avatarPath = documentPath.appendingPathComponent("userAvatar.png")
        
        if let avatar = UIImage(contentsOfFile:avatarPath.path) {
            userAvatar.setImage(avatar, for: .normal)
        }
        
        print(Display.typeIsLike)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AllActivitiesViewController {
            destination.managedObjectContext = self.managedObjectContext
        }
    }

}
