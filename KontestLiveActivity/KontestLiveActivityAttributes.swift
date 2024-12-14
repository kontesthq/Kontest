//
//  KontestLiveActivityAttributes.swift
//  KontestLiveActivityExtension
//
//  Created by Ayush Singhal on 29/11/24.
//

#if os(iOS)
import ActivityKit
import Foundation

struct KontestLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
    }

    // Fixed non-changing properties about your activity go here!
    var kontest: KontestModel
}
#endif
