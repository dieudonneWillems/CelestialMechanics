//
//  CelestialObject.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

public protocol CelestialObject {
    
    func sphericalCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame)
    func rectangularCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame)
    func visualMagnitude(at epoch: Date)
    
}

public protocol DeepSkyObject: CelestialObject {
    
}

public protocol PointSource: CelestialObject {
    
}

public protocol Star: DeepSkyObject, PointSource {
    
}

public protocol VariableStar: Star {
    
}

public protocol MultipleStar: Star {
    
}

public protocol ExtendedDeepSkyObject: DeepSkyObject {
    
}

public protocol SolarSystemObject: CelestialObject {
    
}

public protocol Planet: SolarSystemObject {
    
}

public protocol DwarfPlanet: Planet {
    
}

public protocol MinorPlants: SolarSystemObject {
    
}

public protocol Comet: SolarSystemObject {
    
}

public protocol Satellite: SolarSystemObject {
    
}
