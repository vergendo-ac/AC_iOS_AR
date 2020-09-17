//
//  YaMotionManager.swift
//  myPlace
//
//  Created by Mac on 08/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import CoreMotion
import UIKit
import ARKit

@objc protocol YaMotionManagerDelegate: class {
    @objc optional func motionManager(didUpdate deviceMotion: CMDeviceMotion)
    @objc optional func motionManager(wrong state: String)
}

class YaMotionManager {
    
    static let sharedInstance = YaMotionManager()
    
    private var latestSensorData : [String : simd_double3] = [:]
    private var latestSensorsState: [String: (Bool, String)] = [:] {
        didSet {
            delegate?.motionManager?(wrong: sensorsState())
        }
    }
    private var latestDeviceOrientation : CW = ._90
    weak var delegate: YaMotionManagerDelegate?
    
    private let syncRoot: NSRecursiveLock = NSRecursiveLock()

    /// CoreMotion manager instance we receive updates from.
    fileprivate let motionManager = CMMotionManager()
    
    internal enum CW {
        
        case _0
        case _90
        case _180
        case _270

        /// A description of the sensor as a `String`.
        internal var description: UIDeviceOrientation {
            switch self {
            case ._0:
                return .landscapeLeft
            case ._90:
                return .portrait
            case ._180:
                return .landscapeRight
            case ._270:
                return .portraitUpsideDown
            }
        }

    }
    
    internal enum DeviceSensor {
        
        /// Gyroscope
        case gyro
        /// Accelerometer
        case accelerometer
        /// Magnetormeter
        case magnetometer
        /// A set of iOS SDK algorithms that work with raw sensors data
        case deviceMotion
        
        /// A description of the sensor as a `String`.
        internal var description: String {
            switch self {
            case .gyro:
                return "Gyroscope"
            case .accelerometer:
                return "Accelerometer"
            case .magnetometer:
                return "Compass"
            case .deviceMotion:
                return "Device motion"
            }
        }
        
    }
    
    internal enum SensorData {
        
        /// Raw gyroscope data.
        case rawGyroData
        /// Raw accelerometer data.
        case rawAccelerometerData
        /// Raw magnetometer data.
        case rawMagnetometerData
        /// Rotation rate as returned by the `DeviceMotion` algorithms.
        case rotationRate
        /// User acceleration as returned by the `DeviceMotion` algorithms.
        case userAcceleration
        /// Gravity value as returned by the `DeviceMotion` algorithms.
        case gravity
        
        internal var description: String {
            switch self {
            case .rawGyroData:
                return "GyroData"
            case .rawAccelerometerData:
                return "AccelerometerData"
            case .rawMagnetometerData:
                return "MagnetometerData"
            case .rotationRate:
                return "RotationRateData"
            case .userAcceleration:
                return "UserAccelerationData"
            case .gravity:
                return "GravityData"
            }
        }
        
    }

    
    init() {
        self.startUpdate()
    }
    
    deinit {
        self.stopUpdate()
    }
    
    func startUpdate() {
        // Initiate the `CoreMotion` updates to our callbacks.
        startAccelerometerUpdates()
        startGyroUpdates()
        startMagnetometerUpdates()
        startDeviceMotionUpdates()
    }
    
    func stopUpdate() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func setDeviceMotionUpdates(_ timeInterval: TimeInterval) {
        motionManager.stopDeviceMotionUpdates()
        startDeviceMotionUpdates(timeInterval)
    }
    
    // MARK: - Configuring CoreMotion callbacks triggered for each sensor
    
