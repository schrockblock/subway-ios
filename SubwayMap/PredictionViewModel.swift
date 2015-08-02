//
//  PredictionViewModel.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 8/1/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import UIKit
import GTFSStations

class PredictionViewModel: NSObject, Equatable {
    var routeId: String!
    var direction: Direction!
    var prediction: Prediction!
    var onDeckPrediction: Prediction?
    var inTheHolePrediction: Prediction?
   
    init(routeId: String!, direction: Direction!) {
        self.routeId = routeId
        self.direction = direction
    }
    
    func setupWithPredictions(predictions: Array<Prediction>!){
        var relevantPredictions = predictions.filter({(prediction) -> Bool in
            return prediction.direction == self.direction && prediction.route!.objectId == self.routeId
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
}
func ==(predictionVM1: PredictionViewModel, predictionVM2: PredictionViewModel) -> Bool {
    return predictionVM1.routeId == predictionVM2.routeId && predictionVM1.direction == predictionVM2.direction
}