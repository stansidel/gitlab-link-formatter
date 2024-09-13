//
//  GitLab_Link_FormatterApp.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import SwiftUI

@main
struct GitLab_Link_FormatterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MenuBarView()
                .environmentObject(appDelegate.contentViewModel)
        }
    }
}
