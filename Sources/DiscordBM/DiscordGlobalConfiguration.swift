import Foundation
import Logging

public enum DiscordGlobalConfiguration {
    public static var apiVersion = 10
    public static var decoder: DiscordDecoder = JSONDecoder()
    public static var encoder: DiscordEncoder = JSONEncoder()
    public static var makeLogger: (String) -> Logger = { Logger(label: $0) }
    /// How many seconds till each connection's `zombiedConnectionChecker`
    /// becomes suspicious that the current connection is not healthy anymore.
    /// It might take 5-10s more before the `zombiedConnectionChecker` makes
    /// sure and drops the connection.
    public static var zombiedConnectionCheckerTolerance = 90.0
}

//MARK: - DiscordDecoder
public protocol DiscordDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

extension JSONDecoder: DiscordDecoder { }

//MARK: - DiscordEncoder
public protocol DiscordEncoder {
    func encode<E: Encodable>(_ value: E) throws -> Data
}

extension JSONEncoder: DiscordEncoder { }