@testset "PIP" begin
  G = small_group(8, 3) # D_4
  QG = QQ[G]
  ZG = Order(QG, basis(QG))
  I = 1 * ZG
  Hecke._assert_has_refined_wedderburn_decomposition(QG)
  fl, a = Hecke.is_principal_with_data(I, ZG, side = :right)
  @test fl
  @test a * ZG == I
  fl, a = Hecke._is_principal_with_data_bj(I, ZG, side = :right)
  @test fl
  @test a * ZG == I

  G = small_group(8, 4) # Q_8
  QG = QQ[G]
  ZG = Order(QG, basis(QG))
  I = 1 * ZG
  Hecke._assert_has_refined_wedderburn_decomposition(QG)
  fl, a = Hecke._is_principal_with_data_bj(I, ZG, side = :right)
  @test fl
  @test a * ZG == I

  G = small_group(16, 9) # Q_16
  QG = QQ[G]
  ZG = Order(QG, basis(QG))
  I = 1 * ZG
  Hecke._assert_has_refined_wedderburn_decomposition(QG)
  fl, a = Hecke._is_principal_with_data_bj(I, ZG, side = :right)
  @test fl
  @test a * ZG == I

  N = Hecke.swan_module(ZG, 3)
  fl, a = Hecke._is_principal_with_data_bj(N, ZG, side = :right)
  @test !fl

  # Issue #834
  Qx, x = QQ["x"]
  K, _a = number_field(x^2 + 15)
  OK = maximal_order(K)
  N = matrix(OK, 3, 3, OK.([1//2*_a + 1//2, 0, 1,
                            1//2*_a + 3//2, 1//2*_a + 3//2, 1//2*_a + 1//2,
                            0, 1, 1//2*_a + 1//2]))

  I = 2 * OK
  R, = quo(OK, I)
  mats = Hecke._write_as_product_of_elementary_matrices(N, R)
  @test map_entries(R, reduce(*, mats)) == map_entries(R, N)

  # zero algebra
  A = zero_algebra(QQ)
  M = maximal_order(A)
  F = 1 * M
  reps = Hecke.__unit_reps_simple(M, F)
  @test length(reps) <= 1
  reps = Hecke._unit_group_generators_maximal_simple(M)
  @test length(reps) <= 1

  include("PIP/unit_group_generators.jl")

  let
    # Something bad
    # Q_{40}
    G = MultTableGroup([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40;
                        2 6 1 7 8 13 14 15 3 4 5 16 21 22 23 24 9 10 11 12 29 30 31 32 17 18 19 20 37 38 39 40 25 26 27 28 36 35 34 33;
                        3 1 9 10 11 2 4 5 17 18 19 20 6 7 8 12 25 26 27 28 13 14 15 16 33 34 35 36 21 22 23 24 40 39 38 37 29 30 31 32;
                        4 10 7 12 1 18 20 3 14 16 2 5 26 28 9 11 22 24 6 8 34 36 17 19 30 32 13 15 39 37 25 27 38 40 21 23 31 29 33 35;
                        5 11 8 1 12 19 3 20 15 2 16 4 27 9 28 10 23 6 24 7 35 17 36 18 31 13 32 14 38 25 37 26 39 21 40 22 30 33 29 34;
                        6 13 2 14 15 21 22 23 1 7 8 24 29 30 31 32 3 4 5 16 37 38 39 40 9 10 11 12 36 35 34 33 17 18 19 20 28 27 26 25;
                        7 4 14 16 2 10 12 1 22 24 6 8 18 20 3 5 30 32 13 15 26 28 9 11 38 40 21 23 34 36 17 19 35 33 29 31 39 37 25 27;
                        8 5 15 2 16 11 1 12 23 6 24 7 19 3 20 4 31 13 32 14 27 9 28 10 39 21 40 22 35 17 36 18 34 29 33 30 38 25 37 26;
                        9 3 17 18 19 1 10 11 25 26 27 28 2 4 5 20 33 34 35 36 6 7 8 12 40 39 38 37 13 14 15 16 32 31 30 29 21 22 23 24;
                        10 18 4 20 3 26 28 9 7 12 1 11 34 36 17 19 14 16 2 5 39 37 25 27 22 24 6 8 31 29 33 35 30 32 13 15 23 21 40 38;
                        11 19 5 3 20 27 9 28 8 1 12 10 35 17 36 18 15 2 16 4 38 25 37 26 23 6 24 7 30 33 29 34 31 13 32 14 22 40 21 39;
                        12 16 20 5 4 24 8 7 28 11 10 1 32 15 14 2 36 19 18 3 40 23 22 6 37 27 26 9 33 31 30 13 29 35 34 17 25 39 38 21;
                        13 21 6 22 23 29 30 31 2 14 15 32 37 38 39 40 1 7 8 24 36 35 34 33 3 4 5 16 28 27 26 25 9 10 11 12 20 19 18 17;
                        14 7 22 24 6 4 16 2 30 32 13 15 10 12 1 8 38 40 21 23 18 20 3 5 35 33 29 31 26 28 9 11 27 25 37 39 34 36 17 19;
                        15 8 23 6 24 5 2 16 31 13 32 14 11 1 12 7 39 21 40 22 19 3 20 4 34 29 33 30 27 9 28 10 26 37 25 38 35 17 36 18;
                        16 24 12 8 7 32 15 14 20 5 4 2 40 23 22 6 28 11 10 1 33 31 30 13 36 19 18 3 25 39 38 21 37 27 26 9 17 34 35 29;
                        17 9 25 26 27 3 18 19 33 34 35 36 1 10 11 28 40 39 38 37 2 4 5 20 32 31 30 29 6 7 8 12 24 23 22 21 13 14 15 16;
                        18 26 10 28 9 34 36 17 4 20 3 19 39 37 25 27 7 12 1 11 31 29 33 35 14 16 2 5 23 21 40 38 22 24 6 8 15 13 32 30;
                        19 27 11 9 28 35 17 36 5 3 20 18 38 25 37 26 8 1 12 10 30 33 29 34 15 2 16 4 22 40 21 39 23 6 24 7 14 32 13 31;
                        20 12 28 11 10 16 5 4 36 19 18 3 24 8 7 1 37 27 26 9 32 15 14 2 29 35 34 17 40 23 22 6 21 38 39 25 33 31 30 13;
                        21 29 13 30 31 37 38 39 6 22 23 40 36 35 34 33 2 14 15 32 28 27 26 25 1 7 8 24 20 19 18 17 3 4 5 16 12 11 10 9;
                        22 14 30 32 13 7 24 6 38 40 21 23 4 16 2 15 35 33 29 31 10 12 1 8 27 25 37 39 18 20 3 5 19 17 36 34 26 28 9 11;
                        23 15 31 13 32 8 6 24 39 21 40 22 5 2 16 14 34 29 33 30 11 1 12 7 26 37 25 38 19 3 20 4 18 36 17 35 27 9 28 10;
                        24 32 16 15 14 40 23 22 12 8 7 6 33 31 30 13 20 5 4 2 25 39 38 21 28 11 10 1 17 34 35 29 36 19 18 3 9 26 27 37;
                        25 17 33 34 35 9 26 27 40 39 38 37 3 18 19 36 32 31 30 29 1 10 11 28 24 23 22 21 2 4 5 20 16 15 14 13 6 7 8 12;
                        26 34 18 36 17 39 37 25 10 28 9 27 31 29 33 35 4 20 3 19 23 21 40 38 7 12 1 11 15 13 32 30 14 16 2 5 8 6 24 22;
                        27 35 19 17 36 38 25 37 11 9 28 26 30 33 29 34 5 3 20 18 22 40 21 39 8 1 12 10 14 32 13 31 15 2 16 4 7 24 6 23;
                        28 20 36 19 18 12 11 10 37 27 26 9 16 5 4 3 29 35 34 17 24 8 7 1 21 38 39 25 32 15 14 2 13 30 31 33 40 23 22 6;
                        29 37 21 38 39 36 35 34 13 30 31 33 28 27 26 25 6 22 23 40 20 19 18 17 2 14 15 32 12 11 10 9 1 7 8 24 16 5 4 3;
                        30 22 38 40 21 14 32 13 35 33 29 31 7 24 6 23 27 25 37 39 4 16 2 15 19 17 36 34 10 12 1 8 11 9 28 26 18 20 3 5;
                        31 23 39 21 40 15 13 32 34 29 33 30 8 6 24 22 26 37 25 38 5 2 16 14 18 36 17 35 11 1 12 7 10 28 9 27 19 3 20 4;
                        32 40 24 23 22 33 31 30 16 15 14 13 25 39 38 21 12 8 7 6 17 34 35 29 20 5 4 2 9 26 27 37 28 11 10 1 3 18 19 36;
                        33 25 40 39 38 17 34 35 32 31 30 29 9 26 27 37 24 23 22 21 3 18 19 36 16 15 14 13 1 10 11 28 12 8 7 6 2 4 5 20;
                        34 39 26 37 25 31 29 33 18 36 17 35 23 21 40 38 10 28 9 27 15 13 32 30 4 20 3 19 8 6 24 22 7 12 1 11 5 2 16 14;
                        35 38 27 25 37 30 33 29 19 17 36 34 22 40 21 39 11 9 28 26 14 32 13 31 5 3 20 18 7 24 6 23 8 1 12 10 4 16 2 15;
                        36 28 37 27 26 20 19 18 29 35 34 17 12 11 10 9 21 38 39 25 16 5 4 3 13 30 31 33 24 8 7 1 6 22 23 40 32 15 14 2;
                        37 36 29 35 34 28 27 26 21 38 39 25 20 19 18 17 13 30 31 33 12 11 10 9 6 22 23 40 16 5 4 3 2 14 15 32 24 8 7 1;
                        38 30 35 33 29 22 40 21 27 25 37 39 14 32 13 31 19 17 36 34 7 24 6 23 11 9 28 26 4 16 2 15 5 3 20 18 10 12 1 8;
                        39 31 34 29 33 23 21 40 26 37 25 38 15 13 32 30 18 36 17 35 8 6 24 22 10 28 9 27 5 2 16 14 4 20 3 19 11 1 12 7;
                        40 33 32 31 30 25 39 38 24 23 22 21 17 34 35 29 16 15 14 13 9 26 27 37 12 8 7 6 3 18 19 36 20 5 4 2 1 10 11 28])

    x = G[2]
    QG = QQ[G]
    xx = QG(x)
    ZG = Hecke.integral_group_ring(QG)
    Lambda, m = Hecke.quotient_order(ZG, (xx^10 + 1)*ZG)
    A = codomain(m)
    Aop, AtoAop = opposite_algebra(A)
    cens = Vector{QQFieldElem}[
            [25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [15, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [13, 0, 0, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 24, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [24, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 24, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [14, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 6, 2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [16, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
            [10, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
            [0, 23, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
            [23, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
            [0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
            [0, 17, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
            [12, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
            [18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
            [0, 20, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]]
    Mgens = Aop.(cens);
    Lambdaop = AtoAop(Lambda)
    M = Hecke.ideal_from_lattice_gens(Aop, Lambdaop, Mgens)
    @test M * Lambdaop == M
    fl, alpha = Hecke._is_principal_with_data_bj(M * Lambdaop, Lambdaop; side = :right)
    @test fl
    @test alpha * Lambdaop == M
  end
end
