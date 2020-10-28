//
//  Date+CMextensions.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation

public extension Date {
    
    static let B1900 = Date(julianDay: 2415020.3135)
    static let B1950 = Date(julianDay: 2433282.4235)
    static let J2000 = Date(julianDay: 2451545.0)
    static let J2050 = Date(julianDay: 2469807.5)
    
    static func julianEpoch(_ epoch: Double) -> Date {
        return Date(julianEpoch: epoch)
    }
    
    static func besselianEpoch(_ epoch: Double) -> Date {
        return Date(besselianEpoch: epoch)
    }
    
    private static let lengthOfDay : TimeInterval = 86400.0
    
    static let julianYear : TimeInterval = 365.25 * lengthOfDay
    
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
    
    private init(julianEpoch epoch: Double) {
        let timeInterval = (epoch-1970) * Date.julianYear
        self.init(timeIntervalSince1970: timeInterval)
    }
    
    private init(besselianEpoch epoch: Double) {
        let timeInterval = (epoch-1970) * Date.besselianYear
        self.init(timeIntervalSince1970: timeInterval)
    }
    
    /**
     * The Julian Day number that is specific to the date and time value of this `Date` object.
     */
    var julianDay : Double {
        get {
            let secs = self.timeIntervalSince1970
            let jd = Date.julianDayOn1970 + secs / 86400.0
            return jd
        }
    }
    
    var julianEpoch: Double {
        get {
            let timeInterval = self.timeIntervalSince1970
            let epoch = timeInterval/Date.julianYear + 1970.0
            return epoch
        }
    }
    
    var besselianEpoch: Double {
        get {
            let timeInterval = self.timeIntervalSince1970
            let epoch = timeInterval/Date.besselianYear + 1970.0
            return epoch
        }
    }
}
