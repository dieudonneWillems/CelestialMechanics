//
//  CelestialObject.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation


public enum CelestialObjectException : Error {
    case undefinedPropertyException
    case angleWithSelfException
    case unspecifiedDistanceException
}


public class CelestialObject : Equatable {
    
    public let identifiers: [String]
    
    public init(_ identifier: String) {
        self.identifiers = [identifier]
    }
    
    public init(identifiers: [String]) {
        self.identifiers = identifiers
    }
    
    public func sphericalCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> SphericalCoordinates {
        throw CelestialObjectException.undefinedPropertyException
    }
    
    public func rectangularCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> RectangularCoordinates {
        throw CelestialObjectException.undefinedPropertyException
    }
    
    public func visualMagnitude(at epoch: Date) throws -> Magnitude {
        throw CelestialObjectException.undefinedPropertyException
    }
    
    /**
     * The phase angle of the object, which is the angle Sun-object-Earth.
     *
     * - Parameter epoch: The epoch (date and time) for which the phase angle should be
     * calculated.
     * - Returns: The phase angle.
     */
    public func phaseAngle(at epoch: Date) throws -> Double {
        if self == Sun.sun || self == Planet.earth {
            throw CelestialObjectException.angleWithSelfException
        }
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let sunCoord = try Sun.sun.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let Δ = rectCoord.distance
        let R = sunCoord.distance
        if Δ == nil || R == nil {
            // Distance is unknown and therefore assumed to be very
            // large. The phase angle should therefore be 0.0.
            return 0.0
        }
        let r = sqrt(pow(rectCoord.x-sunCoord.x , 2) + pow(rectCoord.y-sunCoord.y , 2) + pow(rectCoord.z-sunCoord.z , 2))
        let i = acos((pow(r, 2) + pow(Δ!, 2) - pow(R!, 2)) / (2 * r * Δ!))
        return i
    }
    
    /**
     * Returns the distance of the celestial object to the Sun in meters.
     *
     * - Parameter epoch: The epoch (date and time) for which the distance should be
     * calculated.
     * - Returns: The distance to the Sun in meters.
     * - Throws `CelestialObjectException.unspecifiedDistanceException`: when
     * the distance to the Earth was not specified or is unknown (e.g. for distant stars).
     */
    func distanceToTheSun(at epoch: Date) throws -> Double {
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let sunCoord = try Sun.sun.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let Δ = rectCoord.distance
        let R = sunCoord.distance
        if Δ == nil || R == nil {
            throw CelestialObjectException.unspecifiedDistanceException
        }
        let r = sqrt(pow(rectCoord.x-sunCoord.x , 2) + pow(rectCoord.y-sunCoord.y , 2) + pow(rectCoord.z-sunCoord.z , 2))
        return r
    }
    
    /**
     * Calculates the rising, transit, and setting times for the celestial body at the specified location
     * and date.It reutrns an array of ´AstronomicalEvent`s.
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
     * - Returns: The  rising, transit, and setting events for the object.
     */
    func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> [AstronomicalEvent] {
        throw CelestialObjectException.undefinedPropertyException
    }
    
    public static func == (lhs: CelestialObject, rhs: CelestialObject) -> Bool {
        for id in lhs.identifiers {
            if rhs.identifiers.contains(id) {
                return true
            }
        }
        return false
    }
  
}
public protocol DeepSkyObject {
    
}

public protocol PointSource {
    
}

public protocol Star: DeepSkyObject, PointSource {
    
}

public protocol VariableStar: Star {
    
}

public protocol MultipleStar: Star {
    
}

public protocol ExtendedDeepSkyObject: DeepSkyObject {
    
}

public protocol SolarSystemObject {
    
    /**
     * Calculates the effect of light time (τ) for a specific epoch.
     *
     * This effect is due to the fact that the speed of light is finite, it is is time needed for light to travel
     * from the object to the observer. The position of the object as observed is the position of the object
     * at the current time subtracted by the effect of light time.
     *
     * - Parameter epoch: The epoch (date and time) for which the effect of light time should be
     * calculated.
     * - Returns: The effect of light time in seconds.
     * - Throws: `CelestialObjectException.unspecifiedDistanceException` when the
     * distance is unknown.
     */
    func effectOfLightTime(at epoch: Date) throws -> Double
}

