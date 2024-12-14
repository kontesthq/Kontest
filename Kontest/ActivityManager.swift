//
//  ActivityManager.swift
//  Kontest
//
//  Created by Ayush Singhal on 29/11/24.
//

#if os(iOS)
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
        
        let initialContentState: ActivityContent<KontestLiveActivityAttributes.ContentState>
        
        if let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time), let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time) {
//            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate) {
//                initialContentState = ActivityContent(state: KontestLiveActivityAttributes.ContentState(),
//                                                      staleDate: kontestStartDate,
//                                                      relevanceScore: 0)
//            } else {
//                initialContentState = ActivityContent(state: KontestLiveActivityAttributes.ContentState(),
//                                                      staleDate: kontestEndDate,
//                                                      relevanceScore: 0)
//            }
            
            initialContentState = ActivityContent(state: KontestLiveActivityAttributes.ContentState(),
                                                  staleDate: kontestEndDate,
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

            } catch {
                print("Failed to create activity with error: \(error)")
            }
        } else {
            print("Failed to create activity with error: Invalid start or end date")
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
            ActivityContent(state: initialContentState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        
        await MainActor.run {
            self.activityID = nil
            self.activityToken = nil
            self.kontest = nil
        }
    }
    
    func cancelAllRunningActivities() async {
        print("Cancelling all running activities...")
        
        for activity in Activity<KontestLiveActivityAttributes>.activities {
            let initialContentState = KontestLiveActivityAttributes.ContentState()
            
            await activity.end(
                ActivityContent(state: initialContentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        
        await MainActor.run {
            activityID = nil
            activityToken = nil
            self.kontest = nil
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
#endif
