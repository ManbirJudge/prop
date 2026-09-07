import 'common.dart';

String serialize(Formula formula, {bool unicode = true}) {
    String out = '';

    void y(Formula f) {
        if (f is Const) {
            out += f.val ? 'T' : 'F';
        } else if (f is Var) {
            out += f.name;
        } else if (f is UnaryOp) {
            out += serialize(f);
        } else {
            out += '(${serialize(f)})';
        }
    }
    
    if (formula is Const) {
        out += formula.val ? 'T' : 'F';
    } else if (formula is Var) {
        out += formula.name;
    } else if (formula is UnaryOp) {
        switch (formula.type) {
            case UnaryOpType.not: 
                out += unicode ? '¬' : '!';
                y(formula.sub);
                break;
        }
    } else if (formula is BinaryOp) {
        String x;
        switch (formula.type) {
            case BinOpType.implication: 
                x = unicode ? '→' : '->';
                break;
            
            case BinOpType.biconditional: 
                x = unicode ? '↔' : '<->';
                break;
        }
        y(formula.left);
        out += ' $x ';
        y(formula.right);
    } else if (formula is VariadicOp) {
        String x;
        switch (formula.type) {
            case VariadicOpType.and:
                x = unicode ? '∧' : '&';
                break;
            case VariadicOpType.or:
                x = unicode ? '∨' : '|';
                break;
            case VariadicOpType.xor:
                x = unicode ? '⊕' : '^';
                break;
        }

        for (var (i, f) in formula.sub.indexed) {
            y(f);
            if (i != formula.sub.length - 1) {
                out += ' $x ';
            }
        }
    }

    return out;
}