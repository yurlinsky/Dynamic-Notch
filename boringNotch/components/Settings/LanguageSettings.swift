import SwiftUI
import Defaults

struct LanguageSettings: View {
    @Default(.selectedLanguage) private var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    
    let availableLanguages = [
        ("English", "en"),
        ("Русский", "ru")
    ]
    
    var body: some View {
        Form {
            Section {
                Picker("Select Language", selection: $selectedLanguage) {
                    ForEach(availableLanguages, id: \.1) { language in
                        Text(language.0).tag(language.1)
                    }
                }
                .onChange(of: selectedLanguage) { oldValue, newValue in
                    UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                    
                    let alert = NSAlert()
                    alert.messageText = "Restart Required"
                    alert.informativeText = "Please restart the application to apply language changes."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "Restart Now")
                    alert.addButton(withTitle: "Later")
                    
                    let response = alert.runModal()
                    if response == .alertFirstButtonReturn {
                        // Получаем URL приложения
                        let bundleURL = Bundle.main.bundleURL
                        let appURL = bundleURL.deletingLastPathComponent().deletingLastPathComponent()
                            
                        // Создаем новый процесс
                        let task = Process()
                        let executableURL = URL(fileURLWithPath: "/usr/bin/open")
                        task.executableURL = executableURL
                        task.arguments = [appURL.path]
                        
                        do {
                            try task.run()
                            // Завершаем текущий процесс после небольшой задержки
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                NSApplication.shared.terminate(nil)
                            }
                        } catch {
                            print("Failed to restart: \(error)")
                        }
                    }
                }
            } header: {
                Text("Application Language")
            } footer: {
                Text("The app will restart to apply language changes")
                    .foregroundStyle(.secondary)
            }
        }
        .tint(Defaults[.accentColor])
        .navigationTitle("Language")
    }
}