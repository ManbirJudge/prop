// tokenization
enum TokenType { amp, bar, ex, arrow, doubleArrow, upArrow, parenOpen, parenClose, lit }
typedef Token = (TokenType, String);

// ast
enum UnaryOpType { not }
enum BinOpType { implication, biconditional }
enum VariadicOpType { and, or, xor }

class Formula;

class Const extends Formula {
    final bool val;

    Const({required this.val});
}

class Var extends Formula {
    final String name;

    Var({required this.name});
}

class Op extends Formula;

class UnaryOp extends Op {
    final UnaryOpType type;
    final Formula sub;

    UnaryOp({
        required this.type,
        required this.sub
    });
}

class BinaryOp extends Op {
    final BinOpType type;
    final Formula left;
    final Formula right;

    BinaryOp({
        required this.type,
        required this.left,
        required this.right
    });
}

class VariadicOp extends Op {
    final VariadicOpType type;
    final List<Formula> sub;

    VariadicOp({
        required this.type,
        required this.sub
    });
}

// evaluation
typedef Context = Map<String, bool>;
typedef Input   = Context;
typedef TT      = List<(Input, bool)>;