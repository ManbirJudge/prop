import 'common.dart';

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