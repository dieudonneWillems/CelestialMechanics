//
//  Coordinates.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation


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
     * Creates a new ´GeographicalLocation´ with the specified latitude and longitude.
     *
     * - Parameter latitude: The latitude of the geographical location.North is positive and south
     * negative. The latitude is given in radians.
     * - Parameter longitude: The longitude of the geographical location. West is positive and east
     * negative. The latitude is given in radians.
     */
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public static func == (lhs: GeographicLocation, rhs: GeographicLocation) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
}

public enum CoordinateFrameType {
    case ICRS
    case FK4
    case FK5
    case meanEcliptical
    case trueEcliptical
    case galactic
    case horizontal
}

public enum CoordinateFrameOrigin : Equatable {
    case geocentric
    case heliocentric
    case topocentric(location: GeographicLocation)
    
    public static func == (lhs: CoordinateFrameOrigin, rhs: CoordinateFrameOrigin) -> Bool {
        return false
    }
}

public struct CoordinateFrame : Equatable {
    
    public static let ICRS = CoordinateFrame(type: .ICRS, equinox: nil)
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
    
    private init(type: CoordinateFrameType, equinox: Date?) {
        self.type = type
        self.equinox = equinox
    }
    
    public static func == (lhs: CoordinateFrame, rhs: CoordinateFrame) -> Bool {
        if lhs.type == rhs.type {
            if lhs.type == .FK5 || lhs.type == .FK4 || lhs.type == .meanEcliptical || lhs.type == .trueEcliptical {
                if lhs.equinox != rhs.equinox {
                    return false
                }
            } else if lhs.type == .horizontal {
                
            }
            return true
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
            if frame.type == .FK4 || frame.type == .FK5 || frame.type == .ICRS {
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
                if frame.type == .ICRS {
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
                if frame.type == .ICRS {
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
        if frame.type == .ICRS {
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
