"""
    QuiltCanary

FNV-1a 64-bit, the fleet's substrate-wide canary.

Every polyformalism port must produce the same digest for the same bytes. That is the
whole point: a doctrine that survives in N languages is a checkable claim, and a doctrine
that only *works* is a coincidence of mood.
"""
module QuiltCanary

export fnv1a_64, CANARY_INPUT, CANARY_DIGEST, canary

const FNV_OFFSET_BASIS = 0xcbf29ce484222325
const FNV_PRIME         = 0x100000001b3
const MASK64            = typemax(UInt64)

"""
    fnv1a_64(s::AbstractString) -> UInt64

FNV-1a 64-bit over the UTF-8 bytes of `s`.

`UInt64` arithmetic wraps, so the `mod 2^64` that the reference implementations do with
an explicit mask happens here for free — which is why this port is short and why it is
*also* the reason to be careful: a Julia port that used `Int64` would silently go negative
and produce a different number with no error at all. The type is the contract.
"""
function fnv1a_64(s::AbstractString)::UInt64
    h = FNV_OFFSET_BASIS
    for b in codeunits(s)          # codeunits yields UTF-8 bytes, matching .encode("utf-8")
        h = (h ⊻ UInt64(b)) * FNV_PRIME   # wraps mod 2^64 by construction
    end
    return h
end

const CANARY_INPUT  = "café Δ 日本語"
const CANARY_DIGEST = UInt64(0x024a555471370b18d)

"""
    canary() -> UInt64

The fleet canary digest. If this differs from `CANARY_DIGEST`, the substrate's claim to
polyformalism is false, and no other statement in this repository should be believed until
that is fixed.
"""
canary() = fnv1a_64(CANARY_INPUT)

end # module
