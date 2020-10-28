//
//  Ephemerides.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

class Ephemerides : NSObject {
    static let EPHEM_COORDSYS_ICRS = InterpolationTimeSeries(fromResource: "icrs.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_COORDSYS_FK5 = InterpolationTimeSeries(fromResource: "fk5.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_COORDSYS_FK4 = InterpolationTimeSeries(fromResource: "fk4.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_COORDSYS_GEOCENTRIC_TRUE_ECLIPTIC = InterpolationTimeSeries(fromResource: "geocentricmeanecliptic.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_COORDSYS_GEOCENTRIC_MEAN_ECLIPTIC = InterpolationTimeSeries(fromResource: "geocentrictrueecliptic.ephem", in: Bundle(for: Ephemerides.self))
    
    static let EPHEM_SUN = InterpolationTimeSeries(fromResource: "sun.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_MERCURY = InterpolationTimeSeries(fromResource: "mercury.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_VENUS = InterpolationTimeSeries(fromResource: "venus.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_MARS = InterpolationTimeSeries(fromResource: "mars.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_JUPITER = InterpolationTimeSeries(fromResource: "jupiter.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_SATURN = InterpolationTimeSeries(fromResource: "saturn.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_URANUS = InterpolationTimeSeries(fromResource: "uranus.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_NEPTUNE = InterpolationTimeSeries(fromResource: "neptune.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_PLUTO = InterpolationTimeSeries(fromResource: "pluto.ephem", in: Bundle(for: Ephemerides.self))
    static let EPHEM_MOON = InterpolationTimeSeries(fromResource: "moon.ephem", in: Bundle(for: Ephemerides.self))
}
