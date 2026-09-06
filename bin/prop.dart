import 'dart:core';

// A & B
// A | B
// !A
// A -> B
// A <-> B
// A ^ B
// A & (B | !C | D) = And(A, Or(B, Not(C), D))

// ---
enum TokenType { amp, bar, ex, arrow, doubleArrow, upArrow, parenOpen, parenClose, variable }

typedef Token = (TokenType, String);

// ---
enum UnaryOpType { not }
enum BinOpType { implication, biconditional }
enum VariadicOpType { and, or, xor }

class Formula;

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

        String varName = '';
        idx--;
        while (idx < str.length && RegExp(r'^[a-zA-Z]$').hasMatch(str[idx])) {
            varName += str[idx];
            idx++;
        }

        tokens.add((TokenType.variable, varName));
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

Formula parsePrimary(Parser parser) {
    if (parser.available()) {
        Token tok = parser.consume();

        if (tok.$1 == TokenType.variable) {
            return Var(name: tok.$2);
        } else if (tok.$1 == TokenType.parenOpen) {
            Formula frmla = parse(parser);
            if (parser.consume().$1 == TokenType.parenClose) {
                return frmla;
            }
        }
    }
    throw Exception('FUCK YOU');
}

Formula parseNot(Parser parser) {
    if (parser.inspect().$1 == TokenType.ex) {
        parser.consume();

        Formula sub = parsePrimary(parser);
        return UnaryOp(type: UnaryOpType.not, sub: sub);
    }
    return parsePrimary(parser);
}

Formula parseAnd(Parser parser) {
    List<Formula> sub = [parseNot(parser)];

    while (parser.available() && parser.inspect().$1 == TokenType.amp) {
        parser.consume();
        sub.add(parseNot(parser));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.and, sub: sub);
    }
}

Formula parseXor(Parser parser) {
    List<Formula> sub = [parseAnd(parser)];

    while (parser.available() && (parser.inspect().$1 == TokenType.upArrow)) {
        parser.consume();
        sub.add(parseAnd(parser));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.xor, sub: sub);
    }
}

Formula parseOr(Parser parser) {
    List<Formula> sub = [parseXor(parser)];

    while (parser.available() && (parser.inspect().$1 == TokenType.bar)) {
        parser.consume();
        sub.add(parseXor(parser));
    }

    if (sub.length == 1) {
        return sub[0];
    } else {
        return VariadicOp(type: VariadicOpType.or, sub: sub);
    }
}

Formula parseImplication(Parser parser) {
    Formula left = parseOr(parser);

    while (parser.available() && parser.inspect().$1 == TokenType.arrow) {
        parser.consume();
        Formula right = parseImplication(parser);
        left = BinaryOp(type: BinOpType.implication, left: left, right: right);
    }

    return left;
}

Formula parseBiconditional(Parser parser) {
    Formula left = parseImplication(parser);

    while (parser.available() && (parser.inspect().$1 == TokenType.doubleArrow)) {
        parser.consume();
        Formula right = parseImplication(parser);
        left = BinaryOp(type: BinOpType.biconditional, left: left, right: right);
    }

    return left;
}

Formula parse(Parser parser) {
    return parseBiconditional(parser);
}

// ---
String serialize(Formula formula, {bool unicode = true}) {
    String out = '';

    void y(Formula f) {
        if (f is Var) {
            out += f.name;
        } else if (f is UnaryOp) {
            out += serialize(f);
        } else {
            out += '(${serialize(f)})';
        }
    }

    if (formula is Var) {
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

    watch = Stopwatch()..start();
    final parser = Parser(tokens: tokens);
    final formula = parse(parser);
    watch.stop();

    final timeParse = watch.elapsed.inMilliseconds;

    watch = Stopwatch()..start();
    final out = serialize(formula);
    watch.stop();
    
    final timeSerialize = watch.elapsed.inMilliseconds;

    print(out);

    print('\nStats:');
    print('Tokenized in $timeToken ms.');
    print('Parsed in $timeParse ms.');
    print('Serialized in $timeSerialize ms.');
}