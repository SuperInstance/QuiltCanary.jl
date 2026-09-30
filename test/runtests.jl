using Test
using QuiltCanary

@testset "QuiltCanary — polyformalism across substrates" begin
    @testset "the fleet canary" begin
        # THE cross-substrate contract. Same string, same digest, in every port.
        @test QuiltCanary.canary() == QuiltCanary.CANARY_DIGEST
        @test QuiltCanary.canary() == 0x024a555471370b18d
    end

    @testset "reference vectors" begin
        # values cross-checked against the Python and Rust ports in SuperInstance/quilt-canary
        @test fnv1a_64("")       == 0xcbf29ce484222325   # offset basis, empty input
        @test fnv1a_64("a")      == 0xaf63dc4c8601ec8c
        @test fnv1a_64("foobar") == 0x85944171f73967e8
    end

    @testset "arithmetic is mod 2^64, and the TYPE enforces it" begin
        # A negative intermediate is the failure mode an Int64 port would hit silently.
        h = fnv1a_64("a")
        @test h isa UInt64
        @test h > 0
        @test fnv1a_64("é") isa UInt64          # multi-byte: exercises the UTF-8 path
        @test fnv1a_64("日本語") isa UInt64
    end

    @testset "multi-byte input matches byte-wise hashing" begin
        # If the port ever hashed code points instead of bytes, this is where it would
        # diverge from the other ports.
        s = "café Δ 日本語"
        manual = 0xcbf29ce484222325
        for b in codeunits(s)
            manual = (manual ⊻ UInt64(b)) * 0x100000001b3
        end
        @test fnv1a_64(s) == manual
        @test length(codeunits(s)) == 18   # 6 chars, 18 UTF-8 bytes
    end

    @testset "the control can fail" begin
        # A KAT that only ever confirms is decoration. Perturb the input and require
        # that the digest MOVES. If the hash were a constant this would not hold.
        @test fnv1a_64(CANARY_INPUT) != fnv1a_64(CANARY_INPUT * " ")
        @test fnv1a_64("a") != fnv1a_64("b")
    end
end
