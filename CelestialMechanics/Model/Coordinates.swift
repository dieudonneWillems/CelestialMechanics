//
//  Coordinates.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

/**
 * This structure represents a location of the Earth. It contains a latitude, longitude and elevation.
 */
public struct GeographicLocation : Hashable, Equatable {
    
    /**
     * The latitude of the geographical location.
     * North is positive and south negative. The latitude is given in radians.
     */
    public let latitude: Double
    
    /**
     * The longitude of the geographical location for which the predictions are
     * valid. West is negative and east positive. The latitude is given in
     * radians.
     */
    public let longitude: Double
    
    /**
     * The elevation above sea level in meters. This property is optional.
     */
    public let elevation: Double?
    
    
    /**
     * Creates a new ´GeographicalLocation´ with the specified latitude and longitude.
     *
     * - Parameter latitude: The latitude of the geographical location.North is positive and south
     * negative. The latitude is given in radians.
     * - Parameter longitude: The longitude of the geographical location. West is positive and east
     * negative. The latitude is given in radians.
     * - Parameter elevation: The elevation above sea level in meters. This value is optional.
     */
    public init(latitude: Double, longitude: Double, elevation: Double?=nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
    
    /**
     * Tests whether two geographical locations are equal (i..e. specify the same position on the globe).
     * Both geographical longitude, latitude and elevation of the sight should be the same.
     *
     * - Parameter lhs: The left hand side geographical location in the comparisson.
     * - Parameter rhs: The right hand side geographical location in the comparisson.
     * - Returns: `true` when the locations are equal.
     */
    public static func == (lhs: GeographicLocation, rhs: GeographicLocation) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.elevation == rhs.elevation)
    }
}

/**
 * Am enumeration of the different types of coordinate frames that can be used.
 *
 *`ICRF` is the default coordinate frame type as it is calibrated to extragalactic sources and should, therefore,
 * be the most consistent.
 *
 *`ICRS`, `FK4` and `FK5` are all equatorial systems where the zero point is defined
 * to be the vernal equinox of the Sun and the north pole is aligned with the Earth's rotation axis. Due to
 * precession, these positions will slowly change, therefore, the `Fk4` and `FK5` frames are always
 * given for a specific equinox (date). The most commonly used frame is the `FK5` frame for the
 * equinox of J2000.0 (i.e first of January 2000 at 12pm).
 *
 * `meanEcliptical` and `trueEcliptical` are both ecliptical coordinate systems where the zero
 * point is also defined to be the vernal equinox of the Sun, but the principal plane is defined to be the
 * trajectory of the Sun during the year, which is known as the ecliptic. The difference between the
 * `meanEcliptical` and the `trueEcliptical` frame is that the mean ecliptical frame only takes the
 * precession into account, while the true ecliptical frame also takes smaller variations, like those due to
 * nutation, into account. The mean ecliptical frame can be defined for a standard epoch like J2000.0, so that
 * the positions can be more easily compared to each other. Both the mean and true ecliptical frames can
 * be defined to the ecliptic of date, meaning the the intersection between the equator and ecliptic (the
 * vernal equinox) of a specific date is used as reference.
 *
 * The `galactic` frame is used for specifying locations with respect to the Milky Way. The zero point is
 * defined to be a position pointing to the centre of the Milky Way as seen from Earth. The principal plane is
 * the plane of the Milky Way as seen from Earth.
 *
 * A `horizonal` coordinate frame is theframe specific for a specific geographic location on Earth and
 * specific to a specific date and time. It gives the observer the coordinates in the sky for his location.
 */
public enum CoordinateFrameType {
    
    /**
     * The ICRF frame that is defined to the positions of extragalactic (quasar) sources. It superseded the
     * FK4 and FK5 systems that were based on versions of the catalogue of fundamental stars.
     */
    case ICRF
    
    /**
     * The FK4 equatorial frame. An equatorial coordinate system that is  based on the fourth  catalogue
     * of fundamental stars created in 1963. It was superseded by the FK5 system and later by the
     * ICRF frame.
     */
    case FK4
    
