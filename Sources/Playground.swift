/**
 *  Xgen
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
import Files

/// Class representing an Xcode playground
public class Playground: Generatable {
    /// Enum representing platforms that are playground compatible
    public enum Platform: String {
        case iOS = "ios"
        case macOS = "macos"
        case tvOS = "tvos"
    }

    /// Enum representing the source of the playground content
    public enum Source {
        case code(String)
        case template(path: String)
    }

    /// The path to generate a playground at
    public let path: String
    /// The platform to generate a playground for
    public var platform: Platform
    /// The source that the playground should contain (if nil, a default will be used)
    public var source: Source?

    // MARK: - Initializer

    /**
     *  Initialize a playground with a certain configuration
     *
     *  - parameter path: The path to generate a playground at
     *  - parameter platform: The platform to generate a playground for
     *  - parameter code: The source that the playground should contain. If `nil`
     *                    the playground will contain a system framework import
     *
     *  Note that you have to call `generate()` on the playground to actually
     *  generate it on the file system.
     */
    public init(path: String, platform: Platform = .iOS, source: Source? = nil) {
        self.path = path.removingSuffixIfNeeded("/")
            .addingSuffixIfNeeded(".playground")
            .appending("/")

        self.platform = platform
        self.source = source
    }

    // MARK: - Generatable

    public func generate() throws {
        do {
            let folder = try FileSystem().createFolderIfNeeded(at: path)

            try generateSourceCode(in: folder)

            let xmlFile = try folder.createFile(named: "contents.xcplayground")
            try xmlFile.write(string: generateXML())

            let workspace = Workspace(path: path + "playground.xcworkspace")
            workspace.addReference(to: "self:")
            try workspace.generate()
        } catch {
            throw XgenError(underlyingError: error)
        }
    }

    // MARK: - Private

    private func generateXML() -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
        xml.append("<playground version=\"5.0\" target-platform=\"\(platform.rawValue)\">")
        xml.append("    <timeline fileName=\"timeline.xctimeline\"/>")
        xml.append("</playground>")
        return xml
    }

    private func generateSourceCode(in folder: Folder) throws {
        switch source {
        case let .code(string)?:
            let codeFile = try folder.createFile(named: "Contents.swift")
            try codeFile.write(string: string)
        case let .template(path)?:
            let template = try Template(path: path, platform: platform)
            try template.copyContents(to: folder)
        default:
            let codeFile = try folder.createFile(named: "Contents.swift")
            try codeFile.write(string: .makeDefaultCode(for: platform))
        }
    }
}

public extension Playground {
    public final class Template {
        public let info: Info
        public let folder: Folder

        public init(path: String, platform: Playground.Platform) throws {
            let folderPath = path.removingSuffixIfNeeded("/")
                .addingSuffixIfNeeded(".xctemplate")
                .appending("/")
            self.folder = try Folder(path: folderPath)

            let data = try self.folder.file(named: "TemplateInfo.plist").read()
            let decoder = PropertyListDecoder()
            self.info = try decoder.decode(Info.self, from: data)

            guard self.info.platforms.contains(platform.templateIdentifier) else {
                throw Error.notAvailableForPlatform(platform.rawValue)
            }

            guard self.info.allowedTypes.contains("com.apple.dt.playground") else {
                throw Error.invalidTemplateType
            }
        }

        public var mainFolder: Folder {
            return try! folder.subfolder(named: info.mainFilename)
        }

        public func copyContents(to targetFolder: Folder) throws {
            try mainFolder.file(named: "Contents.swift").copy(to: targetFolder)

            if let sourcesFolder = try? mainFolder.subfolder(named: "Sources") {
                try sourcesFolder.copy(to: targetFolder)
            }
        }
    }
}

public extension Playground.Template {
    public struct Info: Decodable {
        public let mainFilename: String
        public let platforms: [String]
        public let allowedTypes: [String]

        private enum CodingKeys: String, CodingKey {
            case mainFilename = "MainTemplateFile"
            case platforms = "Platforms"
            case allowedTypes = "AllowedTypes"
        }
    }

    public enum Error: Swift.Error {
        case notAvailableForPlatform(String)
        case invalidTemplateType
    }
}

// MARK: - Private extensions

private extension Playground.Platform {
    var systemFrameworkName: String {
        switch self {
        case .iOS, .tvOS:
            return "UIKit"
        case .macOS:
            return "Cocoa"
        }
    }

    var templateIdentifier: String {
        switch self {
        case .iOS:
            return "com.apple.platform.iphoneos"
        case .macOS:
            return "com.apple.platform.macosx"
        case .tvOS:
            return "com.apple.platform.appletvos"
        }
    }
}

private extension String {
    static func makeDefaultCode(for platform: Playground.Platform) -> String {
        return "import \(platform.systemFrameworkName)\n\n"
    }
}
