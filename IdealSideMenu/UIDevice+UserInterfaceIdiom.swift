//
//  UIDevice.swift
//  IdealSideMenu
//
//  Created by 住田雅隆 on 2022/05/15.
//

import UIKit

extension UIDevice {
    
    static var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
