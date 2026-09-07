# prop
Propositional logic truth table calculator.

## Capabilities
- NOT, AND, OR, XOR, IMPLICATION, BICONDITIONAL, variables and constants.
- Handles presedence.
- Any number of variables.
- ASCII input, unicode pretty-print output.

## Examples
Build using `dart compile exe bin/prop.dart -o prop`.<br>
Usage example:
```
>$ ./prop '(p & (q -> r)) -> (p | !r)'
Formula: (p ∧ (q → r)) → (p ∨ ¬r)

p q r | Output
--------------
F F F | T
F F T | T
F T F | T
F T T | T
T F F | T
T F T | T
T T F | T
T T T | T

Stats:
Tokenized in 0 ms.
Parsed in 0 ms.
Serialized in 0 ms.
Truth table generated in 0 ms.
```

## TODOs
- Organize code in the 'dart way'.
- 0/1 output option.
- Unicode input?
- Web or UI?