//
//  Log.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation
import SwiftyBeaver


let log = SwiftyBeaver.self

func initializeLogging() {
    print("Initializing logging")
    log.addDestination(ConsoleDestination())
    log.info("Logging initialized")
}

