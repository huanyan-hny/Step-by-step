//
//  LeaderboardSettingTableViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/22.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import AWSDynamoDB

class LeaderboardSettingTableViewController: UITableViewController {

    @IBOutlet weak var joinCheck: UIImageView!
    @IBOutlet weak var notJoinCheck: UIImageView!
    
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    let component = Calendar.current.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: Date())
    let userID = UserDefaults.standard.string(forKey: "userID")
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let appear = UserDefaults.standard.bool(forKey: "appear")
    var appear_set:Bool?
    
    func updateWeeklyRunningTable() {
        startLoadingAnimation()
        let weekNumString = String(component.year!) + String(component.weekOfYear!)
        let weekNum = NSNumber.init(value: Int(weekNumString)!)
        objectMapper.load(WeeklyRanking.classForCoder(), hashKey: weekNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to set", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let weeklyRanking = task.result as! WeeklyRanking
                    weeklyRanking._appear = self.appear_set! as NSNumber
                    self.objectMapper.save(weeklyRanking)
                    self.updateMonthlyRankingTable()
                }
            }
        })

    }
    
    func updateMonthlyRankingTable(){
        let monthNumString = String(component.year!) + String(component.month!)
        let monthNum = NSNumber.init(value: Int(monthNumString)!)
        objectMapper.load(MonthlyRanking.classForCoder(), hashKey: monthNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to set", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    self.stopLoadingAnimation()
                    let monthlyRanking = task.result as! MonthlyRanking
                    monthlyRanking._appear = self.appear_set! as NSNumber
                    self.objectMapper.save(monthlyRanking)
                    UserDefaults.standard.set(self.appear_set, forKey: "appear")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0 ) {
            joinCheck.isHidden = false
            notJoinCheck.isHidden = true
            appear_set = true
        } else {
            joinCheck.isHidden = true
            notJoinCheck.isHidden = false
            appear_set = false
        }
        
        if (appear_set == appear) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
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
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = NSLocalizedString("Leaderboard", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(updateWeeklyRunningTable))
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityIndicator.center = self.view.center
        stopLoadingAnimation()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        
        if (appear) {
            joinCheck.isHidden = false
            notJoinCheck.isHidden = true
        } else {
            joinCheck.isHidden = true
            notJoinCheck.isHidden = false
        }
    }

}
