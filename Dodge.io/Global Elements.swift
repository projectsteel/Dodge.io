//
//  Global Variables.swift
//  Dodge.io
//
//  Created by Jamie Pickar on 12/28/18.
//  Copyright © 2018 Project Steel. All rights reserved.
//
//  All Global Elements are declaired here.

import Foundation
import UIKit

var runnerStandardSpeed : CGFloat = 1000
var wallMoveDownDuration : Double = 10
var secsToMoveGap : TimeInterval = 5
let gapDistance : CGFloat = 250
let minimumWallWidth : CGFloat = 10

public func restoreSpeed(){
    runnerStandardSpeed = 700
    wallMoveDownDuration = 10
    secsToMoveGap = 5
}
