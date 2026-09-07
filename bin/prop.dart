import 'dart:core';
import 'dart:io';

// A & B
// A | B
// !A
// A -> B
// A <-> B
// A ^ B
// A & (B | !C | D) = And(A, Or(B, Not(C), D))

// ---
enum TokenType { amp, bar, ex, arrow, doubleArrow, upArrow, parenOpen, parenClose, lit }

typedef Token = (TokenType, String);

// ---
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

// ---
List<Token> tokenize(String str) {
    str = str.replaceAll(RegExp(r'\s+'), '');

    int idx = 0;
    List<Token> tokens = [];

    while (idx < str.length) {
        String char = str[idx++];
        bool done = true;

        switch (char) {
            case '&':
                tokens.add((TokenType.amp, '&'));
                break;
            case '|':
                tokens.add((TokenType.bar, '|'));
                break;
            case '!':
                tokens.add((TokenType.ex, '!'));
                break;
            case '^':
                tokens.add((TokenType.upArrow, '^'));
                break;
            case '(':
                tokens.add((TokenType.parenOpen, '('));
                break;
            case ')':
                tokens.add((TokenType.parenClose, ')'));
                break;
            case '-': {
                char = str[idx++];

                if (char == '>') {
                    tokens.add((TokenType.arrow, '->'));
                } else {
                    return tokens;
                }

                break;
            }
            case '<': {
                String a = str.substring(idx, idx + 2);
                idx += 2;

                if (a == '->') {
                    tokens.add((TokenType.doubleArrow, '<->'));
                } else {
                    return tokens;
                }

                break;
            }
            default:
                done = false;
        }

        if (done) continue;

        String name = '';
        idx--;
        while (idx < str.length && RegExp(r'^[a-zA-Z]$').hasMatch(str[idx])) {
            name += str[idx];
            idx++;
        }

        tokens.add((TokenType.lit, name));
    }

    return tokens;
}

// ---
class Parser {
    int idx = 0;
    final List<Token> tokens;

    Parser({
        required this.tokens
    }) {
        // print('${tokens.length} tokens available');
    }

    bool available() {
        return idx < tokens.length;
    }

    Token inspect() {
        // print('Inspected: ${tokens[idx]}');
        return tokens[idx];
    }

    Token consume() {
        // print('Consumed: ${tokens[idx]}');
        return tokens[idx++];
    }
}

Formula parsePrimary(Parser parser, Context ctxt) {
    if (parser.available()) {
        Token tok = parser.consume();

        if (tok.$1 == TokenType.lit) {
            if (tok.$2 == 'T') {
                return Const(val: true);
            } else if (tok.$2 == 'F') {
                return Const(val: false);
            } else {
                ctxt[tok.$2] = false;  // add variable to context with defautl value of false
                return Var(name: tok.$2);
            }
        } else if (tok.$1 == TokenType.parenOpen) {
            Formula frmla = parse(parser, ctxt);
            if (parser.consume().$1 == TokenType.parenClose) {
                return frmla;
            }
        }
    }
    throw Exception('FUCK YOU');
}

Formula parseNot(Parser parser, Context ctxt) {
    if (parser.inspect().$1 == TokenType.ex) {
        parser.consume();

        Formula sub = parsePrimary(parser, ctxt);
        return UnaryOp(type: UnaryOpType.not, sub: sub);
    }
    return parsePrimary(parser, ctxt);
}

Formula parseAnd(Parser parser, Context ctxt) {
    List<Formula> sub = [parseNot(parser, ctxt)];

    while (parser.available() && parser.inspect().$1 == TokenType.amp) {
        parser.consume();
        sub.add(parseNot(parser, ctxt));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.and, sub: sub);
    }
}

Formula parseXor(Parser parser, Context ctxt) {
    List<Formula> sub = [parseAnd(parser, ctxt)];

    while (parser.available() && (parser.inspect().$1 == TokenType.upArrow)) {
        parser.consume();
        sub.add(parseAnd(parser, ctxt));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.xor, sub: sub);
    }
}

Formula parseOr(Parser parser, Context ctxt) {
    List<Formula> sub = [parseXor(parser, ctxt)];

    while (parser.available() && (parser.inspect().$1 == TokenType.bar)) {
        parser.consume();
        sub.add(parseXor(parser, ctxt));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.or, sub: sub);
    }
}

