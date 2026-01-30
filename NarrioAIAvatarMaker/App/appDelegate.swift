//
//  appDelegate.swift
//  SynthesiaAI
//
//  Created by b on 27.01.2026.
//

import UIKit
import ApphudSDK
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        Apphud.start(apiKey: "app_RwCnjnHuN2rGcX3esHSw6kyaTwMiHV")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)

        return true
    }
}
