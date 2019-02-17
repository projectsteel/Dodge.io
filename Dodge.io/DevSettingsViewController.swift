//
//  DevSettingsViewController.swift
//  Dodge.io
//
//  Created by Jamie Pickar on 11/23/18.
//  Copyright © 2018 Project Steel. All rights reserved.
//

import UIKit

class DevSettingsViewController: UIViewController {

    @IBOutlet weak var runnerSpeedTextBox: UITextField!
    @IBOutlet weak var wallDownDurationTextBox: UITextField!
    @IBOutlet weak var gapDiffPerTenthSecTextBox: UITextField!
    
    @IBAction func setButton(_ sender: Any) {
        
        var runnerSpeedWasUpdated : Bool = false
        var wallMoveDownDurationWasUpdated : Bool = false
        var differenceInWallResizePerTenthSecWasUpdated : Bool = false
        
        if let runnerSpeedString = runnerSpeedTextBox.text{
            if let runnerSpeedInt = Int(runnerSpeedString){
                runnerStandardSpeed = CGFloat(runnerSpeedInt)
                runnerSpeedWasUpdated = true
            }
        }
       
        if let wallMoveDownDurationString = wallDownDurationTextBox.text{
            if let wallMoveDownDurationDouble = Double(wallMoveDownDurationString){
                wallMoveDownDuration = wallMoveDownDurationDouble
                wallMoveDownDurationWasUpdated = true
            }
        }
    
        if let gapDiffPerTenthSecString = gapDiffPerTenthSecTextBox.text{
            if let gapDiffPerTenthSecInt = Int(gapDiffPerTenthSecString){
                differenceInWallResizePerTenthSec = CGFloat(gapDiffPerTenthSecInt)
                differenceInWallResizePerTenthSecWasUpdated = true
            }
        }
        
        let alertController = UIAlertController(title: "Settings Updated", message: "A varible was successfully updated if it it marked as true: \nrunnerSpeed:\(runnerSpeedWasUpdated) \nwallMoveDownDuration:\(wallMoveDownDurationWasUpdated) \ndifferenceInWallResizePerTenthSec:\(differenceInWallResizePerTenthSecWasUpdated)", preferredStyle: .alert)
       
        let okButton = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okButton)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
