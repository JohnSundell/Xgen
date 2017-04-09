/**
 *  Xgen
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

/// Error thrown when Xgen failed to generate an object
public struct XgenError: Error {
    /// The underlying error that was the reason generation failed
    let underlyingError: Error
}

extension XgenError: CustomStringConvertible {
    public var description: String {
        return "Xgen failed to generate. Underlying error: \(underlyingError)"
    }
}
