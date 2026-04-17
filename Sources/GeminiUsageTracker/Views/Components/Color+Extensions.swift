import SwiftUI

#if canImport(AppKit)
import AppKit
public let SystemBackgroundColor = Color(NSColor.windowBackgroundColor)
#else
import UIKit
public let SystemBackgroundColor = Color(UIColor.systemBackground)
#endif
