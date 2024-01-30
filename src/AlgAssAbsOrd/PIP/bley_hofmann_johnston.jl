################################################################################
#
#  Bley--Johnston--Hofmann algorithm
#
################################################################################

# This is the algorithm from
# Computation of lattice isomorphisms and the integral matrix similarity problem
# Note that the implementation is for right ideals, while the paper describes
# it for left ideals.

function _is_principal_with_data_bhj(a::AlgAssAbsOrdIdl, O; side = :right)
  # only implemented for right ideals
  @assert side === :right
  if O != right_order(a)
    return false, zero(algebra(O))
  end

  if is_maximal(O)
    return _isprincipal_maximal(a, O, side)
  end

  # So O is the right order of a

  n = dim(algebra(O))
  aa = denominator(a, O) * a
  aa.order = O
  for (p, ) in factor(discriminant(O))
    @vprintln :PIP 1 "Testing local freeness at $p"
    if !is_locally_free(O, aa, p, side = :right)[1]::Bool
      return false, zero(algebra(O))
    end
  end

  # So a is locally free over O

  A = algebra(O)
  #@show [isdefined(B, :isomorphic_full_matrix_algebra) for (B, mB) in decompose(A)]
  OA = maximal_order(O)
  Z, ZtoA = center(A)
  Fl = conductor(O, OA, :left)

  FinZ = _as_ideal_of_smaller_algebra(ZtoA, Fl)
  # Compute FinZ*OA but as an ideal of O
  bOA = basis(OA, copy = false)
  bFinZ = basis(FinZ, copy = false)
  basis_F = Vector{elem_type(A)}()
  for x in bOA
    for y in bFinZ
      yy = ZtoA(y)
      t = yy * elem_in_algebra(x, copy = false)
      push!(basis_F, t)
    end
  end

  for b in basis_F
    @assert b in O
  end

  F = ideal_from_lattice_gens(A, O, basis_F, :twosided)

  #@show F == A(1) * O
  #@show F == A(1) * OA

  aorig = a

  # I should improve this
  a, sca = _coprime_integral_ideal_class_deterministic(a, F)
  #a, sca = _coprime_integral_ideal_class(a, F)
  @vprintln :PIP 1 "Found coprime integral ideal class"

  @hassert :PIP 1 sca * aorig == a

  @hassert :PIP 1 a + F == one(A) * O

  # Compute K_1(O/F) and the subgroup of R generated by nr(a)*OZ for a in k1 where
  # nr is the reduced norm and OZ the maximal order in Z
  @vprintln :PIP 1 "Lifting ideal to maximal order"
  aOA = a * OA #sum([b * OA for b in basis(a)])
  @vprintln :PIP 1 "Testing if principal over maximal order"
  fl, beta = _isprincipal_maximal(aOA, OA, side)
  if !fl
    return false, zero(A)
  end
  @hassert :PIP 1 beta * OA == aOA

  @vprintln :PIP "Computing K1..."
  #@show F, FinZ
  k1 = K1_order_mod_conductor(O, OA, F, FinZ)
  OZ = maximal_order(Z)
  Q, mQ = quo(OZ, FinZ)
  Quni, mQuni = unit_group(Q)
  U::GrpAbFinGen, mU::MapUnitGrp{Hecke.AlgAssAbsOrd{AlgAss{QQFieldElem},AlgAssElem{QQFieldElem,AlgAss{QQFieldElem}}}} = unit_group(OZ)
  @vprintln :PIP 1 "Solving principal ideal problem over maximal order..."

  #@show Q
  normbeta = OZ(normred_over_center(beta, ZtoA))

  #@show parent(normbeta) == domain(mQ)
  ttt = mQuni\(mQ(normbeta))
  imgofK1 = GrpAbFinGenElem[ mQuni\(mQ(OZ(normred_over_center(elem_in_algebra(b), ZtoA)))) for b in k1]
  imgofK1assub, m_imgofK1assub = sub(Quni, imgofK1)
  QbyK1, mQbyK1 = quo(Quni, imgofK1)

  SS, mSS = sub(Quni, imgofK1)

  # This is O_C^* in Q/K1
  S, mS = sub(QbyK1, elem_type(QbyK1)[ mQbyK1(mQuni\(mQ(mU(U[i])::elem_type(OZ)))) for i in 1:ngens(U)])
  fl, u = has_preimage_with_preimage(mS, mQbyK1(ttt))
  if !fl
    return false, zero(A)
  end

  @vprintln :PIP 1 "Solving norm requation over center"
  #@show typeof(OA)
  #@show typeof(ZtoA(elem_in_algebra(mU(u)::elem_type(OZ))))
  _u = prod([ mU(U[i])^u.coeff[1, i] for i in 1:length(u.coeff)])
  UU = _solve_norm_equation_over_center(OA, ZtoA(elem_in_algebra(_u::elem_type(OZ))))

  fll, uu = has_preimage_with_preimage(mSS,  mQuni\(mQ(OZ(normred_over_center(elem_in_algebra(UU), ZtoA)))) - ttt)

  @assert fll

  elemA = one(A)
  for i in 1:length(uu.coeff)
    if !iszero(uu.coeff[1, i])
      elemA = elemA * elem_in_algebra(k1[i])^Int(uu.coeff[1, i])
    end
  end

  ##@show mQuni\(mQ(OZ(normred_over_center(elem_in_algebra(UU), ZtoA)))) ==  mQuni\(mQ(OZ(normred_over_center(beta * elemA, ZtoA))))

  @vprintln :PIP "Lifting to norm one unit"
  V = lift_norm_one_unit( UU^(-1) * OA(elemA)  * OA(beta), F)

  gamma =  beta * inv(elem_in_algebra(UU) * V)
  @hassert :PIP 1 gamma * O == a
  gammaorig = inv(sca) * gamma
  @assert gammaorig * O == aorig

  return true, gammaorig
