/**
 *  Xgen
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

internal extension String {
    var length: IndexDistance {
        return distance(from: startIndex, to: endIndex)
    }

    func addingSuffixIfNeeded(_ suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self + suffix
        }

        return self
    }

    func removingSuffixIfNeeded(_ suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }

        let substringEndIndex = index(endIndex, offsetBy: -suffix.length)
        return substring(to: substringEndIndex)
    }
}
