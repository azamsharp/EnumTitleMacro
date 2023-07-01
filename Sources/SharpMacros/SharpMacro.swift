import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

enum EnumInitError: CustomStringConvertible, Error {
    case onlyApplicableToEnum
    
    var description: String {
        switch self {
        case .onlyApplicableToEnum: return "This macro can only be applied to a enum."
        }
    }
}

public struct EnumTitleMacro: MemberMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        // this macro can only be assigned to enums
        guard let enumDel = declaration.as(EnumDeclSyntax.self) else {
            throw EnumInitError.onlyApplicableToEnum
        }
        
        let members = enumDel.memberBlock.members
        let caseDecl = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let cases = caseDecl.compactMap {
            $0.elements.first?.identifier.text
        }
        
        var title = """
        var title: String {
            switch self {
        """
        
        for titleCase in cases {
            title += "case .\(titleCase):"
            title += "return \"\(titleCase.capitalized)\""
        }
        
        title += """
            }
        }
        """
        
        return [DeclSyntax(stringLiteral: title)]
    }
    
}



@main
struct SharpPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        EnumTitleMacro.self
    ]
}
