//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Yang Ji on 8/22/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}