    /**
     * The FK5 equatorial frame. An equatorial coordinate system that is  based on the fifth  catalogue
     * of fundamental stars created in 1988. It was superseded by the ICRF frame.
     */
    case FK5
    
    /**
     * The ecliptial coordinate frame base on the mean equator of either a standard epoch or of a specific
     * date. The mean equator takes into account the changes due to precession but not to the smaller
     * changes such as those due to nutation.
     */
    case meanEcliptical
    
    /**
     * The ecliptial coordinate frame base on the true equator of a specific date. The mean equator takes
     * into account the changes due to precession but not to the smaller
     * changes such as those due to nutation.
     */
    case trueEcliptical
    
    /**
     * The galactic coordinate frame, based on the plane of the Milky Way projected onto the celestial
     * sphere. The zero point (i.e. zero longitude and zero latitude) is in the direction of the centre of
     * the Milky Way.
     */
    case galactic
    
    /**
     * The horizontal coordinate frame is specific to an observer at a specific location on the Earth and
     * at a specific time. Coordinate in this frame are used to specify the location of an object in the
     * sky as visible at a specific time for an observer.
     */
    case horizontal
}


/**
 * Represents the origin of the coordinate frane. Common origins are the geocentric origin, where the
 * centre of the Earth is taken as the origin, and topocentric, where the position of an observer on the
 * Earth is used as the origin.
 */
public enum CoordinateFrameOrigin : Equatable {
    
    /**
     * The centre of the Earth as origin of the coordinate frame.
     */
    case geocentric
    
    /**
     * The centre of the Sun as origin of the coordinate frame.
     */
    case heliocentric
    
    /**
     * A location at a specific location on Earth at a specific time as origin of the coordinate frame.
     *
     * - Parameter location: The geographic location.
     */
    case topocentric(location: GeographicLocation)
    
    /**
     * Tests whether two origins are the same. They can only be the same when they are in the same
     * location in space.
     *
     *- Parameter lhs: The left hand side of the equality equation.
     *- Parameter lhs: The right hand side of the equality equation.
     */
    public static func == (lhs: CoordinateFrameOrigin, rhs: CoordinateFrameOrigin) -> Bool {
        if case CoordinateFrameOrigin.geocentric = lhs, case CoordinateFrameOrigin.geocentric = rhs {
            return true
        }
        if case CoordinateFrameOrigin.heliocentric = lhs, case CoordinateFrameOrigin.heliocentric = rhs {
            return true
        }
        if case CoordinateFrameOrigin.topocentric(let locationLhs) = lhs, case CoordinateFrameOrigin.topocentric(let locationRhs) = rhs {
            if locationLhs == locationRhs {
                return true
            }
        }
        return false
    }
}

public struct CoordinateFrame : Equatable {
    
    public static let ICRS = CoordinateFrame(type: .ICRF, equinox: nil)
    public static let galactic = CoordinateFrame(type: .galactic, equinox: nil)
    public static let B1900 = CoordinateFrame(type: .FK4, equinox: Date.B1900)
    public static let B1950 = CoordinateFrame(type: .FK4, equinox: Date.B1950)
    public static let J2000 = CoordinateFrame(type: .FK5, equinox: Date.J2000)
    public static let J2050 = CoordinateFrame(type: .FK5, equinox: Date.J2050)
    
    /*
    case galactic
    case fk4(equinox: Date)
    case fk5(equinox: Date)
    case meanEcliptic(equinox: Date)
    case trueEcliptic(equinox: Date)
    case horizontal(geographicalLocation: GeographicLocation, epoch: Date)
 */
    
    public let type: CoordinateFrameType
    public let equinox: Date?
    public let origin: CoordinateFrameOrigin
    
    private init(type: CoordinateFrameType, origin: CoordinateFrameOrigin = .geocentric, equinox: Date?) {
        self.type = type
        self.equinox = equinox
        self.origin = origin
    }
    
