import Foundation

struct Glyphs {
    private(set) var charaters: [Character]
    
    private init(charaters: [Character]) {
        self.charaters = charaters
    }
}

extension Glyphs: Equatable {
    static func == (lhs: Glyphs, rhs: Glyphs) -> Bool {
        lhs.charaters == rhs.charaters
    }
}

extension Glyphs {
    static let ascii: Self = .init(charaters: [
        "$", "@", "B", "%", "8", "&", "W", "M", "#", "*", "o", "a", "h", "k", "b", "d", "p", "q", "w", "m",
        "Z", "O", "0", "Q", "L", "C", "J", "U", "Y", "X", "z", "c", "v", "u", "n", "x", "r", "j", "f", "t",
        "/", "\\", "|", ")", "(", "1", "}", "{", "]", "[", "?", "-", "_", "+", "~", ">", "<", "i", "!", "l",
        "I", ";", ":", ",", "\"", "^", "`", "\\", "\'", ".", " ", " ", " ", " ", " "
    ])
}
