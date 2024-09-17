//
//  NYCDirectionNameProvider.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/17/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

public enum ImageDirection: Int {
    case left, right, up, down
}

public protocol DirectionProvider {
    func directionName(for direction: Int, routeId: String) -> String
    func directionEnum(for direction: Int, routeId: String) -> ImageDirection
}

open class NYCDirectionNameProvider: DirectionProvider {
    public func directionName(for direction: Int, routeId: String) -> String {
        var directionName = direction == 0 ? "Uptown" : "Downtown"
        
        if routeId == "7" || routeId == "7X" {
            directionName = direction == 0 ? "Manhattan bound" : "Queens bound"
        }
        if routeId == "L" {
            directionName = direction == 0 ? "Manhattan bound" : "Brooklyn bound"
        }
        if routeId == "G" {
            directionName = direction == 0 ? "Queens bound" : "Brooklyn bound"
        }
        if routeId == "GS" {
            directionName = direction == 0 ? "Times Square Bound" : "Grand Central bound"
        }
        
        return directionName
    }
    
    public func directionEnum(for direction: Int, routeId: String) -> ImageDirection {
        var directionEnum = direction == 0 ? ImageDirection.up : ImageDirection.down
        
        if routeId == "7" || routeId == "7X" {
            directionEnum = direction == 0 ? .left : .right
        }
        if routeId == "L" {
            directionEnum = direction == 0 ? .left : .right
        }
    
        return directionEnum
    }
}

func image(for direction: ImageDirection) -> UIImage? {
    switch direction {
    case .left: return UIImage(named: "ic_arrow_back_black_24dp")
    case .right: return UIImage(named: "ic_arrow_forward_black_24dp")
    case .up: return UIImage(named: "ic_arrow_upward_black_24dp")
    case .down: return UIImage(named: "ic_arrow_downward_black_24dp")
    }
}
