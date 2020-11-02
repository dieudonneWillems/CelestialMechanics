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
    
    /**
     * Calculates the rising, transit, and setting times for the celestial body at the specified location
     * and date.
     *
     * The values are returned in a tuple containing the forllowing keyword with associated values.
     * * `rising` The time of rising of the celestial body at the specified location and date.
     * * `transit` The time of transit of the celestial body at the specified location and date.
     * * `setting` The time of setting of the celestial body at the specified location and date.
     * * `antitransit` The time opposite to the transit time, i.e. when the celestial body is at its lowest
     * position. If the location is on the northern hemisphere, this will be the time when the celestial body is
     * due north, below the horizon, or above the horizon if the celestial body is circumpolar.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: The height below the horizon for which the rising and
     * setting times are calculated. Default is equal to the mean atmospheric refraction of 0°34".
     * - Returns: The  rising, transit, and setting times of the coordinates.
     */
    func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> (rising: Date?, transit: Date, setting: Date?, antiTransit: Date)
  
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
    
    /**
     * Calculates the rising, transit, and setting times for the celestial body at the specified location
     * and date.
     *
     * The values are returned in a tuple containing the forllowing keyword with associated values.
     * * `rising` The time of rising of the celestial body at the specified location and date.
     * * `transit` The time of transit of the celestial body at the specified location and date.
     * * `setting` The time of setting of the celestial body at the specified location and date.
     * * `antitransit` The time opposite to the transit time, i.e. when the celestial body is at its lowest
     * position. If the location is on the northern hemisphere, this will be the time when the celestial body is
     * due north, below the horizon, or above the horizon if the celestial body is circumpolar.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: The height below the horizon for which the rising and
     * setting times are calculated. Default is equal to the mean atmospheric refraction of 0°34".
     * - Returns: The  rising, transit, and setting times of the coordinates.
     */
    public func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h0: Double = SphericalCoordinates.meanAtmosphericRefraction) throws -> (rising: Date?, transit: Date, setting: Date?, antiTransit: Date) {
        let pos = try self.rectangularCoordinates(at: date, inCoordinateFrame: .ICRS)
        let h0 = standardAltitude(distance: pos.distance)
        let rts = try pos.sphericalCoordinates.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: h0)
        let rising = try self.iterateOnRising(rising: rts.rising, at: location, angleBelowTheHorizon: h0)
        let transit = try self.iterateOnTransit(transit: rts.transit, at: location, angleBelowTheHorizon: h0)
        let setting = try self.iterateOnSetting(setting: rts.setting, at: location, angleBelowTheHorizon: h0)
        let antiTransit = try self.iterateOnAntiTransit(antiTransit: rts.antiTransit, at: location, angleBelowTheHorizon: h0)
        return (rising: rising, transit: transit, setting: setting, antiTransit: antiTransit)
    }
    
    private func iterateOnRising(rising: Date?, at location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> Date? {
        if rising == nil {
            return nil
        }
        print("rising: \(rising!)")
        let rts = try self.sphericalCoordinates(at: rising!, inCoordinateFrame: .ICRS).risingTransitAndSetting(at: rising!, and: location, angleBelowTheHorizon: h0)
        if rts.rising == nil {
            return nil
        }
        let dt = fabs(rising!.timeIntervalSince(rts.rising!))
        print("dt = \(dt)")
        if dt > 1.0 {
            return try self.iterateOnRising(rising: rts.rising!, at: location, angleBelowTheHorizon: h0)
        }
        return rts.rising!
    }
    
    private func iterateOnTransit(transit: Date, at location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> Date {
        print("transit: \(transit)")
        let rts = try self.sphericalCoordinates(at: transit, inCoordinateFrame: .ICRS).risingTransitAndSetting(at: transit, and: location, angleBelowTheHorizon: h0)
        let dt = fabs(transit.timeIntervalSince(rts.transit))
        print("dt = \(dt)")
        if dt > 1.0 {
            return try self.iterateOnTransit(transit: rts.transit, at: location, angleBelowTheHorizon: h0)
        }
        return rts.transit
    }
    
    private func iterateOnSetting(setting: Date?, at location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> Date? {
        if setting == nil {
            return nil
        }
        print("setting: \(setting!)")
        let rts = try self.sphericalCoordinates(at: setting!, inCoordinateFrame: .ICRS).risingTransitAndSetting(at: setting!, and: location, angleBelowTheHorizon: h0)
        if rts.setting == nil {
            return nil
        }
        let dt = fabs(setting!.timeIntervalSince(rts.setting!))
        print("dt = \(dt)")
        if dt > 1.0 {
            return try self.iterateOnSetting(setting: rts.setting!, at: location, angleBelowTheHorizon: h0)
        }
        return rts.setting!
    }
    
    private func iterateOnAntiTransit(antiTransit: Date, at location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> Date {
        print("antiTransit: \(antiTransit)")
        let rts = try self.sphericalCoordinates(at: antiTransit, inCoordinateFrame: .ICRS).risingTransitAndSetting(at: antiTransit, and: location, angleBelowTheHorizon: h0)
        let dt = fabs(antiTransit.timeIntervalSince(rts.antiTransit))
        print("dt = \(dt)")
        if dt > 1.0 {
            return try self.iterateOnAntiTransit(antiTransit: rts.antiTransit, at: location, angleBelowTheHorizon: h0)
        }
        return rts.antiTransit
    }
    
    /**
     * The standard altitude, i.e. the angle that a body needs to be below the horizon when it starts to rise.
     * This value depends on atmospheric refraction and also on the apparent size of the body.
     *
     * - Parameter distance: The distance to the celestial object. This
     * parameter is only important when the size of the disk changes significantly, i.e. with the Moon.
     * - Returns: The standard altitude in radians. NB. This value will be positive.
     */
    func standardAltitude(distance: Double?) -> Double {
        return 0.5667/Double.rpi
    }
}

public class Sun: EphemeridesObject, Star {
    
    public static let sun = Sun(name: "Sun")
    
    /**
     * The standard altitude, i.e. the angle that a body needs to be below the horizon when it starts to rise.
     * This value depends on atmospheric refraction and also on the apparent size of the body. In the case
     * of the Sun, this value is equal to 0.8333°.
     *
     * - Parameter distance: The distance to the Sun. This
     * parameter will be ignored for the Sun.
     * - Returns: The standard altitude in radians. NB. This value will be positive.
     */
    public override func standardAltitude(distance: Double?) -> Double {
        return 0.8333/Double.rpi
    }
}

public class Moon: EphemeridesObject, Satellite {
    
    public static let moon = Moon(name: "Moon")
    
    /**
     * Calculates the equatorial horizontal parallax, i.e. the parallax of the moon as seen from two opposite
     * positions on the Earth's equator.
     *
     * - Parameter date: The date for which the parallax is to be calculated.
     * - Returns: The parallax of the moon.
     */
    public func equatorialHorizontalParallax(at date: Date) -> Double {
        let pos = try! self.rectangularCoordinates(at: date, inCoordinateFrame: .ICRS)
        let parallax = asin(6378140/pos.distance!)
        return parallax
    }
    
    /**
     * Calculates the equatorial horizontal parallax, i.e. the parallax of the moon as seen from two opposite
     * positions on the Earth's equator.
     *
     * - Parameter date: The date for which the parallax is to be calculated.
     * - Returns: The parallax of the moon.
     */
    private func equatorialHorizontalParallax(distance: Double?) -> Double {
        if distance == nil {
            return 0.0
        }
        let parallax = asin(6378140/distance!)
        return parallax
    }
    
    /**
     * The standard altitude, i.e. the angle that the Moon needs to be below the horizon when it starts to rise.
     * This value depends on atmospheric refraction and also on the apparent size of the Moon.
     *
     * - Parameter distance: The distance to the Moon.
     * - Returns: The standard altitude in radians. NB. This value will be positive.
     */
    public override func standardAltitude(distance: Double?) -> Double {
        let h0 = 0.7275*self.equatorialHorizontalParallax(distance: distance) - 0.5667
        return -h0/Double.rpi
    }
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
