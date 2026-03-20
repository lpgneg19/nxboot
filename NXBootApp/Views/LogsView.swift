import SwiftUI

struct LogsView: View {
    @Environment(Logger.self) private var logger
    @State private var selectedLogType: Logger.LogType = .system
    @Namespace private var bottomID
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    let logs = selectedLogType == .system ? logger.systemLogs : logger.deviceLogs
                    ForEach(logs) { entry in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(entry.timestamp, style: .time)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(entry.message)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }
                .listStyle(.plain)
                .onChange(of: selectedLogType == .system ? logger.systemLogs.count : logger.deviceLogs.count) { _ in
                    withAnimation {
                        proxy.scrollTo(bottomID)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $selectedLogType) {
                    Text(String(localized: "System")).tag(Logger.LogType.system)
                    Text(String(localized: "Serial (EP1)")).tag(Logger.LogType.device)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { logger.clear(type: selectedLogType) }) {
                    Label(String(localized: "Clear Logs"), systemImage: "trash")
                }
                .help(String(localized: "Clear Logs"))
            }
        }
        .navigationTitle(String(localized: "Logs"))
    }
}
