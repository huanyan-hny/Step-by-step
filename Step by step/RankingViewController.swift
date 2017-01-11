//
//  MedalViewController.swift
//  Step by step
//
//  Created by Troy on 15/10/26.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var starDistances: [UILabel]!
    @IBOutlet var starSignitures: [UILabel]!
    @IBOutlet var starNames: [UILabel]!
    @IBOutlet var starAvatars: [UIImageView]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var dateLabel: UILabel!
   
    var rowHeight = CGFloat(75)
    var managedObjectContext:NSManagedObjectContext?
    
    
    @IBAction func changeToWeekly(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.slider.center.x = self.weeklyButton.center.x
            self.weeklyButton.setTitleColor(UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0), for: .normal)
            
            self.monthlyButton.setTitleColor(UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0), for: .normal)
        })
    }
    @IBAction func changeToMonthly(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.slider.center.x = self.monthlyButton.center.x
            self.monthlyButton.setTitleColor(UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0), for: .normal)
            
            self.weeklyButton.setTitleColor(UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0), for: .normal)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingViewCell", for: indexPath) as! RankingViewCell
        
        
        if(indexPath.row==0) {
            cell.name.text = "陈垚"
            cell.distance.text = "16 miles"
            cell.ranking.text = "1"
            cell.avatar.image = #imageLiteral(resourceName: "chenyao")
            cell.signature.text = "make things happen."
        } else if(indexPath.row==1) {
            cell.name.text = "小胖兔"
            cell.distance.text = "15 miles"
            cell.ranking.text = "2"
            cell.avatar.image = #imageLiteral(resourceName: "shezhang")
            cell.signature.text = "我虽然胖，但我吃得多啊"
        } else if(indexPath.row==2) {
            cell.name.text = "欢言"
            cell.distance.text = "7 miles"
            cell.ranking.text = "3"
            cell.avatar.image = #imageLiteral(resourceName: "huanyan")
            cell.signature.text = "Maplestory"
        } else if(indexPath.row==3) {
            cell.name.text = "站在树上唱rap"
            cell.distance.text = "13 miles"
            cell.ranking.text = "4"
            cell.avatar.image = #imageLiteral(resourceName: "laoshezhang")
            cell.signature.text = "生活不止眼前的苟且，还有诗和远方"
        } else {
            cell.name.text = "小狗君"
            cell.distance.text = "8 miles"
            cell.ranking.text = "5"
            cell.avatar.image = #imageLiteral(resourceName: "xiaogou")
            cell.signature.text = "Had I not seen the sun"
        }
        
        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width/2
        cell.avatar.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        print("selected")
        performSegue(withIdentifier: "showDetail", sender: self)
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
        self.navigationItem.title = "Leaderboard";
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        tableView.delegate = self
        slider.layer.cornerRadius = 2
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "MMMM d, yyyy - EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateLabel.text = dateFormatter.string(from: Date())
        if (Display.typeIsLike == .iphone5) {
            rowHeight = 64
            for starSigniture in starSignitures {
                starSigniture.font = UIFont(name: "Helvetica Neue", size: 10)
            }
        }
        
        for starAvatar in starAvatars {
            starAvatar.layer.borderColor = UIColor.white.cgColor
            starAvatar.layer.borderWidth = 3.0
        }
    }
    
}
