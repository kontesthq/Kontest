//
//  NetworkMonitor.swift
//  Kontest
//
//  Created by Ayush Singhal on 13/09/23.
//

import Foundation
public import Network
import OSLog

extension NWInterface.InterfaceType: CaseIterable {
    public static let allCases: [NWInterface.InterfaceType] = [.other, .wifi, .cellular, .loopback, .wiredEthernet]
}

extension NWPath.Status: CaseIterable {
    public static let allCases: [NWPath.Status] = [.satisfied, .unsatisfied, .requiresConnection]
}

enum AppNetworkStatus {
    case satisfied
    case unsatisfied
    case requiresConnection
    case initialPhase
}

@Observable
final class NetworkMonitor: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "NetworkMonitor")
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    var currentInterface: NWInterface.InterfaceType = .other
    var currentStatus: AppNetworkStatus = .initialPhase

    private init() {
        monitor = NWPathMonitor()
    }

    func start() {
        monitor.start(queue: queue)

        let status = monitor.currentPath.status
        logger.log("status: \("\(status)")")

        currentStatus = getAppNetworkStatus(status: status)

        monitor.pathUpdateHandler = { [weak self] path in

            guard let self else { return }

            guard let interface = NWInterface.InterfaceType.allCases.filter({ path.usesInterfaceType($0) }).first else { return }

            self.currentInterface = interface

            let status = path.status

            self.currentStatus = getAppNetworkStatus(status: status)

//            self.logger.info("Status: \("\(path.status)")")
//            self.logger.info("Interface: \("\(interface)")")
        }
    }

    func start(afterSeconds seconds: Float) {
        Task {
            monitor.start(queue: queue)

            let nanoSeconds = UInt64(seconds*1000000000)

            self.currentStatus = .satisfied
            try? await Task.sleep(nanoseconds: nanoSeconds)

            let status = monitor.currentPath.status
            logger.log("status: \("\(status)")")

            await MainActor.run {
                currentStatus = getAppNetworkStatus(status: status)
            }

            monitor.pathUpdateHandler = { [weak self] path in

                guard let self else { return }

                guard let interface = NWInterface.InterfaceType.allCases.filter({ path.usesInterfaceType($0) }).first else { return }

                self.currentInterface = interface

                let status = path.status

                self.currentStatus = getAppNetworkStatus(status: status)

//                self.logger.info("Status: \("\(path.status)")")
//                self.logger.info("Interface: \("\(interface)")")
            }
        }
    }

    func startFromWidget() async {
        monitor.start(queue: queue)

        try? await Task.sleep(nanoseconds: 2*100000000)

        let p = monitor.currentPath.status
        logger.log("p: \("\(p)")")

        currentStatus = switch p {
        case .satisfied:
            .satisfied

        case .unsatisfied:
            .unsatisfied

        case .requiresConnection:
            .requiresConnection

        @unknown default:
            .initialPhase
        }

        monitor.pathUpdateHandler = { [weak self] path in

            guard let self else { return }

            guard let interface = NWInterface.InterfaceType.allCases.filter({ path.usesInterfaceType($0) }).first else { return }

            self.currentInterface = interface

            let status = path.status

            self.currentStatus = getAppNetworkStatus(status: status)

//            self.logger.info("Status: \("\(path.status)")")
//            self.logger.info("Interface: \("\(interface)")")
        }
    }

    func stop() {
        monitor.cancel()
    }

    private func getAppNetworkStatus(status: NWPath.Status) -> AppNetworkStatus {
        return switch status {
        case .satisfied:
            .satisfied

        case .unsatisfied:
            .unsatisfied

        case .requiresConnection:
            .requiresConnection

        @unknown default:
            .initialPhase
        }
    }
}
