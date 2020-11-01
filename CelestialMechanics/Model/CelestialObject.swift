//
//  CelestialObject.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

public protocol CelestialObject {
    
    var identifiers: [String] { get }
    
    func sphericalCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> SphericalCoordinates
    func rectangularCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> RectangularCoordinates
    func visualMagnitude(at epoch: Date) throws -> Magnitude
    
    func rising(at epoch: Date, for location: GeographicLocation) throws -> Date?
    func transit(at epoch: Date, for location: GeographicLocation) throws -> Date?
    func setting(at epoch: Date, for location: GeographicLocation) throws -> Date?
    
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

public class EphemeridesObject: SolarSystemObject {
    
    public var identifiers: [String]
    
    public let name: String
    private var ephemerides: InterpolationTimeSeries?
    
    init(name: String) {
        self.name = name
        self.identifiers = [String]()
        self.identifiers.append(name)
        if name == "Sun" {
           self.ephemerides = Ephemerides.EPHEM_SUN
        } else if name == "Mercury" {
            self.ephemerides = Ephemerides.EPHEM_MERCURY
        } else if name == "Venus" {
            self.ephemerides = Ephemerides.EPHEM_VENUS
        } else if name == "Mars" {
            self.ephemerides = Ephemerides.EPHEM_MARS
        } else if name == "Jupiter" {
            self.ephemerides = Ephemerides.EPHEM_JUPITER
        } else if name == "Saturn" {
            self.ephemerides = Ephemerides.EPHEM_SATURN
        } else if name == "Uranus" {
            self.ephemerides = Ephemerides.EPHEM_URANUS
        } else if name == "Neptune" {
            self.ephemerides = Ephemerides.EPHEM_NEPTUNE
        } else if name == "Pluto" {
            self.ephemerides = Ephemerides.EPHEM_PLUTO
        } else if name == "Moon" {
            self.ephemerides = Ephemerides.EPHEM_MOON
        }
    }
    
    public func sphericalCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> SphericalCoordinates {
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: frame)
        return rectCoord.sphericalCoordinates
    }
    
    public func rectangularCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> RectangularCoordinates {
        if name == "Earth" {
            let rectValuesICRS = RectangularCoordinates(x: 0.0, y: 0.0, z: 0.00000000001, frame: .ICRS)
            return try rectValuesICRS.transform(to: frame)
        }
        let values = try ephemerides!.interpolatedValues(time: epoch)
        let rectValuesICRS = RectangularCoordinates(x: values[0], y: values[1], z: values[2], frame: .ICRS)
        return try rectValuesICRS.transform(to: frame)
    }
    
    public func visualMagnitude(at epoch: Date) -> Magnitude {
        return Magnitude(value: 1.0)
    }
    
    public func rising(at epoch: Date, for location: GeographicLocation) -> Date? {
        return nil
    }
    
    public func transit(at epoch: Date, for location: GeographicLocation) -> Date? {
        return nil
    }
    
    public func setting(at epoch: Date, for location: GeographicLocation) -> Date? {
        return nil
    }
    
}

public class Sun: EphemeridesObject, Star {
    
    public static let sun = Sun(name: "Sun")
}

public class Moon: EphemeridesObject, Satellite {
    
    public static let moon = Moon(name: "Moon")
}

public class Planet: EphemeridesObject {
    
    public static let mercury = Planet(name: "Mercury")
    public static let venus = Planet(name: "Venus")
    public static let earth = Planet(name: "Earth")
    public static let mars = Planet(name: "Mars")
    public static let jupiter = Planet(name: "Jupiter")
    public static let saturn = Planet(name: "Saturn")
    public static let uranus = Planet(name: "Uranus")
    public static let neptune = Planet(name: "Neptune")
}

public protocol DwarfPlanet: Planet {
    
}

public protocol MinorPlants: SolarSystemObject {
    
}

public protocol Comet: SolarSystemObject {
    
}

public protocol Satellite: SolarSystemObject {
    
}
