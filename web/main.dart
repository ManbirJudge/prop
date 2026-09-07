import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:web/web.dart' as web;

import 'package:prop/prop.dart';

void main() {
    final inBox = document.getElementById('in-box')! as web.HTMLInputElement;
    final inGroup = document.querySelector('.in-form')! as web.HTMLFormElement;
    final outBox = document.getElementById('out-box')! as web.HTMLTextAreaElement;
    final statToken = document.getElementById('stat-token')! as web.HTMLSpanElement;
    final statParse = document.getElementById('stat-parse')! as web.HTMLSpanElement;
    final statTt = document.getElementById('stat-tt')! as web.HTMLSpanElement;

    void onSubmit(SubmitEvent evt) {
        evt.preventDefault();

        Stopwatch watch = Stopwatch()..start();
        final tokens = tokenize(inBox.value);
        watch.stop();

        final timeToken = watch.elapsed.inMilliseconds;

        Context ctxt = {};

        watch = Stopwatch()..start();
        final parser = Parser(tokens: tokens);
        final formula = parse(parser, ctxt);
        watch.stop();

        final timeParse = watch.elapsed.inMilliseconds;

        final serialized = serialize(formula);

        watch = Stopwatch()..start();
        final (vars, tt) = gen_tt(formula, ctxt);
        watch.stop();
        
        final timeTt = watch.elapsed.inMilliseconds;

        // --- result ---
        String res = '';
        res += 'Formula: $serialized\n\n';
        for (var var_name in vars) {
            res += '$var_name ';
        }
        res += '| \n';
        res += List.filled(vars.length * 2 + 3, '-').join('');
        res += '\n';
        for (var (inp, out) in tt) {
            for (var var_name in vars) {
                res += '${inp[var_name]! ? 'T' : 'F'} ';
            }
            res += '| ${out ? 'T' : 'F'}\n';
        }
        outBox.value = res;

        statToken.innerText = '$timeToken';
        statParse.innerText = '$timeParse';
        statTt.innerText = '$timeTt';
    }

    inGroup.addEventListener('submit', onSubmit.toJS);
}