end

function _solve_norm_equation_over_center(M, x)
  A = algebra(M)
  dec = decompose(A)
  #@show x
  Mbas = basis(M)
  sol = zero(M)
  for i in 1:length(dec)
    Ai, mAi = dec[i]
    MinAi = Order(Ai, [ mAi\(mAi(one(Ai)) * elem_in_algebra(b)) for b in Mbas])
    si = _solve_norm_equation_over_center_simple(MinAi, preimage(mAi, x))
    sol += M(mAi(elem_in_algebra(si)))
  end
  ZA, ZAtoA = center(A)
  @assert ZAtoA(normred_over_center(elem_in_algebra(sol), ZAtoA)) == x
  return sol
end

function _solve_norm_equation_over_center_simple(M, x)
  A = algebra(M)
  if isdefined(A, :isomorphic_full_matrix_algebra)
    local B::AlgMat{AbsSimpleNumFieldElem, Generic.MatSpaceElem{AbsSimpleNumFieldElem}}
    @assert isdefined(A, :isomorphic_full_matrix_algebra)
    B, AtoB = A.isomorphic_full_matrix_algebra
    Mbas = absolute_basis(M)
    MinB = _get_order_from_gens(B, elem_type(B)[ AtoB(elem_in_algebra(b))::elem_type(B) for b in Mbas])
    y = Hecke._solve_norm_equation_over_center_full_matrix_algebra(MinB, AtoB(x)::elem_type(B))
    sol = M(AtoB\elem_in_algebra(y))
    ZA, ZAtoA = center(A)
    @assert ZAtoA(normred_over_center(elem_in_algebra(sol), ZAtoA)) == x
    return sol
  elseif degree(A) == 4 && !is_split(A)
    return _solve_norm_equation_over_center_quaternion(M, x)
  else
    throw(NotImplemented())
  end
end

function _solve_norm_equation_over_center_quaternion(M, x)
  A = algebra(M)
  !(base_ring(A) isa QQField) && error("Only implemented for rational quaternion algebras")
  B = basis_alg(M)
  G = zero_matrix(FlintQQ, 4, 4)
  f = standard_involution(A)
  for i in 1:4
    for j in 1:4
      G[i, j] = FlintZZ(trred(B[i] * f(B[j])))//2
    end
  end
  # TODO: Replace this by short_vectors_gram(M, nrr) once it works
  i = 0
  xalg = x
  local nrm
  for i in 1:dim(A)
    if !iszero(xalg.coeffs[i])
      nrm = FlintZZ(divexact(xalg.coeffs[i], one(A).coeffs[i]))
    end
  end
  #@show nrm
  V = _short_vectors_gram(Vector, G, nrm)
  for i in 1:length(V)
    if V[i][2] == nrm
      y = sum(V[i][1][j] * B[j] for j in 1:4)
      @assert normred(y) == nrm
      return M(y)
    end
  end