    public static func == (lhs: CoordinateFrame, rhs: CoordinateFrame) -> Bool {
        if lhs.type == rhs.type {
            if lhs.type == .FK5 || lhs.type == .FK4 || lhs.type == .meanEcliptical || lhs.type == .trueEcliptical || lhs.type == .horizontal {
                if lhs.equinox != rhs.equinox {
                    return false
                }
            }
            return lhs.origin == rhs.origin
        }
        return false
    }
}

public struct SphericalCoordinates : CustomStringConvertible {
    
    public let longitude: Double
    
    public let latitude: Double
    
    public let distance: Double?
    
    public var distanceIsKnown: Bool {
        get {
            return self.distance != nil
        }
    }
    
    public let frame : CoordinateFrame
    
    public init(longitude: Double, latitude: Double, distance: Double? = nil, frame: CoordinateFrame) {
        var lon = longitude
        while lon < 0.0 {
            lon = lon + 2*Double.pi
        }
        while lon > 2*Double.pi {
            lon = lon - 2*Double.pi
        }
        var lat = latitude
        if lat < -Double.pi {
            lat = -Double.pi
        }
        if lat > Double.pi {
            lat = Double.pi
        }
        self.longitude = lon
        self.latitude = latitude
        self.distance = distance
        self.frame = frame
    }
    
    public func transform(to frame: CoordinateFrame) -> SphericalCoordinates {
        let rectCoord = self.rectangularCoordinates
        let transformedRectCoord = rectCoord.transform(to: frame)
        let transformedCoord = transformedRectCoord.sphericalCoordinates
        return transformedCoord
    }
    
    public var rectangularCoordinates : RectangularCoordinates {
        get {
            let d = distance != nil ? distance!: 1.0
            let ra = cos(latitude) * d
            let z = sin(latitude) * d
            let x = cos(longitude) * ra
            let y = sin(longitude) * ra
            return RectangularCoordinates(x: x, y: y, z: z, frame: frame)
        }
    }
    
    public func angularSeparation(with coordinates: SphericalCoordinates) -> Double {
        let transformedCoordinates = coordinates.transform(to: self.frame)
        let x = cos(self.latitude)*sin(transformedCoordinates.latitude) - sin(self.latitude)*cos(transformedCoordinates.latitude) * cos(transformedCoordinates.longitude - self.longitude)
        let y = cos(transformedCoordinates.latitude) * sin(transformedCoordinates.longitude - self.longitude)
        let z = sin(self.latitude)*sin(transformedCoordinates.latitude) + cos(self.latitude)*cos(transformedCoordinates.latitude) * cos(transformedCoordinates.longitude - self.longitude)
        let d = fabs(atan(sqrt(pow(x,2)+pow(y,2)) / z))
        return d
    }
    
    /**
     * Calculates the position angle in radians of these coordinates with respect to other coordinates. If these
     * coordinates are due north of the specified coordinates, the value will be `0 rad`. If these coordinates
     * are to the **west** of the specified coordinates the position angle will be `½π rad`.
     *
     * - Parameter coordinates: The coordinates, where the position angle is calculates in respect
     * of.
     * - Returns: The position angle in radians.
     */
    public func positionAngle(withRespectTo coordinates: SphericalCoordinates) -> Double {
        let transformedCoordinates = coordinates.transform(to: self.frame)
        let Δlon = self.longitude - transformedCoordinates.longitude
        var P = atan2(sin(Δlon), cos(transformedCoordinates.latitude)*tan(self.latitude) - sin(transformedCoordinates.latitude)*cos(Δlon))
        if P < 0.0 {
            P = P + 2 * Double.pi
        }
        return P
    }
    
