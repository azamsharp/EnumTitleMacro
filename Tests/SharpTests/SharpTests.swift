import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SharpMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "EnumTitle": EnumTitleMacro.self
]

final class SharpTests: XCTestCase {
    
    
    func testEnumTitleMacro() {
        
        assertMacroExpansion("""
            
            @EnumTitle
            enum Genre {
                case horror
                case comedy
                case kids
                case action
            }
            
            
            """, expandedSource: """

    @EnumTitle
    enum Genre {
        case horror
        case comedy
        case kids
        case action
        
        var title: String {
            switch self {
                case .action:
                    return "Action"
                case .comedy:
                    return "Comedy"
                case .kids:
                    return "Kids"
                case .horror:
                    return "Horror"
            }
        }
    }
""" , macros: testMacros)
        
    }
    
    
    func testMacro() {
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
    }

    func testMacroWithStringLiteral() {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
    }
}
