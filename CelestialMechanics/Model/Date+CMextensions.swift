//
//  Date+CMextensions.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

public extension Date {
    
    /* The Julian Day corresponding to B1900. */
    private static let julianDayB1900 = 2415020.3135
    
    /**
     * The standard epoch of B1900.0 represented as a `Date` object.
     */
    static let B1900 = Date(julianDay: julianDayB1900)
    
    /**
     * The standard epoch of B1950.0 represented as a `Date` object.
     */
    static let B1950 = Date(julianDay: 2433282.42344)
    
    /* The Julian Day corresponding to J2000. */
    private static let julianDayJ2000 = 2451545.0
    
    /**
     * The standard epoch of J2000.0 represented as a `Date` object.
     */
    static let J2000 = Date(julianDay: julianDayJ2000)
    
    /**
     * The standard epoch of J2050.0 represented as a `Date` object.
     */
    static let J2050 = Date(julianDay: 2469807.5)
    
    /**
     * The number of seconds in a day.
     */
    static let lengthOfDay : TimeInterval = 86400.0
    
    /**
     * The number of seconds in a sidereal day.
     */
    static let lengthOfSiderealDay: TimeInterval = 0.9972695671 * lengthOfDay
    
    /**
     * The number of seconds in a Julian year (equal to `365.25` days).
     */
    static let julianYear : TimeInterval = 365.25 * lengthOfDay
    
    /**
     * The number of seconds in a Besselian year (i.e. a tropical year, which is equal to `365.2421988`
     * days).
     */
    static let besselianYear : TimeInterval = 365.2421988 * lengthOfDay
    
    /**
     * The julian day on 1st January 1970 at 0h UTC.
     */
    private static let julianDayOn1970 = 2440587.5
    
    /**
     * Creates a new `Date` from the specified Julian Day.
     *
     * - Parameter jd: The Julian Day number of the date that is requested.
     * - Returns: A `Date` object that specifies the same instant of time as the provided Julian Day.
     */
    init(julianDay jd: Double) {
        let timeInterval = (jd - Date.julianDayOn1970) * Date.lengthOfDay
        self.init(timeIntervalSince1970: timeInterval)
    }
    
    /**
     * Creates a new `Date` from the specified Julian Epoch, which is the number of Julian years since
     * the year 1 BC. A Julian year is equal to 365.25 days.
     *
     * The Julian Epoch is often used to specify the equinox for which positions in an astronomical
     * catalogue are given. They are often preceded by the capital `J`. So `J2000.0` correspond
     * to the Julian Epoch 2000.0.
     */
    init(julianEpoch epoch: Double) {
        let dJulianYears = epoch-2000.0
        let jd = Date.julianDayJ2000 + dJulianYears*Date.julianYear/Date.lengthOfDay
        self.init(julianDay: jd)
    }
    
    /**
     * Creates a new `Date` from the specified Besselian Epoch, which is the number of tropical years
     * since the year 1 BC.
     *
     * The Julian Epoch is was often used to specify the equinox for which positions in an astronomical
     * catalogue are given. They are often preceded by the capital `B`. So `B1950.0` correspond
     * to the Besselian Epoch 1950.0. 
     */
    init(besselianEpoch epoch: Double) {
        let dBesselianYears = epoch-1900.0
        let jd = Date.julianDayB1900 + dBesselianYears*Date.besselianYear/Date.lengthOfDay
        self.init(julianDay: jd)
    }
    
    /**
     * The `Date` object for midnight in the user's current timezone.
     *
     * When the time
     * is passed noon (i.e. in the afternoon or evening), the following occurence of midnight will be given.
     * If the time is before noon (i.e. in the morning), the previous occurecnce of midnight will be given.
     */
    var midnight: Date {
        get {
            return self.midnight(for: TimeZone.current)
        }
    }
    
    /**
     * The `Date` object for noon in the user's current timezone.
     */
    var noon: Date {
        get {
            return self.noon(for: TimeZone.current)
        }
    }
    
    /**
     * The `Date` object representing midnight in the specified timezone.
     *
     * When the time
     * is passed noon (i.e. in the afternoon or evening), the following occurence of midnight will be given.
     * If the time is before noon (i.e. in the morning), the previous occurecnce of midnight will be given.
     *
     * - Parameter timezone: The timezone for which midnight should be calculated.
     * - Returns: The date of midnight either the previous or following occurence depending on which
     * is closer.
     */
    func midnight(for timezone: TimeZone) -> Date {
        let offset = Double(timezone.secondsFromGMT(for: self)) / Date.lengthOfDay
        var localJD = self.julianDay + offset - 0.5
        localJD.round()
        let jd = localJD - offset + 0.5
        return Date(julianDay: jd)
    }
    
    /**
     * The `Date` object representing noon in the specified timezone.
     *
     * - Parameter timezone: The timezone for which noon should be calculated.
     * - Returns: The date of noon of the current date.
     */
    func noon(for timezone: TimeZone) -> Date {
        let offset = Double(timezone.secondsFromGMT(for: self)) / Date.lengthOfDay
        var localJD = self.julianDay + offset
        localJD.round()
        let jd = localJD - offset
        return Date(julianDay: jd)
    }
    
    /**
     * The date-time for midnight (0h UT) of the date represented by current `Date` object.
     *
     * When the time
     * is passed noon (i.e. in the afternoon or evening), the following occurence of midnight will be given.
     * If the time is before noon (i.e. in the morning), the previous occurecnce of midnight will be given.
     */
    var midnightUT: Date {
        get {
            let jd = self.julianDayAtMidnightUT
            return Date(julianDay: jd)
        }
    }
    
