//
//  RankingDetailViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/10.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import PNChart
import AWSDynamoDB

class RankingDetailViewController: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ranking: UILabel!
    @IBOutlet weak var signature: UILabel!
    @IBOutlet weak var barChart: PNBarChart!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var thisweekLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    
    var dayOfWeek = 7
    var data = [Double]()
    var dataUpdatedCount = 0
    var weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var colors = [UIColor](repeatElement(Colors.myBlue, count: 7))
    var displayAvatar:UIImage?
    var displayName:String?
    var displaySignature:String?
    var displayCurrentDistance:String?
    var displayRanking:String?
    var userId:String?
    var calendar = Calendar.current
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    
    @IBAction func enlargeImage(_ sender: UIButton) {
        barChart.displayAnimated = false
        let imageView = sender.imageView!
        let newImageView = UIImageView(image: imageView.image)
        let newBackgroundView = UIView(frame: self.view.frame)
        let scaleFactorX = self.view.frame.width/imageView.frame.width
        newBackgroundView.backgroundColor = .black
        newImageView.frame = imageView.convert(imageView.frame, to: self.view)
        newImageView.contentMode = .scaleAspectFit
        newBackgroundView.addSubview(newImageView)
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.center = newBackgroundView.center
            newImageView.transform = CGAffineTransform(scaleX: scaleFactorX, y: scaleFactorX)
        })
        
        newBackgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissEnlargedImage))
        newBackgroundView.addGestureRecognizer(tap)
        self.view.addSubview(newBackgroundView)
    }
    
    func dismissEnlargedImage(_ sender:UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func adjustAndDraw() {
        if (Display.typeIsLike == .iphone5) {
            name.font = UIFont.init(name: "HelveticaNeue-Medium", size: 13)
            signature.font = UIFont.init(name: "HelveticaNeue", size: 11)
            currentDistance.frame = CGRect(x:17,y:20,width:66,height:24)
            currentDistance.font = UIFont.systemFont(ofSize: 14)
            currentDistance.sizeToFit()
            thisweekLabel.center.x = currentDistance.center.x
            thisweekLabel.center.y = 50
            totalDistance.font = UIFont.systemFont(ofSize: 14)
            totalDistance.sizeToFit()
            totalDistance.frame.origin.y = 65
            totalDistance.center.x = currentDistance.center.x
            totalLabel.center.x = currentDistance.center.x
            totalLabel.center.y = totalDistance.center.y + thisweekLabel.center.y - currentDistance.center.y
            barChart.frame = CGRect(x:60, y: 10, width:220,height:105)
        } else if (Display.typeIsLike == .iphone7plus) {
            currentDistance.frame = CGRect(x:30,y:30,width:90,height:29)
            currentDistance.font = UIFont.systemFont(ofSize: 18)
            currentDistance.sizeToFit()
            thisweekLabel.center.x = currentDistance.center.x
            thisweekLabel.center.y = 60
            thisweekLabel.font = UIFont.systemFont(ofSize: 11)
            totalDistance.font = UIFont.systemFont(ofSize: 18)
            totalDistance.frame.size.width = 90
            totalDistance.sizeToFit()
            totalDistance.frame.origin.y = 85
            totalDistance.center.x = currentDistance.center.x
            totalLabel.center.x = currentDistance.center.x
            totalLabel.center.y = totalDistance.center.y + thisweekLabel.center.y - currentDistance.center.y
            totalLabel.font = UIFont.systemFont(ofSize: 11)
            barChart.frame = CGRect(x:100, y: 22, width:260,height:135)
        }
        
        separator.center.y = (thisweekLabel.center.y + totalDistance.center.y)/2-3
        
        drawWeeklyChart(chart: barChart, values: data, maxValue: 6)
    }
    
    func drawWeeklyChart(chart:PNBarChart,values:[Any], maxValue:Float) {
        let yRunningLabelZero = UILabel()
        let yRunningLabelHalf = UILabel()
        let yRunningLabelFull = UILabel()
        
        var displayHalf = ""
        var displayFull = ""
        
        if (maxValue.truncatingRemainder(dividingBy: 1) == 0) {
            if (maxValue.truncatingRemainder(dividingBy: 2) == 0 || maxValue > 20000) {
                displayHalf = "\(Int(maxValue)/2)"
            } else {
                displayHalf = "\(maxValue/2)"
            }
            displayFull = "\(Int(maxValue))"
        } else {
            displayHalf = String(format:"%.1f", maxValue/2)
            displayFull = String(format:"%.1f", maxValue)
        }
        
        chart.backgroundColor = UIColor.clear
        chart.xLabels = weekDays
        chart.yValues = values
        chart.yValueMax = maxValue
        colors[dayOfWeek-1] = Colors.myOrange
        chart.strokeColors = colors
        
        yRunningLabelZero.frame = CGRect(x:chart.frame.width - 30, y:chart.frame.height-30, width:30, height:11)
        yRunningLabelZero.text = "0"
        yRunningLabelZero.textColor = UIColor.gray
        yRunningLabelZero.font = UIFont.systemFont(ofSize: 9)
        yRunningLabelZero.textAlignment = .natural
        
        yRunningLabelHalf.frame = CGRect(x:chart.frame.width - 30, y:chart.frame.height/3+5,width:30,height:11)
        yRunningLabelHalf.text = displayHalf
        yRunningLabelHalf.textColor = UIColor.gray
        yRunningLabelHalf.font = UIFont.systemFont(ofSize: 9)
        yRunningLabelHalf.textAlignment = .natural
        
        yRunningLabelFull.frame = CGRect(x:chart.frame.width - 30, y:0, width:40, height:11)
        yRunningLabelFull.text = displayFull
        yRunningLabelFull.textColor = UIColor.gray
        yRunningLabelFull.font = UIFont.systemFont(ofSize: 9)
        yRunningLabelFull.textAlignment = .natural
        
        chart.addSubview(yRunningLabelZero)
        chart.addSubview(yRunningLabelHalf)
        chart.addSubview(yRunningLabelFull)
        chart.stroke()
    }
    
    @IBAction func dismissDetail(_ sender: UITapGestureRecognizer) {        
        UIView.animate(withDuration: 0.5, animations: {
            self.detailView.center.y += self.view.bounds.height
        })
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI() {
        adjustAndDraw()
        avatar.setImage(displayAvatar, for: .normal)
        name.text = displayName
        signature.text = displaySignature
        ranking.text = displayRanking
        currentDistance.text = displayCurrentDistance
        stopLoadingAnimation()
    }
    
    func retrieveData() {
        let today = Date()
        let beginOfToday = calendar.startOfDay(for: today)
        let beginOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: beginOfToday)!)
        let endOfToday = calendar.date(byAdding: .second, value: -1, to: beginOfTomorrow)!
        
        let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: today)
        dayOfWeek = component.weekday!
        
        for i in 1...component.weekday! {
            let beginOfWeekDay = Int(calendar.date(byAdding: .day, value: -(component.weekday!-i), to: beginOfToday)!.timeIntervalSince1970)
            let endOfWeekDay = Int(calendar.date(byAdding: .day, value: -(component.weekday!-i), to: endOfToday)!.timeIntervalSince1970)
            var distanceOfTheDay = 0.0
            
            let query = AWSDynamoDBQueryExpression()
            
            query.expressionAttributeNames = ["#D":"date"]
            query.expressionAttributeValues = [":userId":userId!,":begin":beginOfWeekDay,":end":endOfWeekDay]
            query.keyConditionExpression = "userId = :userId AND #D BETWEEN :begin AND :end"
            
            objectMapper.query(AllTimeRun.classForCoder(), expression: query).continue(with: AWSExecutor.default(), with: {(task:AWSTask!)-> Any! in
                if (task.error != nil) {
                    print(task.error!)
                }
                if (task.exception != nil) {
                    print(task.exception!)
                }
                if (task.result != nil) {
                    DispatchQueue.main.async {
                        let paginatedOutput = task.result!
                        for item in paginatedOutput.items {
                            if let run = item as? AllTimeRun {
                                if (self.language == "zh_Hans"){
                                    distanceOfTheDay += run._distance!.doubleValue
                                } else {
                                    distanceOfTheDay += run._distance!.doubleValue/1.60934
                                }
                            }
                        }
                        self.data[i-1] = distanceOfTheDay
                        self.dataUpdatedCount += 1
                        if(self.dataUpdatedCount==component.weekday) {
                            self.updateUI()
                        }
                    }
                }
                return nil
            })
        }
        
        objectMapper.load(User.classForCoder(), hashKey: userId!, rangeKey: nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            if (task.error != nil) {
                print(task.error!)
            }
            if (task.exception != nil) {
                print(task.exception!)
            }
            if (task.result != nil) {
                let user = task.result as! User
                DispatchQueue.main.async {
                    if(self.language == "zh_Hans") {
                        self.totalDistance.text = String(format:"%.1f 公里", Double(round(user._totalRunningDistance!.doubleValue*10)/10))
                    } else {
                        self.totalDistance.text = String(format:"%.1f miles", Double(round((user._totalRunningDistance!.doubleValue/1.60934)*10)/10))
                    }
                }
            }
            return nil
        })

    }
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.clipsToBounds = true
        avatar.layer.borderWidth = 2
        avatar.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.detailView.center.y += self.view.bounds.height
        }, completion: {(completed:Bool) -> Void in
            self.retrieveData()
        })
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityIndicator.center = self.view.center
        startLoadingAnimation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.imageView?.contentMode = .scaleAspectFill
        barChart.backgroundColor = Colors.myPinkBackground
        detailView.layer.cornerRadius = 10
        detailView.clipsToBounds = true
        detailView.center.y -= self.view.bounds.height
        data = [Double](repeatElement(0, count: 7))
        if (language == "zh_Hans") {
            weekDays = ["周日","周一","周二","周三","周四","周五","周六"]
        } else {
            weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        }
    }
}
