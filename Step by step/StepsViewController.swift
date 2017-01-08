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

class StepsViewController: UIViewController, ChartViewDelegate, PNChartDelegate, UIScrollViewDelegate {

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let scrollView = UIScrollView()
    let stepsChart = PNBarChart()
    
    func drawScrollView() {
        scrollView.frame = CGRect(x:0, y:325, width:375, height:150)
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        let weekLabel = UILabel(frame:CGRect(x:8, y:26, width:115, height:17))
        weekLabel.font = UIFont.systemFont(ofSize: 14)
        weekLabel.text = "Week 2, Jan 2017"
        weekLabel.textColor = Colors.myTextGray
        
        let totalStepsLabel = UILabel(frame: CGRect(x:24, y:74, width:74, height:25))
        totalStepsLabel.center.x = weekLabel.center.x
        totalStepsLabel.font = UIFont.systemFont(ofSize: 25)
        totalStepsLabel.text = "16847"
        totalStepsLabel.textColor = Colors.myBlue
        
        let thisWeekLabel = UILabel(frame: CGRect(x:32, y:102, width: 59, height: 13))
        thisWeekLabel.center.x = weekLabel.center.x
        thisWeekLabel.font = UIFont.systemFont(ofSize: 13)
        thisWeekLabel.text = "this week"
        thisWeekLabel.textColor = Colors.myTextLightGray
        
        let walkingLabel = UILabel(frame: CGRect(x:310, y:0, width:48, height:16))
        walkingLabel.font = UIFont.systemFont(ofSize: 13)
        walkingLabel.text = "Walking"
        walkingLabel.textColor = Colors.myTextLightGray
        
        scrollView.addSubview(weekLabel)
        scrollView.addSubview(totalStepsLabel)
        scrollView.addSubview(thisWeekLabel)
        scrollView.addSubview(walkingLabel)
        scrollView.addSubview(stepsChart)
        drawChart()
    }
    
    
    func drawChart() {
        
        stepsChart.frame = CGRect(x:105,y:26,width:270,height:121)
        
        var colors = [UIColor](repeatElement(Colors.myBlue, count: 7))
        
        stepsChart.xLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        stepsChart.yValues = [3450,2000,5260,9120,1380,7720,0]
        stepsChart.yValueMax = 10000
        colors[5] = Colors.myOrange
        stepsChart.strokeColors = colors
        stepsChart.backgroundColor = UIColor.clear
        stepsChart.stroke()
        
        let yLabelZero = UILabel(frame:CGRect(x:stepsChart.frame.width - 30, y:stepsChart.frame.height-30, width:30, height:11))
        yLabelZero.text = "0"
        yLabelZero.textColor = UIColor.gray
        yLabelZero.font = UIFont.systemFont(ofSize: 9)
        yLabelZero.textAlignment = .natural
        
        let yLabelHalf = UILabel(frame:CGRect(x:stepsChart.frame.width - 30, y:stepsChart.frame.height/3+5,width:30,height:11))
        yLabelHalf.text = "5000"
        yLabelHalf.textColor = UIColor.gray
        yLabelHalf.font = UIFont.systemFont(ofSize: 9)
        yLabelHalf.textAlignment = .natural
        
        let yLabelFull = UILabel(frame:CGRect(x:stepsChart.frame.width - 30, y:5, width:35, height:11))
        yLabelFull.text = "10000"
        yLabelFull.textColor = UIColor.gray
        yLabelFull.font = UIFont.systemFont(ofSize: 9)
        yLabelFull.textAlignment = .natural
        
        stepsChart.addSubview(yLabelZero)
        stepsChart.addSubview(yLabelHalf)
        stepsChart.addSubview(yLabelFull)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    let ma = MainActivity()
    
    func updateSteps()
    {
        self.currentSteps.text = "\(self.ma.steps)"
        self.currentDistance.text = "\(self.ma.distance) m"
        self.currentSteps.text = "3592"
        self.currentDistance.text = "2314"
    }
    
    
    override func viewDidLoad() {
        self.navigationItem.title = "Steps";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: ma, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
        updateSteps()
        drawScrollView()
    }
}
 
