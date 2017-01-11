//
//  RankingDetailViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/10.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import PNChart

class RankingDetailViewController: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var barChart: PNBarChart!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var thisweekLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var dayOfWeek = 7
    var data = [Double]()
    var weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var colors = [UIColor](repeatElement(Colors.myBlue, count: 7))
    
    @IBAction func enlargeImage(_ sender: UIButton) {
        let imageView = sender.imageView!
        let newImageView = UIImageView(image: imageView.image)
        let newBackgroundView = UIView(frame: self.view.frame)
        let scaleFactor = self.view.frame.width/imageView.frame.width
        newBackgroundView.backgroundColor = .black
        newImageView.frame = imageView.convert(imageView.frame, to: self.view)
        newBackgroundView.addSubview(newImageView)
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.center = newBackgroundView.center
            newImageView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
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
            currentDistance.frame = CGRect(x:17,y:20,width:66,height:24)
            currentDistance.font = UIFont.systemFont(ofSize: 17)
            currentDistance.sizeToFit()
            thisweekLabel.center.x = currentDistance.center.x
            thisweekLabel.center.y = 50
            totalDistance.font = UIFont.systemFont(ofSize: 17)
            totalDistance.sizeToFit()
            totalDistance.frame.origin.y = 65
            totalDistance.center.x = currentDistance.center.x
            totalLabel.center.x = currentDistance.center.x
            totalLabel.center.y = totalDistance.center.y + thisweekLabel.center.y - currentDistance.center.y
            barChart.frame = CGRect(x:60, y: 10, width:220,height:105)
            print(thisweekLabel.center.y)
        } else if (Display.typeIsLike == .iphone7plus) {
            currentDistance.frame = CGRect(x:30,y:30,width:90,height:29)
            currentDistance.font = UIFont.systemFont(ofSize: 22)
            currentDistance.sizeToFit()
            thisweekLabel.center.x = currentDistance.center.x
            thisweekLabel.center.y = 60
            thisweekLabel.font = UIFont.systemFont(ofSize: 11)
            totalDistance.font = UIFont.systemFont(ofSize: 21)
            totalDistance.frame.size.width = 90
            totalDistance.sizeToFit()
            totalDistance.frame.origin.y = 85
            totalDistance.center.x = currentDistance.center.x
            totalLabel.center.x = currentDistance.center.x
            totalLabel.center.y = totalDistance.center.y + thisweekLabel.center.y - currentDistance.center.y
            totalLabel.font = UIFont.systemFont(ofSize: 11)
            barChart.frame = CGRect(x:100, y: 22, width:260,height:135)
        }
        
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
    
    override func viewDidLayoutSubviews() {
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.clipsToBounds = true
        avatar.layer.borderWidth = 2
        avatar.layer.borderColor = UIColor.white.cgColor
        adjustAndDraw()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.detailView.center.y += self.view.bounds.height
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        data = [3.55, 4.29, 5.21, 2.13, 3.57, 3.56, 3.66]
        barChart.backgroundColor = Colors.myPinkBackground
        detailView.layer.cornerRadius = 10
        detailView.clipsToBounds = true
        detailView.center.y -= self.view.bounds.height
    }
}
