//
//  SettingTextFieldController.swift
//  Step by step
//
//  Created by Troy on 2017/1/8.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import AWSDynamoDB


public enum TextFieldType:String {
    case username = "Name"
    case signature = "What's up"
    case dailyWalkingGoal = "Daily walking goal"
    case dailyRunningGoal = "Daily running goal"
    case unknown = ""
}

class SettingTextFieldController: UITableViewController, UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!
    
    var fieldType = TextFieldType.unknown
    var maxTextLength = 10
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let userID = UserDefaults.standard.string(forKey: "userID")!
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    
    func saveUsername() {
        startLoadingAnimation()
        self.objectMapper.load(User.classForCoder(), hashKey:userID, rangeKey:nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil || task.exception != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: "Fail to save username", message: "Please try again later (Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let user = task.result as! User
                    user._name = self.textField.text
                    self.objectMapper.save(user, completionHandler: {(error: Error?) -> Void in
                        DispatchQueue.main.async {
                            self.stopLoadingAnimation()
                            if (error != nil) {
                                let alertController = UIAlertController(title: "Fail to save username", message: "Please try again later (Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                    return
                                }
                                
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            else {
                                UserDefaults.standard.set(user._name!, forKey: "username")
                                _ = self.navigationController?.popViewController(animated: true)
                            }

                        }
                    })

                }
            }
            
        })
    }
    
    func saveSignature() {
        startLoadingAnimation()
        self.objectMapper.load(User.classForCoder(), hashKey:userID, rangeKey:nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil || task.exception != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: "Fail to save signature", message: "Please try again later (Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let user = task.result as! User
                    user._signature = self.textField.text
                    self.objectMapper.save(user, completionHandler: {(error: Error?) -> Void in
                        self.stopLoadingAnimation()
                        DispatchQueue.main.async {
                            if (error != nil) {
                                let alertController = UIAlertController(title: "Fail to save signature", message: "Please try again later (Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                    return
                                }
                                
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            else {
                                UserDefaults.standard.set(user._signature!, forKey: "signature")
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                    })
                    
                }
            }
            
        })

    }
    
    func saveDailyWalkingGoal() {
        let newWalkingGoal = Int(textField.text!)
        UserDefaults.standard.set(newWalkingGoal, forKey: "dailyWalkingGoal")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func saveDailyRunningGoal() {
        let newRunningGoal = Double(textField.text!)
        UserDefaults.standard.set(newRunningGoal, forKey: "dailyRunningGoal")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func checkLength(_ sender: UITextField) {
        guard let inputText = textField.text else { return }
        
        if (inputText.characters.count>0) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        }
        
        let markedRange = textField.markedTextRange
        if (markedRange == nil) {
            if inputText.characters.count>maxTextLength {
                textField.text = inputText.substring(to: inputText.index(inputText.startIndex, offsetBy: maxTextLength))
            }
        }
        
        if (fieldType == .dailyRunningGoal) {
            let parts = inputText.components(separatedBy: ".")
            if parts.count > 2 {
                textField.text = inputText.substring(to: inputText.index(before: inputText.endIndex))
            }
        }
    }

    
    func save() {
        textField.resignFirstResponder()
        switch fieldType {
            case .username:
                saveUsername()
            case .signature:
                saveSignature()
            case .dailyWalkingGoal:
                saveDailyWalkingGoal()
            case .dailyRunningGoal:
                saveDailyRunningGoal()
            default:
                break
        }
    }

    func cancel() {
        _ = self.navigationController?.popViewController(animated: true)
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
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString(fieldType.rawValue, comment: "")
        textField.becomeFirstResponder()
        if (fieldType == .dailyWalkingGoal) {
            textField.keyboardType = .numberPad
            textField.placeholder = "\(UserDefaults.standard.integer(forKey: "dailyWalkingGoal"))"
        } else if (fieldType == .dailyRunningGoal) {
            textField.keyboardType = .decimalPad
            textField.placeholder = String.init(format: "%.1f", UserDefaults.standard.double(forKey: "dailyRunningGoal"))
        } else if (fieldType == .username){
            textField.keyboardType = .default
            textField.placeholder = UserDefaults.standard.string(forKey: "username")
        } else if (fieldType == .signature) {
            textField.keyboardType = .default
            textField.placeholder = UserDefaults.standard.string(forKey: "signature")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancel))
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        textField.returnKeyType = .done
        textField.delegate = self
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = Colors.myUnavailable
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityView.isHidden = true
        activityIndicator.center = self.view.center
    }
}

