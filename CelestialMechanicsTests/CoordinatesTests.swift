//
//  CelestialMechanicsTests.swift
//  CelestialMechanicsTests
//
//  Created by Don Willems on 26/10/2020.
//

import XCTest
@testable import CelestialMechanics

class CoordinatesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDates() throws {
        let j2000Date = Date.J2000
        let b1950Date = Date.B1950
        print(j2000Date)
        print(b1950Date)
        XCTAssert(j2000Date > b1950Date)
    }

    func testEphemerides() throws {
        let coord = SphericalCoordinates(longitude: 0.0, latitude: 0.0, frame: .ICRS)
        let ncoord = try coord.transform(to: .J2000)
        XCTAssertNotNil(ncoord.frame.equinox)
        XCTAssertEqual(ncoord.frame.equinox, Date.J2000)
        XCTAssertNotEqual(ncoord.frame.equinox, Date.J2050)
        XCTAssertTrue(try coord.angularSeparation(with: ncoord)*180/Double.pi < 0.000001)
        print(coord)
        print(ncoord)
    }
    
    func testReciprocity() throws {
        let coord = SphericalCoordinates(longitude: 0.0, latitude: 1.0, frame: .ICRS)
        let ncoord = try coord.transform(to: .galactic)
        let ncoord2 = try ncoord.transform(to: .ICRS)
        print(coord)
        print(ncoord)
        print(ncoord2)
        XCTAssertNil(ncoord.frame.equinox)
        XCTAssertNil(ncoord2.frame.equinox)
        XCTAssertTrue(try coord.angularSeparation(with: ncoord2)*180/Double.pi < 0.000001)
    }
    
    func testPositionAngle() throws {
        let coord = SphericalCoordinates(longitude: 0.0, latitude: 0.0, frame: .ICRS)
        let coord2 = SphericalCoordinates(longitude: 1.9*Double.pi, latitude: 0.0, frame: .ICRS)
        XCTAssertEqual(try coord.positionAngle(withRespectTo: coord2), 0.5*Double.pi)
        XCTAssertNotEqual(try coord.positionAngle(withRespectTo: coord2), 1.5*Double.pi)
        XCTAssertEqual(try coord2.positionAngle(withRespectTo: coord), 1.5*Double.pi)
        XCTAssertNotEqual(try coord2.positionAngle(withRespectTo: coord), 0.5*Double.pi)
    }
    
    func testRisingTransitAndSetting() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 11
        dateComponents.day = 2
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let date = calendar.date(from: dateComponents)!
        print("date: \(date)  JD\(date.julianDay)")
        let eidsvoll = GeographicLocation(latitude: 60.331/Double.rpi, longitude: 11.263/Double.rpi)
        let sun = Sun.sun
        let coordinates = try sun.sphericalCoordinates(at: date, inCoordinateFrame: .ICRS)
        print("Sun: \(coordinates)")
        let rts = try coordinates.risingTransitAndSetting(at: date, and: eidsvoll)
        print("rise: \(rts.rising)  transit: \(rts.transit)  set: \(rts.setting)  antitransit: \(rts.antiTransit)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
