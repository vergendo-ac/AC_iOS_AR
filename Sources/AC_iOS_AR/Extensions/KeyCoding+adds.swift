//
//  File.swift
//  
//
//  Created by Mac on 30.09.2020.
//

import Foundation

extension KeyedEncodingContainerProtocol {

    public mutating func encodeArray<T>(_ values: [T], forKey key: Self.Key) throws where T : Encodable {
        var arrayContainer = nestedUnkeyedContainer(forKey: key)
        try arrayContainer.encode(contentsOf: values)
    }

    public mutating func encodeArrayIfPresent<T>(_ values: [T]?, forKey key: Self.Key) throws where T : Encodable {
        if let values = values {
            try encodeArray(values, forKey: key)
        }
    }

    public mutating func encodeMap<T>(_ pairs: [Self.Key: T]) throws where T : Encodable {
        for (key, value) in pairs {
            try encode(value, forKey: key)
        }
    }

    public mutating func encodeMapIfPresent<T>(_ pairs: [Self.Key: T]?) throws where T : Encodable {
        if let pairs = pairs {
            try encodeMap(pairs)
        }
    }

}

extension KeyedDecodingContainerProtocol {

    public func decodeArray<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T] where T : Decodable {
        var tmpArray = [T]()

        var nestedContainer = try nestedUnkeyedContainer(forKey: key)
        while !nestedContainer.isAtEnd {
            let arrayValue = try nestedContainer.decode(T.self)
            tmpArray.append(arrayValue)
        }

        return tmpArray
    }

    public func decodeArrayIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T]? where T : Decodable {
        var tmpArray: [T]? = nil

        if contains(key) {
            tmpArray = try decodeArray(T.self, forKey: key)
        }

        return tmpArray
    }

    public func decodeMap<T>(_ type: T.Type, excludedKeys: Set<Self.Key>) throws -> [Self.Key: T] where T : Decodable {
        var map: [Self.Key : T] = [:]

        for key in allKeys {
            if !excludedKeys.contains(key) {
                let value = try decode(T.self, forKey: key)
                map[key] = value
            }
        }

        return map
    }

}
