import 'dart:core';
import 'dart:io';

import 'package:prop/prop.dart';

void main(List<String> args) {
    if (args.isEmpty) {
        print('Usage: prop <formula> [flags]');
        print('Flags:');
        print('  -no-tt\tDon\'t print truth table.');
        return;
    }

    Stopwatch watch = Stopwatch()..start();
    final tokens = tokenize(args[0]);
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

    if (!args.contains('-no-tt')) {
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
    }

    print('\nStats:');
    print('Tokenized in $timeToken ms.');
    print('Parsed in $timeParse ms.');
    print('Serialized in $timeSerialize ms.');
    print('Truth table generated in $timeTt ms.');
}