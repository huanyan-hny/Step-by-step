//
//  AboutViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/26.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0 ){
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: "https://icons8.com")!)
                self.present(safariVC, animated: true, completion: nil)
                safariVC.delegate = self
                UIApplication.shared.setStatusBarStyle(.default, animated: false)
            } else {
                UIApplication.shared.openURL(URL(string: "https://icons8.com")!)
            }
        } else if (indexPath.row == 1) {
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: "http://www.flaticon.com")!)
                self.present(safariVC, animated: true, completion: nil)
                safariVC.delegate = self
                UIApplication.shared.setStatusBarStyle(.default, animated: false)
            } else {
                UIApplication.shared.openURL(URL(string: "http://www.flaticon.com")!)
            }
        } else if (indexPath.row == 2){
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: "http://www.freepik.com")!)
                self.present(safariVC, animated: true, completion: nil)
                safariVC.delegate = self
                UIApplication.shared.setStatusBarStyle(.default, animated: false)
            } else {
                UIApplication.shared.openURL(URL(string: "http://www.freepik.com")!)
            }
        }
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (Display.typeIsLike == .iphone5) {
            return 37
        } else if (Display.typeIsLike == .iphone7) {
            return 45
        } else if (Display.typeIsLike == .iphone7plus) {
            return 50
        }
        return 45
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = NSLocalizedString("About", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    

}
