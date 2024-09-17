//
//  FavoritesManager.swift
//  SubwayMap
//
//  Created by Cliff Spencer on 8/30/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import Foundation
import SubwayStations

public class FavoritesManager: NSObject {
    var favoriteIds: [String]!
    var stations: [Station]?
    
    fileprivate let defaultsKey = "favorite_stations"
    
    public override init() {
        self.favoriteIds = []

        if let names = UserDefaults.standard.stringArray(forKey: defaultsKey) {
            self.favoriteIds = names
        }
        
        super.init()
    }
    
    // add stations to favorites list
    func addFavorites(_ stations: [Station]) {
        for station in stations {
            if !favoriteIds.contains(station.name) {
                favoriteIds.append(station.name)
            }
        }
        sync()
    }
    
    // remove stations from favorites list
    func removeFavorites(_ stations: [Station]) {
        for station in stations {
            if favoriteIds.contains(station.name) {
                favoriteIds = favoriteIds.filter( { $0 != station.name } )
            }
        }
        sync()
    }
    
    // clear all favorites
    func clear() {
        favoriteIds.removeAll(keepingCapacity: true)
        sync()
    }
    
    // find favorites by substring
    func findFavorites(_ name: String?) -> [Station]? {
        if name != nil {
            return Current.stationManager.stationsForSearchString(name)!.filter({self.favoriteIds.contains($0.name)})
        } else {
            return Current.stationManager.allStations.filter({self.favoriteIds.contains($0.name)})
        }
    }
    
    // get all favorites
    func favoriteStations() -> [Station]? {
        return findFavorites(nil)
    }
    
    //check if current station exists in favorites
    func isFavorite(_ name: String?) -> Bool {
        let stations: [Station]? = findFavorites(name)
        var isInArray: Bool = false
        for station in stations! {
            if station.name == name {
                isInArray = true
            }
        }
        return isInArray
    }

    // flush out user defaults
    fileprivate func sync() {
        let defaults = UserDefaults.standard
        defaults.set(favoriteIds, forKey: defaultsKey)
        defaults.synchronize()
    }
}
