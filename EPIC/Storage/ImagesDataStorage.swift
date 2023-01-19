//
//  ImagesDataStorage.swift
//  EPIC
//
//  Created by Alexey Budynkov on 19.01.2023.
//

import Foundation
import UIKit

typealias DayImage = (info: DayImageInfo, image: UIImage)

class ImagesDataStorage {
    private static var shared = ImagesDataStorage()
    
    static func getInstance()->ImagesDataStorage{
        return shared
    }
    
    //day:[imageName:(info, image)])
    var imagesInfo:[String:[String:DayImage]] = [:]
}