    public var description: String {
        get {
            var string = ""
            if frame.type == .FK4 || frame.type == .FK5 || frame.type == .ICRF {
                string = "ɑ = \(self.longitude*180/Double.pi)°  δ = \(self.latitude*180/Double.pi)°"
            } else if frame.type == .meanEcliptical || frame.type == .trueEcliptical {
                string = "λ = \(self.longitude*180/Double.pi)°  β = \(self.latitude*180/Double.pi)°"
            } else if frame.type == .galactic {
                string = "l = \(self.longitude*180/Double.pi)°  b = \(self.latitude*180/Double.pi)°"
            } else if frame.type == .horizontal {
                string = "A = \(self.longitude*180/Double.pi)°  h = \(self.latitude*180/Double.pi)°"
            }
            if distance != nil {
                string = "\(string)  d = \(self.distance!)m"
            }
            if frame.equinox != nil {
                if frame.equinox == Date.J2000 {
                    string = "(J2000.0)  \(string)"
                } else if frame.equinox == Date.J2050 {
                    string = "(J2050.0)  \(string)"
                } else if frame.equinox == Date.B1900 {
                    string = "(B1900.0)  \(string)"
                } else if frame.equinox == Date.B1950 {
                    string = "(B1950.0)  \(string)"
                } else {
                    string = "(J\(frame.equinox!.julianEpoch))  \(string)"
                }
            } else {
                if frame.type == .ICRF {
                    string = "(ICRS)  \(string)"
                }
            }
            return string
        }
    }
}

public struct RectangularCoordinates {
    
    public let x: Double
    
    public let y: Double
    
    public let z: Double
    
    public var distance: Double? {
        get {
            var d : Double? = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
            if d! < 1.1 {
                d = nil
            }
            return d
        }
    }
    
    public var distanceIsKnown: Bool {
        get {
            return self.distance != nil
        }
    }
    
    public let frame: CoordinateFrame
    
    public func transform(to frame: CoordinateFrame) -> RectangularCoordinates {
        return RectangularCoordinates.transformCoordinates(coordinates: self, to: frame)
    }
    
    public var sphericalCoordinates : SphericalCoordinates {
        get {
            let distance : Double? = self.distance
            var d = 1.0
            if distance != nil {
                d = distance!
            }
            let latitude = asin(z/d)
            let longitude = atan2(y, x)
            return SphericalCoordinates(longitude: longitude, latitude: latitude, distance: distance, frame: frame)
        }
    }
    
    public var description: String {
        get {
            var string = "(x=\(x), y=\(y), z=\(z))"
            let distance = self.distance
            if distance != nil {
                string = "(x=\(x)m, y=\(y)m, z=\(z)m)  d = \(distance!)m"
            }
            if frame.equinox != nil {
                if frame.equinox == Date.J2000 {
                    string = "(J2000.0)  \(string)"
                } else if frame.equinox == Date.J2050 {
                    string = "(J2050.0)  \(string)"
                } else if frame.equinox == Date.B1900 {
                    string = "(B1900.0)  \(string)"
                } else if frame.equinox == Date.B1950 {
                    string = "(B1950.0)  \(string)"
                } else {
                    string = "(J\(frame.equinox!.julianEpoch))  \(string)"
                }
            } else {
                if frame.type == .ICRF {
                    string = "(ICRS)  \(string)"
                }
            }
            return string
        }
    }
    
    private static func rotateZAxis(coordinates: (x: Double, y: Double, z: Double), cosRotation: Double, sinRotation: Double, sign: Double) -> (x: Double, y: Double, z: Double) {
        let x = coordinates.x*cosRotation - coordinates.y*sign*sinRotation
        let y = coordinates.x*sign*sinRotation + coordinates.y*cosRotation
        return (x: x, y: y, z: coordinates.z)
    }

    private static func rotateYAxis(coordinates: (x: Double, y: Double, z: Double), cosRotation: Double, sinRotation: Double, sign: Double) -> (x: Double, y: Double, z: Double) {
        let x = coordinates.x*cosRotation + coordinates.z*sign*sinRotation
        let z = -coordinates.x*sign*sinRotation + coordinates.z*cosRotation
        return (x: x, y: coordinates.y, z: z)
    }