Formula parseImplication(Parser parser, Context ctxt) {
    Formula left = parseOr(parser, ctxt);

    while (parser.available() && parser.inspect().$1 == TokenType.arrow) {
        parser.consume();
        Formula right = parseImplication(parser, ctxt);
        left = BinaryOp(type: BinOpType.implication, left: left, right: right);
    }

    return left;
}

Formula parseBiconditional(Parser parser, Context ctxt) {
    Formula left = parseImplication(parser, ctxt);

    while (parser.available() && (parser.inspect().$1 == TokenType.doubleArrow)) {
        parser.consume();
        Formula right = parseImplication(parser, ctxt);
        left = BinaryOp(type: BinOpType.biconditional, left: left, right: right);
    }

    return left;
}

Formula parse(Parser parser, Context ctxt) {
    return parseBiconditional(parser, ctxt);
}

// ---
typedef Context = Map<String, bool>;
typedef Input   = Map<String, bool>;
typedef TT      = List<(Input, bool)>;

bool eval(Formula formula, Context ctxt) {
    if (formula is Const) {
        return formula.val;
    } else if (formula is Var) {
        return ctxt[formula.name]!;
    } else if (formula is UnaryOp) {
        final sub = eval(formula.sub, ctxt);

        switch (formula.type) {
            case UnaryOpType.not: {
                return !sub;
            }
        }
    } else if (formula is BinaryOp) {
        final left = eval(formula.left, ctxt);
        final right = eval(formula.right, ctxt);

        switch (formula.type) {
            case BinOpType.implication: {
                if (!left) return true;
                else return right;
            }
            case BinOpType.biconditional: {
                return left == right;
            }
        }
    } else if (formula is VariadicOp) {
        var sub = formula.sub.map((x) => eval(x, ctxt)).toList();

        switch (formula.type) {
            case VariadicOpType.and: {
                return !sub.any((x) => !x);  // there is no false
            }
            case VariadicOpType.or: {
                return sub.any((x) => x);  // there is any true
            }
            case VariadicOpType.xor: {
                int c = 0;
                for (var x in sub) {
                    if (x) {
                        c++;
                    }
                }

                return c % 2 == 1;  // if trues are 1
            }
        }
    }

    throw Exception('FUCK YOU 2');
}

(List<String>, TT) gen_tt(Formula formula, Context ctxt) {
    final vars = ctxt.keys.toList();

    TT tt = [];

    final int n_vars = vars.length;
    final int n_combinations = 1 << n_vars;

    for (int mask = 0; mask < n_combinations; mask++) {
        Input inp = {};

        for (int i = 0; i < n_vars; i++) {
            inp[vars[n_vars - i - 1]] = ((mask >> i) & 1) == 1;
        }

        tt.add((inp, eval(formula, inp)));
    }

    return (vars, tt);
}

// ---
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

// ---
void main(List<String> args) {
    if (args.isEmpty) {
        print('Usage: prop <expression>');
        return;
    }

    Stopwatch watch = Stopwatch()..start();
    final tokens = tokenize(args.join(''));
    watch.stop();

    final timeToken = watch.elapsed.inMilliseconds;

    Context ctxt = {};

    watch = Stopwatch()..start();
    final parser = Parser(tokens: tokens);
    final formula = parse(parser, ctxt);
    watch.stop();

    final timeParse = watch.elapsed.inMilliseconds;

    watch = Stopwatch()..start();
    final out = serialize(formula);
    watch.stop();
    
    final timeSerialize = watch.elapsed.inMilliseconds;

    watch = Stopwatch()..start();
    final (vars, tt) = gen_tt(formula, ctxt);
    watch.stop();
    
    final timeTt = watch.elapsed.inMilliseconds;

    print('Formula: $out\n');

    for (var var_name in vars) {
        stdout.write('$var_name ');
    }
    print('| Output');
    print(List.filled(vars.length * 2 + 8, '-').join(''));
    for (var (inp, out) in tt) {
        for (var var_name in vars) {
            stdout.write('${inp[var_name]! ? 'T' : 'F'} ');
        }
        print('| ${out ? 'T' : 'F'}');
    }

    print('\nStats:');
    print('Tokenized in $timeToken ms.');
    print('Parsed in $timeParse ms.');
    print('Serialized in $timeSerialize ms.');
    print('Truth table generated in $timeTt ms.');
}