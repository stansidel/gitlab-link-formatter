//
//  GitLab_Link_FormatterApp.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import SwiftUI

@main
struct GitLab_Link_FormatterApp: App {
    static let id: String = "MainWindow"

    @Environment(\.scenePhase) var scenePhase
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup(id: Self.id) {
            ContentView()
                .environmentObject(appDelegate.contentViewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                print("App is in the background")
            } else if newPhase == .active {
                print("App is active again")
            }
        }
    }
}