public class EphemeridesObject: CelestialObject, SolarSystemObject {
    
    public let name: String
    private var ephemerides: InterpolationTimeSeries?
    
    init(name: String) {
        self.name = name
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
        super.init(name)
    }
    
    public override func sphericalCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> SphericalCoordinates {
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: frame)
        return rectCoord.sphericalCoordinates
    }
    
    public override func rectangularCoordinates(at epoch: Date, inCoordinateFrame frame: CoordinateFrame) throws -> RectangularCoordinates {
        if name == "Earth" {
            let rectValuesICRS = RectangularCoordinates(x: 0.0, y: 0.0, z: 0.00000000001, frame: .ICRS)
            return try rectValuesICRS.transform(to: frame, at: epoch)
        }
        let values = try ephemerides!.interpolatedValues(time: epoch)
        let rectValuesICRS = RectangularCoordinates(x: values[0], y: values[1], z: values[2], frame: .ICRS)
        return try rectValuesICRS.transform(to: frame, at: epoch)
    }
    
    /**
     * The illuminated fraction of the disk (in case of a spherical object) as seen from Earth.
     *
     * * A value of `0.0` denotes a disk that is not illuminated by the Sun. This happens when the object
     * is between the Earth and the Sun (in the case of the Moon, we call this *New Moon*).
     * * A value of `1.0` denotes a fully illuminated disk. This happens when the Earth is between the
     * object and the Sun (in the case of the Moon this is *Full Moon*) or when the Sun is between the
     * object and the Earth.
     *
     * - Parameter epoch: The epoch (date and time) for which the illuminated fraction should be
     * calculated.
     * - Returns: The illuminated fraction of the object's disk.
     */
    public func illuminatedFraction(at epoch: Date) throws -> Double {
        let i = try self.phaseAngle(at: epoch)
        let k = (1 + cos(i)) / 2
        return k
    }
    
    /**
     * Calculates the effect of light time (τ) for a specific epoch.
     *
     * This effect is due to the fact that the speed of light is finite, it is is time needed for light to travel
     * from the object to the observer. The position of the object as observed is the position of the object
     * at the current time subtracted by the effect of light time.
     *
     * - Parameter epoch: The epoch (date and time) for which the effect of light time should be
     * calculated.
     * - Returns: The effect of light time in seconds.
     * - Throws: `CelestialObjectException.unspecifiedDistanceException` when the
     * distance is unknown.
     */
    public func effectOfLightTime(at epoch: Date) throws -> Double {
        let distance = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS).distance
        if distance ==  nil {
            throw CelestialObjectException.unspecifiedDistanceException
        }
        let τ = 0.0057755183 * distance! / Units.AU
        return τ
    }
    
    /**
     * Calculates the rising, transit, and setting times for the celestial body at the specified location
     * and date.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: The height below the horizon for which the rising and
     * setting times are calculated. Default is equal to the mean atmospheric refraction of 0°34".
     * - Returns: The  rising, transit, and setting times of the celestial object in a list of `AstronomicalEvent`s..
     */
    public override func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h: Double = 0.0) throws -> [AstronomicalEvent] {
        let pos = try self.rectangularCoordinates(at: date, inCoordinateFrame: .ICRS)
        var h0 = h
        if h <= 0.0 {
            h0 = standardAltitude(distance: pos.distance)
        }
        let events = try pos.sphericalCoordinates.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: h0)
        var recalculatedEvents = [AstronomicalEvent]()
        for event in events {
            let recalculatedEvent = try iterateOn(event: event, at: date, and: location, angleBelowTheHorizon: h0)
            recalculatedEvents.append(recalculatedEvent)
        }
        recalculatedEvents = AstronomicalEvent.removeDuplicates(events: recalculatedEvents)
        return recalculatedEvents
    }
    
    private func iterateOn(event: AstronomicalEvent, at date: Date, and location: GeographicLocation, angleBelowTheHorizon h0: Double) throws -> AstronomicalEvent {
        var recEvents = [AstronomicalEvent]()
        let recEventsPrelim = try self.rectangularCoordinates(at: event.date, inCoordinateFrame: .ICRS).sphericalCoordinates.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: h0)
        for prelimEvent in recEventsPrelim { // Add the object to the event (otherwise only associated with coordinates).
            let recEvent = AstronomicalEvent(type: prelimEvent.type, date: prelimEvent.date, objects: [self], coordinates: prelimEvent.coordinates, validForOrigin: prelimEvent.validForOrigin)
            recEvents.append(recEvent)
        }
        let typeEvents = AstronomicalEvent.filter(events: recEvents, include: [event.type])
        var recalculatedEvent : AstronomicalEvent? = nil
        var minDT = 86400.00
        for typeEvent in typeEvents {
            let dt = fabs(event.date.timeIntervalSince(typeEvent.date))
            if dt < minDT {
                minDT = dt
                recalculatedEvent = typeEvent
            }
        }
        if minDT > 1.0 {
            recalculatedEvent = try iterateOn(event: recalculatedEvent!, at: date, and: location, angleBelowTheHorizon: h0)
        }
        return recalculatedEvent!
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
     * Calculates the rising, transit, and setting times for the Sun at the specified location
     * and date.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: The height below the horizon for which the rising and
     * setting times are calculated. Default is equal to the mean atmospheric refraction of 0°34".
     * - Returns: The  rising, transit, and setting events of the Sun.
     */
    public override func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h: Double = 0.0) throws -> [AstronomicalEvent] {
        var events = [AstronomicalEvent]()
        let rtsEvents = try super.risingTransitAndSetting(at: date, and: location)
        events.append(contentsOf: rtsEvents)
        var civilEvents = try super.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: AstronomicalEvent.civilTwilightTresshold)
        civilEvents = AstronomicalEvent.filter(events: civilEvents, include: [.rising, .setting])
        var correctedCivilEvents = [AstronomicalEvent]()
        for event in civilEvents {
            var type = AstronomicalEvent.AstronomicalEventType.civilDawn
            if event.type == .setting {
                type = .civilDusk
            }
            correctedCivilEvents.append(AstronomicalEvent(type: type, date: event.date, objects: event.objects, coordinates: event.coordinates, validForOrigin: event.validForOrigin))
        }
        events.append(contentsOf: correctedCivilEvents)
        var nauticalEvents = try super.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: AstronomicalEvent.nauticalTwilightTresshold)
        nauticalEvents = AstronomicalEvent.filter(events: nauticalEvents, include: [.rising, .setting])
        var correctedNauticalEvents = [AstronomicalEvent]()
        for event in nauticalEvents {
            var type = AstronomicalEvent.AstronomicalEventType.nauticalDawn
            if event.type == .setting {
                type = .nauticalDusk
            }
            correctedNauticalEvents.append(AstronomicalEvent(type: type, date: event.date, objects: event.objects, coordinates: event.coordinates, validForOrigin: event.validForOrigin))
        }
        events.append(contentsOf: correctedNauticalEvents)
        var astronomicalEvents = try super.risingTransitAndSetting(at: date, and: location, angleBelowTheHorizon: AstronomicalEvent.astronomicalTwilightTresshold)
        astronomicalEvents = AstronomicalEvent.filter(events: astronomicalEvents, include: [.rising, .setting])
        var correctedAstronomicalEvents = [AstronomicalEvent]()
        for event in astronomicalEvents {
            var type = AstronomicalEvent.AstronomicalEventType.astronomicalDawn
            if event.type == .setting {
                type = .astronomicalDusk
            }
            correctedAstronomicalEvents.append(AstronomicalEvent(type: type, date: event.date, objects: event.objects, coordinates: event.coordinates, validForOrigin: event.validForOrigin))
        }
        events.append(contentsOf: correctedAstronomicalEvents)
        events = AstronomicalEvent.removeDuplicates(events: events)
        return events
    }
    
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
     * Calculates the rising, transit, and setting times for the Moon at the specified location
     * and date.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: This parameter is ignored as the value is automatically calculated.
     * - Returns: The  rising, transit, and setting times of the Moon in a list of `AstronomicalEvent`s..
     */
    public override func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h: Double = 0.0) throws -> [AstronomicalEvent] {
        var events = try super.risingTransitAndSetting(at: date, and: location)
        events = AstronomicalEvent.filter(events: events, exclude: [.lowerCulmination])
        return events
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
    public static let saturn = Saturn(name: "Saturn")
    public static let uranus = Planet(name: "Uranus")
    public static let neptune = Planet(name: "Neptune")
    
    public override func visualMagnitude(at epoch: Date) throws -> Magnitude {
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let sunCoord = try Sun.sun.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        var Δ = rectCoord.distance
        if Δ == nil {
            throw CelestialObjectException.unspecifiedDistanceException
        }
        var r = sqrt(pow(rectCoord.x-sunCoord.x , 2) + pow(rectCoord.y-sunCoord.y , 2) + pow(rectCoord.z-sunCoord.z , 2))
        var i = try self.phaseAngle(at: epoch)
        Δ = Δ! / Units.AU // Distance should be expressed in AU for these formulae.
        r = r / Units.AU
        i = i / Units.degree  // The phase angle should be expressed in degrees
        if self.name == "Mercury" {
            let mv = -0.42 + 5 * log10(r*Δ!) + 0.0380*i - 0.000273*pow(i, 2) + 0.000002*pow(i, 3)
            return Magnitude(value: mv)
        }
        if self.name == "Venus" {
            let mv = -4.40 + 5 * log10(r*Δ!) + 0.0009*i + 0.000239*pow(i, 2) - 0.00000065*pow(i, 3)
            return Magnitude(value: mv)
        }
        if self.name == "Mars" {
            let mv = -1.52 + 5 * log10(r*Δ!) + 0.016*i
            return Magnitude(value: mv)
        }
        if self.name == "Jupiter" {
            let mv = -9.40 + 5 * log10(r*Δ!) + 0.005*i
            return Magnitude(value: mv)
        }
        // Saturn handled by `Saturn` instance.
        if self.name == "Uranus" {
            let mv = -7.19 + 5 * log10(r*Δ!)
            return Magnitude(value: mv)
        }
        if self.name == "Neptune" {
            let mv = -6.87 + 5 * log10(r*Δ!)
            return Magnitude(value: mv)
        }
        if self.name == "Pluto" {
            let mv = -1.00 + 5 * log10(r*Δ!)
            return Magnitude(value: mv)
        }
        throw CelestialObjectException.undefinedPropertyException
    }
    
    fileprivate override init(name: String) {
        super.init(name: name)
    }
    
    /**
     * Calculates the rising, transit, and setting times for the planet at the specified location
     * and date.
     *
     * - Parameter date: The date for which the rising, transit, and setting times are to be
     * calculated.
     * - Parameter location: The geographical location for which the rising, transit, and setting times
     * are to be calculated.
     * - Parameter h0: This parameter is ignored as the value is automatically calculated.
     * - Returns: The  rising, transit, and setting times of the planet in a list of `AstronomicalEvent`s..
     */
    public override func risingTransitAndSetting(at date: Date, and location: GeographicLocation, angleBelowTheHorizon h: Double = 0.0) throws -> [AstronomicalEvent] {
        var events = try super.risingTransitAndSetting(at: date, and: location)
        events = AstronomicalEvent.filter(events: events, exclude: [.lowerCulmination])
        return events
    }
}

