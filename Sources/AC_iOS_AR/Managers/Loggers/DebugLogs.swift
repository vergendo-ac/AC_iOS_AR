//
//  DebugLogs.swift
//  SensorsLoggerViper
//
//  Created by sss on 20/08/2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import simd

enum StatusCategory : Int {
    case success = 0
    case error = 1
    case info = 2
    case warning = 3
    case text = 4
    case debug = 5
}

protocol DbgOutDelegate : class {
    func writeln(_ text: String)
}

enum DebugLevel {
    case silence, error, audit, verbose
}

class DbgOut {
    
    static public let syncRoot = NSRecursiveLock()
    static public let begT = NSDate().timeIntervalSince1970
    static var spent: Double = 0
    
    public static var debugLevel: DebugLevel = .verbose
    public static var filterTags: [String] = []
    public static var instance = DbgOut()
    
    private(set) static var delegate: DbgOutDelegate? = nil
    
    private init () {
    }
    
    public static func set(_ delegate: DbgOutDelegate?) -> DbgOutDelegate? {
        syncRoot.lock()
        let old = DbgOut.delegate
        DbgOut.delegate = delegate
        syncRoot.unlock()
        return old
    }
    
    private static func save(_ text: String) {
        print(text)
        syncRoot.lock()
        if let d = delegate {
            d.writeln(text)
        }
        syncRoot.unlock()
    }
    
    public static func out(sc: StatusCategory, msg: String, args: [CVarArg] = [], tags: [String] = []) {
        DbgOut.msgOut(sc: sc, msg: msg, args: args, tags: tags)
    }
    
    public static func e(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .error, msg: msg, args: args, tags: tags)
    }
    
    public static func s(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .success, msg: msg, args: args, tags: tags)
    }
    
    public static func i(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .info, msg: msg, args: args, tags: tags)
    }
    
    public static func w(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .warning, msg: msg, args: args, tags: tags)
    }
    
    public static func t(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .text, msg: msg, args: args, tags: tags)
    }
    
    public static func d(_ msg: String, args: [CVarArg] = [], tags: [String] = []) {
        out(sc: .debug, msg: msg, args: args, tags: tags)
    }
    
    private static func msgOut(sc: StatusCategory, msg: String, args: [CVarArg] = [], tags: [String] = []) {
        let b: Double = NSDate().timeIntervalSince1970
        if sc == .debug && DbgOut.filterTags.count > 0 && !DbgOut.filterTags.contains(where: {tags.contains($0)}) {
            return
        }
        switch DbgOut.debugLevel {
            case .silence: return
            case .error: if sc != .error || sc != .text { return}
            case .audit: if sc == .debug { return}
            default: break
        }
        if sc != .text {
            let tid = unsafeBitCast(Thread.current, to: Int.self) & 0xFFFF
            let threadName = Thread.current.isMainThread ? "main" : String(format: "%04x", arguments: [tid])
            let t = b - DbgOut.begT
            let ms: Int = Int(simd_fract(t) * 1000)
            let sec = Int(t) % 100000
            
            save(String(format: "+[%@:%05d.%03d] " + msg, arguments: [threadName, sec, ms] + args))
            let callS = NSDate().timeIntervalSince1970 - b
            DbgOut.spent += callS
            if callS > 0.1 {
                save(String(format: "+[%@:%05d.%03d] DbgOut has spent more 100 ms! ", arguments: [threadName, sec, ms]))
            }
        } else {
            save(String(format: msg, arguments: args))
        }
    }
}