end

function _solve_norm_equation_over_center_full_matrix_algebra(M, x)
  A = algebra(M)
  ZA, ZAtoA = center(A)
  if degree(A) == 1
    @assert ZAtoA(normred_over_center(x, ZAtoA)) == x
    return M(x)
  elseif degree(base_ring(A)) == 1
    B, BtoA = _as_full_matrix_algebra_over_Q(A)
    MB = Order(B, [(BtoA\elem_in_algebra(b))::elem_type(B) for b in absolute_basis(M)])
    xinB = BtoA\x
    solB = _solve_norm_equation_over_center_full_rational_matrix_algebra(MB, xinB)
    sol = M(BtoA(elem_in_algebra(solB))::elem_type(A))
    @assert ZAtoA(normred_over_center(elem_in_algebra(sol), ZAtoA)) == x
    return sol
  else
    N, S = nice_order(M)
    xN = S * x * inv(S)
    solN = _solve_norm_equation_over_center_full_matrix_algebra_nice(N, xN)
    sol = inv(S) * elem_in_algebra(solN) * S
    @assert sol in M
    @assert ZAtoA(normred_over_center(sol, ZAtoA)) == x
    return M(sol)
  end
  throw(NotImplemented())
end

function _solve_norm_equation_over_center_full_rational_matrix_algebra(M, x)
  A = algebra(M)
  R, c = nice_order(M)
  e11 = elem_in_algebra(basis(R)[1])
  u = x
  sol = one(A)
  sol[1, 1] = u[1, 1]
  z = R(sol)
  ZA, ZAtoA = center(A)
  @assert ZAtoA(normred_over_center(elem_in_algebra(z), ZAtoA)) == u
  soladj = inv(c) * sol * c
  @assert soladj in M
  @assert ZAtoA(normred_over_center(soladj, ZAtoA)) == x
  return M(soladj)
end

function _solve_norm_equation_over_center_full_matrix_algebra_nice(M, x)
  A = algebra(M)
  e11 = basis(A)[1]
  u = x
  sol = one(A)
  sol[1, 1] = u[1, 1]
  ZA, ZAtoA = center(A)
  @assert ZAtoA(normred_over_center(sol, ZAtoA)) == x
  return M(sol)
end

function lift_norm_one_unit(x, F)
  # F must be central
  M = parent(x)
  A = algebra(M)
  res = decompose(A)
  Mbas = basis(M)
  z = zero(A)
  #@show F
  for i in 1:length(res)
    Ai, AitoA = res[i]
    MinAi = Order(Ai, elem_type(Ai)[ AitoA\(AitoA(one(Ai)) * elem_in_algebra(b)) for b in Mbas])
    xinAi = MinAi(preimage(AitoA, elem_in_algebra(x)))
    Fi = ideal_from_lattice_gens(Ai, MinAi, [ AitoA\b for b in basis(F) ], :twosided)
    #@show Fi
    y = _lift_norm_one_unit_simple(xinAi, Fi)
    z += AitoA(y)
  end
  FinM = ideal_from_lattice_gens(A, M, basis(F), :twosided)
  @assert _test_ideal_sidedness(FinM, M, :left)
  Q, mQ = quo(M, FinM)
  @assert mQ(M(z)) == mQ(x)
  #@show normred(z)
  return z
end

