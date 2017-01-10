//
//  HomeViewController.swift
//  Step by step
//
//  Created by Troy on 15/5/20.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import UIKit
import Charts
import CoreMotion
import PNChart
import CoreData

class StepsViewController: UIViewController, ChartViewDelegate, PNChartDelegate, UIScrollViewDelegate {

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    var managedObjectContext:NSManagedObjectContext?
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
    
    let monitor = StepsMonitor()
    let scrollView = UIScrollView()
    let walkingChart = PNBarChart()
    let runningChart = PNBarChart()
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
    let totalDistanceLabel = UILabel()
    let thisWeekLabel2 = UILabel()
    let runningLabel  = UILabel()
    
    func drawScrollView() {
        /*Screen size related UI*/
        if (Display.typeIsLike == .iphone7plus) { //iphone7plus
            weekLabel.frame = CGRect(x:9, y:26, width:135, height:18)
            totalStepsLabel.frame = CGRect(x:0, y:78, width:90, height:28)
            thisWeekLabel.frame = CGRect(x:0, y:109, width: 65, height: 15)
            walkingLabel.frame = CGRect(x:340, y:0, width:55, height:18)
            walkingChart.frame = CGRect(x:115, y:30, width:294, height:150)
            scrollView.frame = CGRect(x:0, y:360 , width:414, height:180)
            weekLabel.font = UIFont.systemFont(ofSize: 15)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 28)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 14)
            walkingLabel.font = UIFont.systemFont(ofSize: 14)
        } else if (Display.typeIsLike == .iphone7) { //iphone 7
            weekLabel.frame = CGRect(x:7, y:21, width:115, height:13)
            totalStepsLabel.frame = CGRect(x:0, y:68, width:80, height:25)
            thisWeekLabel.frame = CGRect(x:0, y:106, width: 59, height: 13)
            walkingLabel.frame = CGRect(x:310, y:0, width:50, height:16)
            walkingChart.frame = CGRect(x:105,y:26,width:270,height:121)
            scrollView.frame = CGRect(x:0, y:330, width:375, height:150)
            weekLabel.font = UIFont.systemFont(ofSize: 13)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 25)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 13)
            walkingLabel.font = UIFont.systemFont(ofSize: 13)
        } else { //iphone SE
            weekLabel.frame = CGRect(x:6, y:16, width:105, height:14)
            totalStepsLabel.frame = CGRect(x:20.5, y:55, width:65, height:20)
            thisWeekLabel.frame = CGRect(x:29, y:78, width: 59, height: 11)
            walkingLabel.frame = CGRect(x:266, y:0, width:50, height:14)
            walkingChart.frame = CGRect(x:85,y:21,width:230,height:100)
            scrollView.frame = CGRect(x:0, y:280, width:320, height:125)
            weekLabel.font = UIFont.systemFont(ofSize: 11)
            totalStepsLabel.font = UIFont.systemFont(ofSize: 20)
            thisWeekLabel.font = UIFont.systemFont(ofSize: 11)
            walkingLabel.font = UIFont.systemFont(ofSize: 11)
        }
        
        weekLabel.text = "Week54, Dec 2019"
        weekLabel2.text = "第54周, 2019年12月"
//        weekLabel.text = dateByWeek
        weekLabel.textColor = Colors.myTextGray
        weekLabel.sizeToFit()
        weekLabel.center.x = (scrollView.frame.width - walkingChart.frame.width + 30)/2
        
        totalStepsLabel.center.x = weekLabel.center.x
        totalStepsLabel.text = "\(totalSteps)"
        totalStepsLabel.textColor = Colors.myBlue
        totalStepsLabel.textAlignment = .center
        
        
        thisWeekLabel.center.x = weekLabel.center.x
        thisWeekLabel.text = "this week"
        thisWeekLabel.textColor = Colors.myTextLightGray
        thisWeekLabel.textAlignment = .center
        
        
        walkingLabel.text = "Walking"
        walkingLabel.textColor = Colors.myTextLightGray
        
