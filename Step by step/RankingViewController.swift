//
//  MedalViewController.swift
//  Step by step
//
//  Created by Troy on 15/10/26.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData
//import AWSMobileHubHelper
import AWSDynamoDB
import AWSS3


class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum rankingType {
        case weekly
        case monthly
    }
    
    @IBOutlet var starAvatars: [UIButton]!
    @IBOutlet var starDistances: [UILabel]!
    @IBOutlet var starSignitures: [UILabel]!
    @IBOutlet var starNames: [UILabel]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedAvatar:UIImage?
    var selectedName:String?
    var selectedSignature:String?
    var selectedCurrentDistance:String?
    var selectedRanking:String?
    var selectedUserId:String?
    
    var rowHeight = CGFloat(75)
    var managedObjectContext:NSManagedObjectContext?
    var weeklyRankings = [WeeklyRanking]()
    var monthlyRankings = [MonthlyRanking]()
    var userNames = [String:String]()
    var userSignatures = [String:String]()
    var finishedLoading = false
    var type = rankingType.weekly

    let manager = AWSS3TransferManager.default()
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let calendar = Calendar.current
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    
    

    
    @IBAction func changeToWeekly(_ sender: UIButton) {
        type = .weekly
        disableSwitch()
        refresh()
        UIView.animate(withDuration: 0.2, animations: {
            self.slider.center.x = self.weeklyButton.center.x
            self.weeklyButton.setTitleColor(UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0), for: .normal)
            self.monthlyButton.setTitleColor(UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0), for: .normal)
        })
        enableSwitch()
    }
    @IBAction func changeToMonthly(_ sender: UIButton) {
        type = .monthly
        disableSwitch()
        refresh()
        UIView.animate(withDuration: 0.2, animations: {
            self.slider.center.x = self.monthlyButton.center.x
            self.monthlyButton.setTitleColor(UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0), for: .normal)
            
            self.weeklyButton.setTitleColor(UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0), for: .normal)
        })
        enableSwitch()
    }
    
    @IBAction func displayStarDetail(_ sender: UIButton) {
        let index = starAvatars.startIndex.distance(to: starAvatars.index(of: sender)!) as Int
        
        if (type == .weekly && index >= weeklyRankings.count) {
            return
        }
        
        if (type == .monthly && index >= monthlyRankings.count) {
            return
        }
        
        selectedAvatar = sender.imageView?.image
        selectedName = starNames[index].text
        selectedSignature = starSignitures[index].text
        selectedCurrentDistance = starDistances[index].text
        selectedRanking = "\(index+1)"
        if (type == .weekly) {
            selectedUserId = weeklyRankings[index]._userId
        } else {
            selectedUserId = monthlyRankings[index]._userId
        }
        performSegue(withIdentifier: "showDetail", sender: self)

    }
    
    func disableSwitch() {
        DispatchQueue.main.async {
            self.weeklyButton.isEnabled = false
            self.monthlyButton.isEnabled = false
        }
    }
    
    func enableSwitch() {
        DispatchQueue.main.async {
            self.weeklyButton.isEnabled = true
            self.monthlyButton.isEnabled = true
        }
    }
    
    func displayEmptyMessage() {
        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:self.tableView.bounds.size.width,height:self.tableView.bounds.size.height))
        messageLabel.text = NSLocalizedString("No one is here yet, start running and be the first!", comment: "")
        messageLabel.textColor = Colors.myTextGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel;
    }
    
    func retrieveWeeklyRankingData() {
        disableSwitch()
        let query = AWSDynamoDBQueryExpression()
        let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: Date())
        let weekNumString = String(component.year!) + String(component.weekOfYear!)
        let weekNum = NSNumber.init(value: Int(weekNumString)!)
        
        query.expressionAttributeValues = [":weekNum":weekNum]
        query.expressionAttributeNames = ["#W":"week"]
        query.keyConditionExpression = "#W = :weekNum"
        
        objectMapper.query(WeeklyRanking.classForCoder(), expression: query).continue(with: AWSExecutor.default(), with: {(task:AWSTask!)-> Any! in
            if (task.error != nil) {
                print(task.error!)
            }
            if (task.exception != nil) {
                print(task.exception!)
            }
            if (task.result != nil) {
                let paginatedOutput = task.result!
                for item in paginatedOutput.items {
                    if let rankItem = item as? WeeklyRanking {
                        if rankItem._appear!.boolValue && rankItem._distance!.doubleValue >= 0.1 {
                            self.weeklyRankings.append(rankItem)
                        }
                    }
                }
            }
            self.weeklyRankings.sort(by: {$0._distance!.doubleValue>$1._distance!.doubleValue})
            DispatchQueue.main.async {
                self.finishedLoading = true
                self.tableView.reloadData()
                self.enableSwitch()
                self.activityIndicator.stopAnimating()
                self.activityView.isHidden = true
                if (self.weeklyRankings.count>0){
                    self.tableView.scrollToRow(at: [0,0], at: .top, animated: true)
                } else {
                    self.displayEmptyMessage()
                }
            }
            return nil
        })
        
    }
    
    func retrieveMonthlyRankingData() {
        disableSwitch()
        let query = AWSDynamoDBQueryExpression()
        let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: Date())
        let monthNumString = String(component.year!) + String(component.month!)
        let monthNum = NSNumber.init(value: Int(monthNumString)!)
        
        query.expressionAttributeNames = ["#M":"month"]
        query.expressionAttributeValues = [":monthNum":monthNum]
        query.keyConditionExpression = "#M = :monthNum"
        
        objectMapper.query(MonthlyRanking.classForCoder(), expression: query).continue(with: AWSExecutor.default(), with: {(task:AWSTask!)-> Any! in
            if (task.error != nil) {
                print(task.error!)
            }
            if (task.exception != nil) {
                print(task.exception!)
            }
            if (task.result != nil) {
                let paginatedOutput = task.result!
                for item in paginatedOutput.items {
                    if let rankItem = item as? MonthlyRanking {
                        if rankItem._appear!.boolValue && rankItem._distance!.doubleValue >= 0.1 {
                            self.monthlyRankings.append(rankItem)
                        }
                    }
                }
            }
            
            self.monthlyRankings.sort(by: {$0._distance!.doubleValue>$1._distance!.doubleValue})
            DispatchQueue.main.async {
                self.finishedLoading = true
                self.tableView.reloadData()
                self.enableSwitch()
                self.activityIndicator.stopAnimating()
                self.activityView.isHidden = true
                if (self.monthlyRankings.count>0) {
                    self.tableView.scrollToRow(at: [0,0], at: .top, animated: true)
                } else {
                    self.displayEmptyMessage()
                }
            }
            return nil
        })

    }
    
    func retrieveUserData() {
        disableSwitch()
        let scanExpression = AWSDynamoDBScanExpression()
        objectMapper.scan(User.classForCoder(), expression: scanExpression).continue(with: AWSExecutor.default(), with: {(task:AWSTask!)-> Any! in
            if (task.error != nil) {
                print(task.error!)
            }
            if (task.exception != nil) {
                print(task.exception!)
            }
            if (task.result != nil) {
                let paginatedOutput = task.result!
                for item in paginatedOutput.items {
                    if let userItem = item as? User {
                        self.userNames[userItem._userId!] = userItem._name
                        self.userSignatures[userItem._userId!] = userItem._signature
                    }
                }
            }
            if (self.type == .weekly){
                self.retrieveWeeklyRankingData()
            } else {
                self.retrieveMonthlyRankingData()
            }
            return nil
        })
    }
    
    func refresh() {
        self.activityIndicator.startAnimating()
        self.activityView.isHidden = false
        clearTempFolder()
        finishedLoading = false
        for starAvatar in starAvatars {
            starAvatar.setImage(#imageLiteral(resourceName: "SIcon"), for: .normal)
        }
        
        for starName in starNames {
            starName.text = "---"
        }
        
        for starSigniture in starSignitures {
            starSigniture.text = "---"
        }
        
        for starDistance in starDistances {
            starDistance.text = "---"
        }
        
        weeklyRankings.removeAll()
        monthlyRankings.removeAll()
        retrieveUserData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (type == .weekly) {
            return weeklyRankings.count;
        } else {
            return monthlyRankings.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rankCell = cell as! RankingViewCell
        
        let path = NSTemporaryDirectory().appending(rankCell.userId!)
        let url = URL(fileURLWithPath: path)
        let avatarExists = (try? url.checkResourceIsReachable()) ?? false
        if (!avatarExists) {
            DispatchQueue.global().async {
                let path = NSTemporaryDirectory().appending(rankCell.userId!)
                let url = URL(fileURLWithPath: path)
                let downloadRequest = AWSS3TransferManagerDownloadRequest()
                downloadRequest?.bucket = "stepbystep-userfiles-mobilehub-138898687"
                downloadRequest?.key = "public/avatars/" + rankCell.userId!
                downloadRequest?.downloadingFileURL = url
                self.manager?.download(downloadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                    if (task.error != nil) {
                        print(task.error!)
                    }
                    
                    if (task.exception != nil) {
                        print (task.exception!)
                    }
                    
                    if (task.result != nil) {
                        let avatarPath = NSTemporaryDirectory().appending(rankCell.userId!)
                        let avatarUrl = URL(fileURLWithPath: avatarPath)
                        DispatchQueue.main.async {
                            rankCell.avatar.image = UIImage(contentsOfFile: avatarUrl.path)
                            if (indexPath.row<3) {
                                self.starAvatars[indexPath.row].setImage(UIImage(contentsOfFile: avatarUrl.path), for: .normal)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            rankCell.avatar.image = #imageLiteral(resourceName: "SIcon")
                            if (indexPath.row<3) {
                                self.starAvatars[indexPath.row].setImage(#imageLiteral(resourceName: "SIcon"), for: .normal)
                            }
                        }
                    }
                    return nil
                })
            }
        } else {
            rankCell.avatar.image = UIImage(contentsOfFile: url.path)
            if (indexPath.row<3) {
                self.starAvatars[indexPath.row].setImage(UIImage(contentsOfFile: url.path), for: .normal)
            }
        }
    }
    
    func configureWeeklyRankingCell(cell:RankingViewCell, rank:Int) {
        cell.ranking.text = "\(rank+1)"
        if (language == "zh-Hans") {
            cell.distance.text = String(format:"%.1f 公里", Double(round(weeklyRankings[rank]._distance!.doubleValue*10)/10))
        } else {
            cell.distance.text = String(format:"%.1f miles", Double(round((weeklyRankings[rank]._distance!.doubleValue/1.60934)*10)/10))
        }
        
        cell.name.text = userNames[weeklyRankings[rank]._userId!]
        cell.signature.text = userSignatures[weeklyRankings[rank]._userId!]
        cell.userId = weeklyRankings[rank]._userId
        if (rank<3) {
            starNames[rank].text = userNames[weeklyRankings[rank]._userId!]
            starSignitures[rank].text = userSignatures[weeklyRankings[rank]._userId!]
            starDistances[rank].text = cell.distance.text
        }
        
        if (weeklyRankings[rank]._userId == UserDefaults.standard.string(forKey: "userID")) {
            if (rank+1<=20) {
                updateRankingAchievement(id: 6)
            }
            
            if (rank+1<=10) {
                updateRankingAchievement(id: 7)
            }
            
            if (rank+1<=3) {
                updateRankingAchievement(id: 8)
            }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ranking")
            fetchRequest.predicate = NSPredicate(format: "week = %@", weeklyRankings[rank]._week!)
            do {
                let records = try managedObjectContext!.fetch(fetchRequest) as! [Ranking]
                if (records.isEmpty) {
                    let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from:Date())
                    let beginOfWeek = calendar.date(byAdding: .day, value: 1-component.weekday!, to: Date())!
                    let endOfWeek = calendar.date(byAdding: .day, value: 7-component.weekday!, to: Date())!
                    let savedRanking = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into:managedObjectContext!) as! Ranking
                    savedRanking.rank = rank+1 as NSNumber?
                    savedRanking.userID = UserDefaults.standard.string(forKey: "userID")
                    savedRanking.type = "Weekly"
                    savedRanking.startDate = beginOfWeek
                    savedRanking.endDate = endOfWeek
                    savedRanking.week = weeklyRankings[rank]._week!
                    savedRanking.totalDistance = weeklyRankings[rank]._distance!
                    
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save rank!")}
                } else {
                    let record = records.first!
                    record.rank = rank+1 as NSNumber?
                    record.totalDistance = weeklyRankings[rank]._distance!
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save rank!")}
                }
                
            } catch _ {}
            
        }

    }
    
    func configureMonthlyRankingCell(cell:RankingViewCell, rank:Int) {
        cell.ranking.text = "\(rank+1)"
        
        if (language == "zh-Hans") {
            cell.distance.text = String(format:"%.1f 公里", Double(round(monthlyRankings[rank]._distance!.doubleValue*10)/10))
        } else {
            cell.distance.text = String(format:"%.1f miles", Double(round((monthlyRankings[rank]._distance!.doubleValue/1.60934)*10)/10))
        }
        cell.name.text = userNames[monthlyRankings[rank]._userId!]
        cell.signature.text = userSignatures[monthlyRankings[rank]._userId!]
        cell.userId = monthlyRankings[rank]._userId
        if (rank<3) {
            starNames[rank].text = userNames[monthlyRankings[rank]._userId!]
            starSignitures[rank].text = userSignatures[monthlyRankings[rank]._userId!]
            starDistances[rank].text = cell.distance.text
        }
        
        if (monthlyRankings[rank]._userId == UserDefaults.standard.string(forKey: "userID")) {
            if (rank+1<=20) {
                updateRankingAchievement(id: 6)
            }
            
            if (rank+1<=10) {
                updateRankingAchievement(id: 7)
            }
            
            if (rank+1<=3) {
                updateRankingAchievement(id: 8)
            }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ranking")
            fetchRequest.predicate = NSPredicate(format: "month = %@", monthlyRankings[rank]._month!)
            do {
                let records = try managedObjectContext!.fetch(fetchRequest) as! [Ranking]
                if (records.isEmpty) {
                   
                    let beginOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
                    
                    let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: beginOfMonth)!

                    let savedRanking = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into:managedObjectContext!) as! Ranking
                    savedRanking.rank = rank+1 as NSNumber?
                    savedRanking.userID = UserDefaults.standard.string(forKey: "userID")
                    savedRanking.type = "Monthly"
                    savedRanking.startDate = beginOfMonth
                    savedRanking.endDate = endOfMonth
                    savedRanking.month = monthlyRankings[rank]._month!
                    savedRanking.totalDistance = monthlyRankings[rank]._distance!
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save rank!")}
                } else {
                    let record = records.first!
                    record.rank = rank+1 as NSNumber?
                    record.totalDistance = monthlyRankings[rank]._distance!
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save rank!")}
                }
                
            } catch _ {}
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingViewCell", for: indexPath) as! RankingViewCell
        
        if (finishedLoading) {
            if (type == .weekly) {
                configureWeeklyRankingCell(cell: cell, rank: indexPath.row)
            } else {
                configureMonthlyRankingCell(cell: cell, rank: indexPath.row)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? RankingViewCell
        
        selectedAvatar = selectedCell?.avatar.image
        selectedName = selectedCell?.name.text
        selectedSignature = selectedCell?.signature.text
        selectedCurrentDistance = selectedCell?.distance.text
        selectedRanking = selectedCell?.ranking.text
        selectedUserId = selectedCell?.userId
        
        performSegue(withIdentifier: "showDetail", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor(red: 253.0/255.0, green: 97.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Leaderboard", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        tableView.delegate = self
        slider.layer.cornerRadius = 2

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.locale = Locale(identifier: UserDefaults.standard.string(forKey: "AppleLocale")!)
        dateLabel.text = dateFormatter.string(from: Date())
        
        if (Display.typeIsLike == .iphone5) {
            rowHeight = 64
            for starSigniture in starSignitures {
                starSigniture.font = UIFont(name: "Helvetica Neue", size: 10)
            }
        }
        
        for starAvatar in starAvatars {
            starAvatar.layer.borderColor = UIColor.white.cgColor
            starAvatar.imageView?.contentMode = .scaleAspectFill
            if Display.typeIsLike == .iphone5 {
                starAvatar.layer.borderWidth = 2.0
            } else {
                starAvatar.layer.borderWidth = 3.0
            }
        }
        
        activityView.layer.cornerRadius = 10
        refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RankingDetailViewController {
            destination.displayAvatar = selectedAvatar
            destination.displayName = selectedName
            destination.displayCurrentDistance = selectedCurrentDistance
            destination.displayRanking = selectedRanking
            destination.displaySignature = selectedSignature
            destination.userId = selectedUserId
        }
    }
        
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: NSTemporaryDirectory() + filePath)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
}
