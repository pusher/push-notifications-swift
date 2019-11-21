//
//  TestHelper.swift
//  PushNotificationsTests
//
//  Created by Danielle Vass on 20/11/2019.
//  Copyright © 2019 Pusher. All rights reserved.
//

import Foundation

struct TestHelper {

    func removeSyncjobStore() {
        let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = url.appendingPathComponent("syncJobStore")
        try? FileManager.default.removeItem(atPath:  filePath.relativePath)
    }
    
}
