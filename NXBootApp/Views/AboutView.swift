import SwiftUI

struct AboutView: View {
    @Environment(CLIInstaller.self) private var installer
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .shadow(radius: 4)
                    
                    VStack(spacing: 4) {
                        Text("NXBoot")
                            .font(.title)
                            .bold()
                        Text("\(String(localized: "Version")) 2.1.0")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Button {
                        Task {
                            do {
                                try await installer.install()
                                showingSuccess = true
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    } label: {
                        Label(String(localized: "Install CLI Tool"), systemImage: "terminal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(installer.isInstalled)
                    
                    if installer.isInstalled {
                        Text(String(localized: "CLI tool is already installed."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: 300)
                
                Spacer(minLength: 40)
                
                VStack(spacing: 2) {
                    Text("© 2018-2024 Oliver Kuckertz")
                    Text("© 2026 SteveShi")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .alert(String(localized: "Install CLI Tool"), isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(String(localized: "The CLI tool has been successfully installed to /usr/local/bin/nxboot"))
        }
        .alert(String(localized: "Install CLI Tool"), isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(String(localized: "Failed to install CLI tool: \(errorMessage)"))
        }
    }
}
