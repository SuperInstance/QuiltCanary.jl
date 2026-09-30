# QuiltCanary.jl

FNV-1a 64-bit for the SuperInstance fleet's polyformalism canary.

A doctrine that survives in N languages is a checkable claim. A doctrine that only
*works* is a coincidence of mood. This package is the check:

```julia
julia> using QuiltCanary

julia> QuiltCanary.canary()
0x024a555471370b18d
```

That value is the fleet-wide contract. It is produced identically by the Python,
TypeScript, Rust, C#, Bash, JS-ESM and SQL ports. **If this package's number differs
from that, the claim to polyformalism is false, and nothing else in the fleet should
be believed until it is fixed.**

## Why this port is short

`UInt64` arithmetic in Julia wraps, so the `mod 2^64` that the other ports perform with
an explicit mask happens here for free.

That is also the thing to be careful about. A port written with `Int64` would overflow
into negative numbers and **produce a different answer with no error at all** — the
signature silent-wrong-answer failure. The return type is part of the contract, which is
why `fnv1a_64` is declared `::UInt64` and why the test suite asserts on the type.

## API

```julia
fnv1a_64(s::AbstractString) -> UInt64     # FNV-1a 64 over the UTF-8 bytes of s
QuiltCanary.canary()          -> UInt64     # fnv1a_64(CANARY_INPUT)
QuiltCanary.CANARY_INPUT      = "café Δ 日本語"
QuiltCanary.CANARY_DIGEST     = 0x024a555471370b18d
```

## Tests

```
julia --project=. -e 'using Pkg; Pkg.test()'
```

13 assertions, including the cross-substrate canary, three reference vectors
cross-checked against the Python and Rust ports, the multi-byte path, a byte-wise
equivalence check (a port that hashed code points instead of bytes would fail here),
and a control that perturbs the input and requires the digest to **move** — a hash that
returns a constant would pass every other assertion in the suite.

## Cross-substrate family

| port | language | canary |
|---|---|---|
| `quilt-canary` | Python · TypeScript · Rust · C# | `0x024a555471370b18d` |
| `QuiltCanary.jl` | Julia | `0x024a555471370b18d` |

Part of the SuperInstance fleet. The substrate grows; the canary is how you know it did
not change while you weren't looking.
