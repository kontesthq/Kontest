//
//  ActivityManager.swift
//  Kontest
//
//  Created by Ayush Singhal on 29/11/24.
//

@preconcurrency import ActivityKit
import Foundation

@Observable
final class ActivityManager: Sendable {
    @MainActor private(set) var activityID: String?
    @MainActor private(set) var activityToken: String?
    @MainActor private(set) var kontest: KontestModel?

    static let shared = ActivityManager()

    private init() {}
    
    func start(kontest: KontestModel) async {
        await cancelAllRunningActivities()
        await startNewLiveActivity(kontest: kontest)
    }

    private func startNewLiveActivity(kontest: KontestModel) async {
        print("Starting new live activity...")

        let attributes = KontestLiveActivityAttributes(kontest: kontest)

        let initialContentState = ActivityContent(state: KontestLiveActivityAttributes.ContentState(),
                                                  staleDate: nil,
                                                  relevanceScore: 0)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: initialContentState,
                pushType: nil
            )

            await MainActor.run {
                activityID = activity.id
                self.kontest = kontest
            }

            for await data in activity.pushTokenUpdates {
                let token = data.map { String(format: "%02x", $0) }.joined()
                print("ACTIVITY TOKEN:\n\(token)")
                await MainActor.run { activityToken = token }
                // HERE SEND THE TOKEN TO THE SERVER
            }
            
        } catch {
            print("Failed to create activity with error: \(error)")
        }
    }
    
    func updateActivityRandomly() async {
        print("Updating activity randomly...")
        
        guard let activityID = await activityID,
              let runningActivity = Activity<KontestLiveActivityAttributes>.activities.first(where: { $0.id == activityID })
        else {
            return
        }
        
        // Update the activity with random content emoji
        let newRandomContentState = KontestLiveActivityAttributes.ContentState()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2) {
            Task {
                await runningActivity.update(using: newRandomContentState,
                                             alertConfiguration: AlertConfiguration(title: "Title",
                                                                                    body: "Body",
                                                                                    sound: .default))
            }
        }
    }
    
    func endActivity() async {
        print("Ending activity...")
        
        guard let activityID = await activityID,
              let runningActivity = Activity<KontestLiveActivityAttributes>.activities.first(where: { $0.id == activityID })
        else {
            return
        }
        let initialContentState = KontestLiveActivityAttributes.ContentState()
        
        await runningActivity.end(
            ActivityContent(state: initialContentState, staleDate: Date.distantFuture),
            dismissalPolicy: .immediate
        )
        
        await MainActor.run {
            self.activityID = nil
            self.activityToken = nil
        }
    }
    
    func cancelAllRunningActivities() async {
        print("Cancelling all running activities...")
        
        for activity in Activity<KontestLiveActivityAttributes>.activities {
            let initialContentState = KontestLiveActivityAttributes.ContentState()
            
            await activity.end(
                ActivityContent(state: initialContentState, staleDate: Date()),
                dismissalPolicy: .default
            )
        }
        
        await MainActor.run {
            activityID = nil
            activityToken = nil
        }
    }
    
    func observeActivity(activity: Activity<KontestLiveActivityAttributes>) {
        Task {
            for await activityState in activity.activityStateUpdates {
                print("ACTIVITY STATE UPDATE:\n\(activityState)")
            }
        }
    }
}