function _lift_norm_one_unit_simple(x, F)
  M = parent(x)
  A = algebra(M)
  # It may happen that the order is maximal in a simple component, that is,
  # F == M
  if F == one(A) * M
    return one(A)
  end
  if isdefined(A, :isomorphic_full_matrix_algebra)
    local B::AlgMat{AbsSimpleNumFieldElem, Generic.MatSpaceElem{AbsSimpleNumFieldElem}}
    @assert isdefined(A, :isomorphic_full_matrix_algebra)
    B, AtoB = A.isomorphic_full_matrix_algebra
    Mbas = basis(M)
    MinB = _get_order_from_gens(B, elem_type(B)[ AtoB(elem_in_algebra(b)) for b in Mbas])
    FinB = ideal_from_lattice_gens(B, MinB, elem_type(B)[ AtoB(b) for b in basis(F) ], :twosided)
    y = _lift_norm_one_unit_full_matrix_algebra(MinB(AtoB(elem_in_algebra(x))::elem_type(B)), FinB)
    return (AtoB\y)::elem_type(A)
  elseif degree(A) == 4 && !is_split(A)
    return _lift_norm_one_unit_quaternion(x, F)
  else
    error("Not implemented yet")
  end
end

function _lift_norm_one_unit_quaternion(x, F)
  M = parent(x)
  A = algebra(M)
  B = basis_alg(M)
  ZA, ZAtoA = center(A)
  FinZA = _as_ideal_of_smaller_algebra(ZAtoA, F)
  G = zero_matrix(FlintQQ, 4, 4)
  f = standard_involution(A)
  for i in 1:4
    for j in 1:4
      G[i, j] = FlintZZ(trred(B[i] * f(B[j])))//2
    end
  end

  #@show M
  #@show F

  #@show elem_in_algebra(x)

  #@show normred(elem_in_algebra(x))
  # TODO: Replace this by short_vectors_gram(M, nrr) once it works
  V = _short_vectors_gram(Vector, G, ZZRingElem(1))
  for i in 1:length(V)
    y = sum(V[i][1][j] * B[j] for j in 1:4)
    @assert normred(y) == 1
    if y - x in F
      return y
      println("success");
    end
    if -y - x in F
      return -y
      println("success");
    end
  end

  @assert false
end

function _lift_norm_one_unit_full_matrix_algebra(x, F)
  #@show F
  A = algebra(parent(x))
  if degree(A) == 1
    return elem_in_algebra(one(parent(x)))
  elseif degree(base_ring(A)) == 1
    M = parent(x)
    A = algebra(M)
    B, BtoA = _as_full_matrix_algebra_over_Q(A)
    MinB = _get_order_from_gens(B, elem_type(B)[BtoA\elem_in_algebra(b) for b in absolute_basis(M)])
    FinB = ideal_from_lattice_gens(B, MinB, elem_type(B)[ BtoA\(b) for b in absolute_basis(F) ], :twosided)
    yy = _lift_norm_one_unit_full_rational_matrix_algebra(MinB(BtoA\(elem_in_algebra(x))), FinB)
    return BtoA(yy)
  else
    M = parent(x)
    N, S = nice_order(M)
    xN = N(S * elem_in_algebra(x) * inv(S))
    y = _lift_norm_one_unit_full_matrix_algebra_nice(xN, F)
    return inv(S) * y * S
  end
  throw(NotImplemented())
end

function _lift_norm_one_unit_full_matrix_algebra_nice(x, F)
  M = parent(x)
  A = algebra(M)
  ZA, ZAtoA = center(A)
  FinZA = _as_ideal_of_smaller_algebra(ZAtoA, F)
  # the center is a number field
  #@show FinZA
  el, id = pseudo_basis(FinZA)[1]
  fl, el2 = is_principal(id)
  # now lift

  a = nice_order_ideal(M)
  @assert isone(denominator(id))
  anu = numerator(a)
  idnu = numerator(id)
  b, zetainv = _coprime_integral_ideal_class(a, idnu)
  # zetainv * a == b
  @assert b + idnu == 1*order(b)
  zeta = inv(zetainv)
  n = degree(A)
  Phi1 = identity_matrix(base_ring(A), n)
  Phi1[n, n] = zetainv
  _belem, y = idempotents(b, idnu)
  belem = elem_in_nf(_belem)
  Phi2 = identity_matrix(base_ring(A), n)
  Phi2[n, n] = belem * zeta
  xtrans = matrix(Phi1 * elem_in_algebra(x) * Phi2)
  @assert all(x -> is_integral(x), xtrans)
  OK = base_ring(M)
  K = nf(OK)
  R, mR = quo(OK, idnu)
  @assert isone(det(map_entries(mR, change_base_ring(OK, xtrans))))
  el_matrices = _write_as_product_of_elementary_matrices(change_base_ring(OK, xtrans), R)
  lifted_el_matrices = elem_type(M)[]
  for E in el_matrices
    _E = _lift_and_adjust(E, zeta, belem)
    @assert A(_E) in M
    push!(lifted_el_matrices, M(A(_E)))
  end

  li = reduce(*, lifted_el_matrices)
  @assert isone(det(matrix(elem_in_algebra(li))))

  @assert li - x in id * M

  #@show (li - x) in id * M

  return elem_in_algebra(li)
