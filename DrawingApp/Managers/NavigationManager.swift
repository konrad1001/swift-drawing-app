//
//  NavigationManager.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//

import Observation
import SwiftUI

@Observable final class NavigationManager {
    var path = NavigationPath()
    var isUploadedPresented: Bool = false

    var homePageIsActive: Bool = true

    var scrollFocusID: UUID?

    func navigateOnto(page: Page) {
        path.append(page)
    }

    func navigateBack() {
        path.removeLast()
    }

    func navigateToRoot() {
        path = NavigationPath()
    }
}


