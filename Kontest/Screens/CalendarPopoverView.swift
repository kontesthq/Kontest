//
//  CalendarPopoverView.swift
//  Kontest
//
//  Created by Ayush Singhal on 23/09/23.
//

import EventKit
import SwiftUI

struct CalendarPopoverView: View {
    let date: Date
    let kontestStartDate: Date
    @State private var selectedDate: Date
    let isAlreadySetted: Bool

    let calendarsArray = getAllCalendarsArray()

    @State private var selectedAccountIndex = 0
    @State private var selectedCalendarIndex = 0

    let onPressDelete: () -> Void
    let onPressSet: (_ setDate: Date, _ calendar: EKCalendar) -> Void

    init(
        date: Date,
        kontestStartDate: Date,
        isAlreadySetted: Bool,
        calendarName: String?,
        calendarAccount: String?,
        onPressDelete: @escaping () -> Void,
        onPressSet: @escaping (_: Date, _: EKCalendar) -> Void
    ) {
        self.date = date
        self.kontestStartDate = kontestStartDate
        self.isAlreadySetted = isAlreadySetted

        let selectedAccountIndex = calendarsArray.firstIndex { calendar in
            calendar.0 == calendarAccount
        }

        if let selectedAccountIndex {
            self._selectedAccountIndex = State(initialValue: selectedAccountIndex)

            let allCalendarsOfSelectedAccount = calendarsArray[selectedAccountIndex].1

            let selectedCalendarIndex = allCalendarsOfSelectedAccount.firstIndex { calendar in
                calendar.title == calendarName
            }

            if let selectedCalendarIndex {
                self._selectedCalendarIndex = State(initialValue: selectedCalendarIndex)
            }
        } else {
            // Choose the default calendar of device
            let defaultCalendar = CalendarUtility.getDefaultCalendarOfDevice()

            let selectedAccountIndex = calendarsArray.firstIndex { calendar in
                calendar.1.contains(defaultCalendar)
            }

            if let selectedAccountIndex {
                self._selectedAccountIndex = State(initialValue: selectedAccountIndex)

                let allCalendarsOfSelectedAccount = calendarsArray[selectedAccountIndex].1

                let selectedCalendarIndex = allCalendarsOfSelectedAccount.firstIndex { calendar in
                    calendar == defaultCalendar
                }

                if let selectedCalendarIndex {
                    self._selectedCalendarIndex = State(initialValue: selectedCalendarIndex)
                }
            }
        }

        self._selectedDate = State(initialValue: date)
        self.onPressDelete = onPressDelete
        self.onPressSet = onPressSet
    }

    var body: some View {
        VStack {
            DatePicker("Select When to Alert", selection: $selectedDate, in: .now ... kontestStartDate)

            PickerView(
                arr: calendarsArray,
                selectedAccountIndex: $selectedAccountIndex,
                selectedCalendarIndex: $selectedCalendarIndex
            )

            HStack {
                Button(role: .destructive) {
                    onPressDelete()
                } label: {
                    Text(isAlreadySetted ? "Delete" : "Cancel")
                    #if !os(macOS)
                        .foregroundStyle(.red)
                    #endif
                }

                Spacer()

                Button(isAlreadySetted ? "Change" : "Set") {
                    let selectedCalendar = calendarsArray[selectedAccountIndex].1[selectedCalendarIndex]
                    onPressSet(selectedDate, selectedCalendar)
                }
                .foregroundStyle(.blue)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct PickerView: View {
    let arr: [(String, [EKCalendar])]

    @Binding var selectedAccountIndex: Int
    @Binding var selectedCalendarIndex: Int

    var onchangeOfSelectedAccountIndex: () -> Void = {}
    var onchangeOfSelectedCalendarIndex: () -> Void = {}

    var body: some View {
        VStack {
            Picker("Select Account", selection: $selectedAccountIndex) {
                ForEach(arr.indices, id: \.self) { index in
                    Text(arr[index].0)
                        .tag(index)
                }
            }

            Picker("Select Calendar", selection: $selectedCalendarIndex) {
                let selectedAccountValue = arr[selectedAccountIndex].1

                ForEach(selectedAccountValue.indices, id: \.self) { index in
                    let calendar = selectedAccountValue[index]

                    Text("\(calendar.title)")
                        .foregroundStyle(Color(calendar.cgColor))
                        .tag(index)
                }
            }
        }
        .onChange(of: selectedAccountIndex) {
            selectedCalendarIndex = 0
            onchangeOfSelectedAccountIndex()
        }
        .onChange(of: selectedCalendarIndex) { oldValue, newValue in
            print("Changed selected calendar index from \(oldValue) to \(newValue)")
            onchangeOfSelectedCalendarIndex()
        }
    }
}

func getAllCalendarsArray() -> [(String, [EKCalendar])] {
    do {
        let dict = try CalendarUtility.getChangableCalendarsByTheirSources()

        return dict
    } catch {
        return [("Test Calendar", [])]
    }
}

#Preview {
    CalendarPopoverView(
        date: Date().addingTimeInterval(-15 * 60),
        kontestStartDate: Date().addingTimeInterval(86400),
        isAlreadySetted: true,
        calendarName: "",
        calendarAccount: ""
    ) {
        print("Delete")
    } onPressSet: { setDate, _ in
        print("setDate: \(setDate)")
    }
}
