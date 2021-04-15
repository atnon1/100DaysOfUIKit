import UIKit

let string = "This is a test string"
let attributedString = NSMutableAttributedString(string: string)

attributedString.addAttribute(.font,value: UIFont.boldSystemFont(ofSize: 40) ,range: NSRange(location: 4, length: 5))

string.withPrefix("This")


extension String {
    /// Returns 'self' if has prefix; returns self with added prefix otherwise
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        } else {
            return prefix + self
        }
    }
    /// Returns 'true' if represents a number
    func isNumeric() -> Bool {
        if Double(self) == nil {
            return false
        }
        return true
    }
    
    /// Returns array of parts of 'self' devided to lines
    var lines: [String] {
        return self.split(separator: "\n").map { String($0) }
    }
}

"sgdsg".isNumeric()
"8888.0234".isNumeric()
"888.332.33".isNumeric()
"""
dsgsdg
dsgdsgds
sdgdsg
""".lines
"this\nis\na\ntest".lines
"dsgkljgksdgjdsg".lines
let j = """
dsgsdg\njldsgsdg
dsgsdg
\n
sdggds
"""
j.lines
