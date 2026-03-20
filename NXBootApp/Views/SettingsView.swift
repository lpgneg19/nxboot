import SwiftUI

struct SettingsView: View {
    @AppStorage("autoInject") private var autoInject = true
    @AppStorage("defaultPayload") private var defaultPayload = "Hekate"
    @AppStorage("showNotifications") private var showNotifications = true
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Auto-Inject on Connection", isOn: $autoInject)
                Picker("Default Payload", selection: $defaultPayload) {
                    Text("Hekate").tag("Hekate")
                    Text("Fusée").tag("Fusée")
                }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Show Device Notifications", isOn: $showNotifications)
            }
            
            Section(header: Text("Advanced")) {
                Button("Clear Payload Cache") {
                    // Action
                }
            }
        }
        .padding(20)
        .frame(width: 400)
    }
}
