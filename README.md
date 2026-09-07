# prop
Propositional logic truth table calculator.

## Usage
- `prop <formula>`
- Symbols:
  - `!` for NOT
  - `&` for AND
  - `|` for OR
  - `^` for XOR
  - `->` for IMPLICATION
  - `<->` for BICONDITIONAL

## Capabilities
- NOT, AND, OR, XOR, IMPLICATION, BICONDITIONAL, variables and constants.
- Handles presedence.
- Any number of variables.
- ASCII input, unicode pretty-print output.

## Example
```
>$ ./prop '(p & (q -> r)) -> (p | !r)'
Formula: (p ∧ (q → r)) → (p ∨ ¬r)

p q r | 
---------
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
- ~~Organize code in the 'dart way'.~~
- Error handling.
- 0/1 output option.
- Unicode input?
- Web:
  - Buttons for input
  - HTML table for output
  - List of symbols
  - ~~Mobile responsive~~
  - ~~PWA~~