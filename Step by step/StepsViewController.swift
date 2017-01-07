
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

class BarChartFormatter: NSObject, IAxisValueFormatter
{
    var weekdays: [String]! = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return weekdays[Int(value)]
    }
}

class StepsViewController: UIViewController, ChartViewDelegate, PNChartDelegate {

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!

    @IBOutlet weak var runningView: BarChartView!
    @IBOutlet weak var stepsWeekView: PNBarChart!
    
    let ma = MainActivity()

    
    override func viewDidLoad() {
        self.navigationItem.title = "Steps";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: ma, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
        updateSteps()
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0]
        setChart(chartView: runningView,dataPoints: months, values: unitsSold)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
    }
    
    
    func updateSteps()
    {
        self.currentSteps.text = "\(self.ma.steps)"
        self.currentDistance.text = "\(self.ma.distance) m"
        self.currentSteps.text = "3592"
        self.currentDistance.text = "2314"
    }
    
    
    func setChart(chartView:BarChartView, dataPoints: [String], values: [Double]){
        chartView.noDataText = "No steps data"
        chartView.delegate = self
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.drawBordersEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.chartDescription?.enabled = false
        chartView.xAxis.labelPosition = .bottom
        let formatter = BarChartFormatter()
        chartView.xAxis.valueFormatter = formatter
        chartView.isUserInteractionEnabled = false
        //        chartView.xAxis.labelTextColor = UIColor.white
        chartView.borderColor = UIColor.white
        //        chartView.xAxis.labelWidth = 0
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y:values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: nil)
        
        chartDataSet.setColor(UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0))
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setDrawValues(false)
        chartData.barWidth = 0.5
        chartView.data = chartData
        
    }
    
}
 
