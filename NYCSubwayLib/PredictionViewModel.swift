//
//  PredictionViewModel.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 8/1/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import UIKit
import SubwayStations

class PredictionViewModel: NSObject {
    var routeId: String!
    var direction: Direction!
    var prediction: Prediction!
    var onDeckPrediction: Prediction?
    var inTheHolePrediction: Prediction?
    var visits: [Visit]?
    var estimates: [Estimate]?
   
    init(routeId: String!, direction: Direction!) {
        self.routeId = routeId
        self.direction = direction
    }
    
    func setupWithPredictions(_ predictions: [Prediction]!){
        var relevantPredictions = predictions.filter({(prediction) -> Bool in
            return prediction.direction!.rawValue == self.direction!.rawValue && prediction.route!.objectId == self.routeId
        })
        
        relevantPredictions.sort { $0.secondsToArrival < $1.secondsToArrival }
        
        if relevantPredictions.count > 0 {
            prediction = relevantPredictions[0]
        }
        
        if relevantPredictions.count > 1 {
            onDeckPrediction = relevantPredictions[1]
        }
        
        if relevantPredictions.count > 2 {
            inTheHolePrediction = relevantPredictions[2]
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let predictionVM = object as? PredictionViewModel {
            return self.routeId == predictionVM.routeId && self.direction == predictionVM.direction
        }else{
            return false
        }
        
    }
}
