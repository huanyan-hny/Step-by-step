//
//  MeViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/29.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData
import AWSS3



class MeViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
   
    
    @IBOutlet weak var userAvatar: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userSignature: UILabel!
    @IBOutlet weak var runTitle: UILabel!
    @IBOutlet weak var runDetail: UILabel!
    @IBOutlet weak var rankingTitle: UILabel!
    @IBOutlet weak var rankingDetail: UILabel!
    @IBOutlet weak var achievementTitle: UILabel!
    @IBOutlet weak var achievementDetail: UILabel!
    @IBOutlet weak var recordTitle: UILabel!
    @IBOutlet weak var recordDetail: UILabel!
    
    
    
    var managedObjectContext:NSManagedObjectContext?
    var runFetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var rankingFetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var achievementFetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var recordFetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    let numberOfAchievements = 9
    let imagePicker = UIImagePickerController()
    let runFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    let rankingFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ranking")
    let achievementFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Achievement")
    let recordFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    

    
    func initFetchRequest() {
        
        let userID = UserDefaults.standard.string(forKey: "userID")!
        
        runFetchRequest.predicate = NSPredicate(format: "userID = %@", userID)
        runFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        runFetchResultsController = NSFetchedResultsController(fetchRequest: runFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        
        
        rankingFetchRequest.predicate = NSPredicate(format: "userID = %@", userID)
        rankingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        rankingFetchResultsController = NSFetchedResultsController(fetchRequest: rankingFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        
        achievementFetchRequest.predicate = NSPredicate(format: "userID = %@", userID)
        achievementFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        achievementFetchResultsController = NSFetchedResultsController(fetchRequest: achievementFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        
        recordFetchRequest.predicate = NSPredicate(format: "userID = %@", userID)
        recordFetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: false)]
        recordFetchResultsController = NSFetchedResultsController(fetchRequest: recordFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func performFetch() {
        do{ try runFetchResultsController?.performFetch()} catch _ { print("Could not fetch run!")}
        do{ try rankingFetchResultsController?.performFetch()} catch _ { print("Could not fetch ranking!")}
        do{ try achievementFetchResultsController?.performFetch()} catch _ { print("Could not fetch achievement!")}
        do{ try recordFetchResultsController?.performFetch()} catch _ { print("Could not fetch record!")}
    }
    
    
    func updateUI() {
        updateRun()
        updateRanking()
        updateAchievement()
        updateRecord()
    }
    
    func updateRun() {
        var numberOfRun = 0
        var totalDistance = 0.0
        
        for object in (runFetchResultsController?.fetchedObjects)! {
            numberOfRun += 1
            if let run = object as? Run {
                if (language == "zh_Hans") {
                    totalDistance += run.distance!.doubleValue
                } else {
                    totalDistance += run.distance!.doubleValue/1.60934
                }
            }
        }
        self.runTitle.text = "\(numberOfRun)"
        if (language == "zh_Hans") {
            self.runDetail.text = String(format: "共计%.1f公里", totalDistance)
        } else {
            self.runDetail.text = String(format: "%.1f total miles", totalDistance)
        }
    }
    
    func updateRanking() {
        self.rankingTitle.text = "\((rankingFetchResultsController?.fetchedObjects?.count)!)"
    }
    
    func updateAchievement() {
        
        let count = achievementFetchResultsController?.fetchedObjects?.count
        
        
        self.achievementDetail.textColor = Colors.myTextLightGray
        if (language == "zh_Hans") {
            self.achievementTitle.text = "\(count!)/9 已解锁"
            self.achievementDetail.text = "试着解锁更多成就吧!"
        } else {
            self.achievementTitle.text = "\(count!)/9 unlocked"
            self.achievementDetail.text = "Try to unlock more achievements!"
        }
        
        
        if (count == numberOfAchievements) {
            if (language == "zh_Hans") {
                self.achievementDetail.text = "祝贺你，你已经解锁所有成就"
            } else {
                self.achievementDetail.text = "Grats! You have unlocked all achievements"
            }
        }
        
        for object in (achievementFetchResultsController?.fetchedObjects)! {
            if let achievement = object as? Achievement {
                if achievement.isNew!.boolValue{
                    if (language == "zh_Hans") {
                        self.achievementDetail.text = "新成就已解锁！"
                    } else {
                        self.achievementDetail.text = "New achievement unlocked!"
                    }
                    self.achievementDetail.textColor = Colors.myOrange
                }
            }
        }
    }
    
    func updateRecord() {
        let count = (recordFetchResultsController?.fetchedObjects?.count)!
        if (count>0) {
            let displayOne = arc4random_uniform(UInt32(count-1))
            let record = recordFetchResultsController?.object(at: [0,Int(displayOne)]) as! Record
            if let type = record.type {
                switch type {
                case "Distance":
                    self.recordTitle.text = String(format: "%.2f miles", record.value!.doubleValue)
                    self.recordDetail.text = NSLocalizedString("Farthest distance" , comment: "")
                case "Pace":
                    self.recordTitle.text = Time.secondsFormatted(seconds: record.value!.intValue) + "/mi"
                    self.recordDetail.text = NSLocalizedString("Fastest pace", comment: "")
                case "Duration":
                    self.recordTitle.text = Time.secondsFormattedString(seconds: record.value!.intValue)
                    self.recordDetail.text = NSLocalizedString("Longest duration", comment: "")
                case "Steps":
                    self.recordTitle.text = record.value!.stringValue
                    self.recordDetail.text = NSLocalizedString("Highest daily steps", comment: "")
                default:
                    break
                }
            }
        }
    }
    
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let changeAction = UIAlertAction(title: NSLocalizedString("Choose from photo library", comment: ""), style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            UIApplication.shared.setStatusBarStyle(.default, animated: false)
        }
        alertController.addAction(changeAction)
        
        self.navigationController?.present(alertController, animated: true,completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imagePath = documentPath.appendingPathComponent("userAvatarToUpload.png")
            let userAvatarData = UIImageJPEGRepresentation(pickedImage, 0.5)
            try? userAvatarData?.write(to: imagePath, options: .atomic)
            
            let S3BucketName = "stepbystep-userfiles-mobilehub-138898687"
            let uploadRequest = AWSS3TransferManagerUploadRequest()

            uploadRequest?.body = imagePath
            uploadRequest?.key = "public/avatars/" + UserDefaults.standard.string(forKey: "userID")!
            uploadRequest?.contentType = "image/jpeg"
            uploadRequest?.bucket = S3BucketName
            let manager = AWSS3TransferManager.default()
            manager?.upload(uploadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                if (task.error != nil) {
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to change Avatar", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        let avatarPath = documentPath.appendingPathComponent(UserDefaults.standard.string(forKey: "userID")!)
                        try? userAvatarData?.write(to: avatarPath, options: .atomic)
                        self.userAvatar.setImage(pickedImage, for: .normal)
                    }
                }
                
                return nil
            })

        }
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
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
        if let name = UserDefaults.standard.string(forKey: "username") {
            username.text = name
        }
        
        if let signature = UserDefaults.standard.string(forKey: "signature") {
            userSignature.text = signature
        }
        performFetch()
        updateUI()
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
        self.navigationItem.title = NSLocalizedString("Me", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        imagePicker.delegate = self
        initFetchRequest()
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let avatarPath = documentPath.appendingPathComponent(UserDefaults.standard.string(forKey: "userID")!)
        
        if let avatar = UIImage(contentsOfFile:avatarPath.path) {
            userAvatar.setImage(avatar, for: .normal)
        }
        
        print(Display.typeIsLike)
        localizeLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AllActivitiesViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.fetchResultsController = self.runFetchResultsController
        } else if let destination = segue.destination as? AllRankingsViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.fetchResultsController = self.rankingFetchResultsController
        } else if let destination = segue.destination as? AllAchievementsTableViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.fetchResultsController = self.achievementFetchResultsController
        } else if let destination = segue.destination as? AllRecordsTableViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.fetchResultsController = self.recordFetchResultsController
        }
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func localizeLabels() {
    }

}