end

function _lift_norm_one_unit_full_rational_matrix_algebra(x, F)
  M = parent(x)
  B = algebra(M)
  Mbas = basis(M)
  ZB, ZBtoB = center(B)
  FinZB = _as_ideal_of_smaller_algebra(ZBtoB, F)
  bas = basis(FinZB)[1]
  n = bas.coeffs[1]
  @assert n * one(ZB) == bas
  @assert B(n) * M == F

  nn = FlintZZ(n)

  R, c = nice_order(M)

  xwrtR = c * elem_in_algebra(x) * inv(c)

  # Now x is in M_n(Z) and I want to lift from M_n(Z/nn)

  @assert mod(FlintZZ(det(matrix((xwrtR)))), nn) == 1

  R = residue_ring(FlintZZ, nn, cached = false)[1]
  li = _lift2(map_entries(u -> R(FlintZZ(u)), matrix(xwrtR)))
  #li = _lift_unimodular_matrix(change_base_ring(FlintZZ, matrix(xwrtR)), nn, residue_ring(FlintZZ, nn)[1])

  return (inv(c) * B(change_base_ring(FlintQQ, li)) * c)
end

################################################################################
#
#  Lifting unimodular matrix
#
################################################################################

function _lift_and_adjust(E, zeta, b)
  #@show E
  K = parent(zeta)
  n = nrows(E)
  res = identity_matrix(K, nrows(E))
  for i in 1:n
    for j in 1:n
      if i != j && !iszero(E[i, j])
        if j == n
          res[i, j] = lift(E[i, j]) * inv(zeta)
        elseif i == n
          res[i, j] = zeta * b * lift(E[i, j])
        else
          res[i, j] = lift(E[i, j])
        end
        return res
      end
    end
  end
  return res
end

function _write_as_product_of_elementary_matrices(N, R)
  OK = base_ring(N)
  Nred = change_base_ring(R, N)
  k = nrows(N)

  if !isone(det(Nred))
    throw(ArgumentError("Matrix must have determinant one"))
  end

  trafos = typeof(Nred)[]

  for i in 1:k
    Nred, tra = _normalize_column(Nred, i)
    append!(trafos, tra)
  end

  Nred2 = change_base_ring(R, N)
  for T in trafos
    Nred2 = T * Nred2
  end
  @assert Nred2 == Nred

  Nredtr = transpose(Nred)

  trafos_tr = typeof(Nred)[]

  for i in 1:k
    Nredtr, tra = _normalize_column(Nredtr, i)
    append!(trafos_tr, tra)
  end

  #println(sprint(show, "text/plain", Nredtr))

  #Nred2 = change_base_ring(R, N)
  #for T in trafos
  #  Nred2 = T * Nred2
  #end

  #for T in trafos_tr
  #  Nred2 = Nred2 * transpose(T)
  #end

  # I need to normalize a diagonal matrix
  Nredtr, trafos3 = _normalize_diagonal(Nredtr)
  append!(trafos_tr, trafos3)
  @assert isone(Nredtr)

  res = typeof(Nred)[]

  for T in trafos
    push!(res, _inv_elementary_matrix(T))
  end

  for T in reverse(trafos_tr)
    push!(res, transpose(_inv_elementary_matrix(T)))
  end

  @assert reduce(*, res) == change_base_ring(R, N)
  return res
end