/**
 * An instance of this class represents the planet Saturn. Apart from generic parameters such as the position
 * and magnitude, this class also inculdes functions to calculate the positions of the
 * rings of Saturn.
 */
public class Saturn: Planet {
    
    /**
     * This structure represents data about Saturn's ring system.
     */
    public struct SaturnsRing {
        
        /**
         * The inclination of the plane of the rings of Saturn in radians referred to the mean ecliptic and
         * equinox of a specific epoch.
         *
         * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
         */
        public let i: Double
        
        /**
         * The geocentric position angle of the northern semiminor axis of the apparent ellipse of Saturn's
         * ring , measured from North towards the east. The value is given in radians.
         *
         * This is also the position angle of the north pole of Saturn as the Ring is in the equatorial plane
         * of Saturn.
         *
         * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
         */
        public let P: Double
        
        /**
         * The major axis of the outer edge of the outer ring in radians.
         *
         * This axis defines, together with the minor axis, the elliptic projection of Saturn's ring to an
         * observer on Earth.
         */
        public let a: Double
        
        /**
         * The minor axis of the outer edge of the outer ring in radians.
         *
         * This axis defines, together with the major axis, the elliptic projection of Saturn's ring to an
         * observer on Earth.
         */
        public let b: Double
        
        /**
         * The Saturnicentric latitude in radians of the Earth reffered to the plane of Saturn's ring system.
         * This angle is positive to the north.
         *
         * When this value is positive, the visible surface of the ring is the northern surface.
         *
         * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
         */
        public let B: Double
        
