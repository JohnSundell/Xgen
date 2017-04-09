/**
 *  Xgen
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
import Files

/// Class representing an Xcode workspace
public class Workspace: Generatable {
    /// The path to generate a workspace at
    public let path: String
    private var contents = [Reference]()

    // MARK: - Initializer

    /**
     *  Initialize a workspace with a certain configuration
     *
     *  - parameter path: The path to generate a workspace at
     *
     *  Note that you have to call `generate()` on the workspace
     *  to actually generate it on the file system.
     */
    public init(path: String) {
        self.path = path.removingSuffixIfNeeded("/")
                        .addingSuffixIfNeeded(".xcworkspace")
                        .appending("/")
    }

    // MARK: - API

    /// Add a reference to an item at a path to this workspace
    public func addReference(to path: String) {
        contents.append(Reference(path: path, generatable: nil))
    }

    /// Add an Xcode project reference to this workspace
    public func addProject(at path: String) {
        assert(path.hasSuffix(".xcodeproj"),
               "The path '\(path)' does not point to an Xcode project")

        contents.append(Reference(path: path, generatable: nil))
    }

    /// Add a new playground to this workspace, which will be generated along with the workspace
    @discardableResult public func addPlayground(named name: String = "Playground") -> Playground {
        let playground = Playground(path: path + name.addingSuffixIfNeeded(".playground"))
        addPlayground(playground)
        return playground
    }

    /// Add an existing playground to this workspace
    public func addPlayground(at path: String) {
        contents.append(Reference(path: path, generatable: nil))
    }

    /// Add a playground to this workspace, which will be generated along with the workspace
    public func addPlayground(_ playground: Playground) {
        contents.append(Reference(path: playground.path, generatable: playground))
    }

    // MARK: - Generatable

    public func generate() throws {
        do {
            let folder = try FileSystem().createFolder(at: path)

            var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            xml.append("<Workspace version=\"1.0\">")

            for reference in contents {
                try reference.generatable?.generate()

                xml.append("    <FileRef location=\"group:\(reference.path)\"></FileRef>")
            }

            xml.append("</Workspace>")

            let xmlFile = try folder.createFileIfNeeded(withName: "contents.xcworkspacedata")
            try xmlFile.write(string: xml)
        } catch {
            throw XgenError(underlyingError: error)
        }
    }
}

// MARK: - Private

private extension Workspace {
    struct Reference {
        let path: String
        let generatable: Generatable?
    }
}