function _normalize_diagonal(N)
  n = nrows(N)
  trafos = typeof(N)[]
  R = base_ring(N)
  for i in n:-1:2
    a = N[i, i]
    inva = inv(a)
    E1 = elementary_matrix(R, n, i - 1, i, -one(R))
    E2 = elementary_matrix(R, n, i, i - 1,  one(R))
    E3 = elementary_matrix(R, n, i - 1, i, -one(R))
    E4 = elementary_matrix(R, n, i - 1, i, a)
    E5 = elementary_matrix(R, n, i, i - 1,  -inva)
    E6 = elementary_matrix(R, n, i - 1, i, a)
    N = E6 * E5 * E4 * E3 * E2 * E1 * N
    push!(trafos, E1)
    push!(trafos, E2)
    push!(trafos, E3)
    push!(trafos, E4)
    push!(trafos, E5)
    push!(trafos, E6)
  end
  @assert isone(N)
  return N, trafos
end

function _inv_elementary_matrix(M)
  n = nrows(M)
  N = identity_matrix(base_ring(M), n)
  for i in 1:n
    for j in 1:n
      if i != j && !iszero(M[i, j])
        N[i, j] = -M[i, j]
      end
    end
  end
  @assert isone(N * M)
  return N
end


function _normalize_column(N, i)
  n = nrows(N)
  R = base_ring(N)
  trafos = typeof(N)[]
  if is_unit(N[i, i])
    ainv = inv(N[i, i])
    for j in n:-1:(i + 1)
      E = elementary_matrix(R, n, j, i, -ainv * N[j, i])
      #@show N
      N = mul!(N, E, N)
      #@show N
      push!(trafos, E)
    end
    return N, trafos
  else
    for j in (i + 1):n
      if is_unit(N[j, i])
        E1 = elementary_matrix(R, n, i, j, one(R))
        N = mul!(N, E1, N)
        push!(trafos, E1)
        E2 = elementary_matrix(R, n, j, i, -one(R))
        N = mul!(N, E2, N)
        push!(trafos, E2)
        E3 = elementary_matrix(R, n, i, j, one(R))
        N = mul!(N, E3, N)
        push!(trafos, E3)
        @assert is_unit(N[i, i])
        N, trafos2 = _normalize_column(N, i)
        append!(trafos, trafos2)
        return N, trafos
      end
    end

    # This is the complicated case
    while true
      euc_min = euclid(N[i, i])
      i0 = i
      local e
      for j in (i + 1):n
        if iszero(N[j, i])
          continue
        end
        e = euclid(N[j, i])
        if (euc_min == -1 && e != - 1) || (e < euc_min)
          i0 = j
          euc_min = e
        end
      end
      if euc_min == 1
        # We found a unit
        break
      end
      ai0 = N[i0, i]
      for j in i:n
        aj = N[j, i]
        if !divides(aj, ai0)[1]
          q, r = divrem(aj, ai0)
          @assert euclid(r) < euclid(ai0)
          E = elementary_matrix(R, n, j, i0, -q)
          N = mul!(N, E, N)
          push!(trafos, E)
        end
      end
    end
    N, trafos2 = _normalize_column(N, i)
    append!(trafos, trafos2)
    return N, trafos
  end
  error("Something went wrong")
end

################################################################################
#
#  Missing base ring functions
#
################################################################################

_base_ring(::Nemo.ZZModRing) = FlintZZ

################################################################################
#
#  Splitting in good and bad part
#
################################################################################

function _my_direct_product(algebras)
  d = sum(Int[dim(A) for A in algebras])
  K = base_ring(algebras[1])
  maps = dense_matrix_type(K)[]
  pre_maps = dense_matrix_type(K)[]
  mt = zeros(K, d, d, d)
  offset = 0
  for l in 1:length(algebras)
    B = algebras[l]
    Bmult = multiplication_table(B, copy = false)
    dd = dim(B)
    mtB = multiplication_table(B)
    BtoA = zero_matrix(K, dim(B), d)
    AtoB = zero_matrix(K, d, dim(B))
    for i = 1:dd
      BtoA[i, offset + i] = one(K)
      AtoB[offset + i, i] = one(K)
      for j = 1:dd
        for k = 1:dd
          mt[i + offset, j + offset, k + offset] = Bmult[i, j, k]
        end
      end
    end
    offset += dd
    push!(maps, BtoA)
    push!(pre_maps, AtoB)
  end
  A = AlgAss(K, mt)
  A.decomposition = [ (algebras[i], hom(algebras[i], A, maps[i], pre_maps[i])) for i in 1:length(algebras) ]
  return A
end
