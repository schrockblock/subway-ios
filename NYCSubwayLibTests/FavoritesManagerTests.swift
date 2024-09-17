//
//  FavoritesManagerTest.swift
//  SubwayMap
//
//  Created by Cliff Spencer on 8/30/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import Quick
import Nimble
import SubwayStations
import GTFSStations
@testable import NYCSubwayLib

class FavoritesSpec: QuickSpec {
    var stationManager: StationManager!
    var favoritesManager: FavoritesManager!
    override func spec() {
        describe("Favorites", { () -> Void in
            
            beforeSuite({ () -> () in
                DatabaseLoader.loadDb()
                waitUntil(timeout: .seconds(10), action: { (done) -> Void in
                    Thread.sleep(forTimeInterval: 5)
                    self.stationManager = DatabaseLoader.stationManager
                    self.favoritesManager = FavoritesManager()
                    done()
                })
            })
            
            afterEach({ () -> () in
                self.favoritesManager.clear()
            })
            
            it("can clear all favorites") {
                let stationName = "Astor Pl"
                let stations: [Station]? = self.stationManager.stationsForSearchString(stationName)
                expect(stations).toNot(beNil())
                expect(stations!.count == 1).to(beTruthy())
                
                self.favoritesManager.addFavorites(stations!)
                let favorites: [Station]? = self.favoritesManager.findFavorites(nil)
                expect(favorites!.count).to(beTruthy())
                
                self.favoritesManager.clear()
                let emptyFavorites = self.favoritesManager.findFavorites(nil)
                expect(stations).toNot(beNil())
                expect(emptyFavorites!.isEmpty).to(beTruthy())
            }
            
            it("can add a favorite") {
                let allStations = self.stationManager.allStations
                let station = allStations.first
                self.favoritesManager.addFavorites([station!])
                
                let favorites: [Station]? = self.favoritesManager.findFavorites(nil)
                expect(favorites).toNot(beNil())
                expect(favorites!.count).to(beTruthy())
//                expect(favorites).to(contain(station))
            }
            
            it("can remove a favorite") {
                let stations = Array(self.stationManager.allStations[0...2])
                expect(stations.count == 3).to(beTrue())
                self.favoritesManager.addFavorites(stations)
                
                self.favoritesManager.removeFavorites([stations[1]])
                let favorites: [Station]? = self.favoritesManager.findFavorites(nil)
//                expect(favorites).toNot(contain(stations[1]))
            }
            
            it ("can find a favorite") {
                let stationName = "Astor Pl"
                let stations: [Station]? = self.stationManager.stationsForSearchString(stationName)
                expect(stations).toNot(beNil())
                expect(stations!.count == 1).to(beTruthy())
                
                self.favoritesManager.addFavorites(stations!)
                
                let favorites: [Station]? = self.favoritesManager.findFavorites(stationName)
                
                expect(favorites).toNot(beNil())
                if let favs = favorites {
                    expect(favs.count).to(equal(1))
                    if favs.count > 0 {
                        expect(favs[0].name == stationName).to(beTruthy())
                    }
                }
            }
            
            it ("can find multiple favorites") {
                self.favoritesManager.clear()
                let stationName = "Astor"
                let stations: [Station]? = self.stationManager.stationsForSearchString(stationName)
                expect(stations).toNot(beNil())
                expect(stations!.count == 3).to(beTruthy())
                
                self.favoritesManager.addFavorites(stations!)

                let favorites: [Station]? = self.favoritesManager.findFavorites(stationName)
                expect(favorites).toNot(beNil())
                if let favs = favorites {
                    expect(favs.count).to(equal(3))
                    if favs.count == 3 {
                        for stationName in ["Astor Pl", "Astoria Blvd", "Astoria - Ditmars Blvd"] {
                            let station = favs.filter( { $0.name == stationName } )
                            expect(station).toNot(beNil())
                            expect(station.count == 1).to(beTrue())
                            print("station: \(stationName)")
                            expect(station[0].name == stationName).to(beTruthy())
                            
                        }
                    }
                }
            }
            
            it ("can save and restore favorites") {
                self.favoritesManager.clear()
                let stationName = "Astor Pl"
                let stations: [Station]? = self.stationManager.stationsForSearchString(stationName)
                expect(stations).toNot(beNil())
                expect(stations!.count == 1).to(beTruthy())
                
                self.favoritesManager.addFavorites(stations!)
                
                let newFavoritesManager: FavoritesManager! = FavoritesManager()
                

                let favorites: [Station]? = newFavoritesManager.findFavorites(stationName)
                
                expect(favorites).toNot(beNil())
                expect(favorites!.count == 1).to(beTrue())
                expect(favorites![0].name == stationName).to(beTruthy())
            }
            
        })
    }
}

