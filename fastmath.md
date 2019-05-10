
```
a = rand(10^7)
```

### 1. Julia hand-written
```
function mysum(A)
    s = 0.0
    for a in A
        s += a
    end
    return s
end
```
12s

### 2. Julia built-in
```
sum(a)
```
6s

### 3. Julia hand-written w/ @fastmath
```
function mysum_fast(A)
    s = 0.0
    for a in A
        @fastmath s += a
    end
    s
end
```
6s

### 4. @fastmath
The `for` loop

```julia
for a in A
    s += a
end
```

defines a very strict _order_ to the summation: Julia follows exactly what you
wrote and adds the elements of `A` to the result `s` in the order it iterates.
Since floating point numbers aren't associative, a rearrangement here would
change the answer — and Julia is loathe to give you different answer than
the one you asked for.

You can, however, tell Julia to relax that rule and allow for associativity
with the `@fastmath` macro. This might allow Julia to rearrange the sum in an
advantageous manner.

