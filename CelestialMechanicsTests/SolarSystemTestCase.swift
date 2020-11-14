//
//  SolarSystemTestCase.swift
//  CelestialMechanicsTests
//
//  Created by Don Willems on 30/10/2020.
//

import XCTest
@testable import CelestialMechanics

class SolarSystemTestCase: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMars() throws {
        let mars = Planet.mars
        let epoch = Date(julianEpoch: 2020.9)
        print("epoch: \(epoch)  -  \(epoch.julianDay)")
        do {
            let sphericalCoordinates = try mars.sphericalCoordinates(at: epoch, inCoordinateFrame: .J2000)
            print(sphericalCoordinates)
        } catch InterpolationException.epochOutOfEphemerisRange {
            XCTAssertTrue(true)
        }
    }
    
    func testSun() throws {
        let date = Date(julianDay: 2466025.5572292856)
        print("date: \(date)  JD\(date.julianDay)")
        let sun = Sun.sun
        let coordinates = try sun.sphericalCoordinates(at: date, inCoordinateFrame: .ICRS)
        print("Sun: \(coordinates)")
    }
    
    func testDateOutOfRange() throws {
        let jupiter = Planet.jupiter
        let epoch = Date(julianEpoch: 1920.4)
        print("epoch: \(epoch)  -  \(epoch.julianDay)")
        do {
            let _ = try jupiter.sphericalCoordinates(at: epoch, inCoordinateFrame: .J2000)
            XCTAssertTrue(false, "An exception should have been thrown as the epoch is outside of the range of the ephemerides.")
        } catch InterpolationException.epochOutOfEphemerisRange {
            XCTAssertTrue(true)
        }
    }
    
    func testMagnitudeJupiter() throws {
        let jupiter = Planet.jupiter
        let epoch = Date(julianDay: 2459175.50000) // 22 nov 2020 0h UTC
        XCTAssertTrue(fabs(try jupiter.visualMagnitude(at: epoch).value - -2.1) < 0.1)
    }
    
    func testMagnitudeAndIlluminatedFractionVenus() throws {
        let venus = Planet.venus
        let epoch = Date(julianDay: 2459175.50000) // 22 nov 2020 0h UTC
        XCTAssertTrue(fabs(try venus.visualMagnitude(at: epoch).value - -4.0) < 0.1)
        XCTAssertTrue(fabs(try venus.illuminatedFraction(at: epoch) - 0.867) < 0.001)
    }
    
    func testSaturnsRing() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1992
        dateComponents.month = 12
        dateComponents.day = 16
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let date = calendar.date(from: dateComponents)!
        let saturn = Planet.saturn
        let ring = try saturn.propertiesOfTheRing(at: date)
    
        XCTAssertTrue(fabs(ring.B/Units.degree - 16.442) < 0.002, "B = \(ring.B/Units.degree)°")
        XCTAssertTrue(fabs(ring.B´/Units.degree - 14.679) < 0.002, "B´ = \(ring.B´/Units.degree)°")
        XCTAssertTrue(fabs(ring.a/Units.degree*3600 - 35.87) < 0.02, "a = \(ring.a/Units.degree*3600)\"")
        XCTAssertTrue(fabs(ring.b/Units.degree*3600 - 10.15) < 0.02, "b = \(ring.B/Units.degree*3600)\"")
        XCTAssertTrue(fabs(ring.i/Units.degree - 28.076131) < 0.000001, "i = \(ring.i/Units.degree)°")
        // TODO: Expect more precission when the nutation is taken into account.
        XCTAssertTrue(fabs(ring.P/Units.degree - 6.741) < 0.05, "P = \(ring.P/Units.degree)°")
        XCTAssertTrue(fabs(ring.ΔU/Units.degree - 4.198) < 0.002, "ΔU = \(ring.ΔU/Units.degree)°")
    }

    func testPerformanceMoonCoordinates() throws {
        // This is an example of a performance test case.
        self.measure {
            let moon = Moon.moon
            let epoch = Date(julianEpoch: 2020.9)
            do {
                let _ = try moon.sphericalCoordinates(at: epoch, inCoordinateFrame: .J2000)
            } catch {
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformanceVenusMagnitude() throws {
        // This is an example of a performance test case.
        self.measure {
            let venus = Planet.venus
            let epoch = Date(julianDay: 2459175.50000) // 22 nov 2020 0h UTC
            do {
                let _ = try venus.visualMagnitude(at: epoch)
            } catch {
                XCTAssertTrue(true)
            }
        }
    }

}
