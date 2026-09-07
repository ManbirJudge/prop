import 'common.dart';

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