        /**
         * The Saturnicentric latitude in radians of the Sun reffered to the plane of Saturn's ring system.
         * This angle is positive to the north.
         *
         * When this value is positive, the illuminated surface of the ring is the northern surface.
         *
         * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
         */
        public let B´: Double
        
        /**
         * The difference between the Saturnicentric longitudes or the Sun and the Earth.
         *
         * This value is needed to calculate the magnitude of Saturn.
         *
         * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
         */
        public let ΔU: Double
    }
    
    public override func visualMagnitude(at epoch: Date) throws -> Magnitude {
        let rectCoord = try self.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        let sunCoord = try Sun.sun.rectangularCoordinates(at: epoch, inCoordinateFrame: .ICRS)
        var Δ = rectCoord.distance
        if Δ == nil {
            throw CelestialObjectException.unspecifiedDistanceException
        }
        var r = sqrt(pow(rectCoord.x-sunCoord.x , 2) + pow(rectCoord.y-sunCoord.y , 2) + pow(rectCoord.z-sunCoord.z , 2))
        Δ = Δ! / Units.AU // Distance should be expressed in AU for these formulae.
        r = r / Units.AU
        let ring = try self.propertiesOfTheRing(at: epoch)
        let ΔU = ring.ΔU / Units.degree
        let mv = -8.88 + 5 * log10(r*Δ!) + 0.044*fabs(ΔU) - 2.6*sin(fabs(ring.B)) + 1.25*pow(sin(ring.B), 2)
        return Magnitude(value: mv)
    }
    
