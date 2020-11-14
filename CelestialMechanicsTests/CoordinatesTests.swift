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
        let epoch = Date()
        let ncoord = try coord.transform(to: .J2000, at: epoch)
        XCTAssertNotNil(ncoord.frame.equinox)
        XCTAssertEqual(ncoord.frame.equinox, Date.J2000)
        XCTAssertNotEqual(ncoord.frame.equinox, Date.J2050)
        XCTAssertTrue(try coord.angularSeparation(with: ncoord, at: epoch)*180/Double.pi < 0.000001)
        print(coord)
        print(ncoord)
    }
    
    func testReciprocity() throws {
        let coord = SphericalCoordinates(longitude: 0.0, latitude: 1.0, frame: .ICRS)
        let epoch = Date()
        let ncoord = try coord.transform(to: .galactic, at: epoch)
        let ncoord2 = try ncoord.transform(to: .ICRS, at: epoch)
        print(coord)
        print(ncoord)
        print(ncoord2)
        XCTAssertNil(ncoord.frame.equinox)
        XCTAssertNil(ncoord2.frame.equinox)
        XCTAssertTrue(try coord.angularSeparation(with: ncoord2, at: epoch)*180/Double.pi < 0.000001)
    }
    
    func testPositionAngle() throws {
        let coord = SphericalCoordinates(longitude: 0.0, latitude: 0.0, frame: .ICRS)
        let coord2 = SphericalCoordinates(longitude: 1.9*Double.pi, latitude: 0.0, frame: .ICRS)
        let epoch = Date()
        XCTAssertEqual(try coord.positionAngle(withRespectTo: coord2, at: epoch), 0.5*Double.pi)
        XCTAssertNotEqual(try coord.positionAngle(withRespectTo: coord2, at: epoch), 1.5*Double.pi)
        XCTAssertEqual(try coord2.positionAngle(withRespectTo: coord, at: epoch), 1.5*Double.pi)
        XCTAssertNotEqual(try coord2.positionAngle(withRespectTo: coord, at: epoch), 0.5*Double.pi)
    }
    
    func testOriginTranslation() throws {
        let vernalEquinox = Date(julianDay: 2459293.90069) // vernal equinox 2021, March 20th 09:37 UTC
        let coord1 = SphericalCoordinates(longitude: 0.0, latitude: 0.0, frame: .ICRS)
        let heliocentric = CoordinateFrame.heliocentricICRS
        let coord2 = try coord1.transform(to: heliocentric, at: vernalEquinox)
        XCTAssertTrue(fabs(coord1.longitude-coord2.longitude)/Double.rpi < 0.01)
        XCTAssertTrue(fabs(coord1.latitude-coord2.latitude)/Double.rpi < 0.01)
        XCTAssertNil(coord2.distance)
    }
    
    func testOriginTranslation2() throws {
        let vernalEquinox = Date(julianDay: 2459293.90069) // vernal equinox 2021, March 20th 09:37 UTC
        let coord1 = SphericalCoordinates(longitude: 0.0, latitude: 0.0, distance: 0.5 * 1.496e11, frame: .ICRS) // distance 0.5 AU
        let heliocentric = CoordinateFrame.heliocentricICRS
        let coord2 = try coord1.transform(to: heliocentric, at: vernalEquinox)
        XCTAssertTrue(fabs(Double.pi-coord2.longitude)/Double.rpi < 0.01)
        XCTAssertTrue(fabs(coord1.latitude-coord2.latitude)/Double.rpi < 0.01)
        XCTAssertNotNil(coord2.distance)
        XCTAssertTrue(fabs(coord1.distance!-coord2.distance!)/Double.rpi < 0.1*1.496e11)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