    /**
     *  Configure the raw accelerometer data callback.
     */
    fileprivate func startAccelerometerUpdates() {
        self.saveSuccess(for: .accelerometer)

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                if let err = error as NSError? {
                    self.saveError(for: .accelerometer, error: err)
                } else {
                    self.report(maybeAcceleration: accelerometerData?.acceleration, sensorData: .rawAccelerometerData)
                    self.log(error: error, forSensor: .accelerometer)
                }
            }
        } else {
            saveState(
                isAvailable: false,
                for: .accelerometer,
                errorMessage: "\(DeviceSensor.accelerometer.description)  is unavailable now!"
            )
        }
    }
    
    /**
     *  Configure the raw gyroscope data callback.
     */
    fileprivate func startGyroUpdates() {
        self.saveSuccess(for: .gyro)

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { (gyroData, error) in
                if let err = error as NSError? {
                    self.saveError(for: .gyro, error: err)
                } else {
                    self.report(maybeRotationRate: gyroData?.rotationRate, sensorData: .rawGyroData)
                    self.log(error: error, forSensor: .gyro)
                }
            }
        } else {
           saveState(
               isAvailable: false,
               for: .gyro,
               errorMessage: "\(DeviceSensor.gyro.description) is unavailable now!"
           )
        }
    }
    
    /**
     *  Configure the raw magnetometer data callback.
     */
    fileprivate func startMagnetometerUpdates() {
        self.saveSuccess(for: .magnetometer)

        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.1
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (magnetometerData, error) in
                if let err = error as NSError? {
                    self.saveError(for: .magnetometer, error: err)
                } else {
                    self.report(maybeMagneticField: magnetometerData?.magneticField, sensorData: .rawMagnetometerData)
                    self.log(error: error, forSensor: .magnetometer)
                }
            }
        } else {
            saveState(
                isAvailable: false,
                for: .magnetometer,
                errorMessage: "\(DeviceSensor.magnetometer.description) is unavailable now!"
            )
        }
    }
    
    /**
     *  Configure the Device Motion algorithm data callback.
     */
    fileprivate func startDeviceMotionUpdates(_ timeInterval: TimeInterval = 0.1) {
        self.saveSuccess(for: .deviceMotion)

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = timeInterval
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] (deviceMotion, error) in
                guard let `self` = self else {
                    return
                }
                
                if let err = error as NSError? {
                    self.saveError(for: .deviceMotion, error: err)
                } else {
                    self.report(maybeAcceleration: deviceMotion?.gravity, sensorData: .gravity)
                    self.report(maybeAcceleration: deviceMotion?.userAcceleration, sensorData: .userAcceleration)
                    self.report(maybeRotationRate: deviceMotion?.rotationRate, sensorData: .rotationRate)
                    self.log(error: error, forSensor: .deviceMotion)
                    
                    if deviceMotion != nil {
                        self.delegate?.motionManager?(didUpdate: deviceMotion!)
                    }
                }
                
            }
        } else {
            saveState(
                isAvailable: false,
                for: .deviceMotion,
                errorMessage: "\(DeviceSensor.deviceMotion.description) is unavailable now!"
            )
        }
    }
    
    /**
     Logs an error in a consistent format.
     
     - parameter error:  Error value.
     - parameter sensor: `DeviceSensor` that triggered the error.
     */
    fileprivate func log(error: Error?, forSensor sensor: DeviceSensor) {
        // REQUEST: function caused a problem for T2, app falls immediately right after stickers search start 
        //guard let error = error else { return }
        
        //NSLog("Error reading data from \(sensor.description): \n \(error) \n")
    }
    
    func getGravityStringData() -> String? {
        syncRoot.lock()
        guard let dataVector = latestSensorData[SensorData.gravity.description] else {
            syncRoot.unlock()
            return nil
        }
        
        syncRoot.unlock()
    
        let dataArray: [String] = [
            String(format: "%.2f", arguments: [dataVector.x]),
            String(format: "%.2f", arguments: [dataVector.y]),
            String(format: "%.2f", arguments: [dataVector.z])
        ]
        
        return dataArray.joined(separator: " ")

    }
    
    func getGravityData() -> simd_double3? {
        syncRoot.lock()
        
        guard let dataVector = latestSensorData[SensorData.gravity.description] else {
            syncRoot.unlock()
            return nil
        }
        syncRoot.unlock()
        
        return dataVector
    }
    
    func deviceOrientation() -> UIDeviceOrientation {
        syncRoot.lock()
        let orientation = self.latestDeviceOrientation.description
        syncRoot.unlock()
        return orientation
    }
    
    func exifOrientation() -> Int {
        syncRoot.lock()
        let orientation = self.latestDeviceOrientation.description
        syncRoot.unlock()
        switch orientation {
            case .portrait:
                return 6
            case .landscapeRight:
                return 3
            case .portraitUpsideDown:
                return 8
            case .landscapeLeft:
                return 1
            default:
                return 6
        }
    }
    
    fileprivate func saveState(isAvailable: Bool, for sensor: DeviceSensor, errorMessage: String = "") {
        syncRoot.lock()
        self.latestSensorsState[sensor.description] = (isAvailable, errorMessage)
        syncRoot.unlock()
    }

    fileprivate func saveSuccess(for sensor: DeviceSensor) {
        self.latestSensorsState[sensor.description] = nil
    }

    fileprivate func saveError(for sensor: DeviceSensor, error: NSError) {
        switch error.code {
        case 102:
            self.saveState(isAvailable: false, for: .magnetometer, errorMessage: "\(DeviceSensor.magnetometer.description) is unavailable now.\n" + error.localizedDescription)
        default:
            break
        }
        self.saveState(isAvailable: false, for: sensor, errorMessage: "\(sensor.description) is unavailable now.\n" + error.localizedDescription)
    }
    
    func sensorsState() -> String {
        syncRoot.lock()
        guard let sensordData: [(Bool, String)] = Array(latestSensorsState.values) as [(Bool, String)]?, sensordData.count > 0 else {
            syncRoot.unlock()
            return ""
        }
        syncRoot.unlock()
        
        let state = sensordData.filter{ !$0.0 }.map{ $0.1 }.joined(separator: "\n")
        
        return state

    }
    
    func updateState() {
        self.stopUpdate()
        self.startUpdate()
    }

}

