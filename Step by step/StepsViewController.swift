

//
//  HomeViewController.swift
//  Step by step
//
//  Created by Troy on 15/5/20.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import PNChart
import CoreData
import AWSDynamoDB
import AWSS3

class StepsViewController: UIViewController, PNChartDelegate, UIScrollViewDelegate {

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!
    @IBOutlet weak var currentLift: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var todaystepLabel: UILabel!
    

    
    var managedObjectContext:NSManagedObjectContext?
    let runFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    var runFetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var colors = [UIColor](repeatElement(Colors.myBlue, count: 7))
    var emptyWalkingData = [Int]()
    var emptyRunningData = [Double]()
    var walkingData = [Int]()
    var runningData = [Double]()
    var walkingGoal = 3000
    var runningGoal = 5.0
    var weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var totalSteps = 0
    var totalRunnings = 0.0
    var dateByWeek = ""
    var dayOfWeek = 1
    var calendar = Calendar.current
    var dataUpdatedCount = 0
    var walkingChart = PNBarChart()
    var runningChart = PNBarChart()
    
    let userID = UserDefaults.standard.string(forKey: "userID")
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let monitor = StepsMonitor()
    let scrollView = UIScrollView()
    let dateFormatter = DateFormatter()
    let pedometer = Pedometer.sharedInstance
    let yWalkingLabelZero = UILabel()
    let yWalkingLabelHalf = UILabel()
    let yWalkingLabelFull = UILabel()
    let yRunningLabelZero = UILabel()
    let yRunningLabelHalf = UILabel()
    let yRunningLabelFull = UILabel()
    let weekLabel = UILabel()
    let totalStepsLabel = UILabel()
    let thisWeekLabel = UILabel()
    let walkingLabel = UILabel()
    let weekLabel2 = UILabel()
    let totalRunningsLabel = UILabel()
    let thisWeekLabel2 = UILabel()
    let runningLabel  = UILabel()
    
