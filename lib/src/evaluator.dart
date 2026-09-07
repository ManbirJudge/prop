import 'common.dart';

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

                return c % 2 == 1;  // if trues are odd
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