    /**
     * The date-time for noon (12h UT) of the date represented by current `Date` object.
     */
    var noonUT: Date {
        get {
            let jd = self.julianDayAtNoonUT
            return Date(julianDay: jd)
        }
    }
    
    /**
     * The Julian Day number that is specific to the date and time value of this `Date` object.
     */
    var julianDay : Double {
        get {
            let secs = self.timeIntervalSince1970
            let jd = Date.julianDayOn1970 + secs / Date.lengthOfDay
            return jd
        }
    }
    
    /**
     * The Julian Day for midnight (0h UT) of the date represented by current `Date` object.
     *
     * When the time is
     * passed noon (i.e. in the afternoon or evening), the following occurence of midnight will be given.
     * If the time is before noon (i.e. in the morning), the previous occurecnce of midnight will be given.
     */
    var julianDayAtMidnightUT: Double {
        get {
            var jd = self.julianDay - 0.5
            jd.round()
            jd = jd + 0.5
            return jd
        }
    }
    
    /**
     * The Julian Day for noon (12h UT) of the date represented by current `Date` object.
     */
    var julianDayAtNoonUT: Double {
        get {
            var jd = self.julianDay
            jd.round()
            return jd
        }
    }
    
    /**
     * The Julian Century for this `Date`, i.e. the number of Julian centurries (100 Julian Years of
     * 365.25 days since January 1st 2020 (0h UT).
     *
     * This is the value for `T`, used in Astronomical Algorithms by Jean Meeus.
     */
    var julianCentury: Double {
        get {
            let jd = self.julianDay
            let T = (jd-2451545.0) / 36525
            return T
        }
    }
    
    /**
     * The Julian Century for this `Date`'s date at 0h UT, i.e. the number of Julian centurries (100 Julian
     * Years of 365.25 days since January 1st 2020 (0h UT).
     */
    var julianCenturyAtMidnight: Double {
        get {
            let jd = self.julianDayAtMidnightUT
            let T = (jd-2451545.0) / 36525
            return T
        }
    }
    
    /**
     * The Julian Epoch of the current date.
     *
     * The Julian Epoch is the number of Julian years (of 365.25 days) since the year 1 BC.
     *
     * The Julian Epoch is often used to specify the equinox for which positions in an astronomical
     * catalogue are given. They are often preceded by the capital `J`. So `J2000.0` correspond
     * to the Julian Epoch 2000.0.
     */
    var julianEpoch: Double {
        get {
            let dJD = self.julianDay - Date.J2000.julianDay
            let dJY = dJD * Date.lengthOfDay / Date.julianYear
            return 2000.0 + dJY
        }
    }
    
    /**
     * The Besselian Epoch of the current date.
     *
     * The Besselian Epoch is the number of tropical years since the year 1 BC.
     *
     * The Julian Epoch is was often used to specify the equinox for which positions in an astronomical
     * catalogue are given. They are often preceded by the capital `B`. So `B1950.0` correspond
     * to the Besselian Epoch 1950.0.
     */
    var besselianEpoch: Double {
        get {
            let dJD = self.julianDay - Date.B1900.julianDay
            let dJY = dJD * Date.lengthOfDay / Date.besselianYear
            return 1900.0 + dJY
        }
    }
    
    /**
     * The *mean* sidereal time at Greenwich at 0h UT of the current `Date` object.
     *
     * This value does not take nutation into account (hence it is the *mean* sidereal time.
     *
     * When the time in UT is
     * passed noon (i.e. in the afternoon or evening), the sidereal time of the following midnight will be given.
     * If the time is before noon (i.e. in the morning), the sidereal time of the  previous  midnight will be given.
     */
    var meanSiderealTimeAtGreenwichAtMidnight: Double {
        get {
            let T = self.julianCenturyAtMidnight
            let Θ_0 = 100.46061837 + 36000.770053608*T + 0.000387933*T*T - T*T*T/38710000
            return (Θ_0 / Double.rpi).normalisedAngle
        }
    }
    
    /**
     * The *mean* sidereal time at Greenwich of the current `Date` object.
     *
     * This value does not take nutation into account (hence it is the *mean* sidereal time.
     */
    var meanSiderealTimeAtGreenwich: Double {
        get {
            let jd = self.julianDay
            let T = self.julianCentury
            let θ_0 = 280.46061837 + 360.98564736629*(jd-2451545.0) + 0.000387933*T*T - T*T*T/38710000
            return (θ_0 / Double.rpi).normalisedAngle
        }
    }
    
    /**
     * The *mean* sidereal time at the specified location on the date and time of the current `Date` object.
     *
     * This value does not take nutation into account (hence it is the *mean* sidereal time.
     *
     * - Parameter location: The lcoation for which the sidereal time should be given.
     * - Returns: The current sidereal time at the specified location.
     */
    func meanSiderealTime(at location: GeographicLocation) -> Double {
        let θ_0 = meanSiderealTimeAtGreenwich
        let θ = θ_0 + location.longitude
        return θ.normalisedAngle
    }
}


public extension Double {
    
    /**
     * The number of radians in a degree.
     */
    static let rpi = 180.0/Double.pi
    
    /**
     * The normalised (to the range `[0, 2π)`).
     */
    var normalisedAngle: Double {
        get {
            let revolutions = Int(self/Double.pi/2.0)
            var angle = self - Double(revolutions) * Double.pi * 2.0
            if angle < 0 {
                angle = angle + Double.pi * 2.0
            }
            return angle
        }
    }
}