extension YaMotionManager {
    /**
     - parameter rotationRate: A `CMRotationRate` holding the values to set.
     */
    internal func report(maybeRotationRate: CMRotationRate?, sensorData: SensorData) {
        let maybeDataVector: simd_double3? = (maybeRotationRate == nil) ? nil : simd_double3(x: maybeRotationRate!.x, y: maybeRotationRate!.y, z: maybeRotationRate!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    /**
     - parameter acceleration: A `CMAcceleration` holding the values to set.
     */
    internal func report(maybeAcceleration: CMAcceleration?, sensorData: SensorData) {
        let maybeDataVector: simd_double3? = (maybeAcceleration == nil) ? nil : simd_double3(x: maybeAcceleration!.x, y: maybeAcceleration!.y, z: maybeAcceleration!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    /**
     - parameter magnitude:     A `CMMagneticField` holding the values to set.
     */
    internal func report(maybeMagneticField: CMMagneticField?, sensorData: SensorData) {
        let maybeDataVector: simd_double3? = (maybeMagneticField == nil) ? nil : simd_double3(x: maybeMagneticField!.x, y: maybeMagneticField!.y, z: maybeMagneticField!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    fileprivate func saveDataString(maybeDataVector: simd_double3?, sensorData: SensorData) {
        syncRoot.lock()
        
        self.latestSensorData[sensorData.description] = maybeDataVector

        syncRoot.unlock()
    }
    
    fileprivate func saveDeviceOrientation(maybeDataVector: simd_double3?) {
        syncRoot.lock()
        guard let dataVector = maybeDataVector else {
            self.latestDeviceOrientation = CW._90;
            syncRoot.unlock()
            return
        }
        
        if dataVector.x < -0.5 {
            self.latestDeviceOrientation = CW._0
        } else if dataVector.x > 0.5 {
            self.latestDeviceOrientation = CW._180
        } else if dataVector.y > 0.5 {
            self.latestDeviceOrientation = CW._270
        } else {
            self.latestDeviceOrientation = CW._90
        }
        syncRoot.unlock()
    }

    fileprivate func process(maybeDataVector: simd_double3? = nil, sensorData: SensorData) {
        
        
        //Done for future possible changes in final values mutations, for example, different axis directions or positions of phone
        switch sensorData {
        case .gravity:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawAccelerometerData:
            saveDeviceOrientation(maybeDataVector: maybeDataVector)
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawGyroData:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawMagnetometerData:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rotationRate:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .userAcceleration:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        }
        
    }

}
