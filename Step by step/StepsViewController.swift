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
import AWSMobileHubHelper
import AWSDynamoDB
import AWSS3

class StepsViewController: UIViewController, ChartViewDelegate, PNChartDelegate, UIScrollViewDelegate {

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!
    @IBOutlet weak var currentLift: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
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
//    var weekDays = ["周日","周一","周二","周三","周四","周五","周六"]
    var totalSteps = 0
    var totalRunnings = 0.0
    var dateByWeek = ""
    var dayOfWeek = 1
    var calendar = Calendar.current
    var dataUpdatedCount = 0
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
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
            thisWeekLabel.font = UIFont.systemFont(ofSize: 11)
            walkingLabel.font = UIFont.systemFont(ofSize: 11)
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
        thisWeekLabel.text = "this week"
        thisWeekLabel.textColor = Colors.myTextLightGray
        thisWeekLabel.textAlignment = .center
        
        
        walkingLabel.text = "Walking"
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
        totalRunningsLabel.font = totalStepsLabel.font
        totalRunningsLabel.text = String(format:"%.1f miles", Double(round(totalRunnings*10)/10))
        totalRunningsLabel.textColor = Colors.myBlue
        totalRunningsLabel.textAlignment = .center
        
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
            
            runFetchRequest.predicate = NSPredicate(format: "userID = %@ AND date>=%@ AND date <=%@", UserDefaults.standard.string(forKey: "userID")!,beginOfWeekDay as NSDate,endOfWeekDay as NSDate)
            do{ try runFetchResultsController?.performFetch()} catch _ { print("Could not fetch run!")}
            
            var runningMiles = 0.0
            for object in (runFetchResultsController?.fetchedObjects)! {
                if let run = object as? Run {
                    runningMiles += run.distance!.doubleValue
                }
            }
            self.runningData[i-1] = runningMiles
            
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
        walkingData = [Int](repeatElement(0, count: 7))
        emptyWalkingData = [Int](repeatElement(0, count: 7))
        runningData = [Double](repeatElement(0, count: 7))
        emptyRunningData = [Double](repeatElement(0, count: 7))
        monitor.refresh()
        dataUpdatedCount = 0
        retriveStatisticsData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Steps";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: monitor, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
        updateSteps()
        runFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        runFetchResultsController = NSFetchedResultsController(fetchRequest: runFetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        
        dateFormatter.dateFormat = "MMM YYYY";
        dateFormatter.locale = Locale(identifier: "en-US")
        
        
        test()
        
    }
    
        
    
    func test() {
        if(Display.typeIsLike == .iphone5 || Display.typeIsLike == .iphone6plus) {
            updateUI()
        }
    }
    
    func checkFileExists() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let avatarPath = documentPath.appendingPathComponent("userAvatar.png")
        let fileExists = (try? avatarPath.checkResourceIsReachable()) ?? false
        print(fileExists)
    }
    
    func retrieveImg() {
        
        let imgView = UIImageView(frame: CGRect(x:30,y:50,width:300,height:400))
        
        let path = NSTemporaryDirectory().appending("happyhn2020@163.com.png")
        let url = URL(fileURLWithPath: path)
        
        let avatarExists = (try? url.checkResourceIsReachable()) ?? false
        
        if (!avatarExists) {
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest?.bucket = "stepbystep-userfiles-mobilehub-138898687"
            downloadRequest?.key = "happyhn2020@163.com.png"
            downloadRequest?.downloadingFileURL = url
            let manager = AWSS3TransferManager.default()
            manager?.download(downloadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                
                if (task.error != nil) {
                    print(task.error!)
                }
                
                if (task.exception != nil) {
                    print (task.exception!)
                }
                
                if (task.result != nil) {
                    print("File downloaded to " + url.absoluteString)
                    DispatchQueue.main.async {
                        imgView.contentMode = .scaleAspectFit
                        imgView.image = UIImage(contentsOfFile:url.path)
                    }
                    
                }
                
                return nil
            })
        } else {
            imgView.contentMode = .scaleAspectFit
            imgView.image = UIImage(contentsOfFile:url.path)
        }
        
        
        self.view.addSubview(imgView)
    }
    
    func uploadImg() {
        let S3BucketName = "stepbystep-userfiles-mobilehub-138898687"
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let avatarPath = documentPath.appendingPathComponent("userAvatar.png")
        uploadRequest?.body = avatarPath
        uploadRequest?.key = "public/avatars/" + UserDefaults.standard.string(forKey: "userID")!
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.bucket = S3BucketName
        let manager = AWSS3TransferManager.default()
        manager?.upload(uploadRequest).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            if task.error != nil {
                let alertController = UIAlertController(title: "Error", message: "Error logging out, please try again", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                    return
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
           
            if task.result != nil {
                
            }
            return nil
        })
    }
    
    func queryData() {
        let query = AWSDynamoDBQueryExpression()
        
        query.keyConditionExpression = "week = :weekNum"
        query.expressionAttributeValues = [":weekNum":NSNumber.init(value: 201712)]
        
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
                    print(item)
                    if let rank = item as? WeeklyRanking {
                        print(rank._week!)
                        print(rank._userId!)
                        print(rank._distance!)
                    }
                }
            }
            return nil
        })
    }
    
    func loadData() {
        objectMapper.load(WeeklyRanking.classForCoder(), hashKey:NSNumber.init(value: 201712), rangeKey: "chenyaoloveyou@gmail.com").continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                let result = task.result as! WeeklyRanking
                print(result._distance!.intValue)
                return nil
            })
    }
    
    func insertData() {
        let newUser = User()
        newUser?._userId = "咯咯咯？"
        newUser?._totalRunningDistance = 65
        newUser?._name = "呱呱呱？"
        newUser?._signature = "叽叽叽"

        objectMapper.save(newUser!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        
    }
}

