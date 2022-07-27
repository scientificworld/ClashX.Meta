//
//  ClashMetaConfig.swift
//  ClashX Meta

import Foundation
import Cocoa
import Yams

class ClashMetaConfig: NSObject {

    struct Config: Codable {
        var externalUI: String? = {
            guard let htmlPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "dashboard") else {
                return nil
            }
            return URL(fileURLWithPath: htmlPath).deletingLastPathComponent().path
        }()

        var externalController = "127.0.0.1:9090"
        var secret: String?

        var port: Int?
        var socksPort: Int?
        var mixedPort: Int?

        var logLevel = ConfigManager.selectLoggingApiLevel.rawValue

        var path: String {
            get {
                guard let s = try? YAMLEncoder().encode(self),
                      let path = RemoteConfigManager.createCacheConfig(string: s) else {
                    assertionFailure("Create init config file failed.")
                    return ""
                }
                return path
            }
        }

        enum CodingKeys: String, CodingKey {
            case externalController = "external-controller",
                 externalUI = "external-ui",
                 mixedPort = "mixed-port",
                 port,
                 socksPort = "socks-port",
                 logLevel = "log-level",
                 secret
        }

        mutating func loadDefaultConfigFile() {
            let fm = FileManager.default
            guard let data = fm.contents(atPath: kDefaultConfigFilePath),
                  let string = String(data: data, encoding: .utf8),
                  let yaml = try? Yams.load(yaml: string) as? [String: Any] else {
                return
            }

            let keys = Config.CodingKeys.self
            if let ec = yaml[keys.externalController.rawValue] as? String {
                externalController = ec
            }

            if let s = yaml[keys.secret.rawValue] as? String {
                secret = s
            }

            if let port = yaml[keys.mixedPort.rawValue] as? Int {
                mixedPort = port
            } else {
                if let p = yaml[keys.port.rawValue] as? Int {
                    port = p
                }
                if let sp = yaml[keys.socksPort.rawValue] as? Int {
                    socksPort = sp
                }
            }

            if port == nil && mixedPort == nil {
                mixedPort = 7890
            }
        }
    }

    static func generateInitConfig() -> Config {
        var config = Config()
        config.loadDefaultConfigFile()
        return config
    }

}