    /**
     * Calculates the inclination of Saturn's equator in radians,  referred to the mean ecliptic and equinox
     * of the specified epoch.
     *
     * This value is equal to the inclination of Saturn's ring system, which is one of the properties calculated
     * in ``.
     *
     * - Parameter epoch: The date for which the inclination should be calculated.
     * - Returns: The inclination of Saturn's equator.
     */
    public func equatorialInclination(at epoch: Date) -> Double {
        let T = epoch.julianCentury
        let i = 28.075216 - 0.012998*T + 0.000004*pow(T, 2)
        return i * Units.degree
    }
    
    /**
     * Calculates the longitude of the ascending node of Saturn  referred to the mean ecliptic and equinox
     * of the specified epoch.
     *
     * - Parameter epoch: The date for which the longitude should be calculated.
     * - Returns: The longitude of the ascending node.
     */
    public func longitudeOfTheAscendingNode(at epoch: Date) -> Double {
        let T = epoch.julianCentury
        let Ω = 169.508470 + 1.394681*T + 0.000412*pow(T, 2)
        return Ω * Units.degree
    }
    
    /**
     * Calculates the properties that define Saturn's ring system as viewed by an observer from Earth.
     *
     * The algorithm is based on Chapter 45 of Jean Meeus' book on Astronomical Algorithms.
     *
     * Reference: Meeus, Jean, 1998, *Astronomical Algorithms*, Willmann-Bell Inc., second edition.
     *
     * - Parameter epoch: The date for which the longitude should be calculated.
     * - Returns: The properties of Saturn's ring system.
     */
    public func propertiesOfTheRing(at epoch: Date) throws -> SaturnsRing {
        // 1
        let Ω = longitudeOfTheAscendingNode(at: epoch)
        let i = equatorialInclination(at: epoch)
        
        // 2
        let heliocentric = CoordinateFrame.trueEcliptical(origin: .heliocentric, on: epoch)
        let earthHeliocentricCoord = try Planet.earth.sphericalCoordinates(at: epoch, inCoordinateFrame: heliocentric)
        let saturnHeliocentricCoord = try self.sphericalCoordinates(at: epoch, inCoordinateFrame: heliocentric)
        
        // 3
        var τ = try self.effectOfLightTime(at: epoch) * Date.lengthOfDay
        var prevτ = 10000.0
        let maxτ = 1.0
        var newEpoch = epoch
        while fabs(prevτ-τ) > maxτ {
            newEpoch = Date(timeInterval: -τ, since: epoch)
            τ = try self.effectOfLightTime(at: newEpoch) * Date.lengthOfDay
            prevτ = τ
        }
        
        // 4 & 5
        let geocentric = CoordinateFrame.meanEcliptical(origin: .geocentric, on: newEpoch)
        let saturnCoord = try self.sphericalCoordinates(at: newEpoch, inCoordinateFrame: geocentric)
        
        // 6
        let B = asin(sin(i)*cos(saturnCoord.latitude)*sin(saturnCoord.longitude-Ω) - cos(i)*sin(saturnCoord.latitude))
        let a = 375.35/3600*Units.degree / (saturnCoord.distance!/Units.AU)
        let b = a * sin(fabs(B))
        
        // 7
        let T = newEpoch.julianCentury
        let N = (113.6655 + 0.8771*T) * Units.degree // longitude of the ascending node of Saturn's orbit.
        let lonPrime = saturnHeliocentricCoord.longitude - 0.01759*Units.degree / (saturnHeliocentricCoord.distance!/Units.AU)
        let latPrime = saturnHeliocentricCoord.latitude - 0.000764*Units.degree*cos(saturnHeliocentricCoord.longitude-N)/saturnHeliocentricCoord.distance!
        
        // 8
        let Bprime = asin(sin(i)*cos(latPrime)*sin(lonPrime-Ω)-cos(i)*sin(latPrime))
        
        // 9
        let U1 = atan((sin(i)*sin(latPrime) + cos(i)*cos(latPrime)*sin(lonPrime-Ω)) / (cos(latPrime)*cos(lonPrime-Ω)))
        let U2 = atan((sin(i)*sin(saturnCoord.latitude) + cos(i)*cos(saturnCoord.latitude)*sin(saturnCoord.longitude-Ω)) / (cos(saturnCoord.latitude)*cos(saturnCoord.longitude-Ω)))
        let ΔU = fabs(U1-U2)
        
        // 10
        // TODO: Nutation
        
        // 11 Ecliptical longitude and latitude of the northern pole of the ring plane
        let λ0 = Ω - 0.5*Double.pi
        let β0 = 0.5*Double.pi - i
        
        // 12 Aberration of Saturn
        let λ = saturnCoord.longitude + 0.005693*Units.degree * cos(earthHeliocentricCoord.longitude-saturnCoord.longitude) / cos(saturnCoord.latitude)
        let β = saturnCoord.latitude + 0.005693*Units.degree * sin(earthHeliocentricCoord.longitude-saturnCoord.longitude) * sin(saturnCoord.latitude)
        
        // 13 Add nutation
        // TODO: Add nutation to the longitude of the north pole λ0 and to the longitude of Saturn λ
        
        // 14 Transform to equatorial coordinates
        let trueEcliptic = CoordinateFrame.trueEcliptical(on: epoch)
        let northPole = SphericalCoordinates(longitude: λ0, latitude: β0, distance: saturnCoord.distance, frame: trueEcliptic)
        let centre = SphericalCoordinates(longitude: λ, latitude: β, distance: saturnCoord.distance, frame: trueEcliptic)
        let eqNorthPole = try northPole.transform(to: .ICRS, at: epoch)
        let eqCentre = try centre.transform(to: .ICRS, at: epoch)
        
        // 15 Position angle
        let P = tan((cos(eqNorthPole.latitude)*sin(eqNorthPole.longitude-eqCentre.longitude)) / (sin(eqNorthPole.latitude)*cos(eqCentre.latitude) - cos(eqNorthPole.latitude)*sin(eqCentre.latitude)*cos(eqNorthPole.longitude-eqCentre.longitude)))
        
        let props = SaturnsRing(i: i, P: P, a: a, b: b, B: B, B´: Bprime, ΔU: ΔU)
        return props
    }
}

public protocol DwarfPlanet: Planet {
    
}

public protocol MinorPlanet: SolarSystemObject {
    
}

public protocol Comet: SolarSystemObject {
    
}

public protocol Satellite: SolarSystemObject {
    
}
