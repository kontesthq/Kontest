//
//  KontestLiveActivityLiveActivity.swift
//  KontestLiveActivity
//
//  Created by Ayush Singhal on 29/11/24.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct KontestLiveActivityLiveActivity: Widget {
    @Environment(\.colorScheme) private var colorScheme

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KontestLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .center) {
                HStack(alignment: .bottom) {
                    Image(KontestModel.getLogo(siteAbbreviation: context.attributes.kontest.siteAbbreviation, colorScheme: colorScheme))
                        .resizable()
                        .frame(width: 30, height: 30)

                    Text(context.attributes.kontest.name)
                }

                // Progress Bar and Ending Time
                KontestLiveActivityProgressView(context: context)
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Image(KontestModel.getLogo(siteAbbreviation: context.attributes.kontest.siteAbbreviation, colorScheme: .dark))
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Image(.kontestLogo)
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("Kontest")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, spacing: 12) {
                        // Contest Name
                        Text(context.attributes.kontest.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        // Progress Bar and Ending Time
                        KontestLiveActivityProgressView(context: context)
                    }
                    .padding(.vertical)
                }
            } compactLeading: {
                Image(KontestModel.getLogo(siteAbbreviation: context.attributes.kontest.siteAbbreviation, colorScheme: .dark))
                    .resizable()
                    .frame(width: 20, height: 20)

            } compactTrailing: {
                if let kontestStartDate = CalendarUtility.getDate(date: context.attributes.kontest.start_time), let kontestEndDate = CalendarUtility.getDate(date: context.attributes.kontest.end_time) {
                    if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate) {
                        TextTimer(kontestStartDate, font: .systemFont(ofSize: 14, weight: .bold))
                    } else if CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate, kontestEndDate: kontestEndDate) {
                        TextTimer(kontestEndDate, font: .systemFont(ofSize: 14, weight: .bold))
                    }

                } else {
                    Text("\(context.attributes.kontest.end_time)")
                }

            } minimal: {
                Image(KontestModel.getLogo(siteAbbreviation: context.attributes.kontest.siteAbbreviation, colorScheme: .dark))
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct TextTimer: View {
    // Return the largest width string for a time interval
    private static func maxStringFor(_ time: TimeInterval) -> String {
        if time < 600 { // 9:99
            return "0:00"
        }

        if time < 3600 { // 59:59
            return "00:00"
        }

        if time < 36000 { // 9:59:59
            return "0:00:00"
        }

        return "00:00:00" // 99:59:59
    }

    init(_ date: Date, font: UIFont, width: CGFloat? = nil) {
        self.date = date
        self.font = font
        if let width {
            self.width = width
        } else {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let time = date.timeIntervalSinceNow
            let maxString = Self.maxStringFor(time)
            self.width = (maxString as NSString).size(withAttributes: fontAttributes).width
        }
    }

    let date: Date
    let font: UIFont
    let width: CGFloat
    var body: some View {
        Text(timerInterval: Date.now ... date)
            .font(Font(font))
            .frame(width: width > 0 ? width : nil)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }
}

func getFormattedRelativeDate(date: Date) -> String {
    let k = getTimeDifferenceString(startDate: .now, endDate: date)

    return k
}

func getTimeDifferenceString(startDate: Date, endDate: Date) -> String {
    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: startDate, to: endDate)

    var formattedTime = ""

    if let days = components.day, days > 0 {
        formattedTime.append("\(days)d")
    } else {
        if let minutes = components.minute, minutes > 0 {
            if let hours = components.hour, hours > 0 {
                formattedTime.append("\(hours)h, \(minutes)m")
            } else {
                formattedTime.append("\(minutes)min")
            }
        } else {
            if let hours = components.hour, hours > 0 {
                formattedTime.append("\(hours)hrs")
            }
        }
    }

    return formattedTime.isEmpty ? "0H" : formattedTime
}

private extension KontestLiveActivityAttributes {
    static var preview: KontestLiveActivityAttributes {
        KontestLiveActivityAttributes(
            kontest: KontestModel(
                id: "id",
                name: "Kon Name",
//                name: "DIU Take-OFF Programming Contest Fall-24 [Preliminary - A Slot]",
                url: "http://www.apple.com",
                start_time: "December 15, 2024 03:50:00",
                end_time: "December 15, 2024 04:55:00",
                duration: "2 hours",
                site: "codechef.com",
                in_24_hours: "2 hours",
                status: KontestStatus.OnGoing,
                logo: "logo"
            )
        )
    }
}

struct KontestLiveActivityProgressView: View {
    let context: ActivityViewContext<KontestLiveActivityAttributes>

    var body: some View {
        // Progress Bar and Ending Time
        if let kontestEndDate = CalendarUtility.getDate(date: context.attributes.kontest.end_time),
           let kontestStartDate = CalendarUtility.getDate(date: context.attributes.kontest.start_time)
        {
            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)

                    Text("Starting in \(kontestStartDate, style: .relative)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate, kontestEndDate: kontestEndDate) {
                // Progress Bar
                VStack(spacing: 6) {
                    ProgressView(
                        timerInterval: kontestStartDate ... kontestEndDate,
                        countsDown: false,
                        label: { EmptyView() },
                        currentValueLabel: { EmptyView() }
                    )

                    // Time Remaining
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)

                        Text("Ending in \(kontestEndDate, style: .relative)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }

        } else {
            // Fallback if dates are missing
            Text("Ending at \(context.attributes.kontest.end_time)")
                .font(.subheadline)
                .foregroundColor(.red)
        }
    }
}

private extension KontestLiveActivityAttributes.ContentState {
    static var smiley: KontestLiveActivityAttributes.ContentState {
        KontestLiveActivityAttributes.ContentState()
    }
}

#Preview("Notification", as: .content, using: KontestLiveActivityAttributes.preview) {
    KontestLiveActivityLiveActivity()
} contentStates: {
    KontestLiveActivityAttributes.ContentState.smiley
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: KontestLiveActivityAttributes.preview) {
    KontestLiveActivityLiveActivity()
} contentStates: {
    KontestLiveActivityAttributes.ContentState.smiley
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: KontestLiveActivityAttributes.preview) {
    KontestLiveActivityLiveActivity()
} contentStates: {
    KontestLiveActivityAttributes.ContentState.smiley
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: KontestLiveActivityAttributes.preview) {
    KontestLiveActivityLiveActivity()
} contentStates: {
    KontestLiveActivityAttributes.ContentState.smiley
}
