//
//  BaseViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/21.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class BaseViewController: UITabBarController {

    var managedObjectContext:NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 2;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
