using Oceanography
using Test

@testset "Oceanography.jjl" begin
    @test coordinateFromString("1.5") == 1.5
    @test coordinateFromString("1.5n") == 1.5
    @test coordinateFromString("n1.5") == 1.5
    @test coordinateFromString("N1.5") == 1.5
    @test coordinateFromString("1 30") == 1.5
    @test coordinateFromString("1.5S") == -1.5
    @test coordinateFromString("s1 30") == -1.5
end