    func drawScrollView() {
        /*Screen size related UI*/
        if (Display.typeIsLike == .iphone7plus) { //iphone7plus
            weekLabel.frame = CGRect(x:9, y:26, width:135, height:18)
            totalStepsLabel.frame = CGRect(x:0, y:78, width:140, height:28)
            thisWeekLabel.frame = CGRect(x:0, y:109, width: 65, height: 15)
            walkingLabel.frame = CGRect(x:340, y:0, width:55, height:18)
            walkingChart.frame = CGRect(x:115, y:30, width:294, height:150)
            scrollView.frame = CGRect(x:0, y:360 , width:414, height:180)
            weekLabel.font = UIFont.systemFont(ofSize: 15)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 28)
            totalRunningsLabel.font = UIFont.systemFont(ofSize: 24)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 14)
            walkingLabel.font = UIFont.systemFont(ofSize: 14)
        } else if (Display.typeIsLike == .iphone7) { //iphone 7
            weekLabel.frame = CGRect(x:7, y:21, width:115, height:13)
            totalStepsLabel.frame = CGRect(x:0, y:68, width:120, height:25)
            thisWeekLabel.frame = CGRect(x:0, y:106, width: 59, height: 13)
            walkingLabel.frame = CGRect(x:310, y:0, width:50, height:16)
            walkingChart.frame = CGRect(x:105,y:26,width:270,height:121)
            scrollView.frame = CGRect(x:0, y:330, width:375, height:150)
            weekLabel.font = UIFont.systemFont(ofSize: 13)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 25)
            totalRunningsLabel.font = UIFont.systemFont(ofSize: 21)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 13)
            walkingLabel.font = UIFont.systemFont(ofSize: 13)
        } else { //iphone SE
            weekLabel.frame = CGRect(x:6, y:16, width:105, height:14)
            totalStepsLabel.frame = CGRect(x:20.5, y:55, width:100, height:20)
            thisWeekLabel.frame = CGRect(x:29, y:78, width: 59, height: 11)
            walkingLabel.frame = CGRect(x:266, y:0, width:50, height:14)
            walkingChart.frame = CGRect(x:85,y:21,width:230,height:100)
            scrollView.frame = CGRect(x:0, y:280, width:320, height:125)
            weekLabel.font = UIFont.systemFont(ofSize: 11)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 20)
            totalRunningsLabel.font = UIFont.systemFont(ofSize: 17)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 11)
            walkingLabel.font = UIFont.systemFont(ofSize: 11)
        }
        
        if (language == "zh-Hans") {
            thisWeekLabel.text = "本周"
            thisWeekLabel2.text = "本周"
            walkingLabel.text = "步数"
            runningLabel.text = "跑步"
            totalRunningsLabel.text = String(format:"%.1f 公里", Double(round(totalRunnings*10)/10))
        } else {
            thisWeekLabel.text = "this week"
            thisWeekLabel2.text = "this week"
            walkingLabel.text = "Walking"
            runningLabel.text = "Running"
            totalRunningsLabel.text = String(format:"%.1f miles", Double(round((totalRunnings/1.60934)*10)/10))
        }
        
    
        weekLabel.text = dateByWeek
        weekLabel.textColor = Colors.myTextGray
        weekLabel.sizeToFit()
        weekLabel.center.x = (scrollView.frame.width - walkingChart.frame.width + 30)/2
        
        totalStepsLabel.center.x = weekLabel.center.x
        totalStepsLabel.textColor = Colors.myBlue
        totalStepsLabel.textAlignment = .center
        totalStepsLabel.text = "\(totalSteps)"
        
        thisWeekLabel.center.x = weekLabel.center.x
        thisWeekLabel.textColor = Colors.myTextLightGray
        thisWeekLabel.textAlignment = .center
        
        
        walkingLabel.textColor = Colors.myTextLightGray
        
        weekLabel2.text = dateByWeek
        weekLabel2.frame = weekLabel.frame
        weekLabel2.font = weekLabel.font
        weekLabel2.textColor = Colors.myTextGray
        weekLabel2.sizeToFit()
        weekLabel2.center.x = (scrollView.frame.width - walkingChart.frame.width + 30)/2 + scrollView.frame.width
        
        totalRunningsLabel.frame = totalStepsLabel.frame
        totalRunningsLabel.frame.origin.x += scrollView.frame.width
        totalRunningsLabel.center.x = weekLabel2.center.x
        totalRunningsLabel.textColor = Colors.myBlue
        totalRunningsLabel.textAlignment = .center
        
        thisWeekLabel2.frame = thisWeekLabel.frame
        thisWeekLabel2.frame.origin.x += scrollView.frame.width
        thisWeekLabel2.center.x = weekLabel2.center.x
        thisWeekLabel2.font = thisWeekLabel.font
        thisWeekLabel2.textColor = Colors.myTextLightGray
        thisWeekLabel2.textAlignment = .center
        
        runningLabel.frame = walkingLabel.frame
        runningLabel.frame.origin.x += scrollView.frame.width
        runningLabel.font = walkingLabel.font
        
        runningLabel.textColor = Colors.myTextLightGray
        
        runningChart.frame = walkingChart.frame
        runningChart.frame.origin.x += scrollView.frame.width
        
        scrollView.contentSize = CGSize(width:scrollView.frame.width*2, height:scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        
        scrollView.addSubview(weekLabel)
        scrollView.addSubview(totalStepsLabel)
        scrollView.addSubview(thisWeekLabel)
        scrollView.addSubview(walkingLabel)
        scrollView.addSubview(walkingChart)
        drawWeeklyChart(chart: walkingChart, values: walkingData, maxValue:Float(walkingGoal))
        
        
        scrollView.addSubview(weekLabel2)
        scrollView.addSubview(totalRunningsLabel)
        scrollView.addSubview(thisWeekLabel2)
        scrollView.addSubview(runningLabel)
        scrollView.addSubview(runningChart)
        drawWeeklyChart(chart: runningChart, values: runningData, maxValue:Float(runningGoal))
    }
    
    
    func drawWeeklyChart(chart:PNBarChart,values:[Any], maxValue:Float) {
        
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
        colors = [UIColor](repeatElement(Colors.myBlue, count: 7))
        colors[dayOfWeek-1] = Colors.myOrange
        chart.strokeColors = colors
    
        if (chart == walkingChart) {
            yWalkingLabelZero.frame = CGRect(x:chart.frame.width - 30, y:chart.frame.height-30, width:30, height:11)
            yWalkingLabelZero.text = "0"
            yWalkingLabelZero.textColor = UIColor.gray
            yWalkingLabelZero.font = UIFont.systemFont(ofSize: 9)
            yWalkingLabelZero.textAlignment = .natural
            
            yWalkingLabelHalf.frame = CGRect(x:chart.frame.width - 30, y:chart.frame.height/3+5,width:30,height:11)
            yWalkingLabelHalf.text = displayHalf
            yWalkingLabelHalf.textColor = UIColor.gray
            yWalkingLabelHalf.font = UIFont.systemFont(ofSize: 9)
            yWalkingLabelHalf.textAlignment = .natural
            
            yWalkingLabelFull.frame = CGRect(x:chart.frame.width - 30, y:0, width:40, height:11)
            yWalkingLabelFull.text = displayFull
            yWalkingLabelFull.textColor = UIColor.gray
            yWalkingLabelFull.font = UIFont.systemFont(ofSize: 9)
            yWalkingLabelFull.textAlignment = .natural
            
            chart.addSubview(yWalkingLabelZero)
            chart.addSubview(yWalkingLabelHalf)
            chart.addSubview(yWalkingLabelFull)
        } else if (chart == runningChart) {
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
        }
        
    }
    
    
    func retriveStatisticsData() {
        
        walkingGoal = UserDefaults.standard.integer(forKey: "dailyWalkingGoal")
        runningGoal = UserDefaults.standard.double(forKey: "dailyRunningGoal")
        walkingData = [Int](repeatElement(0, count: 7))
        emptyWalkingData = [Int](repeatElement(0, count: 7))
        runningData = [Double](repeatElement(0, count: 7))
        emptyRunningData = [Double](repeatElement(0, count: 7))
        dataUpdatedCount = 0
        
        let today = Date()
        let beginOfToday = calendar.startOfDay(for: today)
        let beginOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: beginOfToday)!)
        let endOfToday = calendar.date(byAdding: .second, value: -1, to: beginOfTomorrow)!
        
        let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: today)
        if (language == "zh-Hans") {
            dateByWeek = "第\(component.weekOfYear!)周, " + dateFormatter.string(from:Date())
        } else {
            dateByWeek = "Week \(component.weekOfYear!), " + dateFormatter.string(from:Date())
        }
        dayOfWeek = component.weekday!
    
        
        for i in 1...component.weekday! {
            let beginOfWeekDay = calendar.date(byAdding: .day, value: -(component.weekday!-i), to: beginOfToday)!
            let endOfWeekDay = calendar.date(byAdding: .day, value: -(component.weekday!-i), to: endOfToday)!
            
            if (userID != nil) {
                runFetchRequest.predicate = NSPredicate(format: "userID = %@ AND date>=%@ AND date <=%@", userID!,beginOfWeekDay as NSDate,endOfWeekDay as NSDate)
                do{ try runFetchResultsController?.performFetch()} catch _ { print("Could not fetch run!")}
                
                var runningDistance = 0.0
                for object in (runFetchResultsController?.fetchedObjects)! {
                    if let run = object as? Run {
                        if (language == "zh-Hans"){
                            runningDistance += run.distance!.doubleValue
                        } else {
                            runningDistance += run.distance!.doubleValue/1.60934
                        }
                    }
                }
                self.runningData[i-1] = runningDistance
            }
            
            pedometer.queryPedometerData(from: beginOfWeekDay, to: endOfWeekDay, withHandler: {data, error in
                if (error==nil) {
                    DispatchQueue.main.async {
                        let steps = data!.numberOfSteps.intValue
                        self.walkingData[i-1] = steps
                        self.dataUpdatedCount += 1
                        
                        if (steps>=10000) {
                            self.updateStepsAchievements(id: 0)
                        }
                        if (steps>=20000) {
                            self.updateStepsAchievements(id: 1)
                        }
                        
                        if (steps>=30000){
                            self.updateStepsAchievements(id: 2)
                        }
                        self.updateStepsRecord(steps:steps)
                        
                        if (self.dataUpdatedCount==component.weekday) {
                            self.updateUI()
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("Motion access denied", comment: ""), message: NSLocalizedString("Step by step is unable to retrieve your steps, please authorize access for in Settings", comment: ""), preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                    
                    alertController.addAction(cancelAction)
                    
                    let openAction = UIAlertAction(title:NSLocalizedString("Go to Settings", comment: ""), style: .default) {(action) in
                        if let settingURL = NSURL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingURL as URL)
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    func updateUI() {
        totalSteps = walkingData.reduce(0, +)
        totalRunnings = runningData.reduce(0, +)
        drawScrollView()
        if (pageControl.currentPage==0) {
            runningChart.updateData(emptyRunningData)
            walkingChart.updateData(walkingData)
        } else {
            runningChart.updateData(runningData)
            walkingChart.updateData(emptyWalkingData)
        }
    }
    
    func updateSteps() {
        self.currentSteps.text = "\(self.monitor.steps)"
        self.currentDistance.text = "\(self.monitor.distance)"
        self.currentCalorie.text = "\(self.monitor.calorie)"
        self.currentLift.text = "\(self.monitor.lift)"
        let today = Date()
        let beginOfToday = calendar.startOfDay(for: today)
        let beginOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: beginOfToday)!)
        let endOfToday = calendar.date(byAdding: .second, value: -1, to: beginOfTomorrow)!
        pedometer.queryPedometerData(from: beginOfToday, to: endOfToday, withHandler: {data, error in
            if (error==nil) {
                DispatchQueue.main.async {
                    let steps = data!.numberOfSteps.intValue
                    self.walkingData[self.dayOfWeek-1] = steps
                    self.updateUI()
                }
            }
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        if (pageNumber==0) {
            runningChart.updateData(emptyRunningData)
            walkingChart.updateData(walkingData)
        } else {
            runningChart.updateData(runningData)
            walkingChart.updateData(emptyWalkingData)
        }
    }
    
    func onNewDay() {
        walkingChart.removeFromSuperview()
        runningChart.removeFromSuperview()
        walkingChart = PNBarChart()
        runningChart = PNBarChart()
        self.monitor.refresh()
        self.retriveStatisticsData()
        self.currentSteps.text = "\(self.monitor.steps)"
        self.currentDistance.text = "\(self.monitor.distance)"
        self.currentCalorie.text = "\(self.monitor.calorie)"
        self.currentLift.text = "\(self.monitor.lift)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = Colors.myBlue
        retriveStatisticsData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = NSLocalizedString("Steps", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: monitor, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil, queue: OperationQueue.main){notification in
            self.onNewDay()
        }
        updateSteps()
        
        runFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        runFetchResultsController = NSFetchedResultsController(fetchRequest: runFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        dateFormatter.locale = Locale(identifier: UserDefaults.standard.string(forKey: "AppleLocale")!)

        if(language == "zh-Hans") {
            dateFormatter.dateFormat = "YYYY年MMM";
            weekDays = ["周日","周一","周二","周三","周四","周五","周六"]
        } else {
            dateFormatter.dateFormat = "MMM YYYY";
            weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        }

    }
}

