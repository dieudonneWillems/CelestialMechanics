//
//  DateTests.swift
//  CelestialMechanicsTests
//
//  Created by Don Willems on 01/11/2020.
//

import XCTest
@testable import CelestialMechanics

class DateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJulianEpoch() throws {
        let J2000 = Date(julianEpoch: 2000.0)
        XCTAssertEqual(J2000, Date.J2000)
        XCTAssertEqual(Date.J2000.julianEpoch, 2000.0)
        let J2050 = Date(julianEpoch: 2050.0)
        XCTAssertEqual(J2050, Date.J2050)
        XCTAssertEqual(Date.J2050.julianEpoch, 2050.0)
    }
    
    func testBesselianEpoch() throws {
        print(Date(besselianEpoch: 1950).julianDay)
        let B1900 = Date(besselianEpoch: 1900.0)
        XCTAssertEqual(B1900, Date.B1900)
        XCTAssertEqual(Date.B1900.besselianEpoch, 1900.0)
        let B1950 = Date(besselianEpoch: 1950.0)
        XCTAssertEqual(B1950, Date.B1950)
        XCTAssertTrue(fabs(Date.B1950.besselianEpoch-1950.0)<0.00000000001)
    }
    
    func testMidnightUT1() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 12
        dateComponents.minute = 16
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        let midnightUT = date.midnightUT
        print("Date: \(date)  midnight UT: \(midnightUT)")
        let hour = calendar.component(.hour, from: midnightUT)
        let minute = calendar.component(.minute, from: midnightUT)
        let second = calendar.component(.second, from: midnightUT)
        let year = calendar.component(.year, from: midnightUT)
        let month = calendar.component(.month, from: midnightUT)
        let day = calendar.component(.day, from: midnightUT)
        XCTAssertEqual(hour, 2)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testMidnightUT2() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 15
        dateComponents.minute = 16
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        let midnightUT = date.midnightUT
        print("Date: \(date)  midnight UT: \(midnightUT)")
        let hour = calendar.component(.hour, from: midnightUT)
        let minute = calendar.component(.minute, from: midnightUT)
        let second = calendar.component(.second, from: midnightUT)
        let year = calendar.component(.year, from: midnightUT)
        let month = calendar.component(.month, from: midnightUT)
        let day = calendar.component(.day, from: midnightUT)
        XCTAssertEqual(hour, 2)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!+1)
    }
    
    func testNoonUT1() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 8
        dateComponents.minute = 34
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        let noonUT = date.noonUT
        print("Date: \(date)  noon UT: \(noonUT)")
        let hour = calendar.component(.hour, from: noonUT)
        let minute = calendar.component(.minute, from: noonUT)
        let second = calendar.component(.second, from: noonUT)
        let year = calendar.component(.year, from: noonUT)
        let month = calendar.component(.month, from: noonUT)
        let day = calendar.component(.day, from: noonUT)
        XCTAssertEqual(hour, 14)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testNoonUT2() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 15
        dateComponents.minute = 34
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        let noonUT = date.noonUT
        print("Date: \(date)  noon UT: \(noonUT)")
        let hour = calendar.component(.hour, from: noonUT)
        let minute = calendar.component(.minute, from: noonUT)
        let second = calendar.component(.second, from: noonUT)
        let year = calendar.component(.year, from: noonUT)
        let month = calendar.component(.month, from: noonUT)
        let day = calendar.component(.day, from: noonUT)
        XCTAssertEqual(hour, 14)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testMidnight1() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 11
        dateComponents.minute = 16
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        var midnight = date.midnight
        midnight = midnight.addingTimeInterval(0.5)
        print("Date: \(date)  midnight : \(midnight)")
        let hour = calendar.component(.hour, from: midnight)
        let minute = calendar.component(.minute, from: midnight)
        let second = calendar.component(.second, from: midnight)
        let year = calendar.component(.year, from: midnight)
        let month = calendar.component(.month, from: midnight)
        let day = calendar.component(.day, from: midnight)
        XCTAssertEqual(hour, 0)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testMidnight2() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 12
        dateComponents.minute = 16
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        var midnight = date.midnight
        midnight = midnight.addingTimeInterval(0.5)
        print("Date: \(date)  midnight: \(midnight)")
        let hour = calendar.component(.hour, from: midnight)
        let minute = calendar.component(.minute, from: midnight)
        let second = calendar.component(.second, from: midnight)
        let year = calendar.component(.year, from: midnight)
        let month = calendar.component(.month, from: midnight)
        let day = calendar.component(.day, from: midnight)
        XCTAssertEqual(hour, 0)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!+1)
    }
    
    func testNoon1() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 8
        dateComponents.minute = 34
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        var noon = date.noon
        noon = noon.addingTimeInterval(0.5)
        print("Date: \(date)  noon: \(noon)")
        let hour = calendar.component(.hour, from: noon)
        let minute = calendar.component(.minute, from: noon)
        let second = calendar.component(.second, from: noon)
        let year = calendar.component(.year, from: noon)
        let month = calendar.component(.month, from: noon)
        let day = calendar.component(.day, from: noon)
        XCTAssertEqual(hour, 12)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testNoon2() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 15
        dateComponents.minute = 34
        dateComponents.second = 12
        let date = calendar.date(from: dateComponents)!
        var noon = date.noon
        noon = noon.addingTimeInterval(0.5)
        print("Date: \(date)  noon: \(noon)")
        let hour = calendar.component(.hour, from: noon)
        let minute = calendar.component(.minute, from: noon)
        let second = calendar.component(.second, from: noon)
        let year = calendar.component(.year, from: noon)
        let month = calendar.component(.month, from: noon)
        let day = calendar.component(.day, from: noon)
        XCTAssertEqual(hour, 12)
        XCTAssertEqual(minute, 0)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(year, dateComponents.year!)
        XCTAssertEqual(month, dateComponents.month!)
        XCTAssertEqual(day, dateComponents.day!)
    }
    
    func testMeanSiderealTimeAtGreenwichAtMidnight() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1987
        dateComponents.month = 4
        dateComponents.day = 10
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 00
        let date = calendar.date(from: dateComponents)!
        print(date)
        let Θ = date.meanSiderealTimeAtGreenwichAtMidnight
        print(fabs(Θ*180/Double.pi - 197.693195))
        XCTAssertTrue(fabs(Θ*180/Double.pi - 197.693195) < 1.0/36000)
    }
    
    func testMeanSiderealTimeAtGreenwich() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1987
        dateComponents.month = 4
        dateComponents.day = 10
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.hour = 19
        dateComponents.minute = 21
        dateComponents.second = 00
        let date = calendar.date(from: dateComponents)!
        let θ = date.meanSiderealTimeAtGreenwich
        XCTAssertTrue(fabs(θ*180/Double.pi - 128.7378734) < 1.0/36000)
    }
    
    func testMeanSiderealTime() throws {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 1987
        dateComponents.month = 4
        dateComponents.day = 10
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.hour = 19
        dateComponents.minute = 21
        dateComponents.second = 00
        let date = calendar.date(from: dateComponents)!
        let θ = date.meanSiderealTime(at: GeographicLocation(latitude: 61.22/180*Double.pi, longitude: 11.443/180*Double.pi))
        print(fabs(θ*180/Double.pi - (128.7378734+11.443)))
        XCTAssertTrue(fabs(θ*180/Double.pi - (128.7378734+11.443)) < 1.0/36000)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
