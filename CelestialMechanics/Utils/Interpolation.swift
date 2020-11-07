//
//  Interpolation.swift
//  CelestialMechanics
//
//  Created by Don Willems on 26/10/2020.
//

import Foundation


public enum InterpolationException : Error {
    case epochOutOfEphemerisRange
}

struct InterpolationValueRow {
    
    let date : Date
    
    let values: [Double]
    
}

struct InterpolationTimeSeries {
    
    var rows = [InterpolationValueRow]()
    
    init?(fromResource named: String, in bundle: Bundle) {
        let url = bundle.url(forResource: named, withExtension: nil)
        if url == nil {
            return nil
        }
        do {
            let contents = try String(contentsOf: url!, encoding: .ascii)
            let lines = contents.split(separator: "\n")
            for line in lines {
                let items = line.split(separator: "|")
                if items.count > 1 {
                    let timeJD = Double(items[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    let time = Date(julianDay: timeJD!)
                    var values = [Double]()
                    for i in 1...items.count-1 {
                        let value = Double(items[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                        values.append(value!)
                    }
                    let row = InterpolationValueRow(date: time, values: values)
                    rows.append(row)
                }
            }
        } catch {
            return nil
        }
    }
    
    func interpolatedValues(time: Date) throws -> [Double] {
        let start = findIndex(time: time, start: 0, end: rows.count) - 2
        var closestIndex = start
        var index = start
        let end = start+5
        if start <= 2 || end >= rows.count-2 {
            throw InterpolationException.epochOutOfEphemerisRange
        }
        if index < 0 {
            index = 0
        }
        var minTD = -1.0
        while index < end {
            let difT = fabs(time.timeIntervalSince1970 - rows[index].date.timeIntervalSince1970)
            if minTD < 0 || difT < minTD {
                minTD = difT
                closestIndex = index
            }
            index = index + 1
        }
        let n = (time.timeIntervalSince1970 - rows[closestIndex].date.timeIntervalSince1970) / (rows[closestIndex+1].date.timeIntervalSince1970 - rows[closestIndex].date.timeIntervalSince1970)
        var interpolatedValues = [Double]()
        for j in 0...rows[closestIndex].values.count-1 {
            var y = [Double]()
            for i in 0...4 {
                index = closestIndex - 2 + i
                let row = rows[index]
                y.append(row.values[j])
            }
            let value = interpolatedValue(n: n, y1: y[0], y2: y[1], y3: y[2], y4: y[3], y5: y[4])
            interpolatedValues.append(value)
        }
        return interpolatedValues
    }
    
    func findIndex(time: Date, start: Int, end: Int) -> Int {
        if end - start <= 1 {
            return start
        }
        let mid = start + (end-start)/2
        let midTime = rows[mid].date
        if time < midTime {
            return findIndex(time: time, start: start, end: mid)
        } else if time > midTime {
            return findIndex(time: time, start: mid, end: end)
        }
        return mid
    }
    
    func interpolatedValue(n: Double, y1: Double, y2: Double, y3: Double, y4: Double, y5: Double) -> Double {
        let A = y2 - y1
        let B = y3 - y2
        let C = y4 - y3
        let D = y5 - y4
        let E = B - A
        let F = C - B
        let G = D - C
        let H = F - E
        let J = G - F
        let K = J - H
        let y = y3 + n/2*(B+C) + n*n/2*F + n*(n*n-1)/12*(H+J) + n*n*(n*n-1)/24*K
        return y
    }
}
