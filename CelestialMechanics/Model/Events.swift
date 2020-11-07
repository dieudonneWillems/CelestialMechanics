//
//  Events.swift
//  CelestialMechanics
//
//  Created by Don Willems on 07/11/2020.
//

import Foundation


public struct AstronomicalEvent : CustomStringConvertible, Equatable {
    
    public static let civilTwilightTresshold = 6.0/Double.rpi
    public static let nauticalTwilightTresshold = 12.0/Double.rpi
    public static let astronomicalTwilightTresshold = 18.0/Double.rpi
    
    public enum AstronomicalEventType : String{
        case rising
        case upperCulmination = "upper culmination"
        case setting
        case lowerCulmination = "lower culmination"
        case astronomicalDawn = "astronomical dawn"
        case nauticalDawn = "nautical dawn"
        case civilDawn = "civil dawn"
        case civilDusk = "civil dusk"
        case nauticalDusk = "nautical dusk"
        case astronomicalDusk = "astronomical dusk"
        case superiorConjunction = "superior conjunction"
        case inferiorConjunction = "inferior conjunction"
        case conjunction
        case tripleConjunction = "triple conjunction"
        case quasiConjunction = "quasi conjunction"
        case eclipse
        case occulation
        case transit
        case timeOfGreatestElongation = "time of greatest elongation"
        
        /**
         * When two celestial objects are at their closest apparent approach (minimal angular separation).
         */
        case appulse
    }
    
    public let type: AstronomicalEventType
    public let date: Date
    public let objects: [CelestialObject]?
    public let coordinates: SphericalCoordinates
    public let validForOrigin: CoordinateFrameOrigin
    
    public static func filter(events: [AstronomicalEvent], type: [AstronomicalEventType]) -> [AstronomicalEvent] {
        var newList = [AstronomicalEvent]()
        for event in events {
            if type.contains(event.type) {
                newList.append(event)
            }
        }
        return newList
    }
    
    public static func filter(events: [AstronomicalEvent], objects: [CelestialObject]) -> [AstronomicalEvent] {
        var newList = [AstronomicalEvent]()
        for event in events {
            if event.objects != nil {
                for object in event.objects! {
                    if objects.contains(object) {
                        newList.append(event)
                    }
                }
            }
        }
        return newList
    }
    
    public static func removeDuplicates(events: [AstronomicalEvent]) -> [AstronomicalEvent] {
        var withoutDuplicates = [AstronomicalEvent]()
        for event in events {
            if !withoutDuplicates.contains(event) {
                withoutDuplicates.append(event)
            }
        }
        return withoutDuplicates
    }
    
    public var description: String {
        get {
            var identifiers = ""
            if objects != nil {
                for object in objects! {
                    if object.identifiers.count > 0 {
                        if identifiers.count > 0 {
                            identifiers = identifiers + ", "
                        }
                        identifiers = identifiers + object.identifiers[0]
                    }
                }
            } else {
                identifiers = "[\(coordinates)]"
            }
            return "\(identifiers)\t\(type.rawValue)\t\(date)"
        }
    }
    
    public static func == (lhs: AstronomicalEvent, rhs: AstronomicalEvent) -> Bool {
        if lhs.type != rhs.type {
            return false
        }
        if lhs.objects == nil && rhs.objects != nil || lhs.objects != nil && rhs.objects == nil {
            return false
        }
        if lhs.objects != nil && rhs.objects != nil {
            if lhs.objects!.count != rhs.objects!.count {
                return false
            }
            for object in lhs.objects! {
                if !rhs.objects!.contains(object) {
                    return false
                }
            }
        }
        let dt = fabs(lhs.date.timeIntervalSince(rhs.date))
        if dt > 2.0 {
            return false
        }
        if lhs.validForOrigin != rhs.validForOrigin {
            return false
        }
        return true
    }
    
}
