import SwiftUI

struct MainLayoutView: View {
    @State private var selectedTab: String? = "Dashboard"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: "Dashboard") {
                    Label(String(localized: "Dashboard"), systemImage: "gauge")
                }
                NavigationLink(value: "Payloads") {
                    Label(String(localized: "Payloads"), systemImage: "tray.and.arrow.down")
                }
                NavigationLink(value: "Hekate") {
                    Label(String(localized: "Hekate"), systemImage: "slider.horizontal.3")
                }
                
                Section(String(localized: "Help")) {
                    NavigationLink(value: "Logs") {
                        Label(String(localized: "Logs"), systemImage: "terminal")
                    }
                    NavigationLink(value: "About") {
                        Label(String(localized: "About"), systemImage: "info.circle")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("NXBoot")
        } detail: {
            if let tab = selectedTab {
                switch tab {
                case "Dashboard":
                    DashboardView()
                case "Payloads":
                    PayloadView()
                case "Hekate":
                    HekateView()
                case "Logs":
                    LogsView()
                case "About":
                    AboutView()
                default:
                    Text(String(localized: "Select an item"))
                }
            } else {
                Text(String(localized: "Dashboard"))
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
