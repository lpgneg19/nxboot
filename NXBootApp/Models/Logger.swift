import Foundation
import Observation

@Observable
class Logger {
    static let shared = Logger()
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp = Date()
        let message: String
        let type: LogType
    }
    
    enum LogType {
        case system
        case device
    }
    
    var systemLogs: [LogEntry] = []
    var deviceLogs: [LogEntry] = []
    
    private init() {
        // Handle logs from Objective-C
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NXLogNotification"), object: nil, queue: .main) { notification in
            if let message = notification.userInfo?["message"] as? String {
                self.addLog(message, type: .system)
            }
        }
    }
    
    func addLog(_ message: String, type: LogType) {
        let entry = LogEntry(message: message, type: type)
        switch type {
        case .system:
            systemLogs.append(entry)
            if systemLogs.count > 500 { systemLogs.removeFirst() }
        case .device:
            deviceLogs.append(entry)
            if deviceLogs.count > 1000 { deviceLogs.removeFirst() }
        }
    }
    
    func clear(type: LogType) {
        switch type {
        case .system: systemLogs.removeAll()
        case .device: deviceLogs.removeAll()
        }
    }
}
