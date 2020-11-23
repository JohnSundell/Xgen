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

    /// The path to generate a playground at
    public let path: String
    /// The platform to generate a playground for
    public var platform: Platform
    /// Whether the playground should be automatically run on each code change
    public var autoRun: Bool
    /// Whether the playground should build the packages or frameworks for import into the playground
    public var buildActiveScheme: Bool
    /// The code that the playground should contain (if nil, a default will be used)
    public var code: String?
    /// The auxiliary source files that the playground should include
    public var auxiliarySourceFiles = [File]()

    // MARK: - Initializer

    /**
     *  Initialize a playground with a certain configuration
     *
     *  - parameter path: The path to generate a playground at
     *  - parameter platform: The platform to generate a playground for
     *  - parameter autoRun: Whether the playground should be run automatically
     *  - parameter code: The code that the playground should contain. If `nil`
     *                    the playground will contain a system framework import
     *
     *  Note that you have to call `generate()` on the playground to actually
     *  generate it on the file system.
     */
    public init(path: String, platform: Platform = .iOS, autoRun: Bool = true, buildActiveScheme: Bool = true, code: String? = nil) {
        self.path = path.removingSuffixIfNeeded("/")
                        .addingSuffixIfNeeded(".playground")
                        .appending("/")

        self.platform = platform
        self.autoRun = autoRun
        self.buildActiveScheme = buildActiveScheme
        self.code = code
    }

    // MARK: - Generatable

    public func generate() throws {
        do {
            let folder = try FileSystem().createFolderIfNeeded(at: path)

            let codeFile = try folder.createFile(named: "Contents.swift")
            try codeFile.write(string: code ?? .makeDefaultCode(for: platform))

            let xmlFile = try folder.createFile(named: "contents.xcplayground")
            try xmlFile.write(string: generateXML())

            try copyAuxiliarySourceFiles(into: folder)

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
        xml.append("<playground version=\"5.0\" target-platform=\"\(platform.rawValue)\" executeOnSourceChanges=\"\(autoRun)\" buildActiveScheme='\(buildActiveScheme)'>")
        xml.append("    <timeline fileName=\"timeline.xctimeline\"/>")
        xml.append("</playground>")
        return xml
    }

    private func copyAuxiliarySourceFiles(into folder: Folder) throws {
        guard !auxiliarySourceFiles.isEmpty else {
            return
        }

        let sourcesFolder = try folder.createSubfolder(named: "Sources")

        for file in auxiliarySourceFiles {
            try file.copy(to: sourcesFolder)
        }
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
}

private extension String {
    static func makeDefaultCode(for platform: Playground.Platform) -> String {
        return "import \(platform.systemFrameworkName)\n\n"
    }
}
