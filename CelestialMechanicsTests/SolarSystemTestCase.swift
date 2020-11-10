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
        let epoch = Date(julianEpoch: 2020.4)
        print("epoch: \(epoch)  -  \(epoch.julianDay)")
        do {
            let _ = try jupiter.sphericalCoordinates(at: epoch, inCoordinateFrame: .J2000)
            XCTAssertTrue(false, "An exception should have been thrown as the epoch is outside of the range of the ephemerides.")
        } catch InterpolationException.epochOutOfEphemerisRange {
            XCTAssertTrue(true)
        }
    }

    func testPerformanceExample() throws {
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

}
