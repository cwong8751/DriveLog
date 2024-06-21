import SwiftUI

struct KeepScreenOn: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

extension View {
    func keepScreenOn() -> some View {
        self.modifier(KeepScreenOn())
    }
}