//        weekLabel2.text = dateByWeek
        weekLabel2.frame = weekLabel.frame
        weekLabel2.font = weekLabel.font
        weekLabel2.textColor = Colors.myTextGray
        weekLabel2.sizeToFit()
        weekLabel2.center.x = (scrollView.frame.width - walkingChart.frame.width + 30)/2 + scrollView.frame.width
        
        totalDistanceLabel.frame = totalStepsLabel.frame
        totalDistanceLabel.frame.origin.x += scrollView.frame.width
        totalDistanceLabel.center.x = weekLabel2.center.x
        totalDistanceLabel.font = totalStepsLabel.font
        totalDistanceLabel.text = "\(totalRunnings)"
        totalDistanceLabel.textColor = Colors.myBlue
        totalDistanceLabel.textAlignment = .center
        
        thisWeekLabel2.frame = thisWeekLabel.frame
        thisWeekLabel2.frame.origin.x += scrollView.frame.width
        thisWeekLabel2.center.x = weekLabel2.center.x
        thisWeekLabel2.font = thisWeekLabel.font
        thisWeekLabel2.text = "this week"
        thisWeekLabel2.textColor = Colors.myTextLightGray
        thisWeekLabel2.textAlignment = .center
        
        runningLabel.frame = walkingLabel.frame
        runningLabel.frame.origin.x += scrollView.frame.width
        runningLabel.font = walkingLabel.font
        runningLabel.text = "Running"
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
        scrollView.addSubview(totalDistanceLabel)
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
    
    
    func retriveWalkingData() {
        
        weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        
        let today = Date()
        let beginOfToday = calendar.startOfDay(for: today)
        let beginOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: beginOfToday)!)
        let endOfToday = calendar.date(byAdding: .second, value: -1, to: beginOfTomorrow)!
        
        let component = calendar.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: today)
        dateByWeek = "Week \(component.weekOfYear!), " + dateFormatter.string(from:Date())
        dayOfWeek = component.weekday!
        
        for i in 1...component.weekday! {
            let beginOfWeekDay = calendar.date(byAdding: .day, value: -(component.weekday!-i), to: beginOfToday)!
            let endOfWeekDay = calendar.date(byAdding: .day, value: -(component.weekday!-i), to: endOfToday)!
            pedometer.queryPedometerData(from: beginOfWeekDay, to: endOfWeekDay, withHandler: {data, error in
                if (error==nil) {
                    DispatchQueue.main.async {
                        self.walkingData[i-1] = (data?.numberOfSteps.intValue)!
                        if(i==component.weekday!) {
                            self.updateUI()
                        }
                    }
                }
            })
        }
    }
    
    func retriveRunningData() {
        runningData = [3.55, 4.29, 5.21, 2.13, 3.57, 3.56, 3.66]
        totalRunnings = runningData.reduce(0, +)
    }
    
    func updateUI() {
        walkingData = [1074,2456,4315,1000,2487,2687,800]
        totalSteps = walkingData.reduce(0, +)
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
        self.currentDistance.text = "\(self.monitor.distance) m"
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = Colors.myBlue
        walkingGoal = UserDefaults.standard.integer(forKey: "dailyWalkingGoal")
        runningGoal = UserDefaults.standard.double(forKey: "dailyRunningGoal")
        retriveWalkingData()
        retriveRunningData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Steps";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: monitor, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
    
        walkingData = [Int](repeatElement(walkingGoal/100, count: 7))
        emptyWalkingData = [Int](repeatElement(walkingGoal/100, count: 7))
        runningData = [Double](repeatElement(runningGoal/100, count: 7))
        emptyRunningData = [Double](repeatElement(runningGoal/100, count: 7))
        
        dateFormatter.dateFormat = "MMM YYYY";
        dateFormatter.locale = Locale(identifier: "en-US")
        updateSteps()
        
        /*Tempoary - to be removed*/
        test()
        
    }
    func test() {
        if(Display.typeIsLike == .iphone5 || Display.typeIsLike == .iphone6plus) {
            updateUI()
        }
        UserDefaults.standard.set("happyhn2020@163.com", forKey: "userID")
        let savedRanking = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into:managedObjectContext!) as! Ranking
        savedRanking.rank = 16
        savedRanking.userID = "happyhn2020@163.com"
        savedRanking.type = "Weekly"
        savedRanking.startDate = calendar.date(byAdding: .day, value: -7, to: Date())
        savedRanking.endDate = Date()
        savedRanking.totalDistance = 12
        
        let savedRanking2 = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into:managedObjectContext!) as! Ranking
        savedRanking2.rank = 8
        savedRanking2.userID = "happyhn2020@163.com"
        savedRanking2.type = "Weekly"
        savedRanking2.startDate = calendar.date(byAdding: .day, value: -21, to: Date())
        savedRanking2.endDate = calendar.date(byAdding: .day, value: -14, to: Date())
        savedRanking2.totalDistance = 18
        
        let savedAchievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into:managedObjectContext!) as! Achievement
        savedAchievement.userID = "happyhn2020@163.com"
        savedAchievement.date = Date()
        savedAchievement.id = 3
        savedAchievement.isNew = 0
        
        let savedAchievement2 = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into:managedObjectContext!) as! Achievement
        savedAchievement2.userID = "happyhn2020@163.com"
        savedAchievement2.date = Date()
        savedAchievement2.id = 6
        savedAchievement2.isNew = 1
        
        let savedRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
        savedRecord.userID = "happyhn2020@163.com"
        savedRecord.date = Date()
        savedRecord.type = "Distance"
        savedRecord.value = 20
        
        let savedRecord2 = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
        savedRecord2.userID = "happyhn2020@163.com"
        savedRecord2.date = Date()
        savedRecord2.type = "Duration"
        savedRecord2.value = 1350
        
        let savedRecord3 = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
        savedRecord3.userID = "happyhn2020@163.com"
        savedRecord3.date = Date()
        savedRecord3.type = "Pace"
        savedRecord3.value = 1350
        
        let savedRecord4 = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
        savedRecord4.userID = "happyhn2020@163.com"
        savedRecord4.date = Date()
        savedRecord4.type = "Steps"
        savedRecord4.value = 19927
        
        do {try managedObjectContext!.save()} catch _ {print ("Cannot save")}
    
    }
}
 
