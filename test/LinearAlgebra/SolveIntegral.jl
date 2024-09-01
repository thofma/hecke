@testset "Solve over maximal orders" begin
  K, a = quadratic_field(-13)
  OK = ring_of_integers(K)
  alpha = 1 + a
  beta = 2
  M = OK[alpha; beta;]
  K = kernel(M)
  @test is_zero(K * M)
  @test nrows(K) >= 2 # the ideal (alpha, beta) is not principal, hence the
                      # kernel is not generated by one elements

  for b in (matrix(OK, 1, 1, [alpha + beta]), OK.([alpha + beta]))
    b = matrix(OK, 1, 1, [alpha + beta])
    fl, X, K = can_solve_with_solution_and_kernel(M, b; side = :left)
    @assert fl
    @assert X * M == b
    @assert is_zero(K * M)
  end
  for b in (matrix(OK, 1, 1, [one(OK)]), [OK(1)])
    fl = can_solve(M, b; side = :left)
    @test !fl
    fl, X = can_solve_with_solution(M, b; side = :left)
    @test !fl
  end

  M = OK[alpha beta;]
  K = kernel(M; side = :right)
  @test is_zero(M * K)
  @test ncols(K) >= 2
  b = matrix(OK, 1, 1, [alpha + beta])
  fl, X, K = can_solve_with_solution_and_kernel(M, b; side = :right)
  @assert fl
  @assert M * X == b
  @assert is_zero(M * K)
  b = matrix(OK, 1, 1, [one(OK)])
  fl = can_solve(M, b; side = :right)
  @test !fl
  fl, X = can_solve_with_solution(M, b; side = :right)
  @test !fl

  for i in 1:10
    n = rand(1:5)
    m = rand(1:5)
    k = rand(1:5)
    A = rand(matrix_space(OK, n, m), 5)
    X = rand(matrix_space(OK, k, n), 5)
    B = X * A
    fl, v = can_solve_with_solution(A, B, side = :left)
    @assert fl
    @assert v * A == B

    X = rand(matrix_space(OK, m, k), 5)
    B = A * X
    fl, v = can_solve_with_solution(A, B, side = :right)
    @assert fl
    @assert A * v == B
  end
end
