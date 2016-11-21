
//
//  HomeViewController.swift
//  Step by step
//
//  Created by Troy on 15/5/20.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{

    @IBOutlet var currentSteps: UILabel!
    @IBOutlet var currentDistance: UILabel!
    @IBOutlet var currentCalorie: UILabel!
    @IBOutlet var runningButton: UIButton!
    
    
    let ma = MainActivity()

    override func viewDidLoad() {
        
        self.navigationItem.title = "Steps";
        
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 102/255.0, green: 51/255, blue: 204/255, alpha: 1)
        self.runningButton.layer.cornerRadius = 10;
      
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "steps"), object: ma, queue: OperationQueue.main){ notification in
            self.updateSteps()
        }
        updateSteps()
        
    }
    
    
    func updateSteps()
    {
//        dispatch_async(dispatch_get_main_queue()) {
            self.currentSteps.text = "\(self.ma.steps)"
            self.currentDistance.text = "\(self.ma.distance) m"
//        }
        
    }
    
}
 
