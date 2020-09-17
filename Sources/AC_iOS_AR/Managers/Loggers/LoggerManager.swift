//
//  LoggerManager.swift
//  myPlace
//
//  Created by Mac on 04.06.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

//import SwiftyBeaver

//EXAMPLE
/*
 var logGPS: LoggerManager!
 self.logGPS = LoggerManager(path: .Documents, filename: "gps \(currentDatetime).txt")
 print("Text for log", to: &logGPS)
 */

import Foundation

class LoggerManager : DbgOutDelegate, AppDirectoryNames  {
    
    private let syncRoot = NSRecursiveLock()
    
    enum State {
        case started(old: DbgOutDelegate?)
        case stopped
        case failed(error: Error)
        case stdout(inpipes: [Pipe], outpipes: [Pipe])
    }
    
    private (set) var state: State = .stopped
    private var url: URL?
    private var fileH: FileHandle?
    public static var ln: Data = String("\n").data(using: .utf8)!
    
    private var dropSavingL: UInt64 = 100 * 1024
    private var dropLimitV: UInt64 = 2 * 1024 * 1024
    private var dropLastPos: UInt64 = 0
    
    init(path: AppDirectories, filename: String) {
        self.url = self.getURL(for: path)?.appendingPathComponent(filename)
    }
    
    
    init(file: URL) {
        self.url = file
    }
    
    deinit {
        cleanup()
    }
    
    private func initialize() throws {
        syncRoot.lock()
        guard fileH == nil, let url = self.url else {
            syncRoot.unlock()
            return
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        do {
            fileH = try FileHandle(forUpdating: url)
            let pos = fileH?.seekToEndOfFile() ?? 0
            if pos < dropLimitV - dropSavingL {
                dropLastPos = pos
            }
        }
        catch {
            syncRoot.unlock()
            throw error
        }
        syncRoot.unlock()
    }
    
    private func cleanup() {
        syncRoot.lock()
        fileH?.closeFile()
        fileH = nil
        syncRoot.unlock()
    }
    
    public func begin(hookStd: Bool = false) {
        DbgOut.syncRoot.lock()
        switch state {
            case .stopped:
                
                do {
                    try initialize()
                    if hookStd {
                        let input = Pipe()
                        let output = Pipe()
                        input.fileHandleForReading.readabilityHandler = {[weak self] fileIn in
                            guard let this = self else { return }
                            let data = fileIn.availableData
                            if let string = String(data: data, encoding: .utf8) {
                                this.write(string)
                            }
                            output.fileHandleForWriting.write(data)
                        }
                        
                        let inputE = Pipe()
                        let outputE = Pipe()
                        inputE.fileHandleForReading.readabilityHandler = {[weak self] fileIn in
                            guard let this = self else { return }
                            let data = fileIn.availableData
                            if let string = String(data: data, encoding: .utf8) {
                                this.write(string)
                            }
                            outputE.fileHandleForWriting.write(data)
                        }
                        
                        let stdOut = FileHandle.standardOutput.fileDescriptor
                        let stdErr = FileHandle.standardError.fileDescriptor
                        
                        dup2(stdOut, output.fileHandleForWriting.fileDescriptor)
                        dup2(input.fileHandleForWriting.fileDescriptor, stdOut)
                        
                        dup2(stdErr, outputE.fileHandleForWriting.fileDescriptor)
                        dup2(inputE.fileHandleForWriting.fileDescriptor, stdErr)
                        
                        state = .stdout(inpipes: [input, inputE], outpipes: [output, outputE])
                    } else {
                        state = .started(old: DbgOut.set(self))
                    }
                } catch {
                    state = .failed(error: error)
                    DbgOut.e("LoggerManager: Couldn't create file for logging. " + error.localizedDescription)
                }
            
            
            default:
                break
        }
        DbgOut.syncRoot.unlock()
    }
    
    public func end() {
        DbgOut.syncRoot.lock()
        switch state {
            case .started(let old):
                let d = DbgOut.set(old)
                assert(d === self, "Something went wrong")
                cleanup()
                state = .stopped
            case .stdout(let inpipes, let outpipes):
                inpipes.forEach {
                    $0.fileHandleForReading.closeFile()
                }
                outpipes.forEach {
                    $0.fileHandleForWriting.closeFile()
                }
                cleanup()
                state = .stopped
            default:
                break
        }
        DbgOut.syncRoot.unlock()
    }
    
    internal func writeln(_ text: String) {
        if let d = text.data(using: .utf8, allowLossyConversion: false) {
            syncRoot.lock()
            fileH?.write(d)
            fileH?.write(LoggerManager.ln)
            fileH?.synchronizeFile()
            let pos = fileH?.seekToEndOfFile() ?? 0
            if pos < dropLimitV - dropSavingL {
                dropLastPos = pos
            } else if pos >= dropLimitV {
                drop(at: pos)
            }
            
            syncRoot.unlock()
        }
    }
    
    private func drop(at: UInt64) {
        //DbgOut.d(">>LoggerManager::drop")
        guard let f = fileH, let u = url else { return }
        do {
            var d: Data?
            if dropLastPos < at && at - dropLastPos < dropSavingL * 2 {
                f.seek(toFileOffset: dropLastPos)
                d = f.readData(ofLength: Int(at - dropLastPos))
            }
            
            let tmp = u.appendingPathExtension("~bk")
            if FileManager.default.fileExists(atPath: tmp.path) {
                try FileManager.default.removeItem(at: tmp)
            }
            if !FileManager.default.createFile(atPath: tmp.path, contents: d) {
                 throw NSError(domain: "Restorator", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't create temporary file \"\(tmp.path) \"."])
            }
            f.closeFile()
            fileH = nil
            try FileManager.default.removeItem(at: u)
            try FileManager.default.moveItem(at: tmp, to: u)
            fileH = try FileHandle(forUpdating: u)
            dropLastPos = fileH?.seekToEndOfFile() ?? 0
            DbgOut.s("LoggerManager::drop completed.")
        } catch {
            dropLimitV += dropLimitV
            try? initialize()
            DbgOut.e("LoggerManager::drop error. \(error.localizedDescription)")
        }
        
    }
}

extension LoggerManager : TextOutputStream {
    public func write(_ string: String) {
        do {
            try initialize()
            if let d = string.data(using: .utf8, allowLossyConversion: false) {
                syncRoot.lock()
                fileH?.write(d)
                fileH?.synchronizeFile()
                let pos = fileH?.seekToEndOfFile() ?? 0
                if pos < dropLimitV - dropSavingL {
                    dropLastPos = pos
                } else if pos >= dropLimitV {
                    drop(at: pos)
                }
                syncRoot.unlock()
            }
        }
        catch {
            DbgOut.e("LoggerManager write error. \(error.localizedDescription)")
        }
    }
}
