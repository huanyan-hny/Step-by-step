//
//  SettingTextFieldController.swift
//  Step by step
//
//  Created by Troy on 2017/1/8.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

public enum TextFieldType:String {
    case username = "Name"
    case signature = "Signature"
    case dailyWalkingGoal = "Daily walking goal"
    case dailyRunningGoal = "Daily running goal"
    case unknown = ""
    
}

class SettingTextFieldController: UITableViewController, UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!
    
    var fieldType = TextFieldType.unknown
    var maxTextLength = 10
    
    func saveUsername() {
        let newUsername = textField.text
        UserDefaults.standard.set(newUsername!, forKey: "username")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func saveSignature() {
        let newSignature = textField.text
        UserDefaults.standard.set(newSignature, forKey: "signature")
        _ = self.navigationController?.popViewController(animated: true)
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
        print (fieldType)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = fieldType.rawValue
        textField.becomeFirstResponder()
        if (fieldType == .dailyWalkingGoal) {
            textField.keyboardType = .numberPad
            textField.placeholder = "\(UserDefaults.standard.integer(forKey: "dailyWalkingGoal"))"
        } else if (fieldType == .dailyRunningGoal) {
            textField.keyboardType = .decimalPad
            textField.placeholder = String.init(format: "%.1f miles", UserDefaults.standard.double(forKey: "dailyRunningGoal"))
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        textField.returnKeyType = .done
        textField.delegate = self
    }
}
