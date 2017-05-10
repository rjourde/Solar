//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct SunPosition {
    
    var azimuth: Double = 0.0
    var altitude: Double = 0.0
    
    init(date: Date, latitude: Double, longitude: Double) {
        
        let lw = rad * -longitude
        let phi = rad * latitude
        
        let coordinates = equatorialCoordinates(with: meanAnomaly(at: date))
        let H = siderealTime(at: date, lw: lw) - coordinates.rightAscension
        
        self.azimuth = getAzimuth(H: H, phi: phi, dec: coordinates.declination)
        self.altitude = getAltitude(H: H, phi: phi, dec: coordinates.declination)
    }
    
}

struct EquatorialCoordinates {
    
    var rightAscension: Double
    var declination: Double
    
    init(rightAscension: Double, declination: Double) {
        self.rightAscension = rightAscension
        self.declination = declination
    }
    
}

fileprivate let rad = .pi / 180.0
fileprivate let E = rad * 23.4397

private let secondsInDay: Double = 60 * 60 * 24
private let J1970: Double = 2440588
private let J2000: Double = 2451545

private extension Date {
    
    var julianDay: Double {
        return Double(self.timeIntervalSince1970) / (60 * 60 * 24) - 0.5 + J1970
    }
}

fileprivate func meanAnomaly(at date: Date) -> Double {
    return rad * (357.5291 + 0.98560028 * (date.julianDay - J2000))
}

fileprivate func equationOfCenter(with meanAnomaly: Double) -> Double {
    let firstFactor = 1.9148 * sin(meanAnomaly)
    let secondFactor = 0.02 * sin(2 * meanAnomaly)
    let thirdFactor = 0.0003 * sin(3 * meanAnomaly)
    
    return rad * (firstFactor + secondFactor + thirdFactor)
}

fileprivate func eclipticLongitude(with meanAnomaly: Double) -> Double {
    let perihelion = rad * 102.9372 // perihelion of the Earth
    return meanAnomaly + equationOfCenter(with: meanAnomaly) + perihelion + .pi
}

fileprivate func rightAscension(l: Double, b: Double) -> Double {
    return atan2(sin(l) * cos(E) - tan(b) * sin(E), cos(l))
}

fileprivate func getAzimuth(H: Double, phi: Double, dec: Double) -> Double {
    return atan2(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi))
}

fileprivate func getAltitude(H: Double, phi: Double, dec: Double) -> Double {
    return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H))
}

fileprivate func siderealTime(at date: Date, lw: Double) -> Double {
    return rad * (280.16 + 360.9856235 * (date.julianDay - J2000)) - lw
}

fileprivate func declination(l:Double, b:Double) -> Double {
    return asin(sin(b) * cos(E) + cos(b) * sin(E) * sin(l))
}

fileprivate func equatorialCoordinates(with meanAnomaly: Double) -> EquatorialCoordinates {
    let ecliptic = eclipticLongitude(with: meanAnomaly)
    
    return EquatorialCoordinates(rightAscension: rightAscension(l: ecliptic, b: 0), declination: declination(l: ecliptic, b: 0))
}
