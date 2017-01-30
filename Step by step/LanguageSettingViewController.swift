//
//  LanguageSettingViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/22.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class LanguageSettingViewController: UITableViewController {

    @IBOutlet weak var enCheck: UIImageView!
    @IBOutlet weak var zhCheck: UIImageView!

    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    var language_set:String?
    
    func save() {
        if (language_set == "zh-Hans") {
            UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
            UserDefaults.standard.set("zh-Hans",forKey:"AppleLocale")
        } else {
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            UserDefaults.standard.set("en",forKey:"AppleLocale")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setLanguage(newLanguage:self.language_set!)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0 ) {
            language_set = "en"
            enCheck.isHidden = false
            zhCheck.isHidden = true
        } else {
            enCheck.isHidden = true
            zhCheck.isHidden = false
            language_set = "zh-Hans"
        }
        
        if (language_set == language) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
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
        self.navigationItem.title = NSLocalizedString("Language", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        if (language == "zh-Hans") {
            enCheck.isHidden = true
            zhCheck.isHidden = false
        } else {
            enCheck.isHidden = false
            zhCheck.isHidden = true
        }
        language_set = language
    }

}
