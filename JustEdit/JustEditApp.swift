//
//  JustEditApp.swift
//  JustEdit
//
//  Created by Nguyen Quang Minh on 5/3/26.
//

import SwiftUI

@main
struct JustEditApp: App {
    @State private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            DocumentBrowserView()
                .preferredColorScheme(settings.preferredColorScheme)
                .tint(AppTheme.primary)
        }
    }
}
