import SwiftUI

struct AlertError: Identifiable {
    var title: String
    var message: LocalizedStringKey?
    
    public init(_ error: any Error, message: LocalizedStringKey? = nil) {
        self.title = error.localizedDescription
        self.message = message
    }
    
    public init(_ title: String, message: LocalizedStringKey? = nil) {
        self.title = title
        self.message = message
    }
    
    public var id: UUID = .init()
}

extension View {
    func alert(_ error: Binding<AlertError?>) -> some View {
        alert(item: error) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message ?? ""),
                dismissButton: nil
            )
        }
    }
}