    private static func rotateFromGalactic(coordinates: (x: Double, y: Double, z: Double), rotationFactors: [(cosRotation: Double, sinRotation: Double)]) -> (x: Double, y: Double, z: Double) {
        var newCoord = rotateZAxis(coordinates: coordinates, cosRotation: rotationFactors[0].cosRotation, sinRotation: rotationFactors[0].sinRotation, sign: 1)
        newCoord = rotateYAxis(coordinates: newCoord, cosRotation: rotationFactors[1].cosRotation, sinRotation: rotationFactors[1].sinRotation, sign: 1)
        newCoord = rotateZAxis(coordinates: newCoord, cosRotation: rotationFactors[2].cosRotation, sinRotation: rotationFactors[2].sinRotation, sign: 1)
        return newCoord
    }

    private static func rotateToGalactic(coordinates: (x: Double, y: Double, z: Double), rotationFactors: [(cosRotation: Double, sinRotation: Double)]) -> (x: Double, y: Double, z: Double) {
        var newCoord = rotateZAxis(coordinates: coordinates, cosRotation: rotationFactors[2].cosRotation, sinRotation: rotationFactors[2].sinRotation, sign: -1)
        newCoord = rotateYAxis(coordinates: newCoord, cosRotation: rotationFactors[1].cosRotation, sinRotation: rotationFactors[1].sinRotation, sign: -1)
        newCoord = rotateZAxis(coordinates: newCoord, cosRotation: rotationFactors[0].cosRotation, sinRotation: rotationFactors[0].sinRotation, sign: -1)
        return newCoord
    }
    
    private static func rotationFactors(for frame: CoordinateFrame, at equinox: Date?) -> [(cosRotation: Double, sinRotation: Double)] {
        var interpolation : InterpolationTimeSeries?
        if frame.type == .ICRF {
            interpolation = Ephemerides.EPHEM_COORDSYS_ICRS
        } else if frame.type == .FK5 {
            interpolation = Ephemerides.EPHEM_COORDSYS_FK5
        } else if frame.type == .FK4 {
            interpolation = Ephemerides.EPHEM_COORDSYS_FK4
        } else if frame.type == .meanEcliptical {
            interpolation = Ephemerides.EPHEM_COORDSYS_GEOCENTRIC_MEAN_ECLIPTIC
        } else if frame.type == .trueEcliptical {
            interpolation = Ephemerides.EPHEM_COORDSYS_GEOCENTRIC_TRUE_ECLIPTIC
        } else if frame.type == .horizontal {
            interpolation = Ephemerides.EPHEM_COORDSYS_FK5
        } else {
            // No rotation
            return [(cosRotation: 1.0, sinRotation: 0.0), (cosRotation: 1.0, sinRotation: 0.0), (cosRotation: 1.0, sinRotation: 0.0)]
        }
        var date = Date()
        if equinox != nil {
            date = equinox!
        }
        let values = interpolation!.interpolatedValues(time: date)
        return [(cosRotation: values[0], sinRotation: values[1]), (cosRotation: values[2], sinRotation: values[3]), (cosRotation: values[4], sinRotation: values[5])]
    }

    private static func transformCoordinates(coordinates: RectangularCoordinates, to frame: CoordinateFrame) -> RectangularCoordinates {
        // TODO: Transformation to correct origin.
        
        if coordinates.frame == .ICRS && frame == .ICRS {
            return coordinates
        }
        if coordinates.frame == .galactic && frame == .galactic {
            return coordinates
        }
        var newCoordinates = (x:coordinates.x, y:coordinates.y, z:coordinates.z)
        
        if coordinates.frame != .galactic {
            let rotationFactors = RectangularCoordinates.rotationFactors(for: coordinates.frame, at: coordinates.frame.equinox)
            newCoordinates = RectangularCoordinates.rotateToGalactic(coordinates: newCoordinates, rotationFactors: rotationFactors)
        }
        if frame != .galactic {
            let rotationFactors = RectangularCoordinates.rotationFactors(for: frame, at: frame.equinox)
            newCoordinates = RectangularCoordinates.rotateFromGalactic(coordinates: newCoordinates, rotationFactors: rotationFactors)
        }
        return RectangularCoordinates(x: newCoordinates.x, y: newCoordinates.y, z: newCoordinates.z, frame: frame)
    }
}
