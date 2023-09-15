export locally_free_class_group, locally_free_class_group_with_disc_log

################################################################################
#
#  Locally free class group
#
################################################################################

add_verbosity_scope(:LocallyFreeClassGroup)

# Bley, Boltje "Computation of Locally Free Class Groups"
# If the left and right conductor of O in a maximal order coincide (which is the
# case if O is the integral group ring of a group algebra), the computation can
# be speeded up by setting cond = :left.
@doc raw"""
    locally_free_class_group(O::AlgAssAbsOrd) -> GrpAbFinGen

Given an order $O$ in a semisimple algebra over $\mathbb Q$, this function
returns the locally free class group of $O$.
"""
function locally_free_class_group(O::AlgAssAbsOrd, cond::Symbol = :center, return_disc_log_data::Type{Val{T}} = Val{false}) where T
  A = algebra(O)
  OA = maximal_order(O)
  Z, ZtoA = center(A)
  Fl = conductor(O, OA, :left)
  if cond == :left
    F = Fl
    FinZ = _as_ideal_of_smaller_algebra(ZtoA, F)
  elseif cond == :center
    FinZ = _as_ideal_of_smaller_algebra(ZtoA, Fl)
    # Compute FinZ*OA but as an ideal of O
    bOA = basis(OA, copy = false)
    bFinZ = basis(FinZ, copy = false)
    basis_F = Vector{elem_type(A)}()
    for x in bOA
      for y in bFinZ
        t = ZtoA(y) * elem_in_algebra(x, copy = false)
        push!(basis_F, t)
      end
    end
    F = ideal_from_lattice_gens(A, O, basis_F, :twosided)
  elseif cond == :product
    Fr = conductor(O, OA, :right)
    F = Fr*Fl
    FinZ = _as_ideal_of_smaller_algebra(ZtoA, F)
  else
    error("Option :$(cond) for cond not implemented")
  end

  @vprintln :LocallyFreeClassGroup "Decomposing algebra"
  Adec = decompose(A)
  fields_and_maps = as_number_fields(Z)

  # Find the infinite places we need for the ray class group of FinZ
  @vprintln :LocallyFreeClassGroup "Find the splitting infinite places"
  inf_plc = Vector{Vector{InfPlc{AnticNumberField, NumFieldEmbNfAbs}}}(undef, length(fields_and_maps))
  for i = 1:length(fields_and_maps)
    inf_plc[i] = Vector{InfPlc{AnticNumberField, NumFieldEmbNfAbs}}()
  end
  for i = 1:length(Adec)
    B, BtoA = Adec[i]
    C, CtoB = _as_algebra_over_center(B)
    K = base_ring(C)
    @assert K === fields_and_maps[i][1]

    places = real_places(K)
    for p in places
      if !is_split(C, p)
        push!(inf_plc[i], p)
      end
    end
  end

  @vprintln :LocallyFreeClassGroup "Compute ray class group"
  R, mR = ray_class_group(FinZ, inf_plc)

  # Compute K_1(O/F) and the subgroup of R generated by nr(a)*OZ for a in k1 where
  # nr is the reduced norm and OZ the maximal order in Z
  @vprintln :LocallyFreeClassGroup "Compute K_1"
  k1 = K1_order_mod_conductor(O, OA, F, FinZ)

  k1_as_subgroup = Vector{elem_type(R)}()
  @vprintln :LocallyFreeClassGroup "Lift generators to units of the algebra"
  for x in k1
    # It is possible that x is not invertible in A
    t = is_invertible(elem_in_algebra(x, copy = false))[1]
    k = 0
    while !t
      k += 1
      r = rand(F, 1)
      x += r
      t = is_invertible(elem_in_algebra(x, copy = false))[1]
      if k > 100
        error("Something wrong")
      end
    end
    s = _reduced_norms(elem_in_algebra(x, copy = false), mR)
    push!(k1_as_subgroup, s)
  end

  @vprintln :LocallyFreeClassGroup "Compute quotient"
  Cl, RtoCl = quo(R, k1_as_subgroup)

  S, StoCl = snf(Cl)

  if return_disc_log_data == Val{true}
    return S, compose(RtoCl, inv(StoCl)), mR, FinZ
  else
    return S
  end
end

# This only works if O is an integral group ring!
# (Because the theory only works in this case, not because of laziness.)
# See Bley, Wilson: "Computations in relative algebraic K-groups".
@doc raw"""
    locally_free_class_group_with_disc_log(O::AlgAssAbsOrd; check::Bool = true)
      -> GrpAbFinGen, DiscLogLocallyFreeClassGroup

Given a group ring $O$, this function returns the locally free class group of
$O$ and map from the set of ideals of $O$ to this group.
As the function only works for group rings, it is tested whether
`A = algebra(O)` is of type `AlgGrp` and whether `O == Order(A, basis(A))`.
These tests can be disabled by setting `check = false`.
"""
function locally_free_class_group_with_disc_log(O::AlgAssAbsOrd; check::Bool = true)
  if check
    if !(algebra(O) isa AlgGrp) || basis_matrix(O, copy = false) != FakeFmpqMat(identity_matrix(FlintZZ, dim(algebra(O))), ZZRingElem(1))
      error("Only implemented for group rings")
    end
  end

  Cl, RtoCl, mR, FinZ = locally_free_class_group(O, :left, Val{true})

  IdlSet = IdealSet(O)
  disc_log = DiscLogLocallyFreeClassGroup{typeof(IdlSet), typeof(Cl)}(IdlSet, Cl, RtoCl, mR, FinZ)

  return Cl, disc_log
end

# Helper function for locally_free_class_group
# Computes the representative in the ray class group (domain(mR)) for the ideal
# nr(a)*O_Z, where nr is the reduced norm and O_Z the maximal order of the centre
# of A.
function _reduced_norms(a::AbsAlgAssElem, mR::MapRayClassGroupAlg)
  A = parent(a)
  Adec = decompose(A)
  r = zero_matrix(FlintZZ, 1, 0)

  for i = 1:length(Adec)
    B, BtoA = Adec[i]
    C, CtoB = _as_algebra_over_center(B)
    c = CtoB\(BtoA\a)
    G, GtoIdl = mR.groups_in_number_fields[i]
    K = number_field(order(codomain(GtoIdl)))
    OK = maximal_order(K)
    @assert K === base_ring(C)
    nc = norm(c)
    I = OK(nc)*OK
    m = isqrt(dim(C))
    @assert m^2 == dim(C)
    b, J = is_power(I, m)
    @assert b
    g = GtoIdl\J
    r = hcat(r, g.coeff)
  end
  G = codomain(mR.into_product_of_groups)
  return mR.into_product_of_groups\(GrpAbFinGenElem(G, r))
end

################################################################################
#
#  K1
#
################################################################################

function K1_order_mod_conductor(O::AlgAssAbsOrd, M::AlgAssAbsOrd, F::AlgAssAbsOrdIdl; do_units::Bool = false)
  A = algebra(O)
  Z, ZtoA = center(A)
  FinZ = _as_ideal_of_smaller_algebra(ZtoA, F)
  @hassert :AlgAssOrd 1 _test_ideal_sidedness(F, O, :right)
  @hassert :AlgAssOrd 1 _test_ideal_sidedness(F, O, :left)
  @hassert :AlgAssOrd 1 _test_ideal_sidedness(F, M, :right)
  @hassert :AlgAssOrd 1 _test_ideal_sidedness(F, M, :left)
  return K1_order_mod_conductor(O, M, F, FinZ, do_units = do_units)
end

# Computes generators for K_1(O/F) where F is the product of the left and right
# conductor of O in the maximal order.
# FinZ should be F intersected with the centre of algebra(O).
# See Bley, Boltje "Computation of Locally Free Class Groups"
#
# If do_units = true, then generators of the unit group will be computed
function K1_order_mod_conductor(O::AlgAssAbsOrd, OA::AlgAssAbsOrd, F::AlgAssAbsOrdIdl, FinZ::AlgAssAbsOrdIdl; do_units::Bool = false)
  A = algebra(O)
  Z, ZtoA = center(A)
  OZ = maximal_order(Z)
  OinZ = _as_order_of_smaller_algebra(ZtoA, O, OA)
  @assert Hecke._test_ideal_sidedness(FinZ, OinZ, :left)
  @assert Hecke._test_ideal_sidedness(FinZ, OinZ, :right)
  @assert isone(denominator(basis_matrix(FinZ) * basis_mat_inv(OinZ)))

  primary_ideals = Vector{Tuple{ideal_type(O), ideal_type(O)}}()
  prim = primary_decomposition(FinZ, OinZ)

  for (q, p) in prim
    # q is p-primary
    pO = _as_ideal_of_larger_algebra(ZtoA, p, O)
    qO = _as_ideal_of_larger_algebra(ZtoA, q, O)
    # The qO are primary ideals such that F = \prod (qO + F)
    push!(primary_ideals, (pO, qO))
  end

  moduli = Vector{ideal_type(O)}()
  for i = 1:length(primary_ideals)
    push!(moduli, primary_ideals[i][2] + F)
  end

  # Compute generators of K_1(O/q + F) resp. (O/q + F)^* for each q and put them together with the CRT
  elements_for_crt = Vector{Vector{elem_type(O)}}(undef, length(primary_ideals))
  for i = 1:length(primary_ideals)
    # We use the exact sequence
    # (1 + p + F)/(1 + q + F) -> K_1(O/q + F) -> K_1(O/p + F) -> 1
    (p, q) = primary_ideals[i]
    pF = p + F
    qF = moduli[i]
    char = minimum(p)
    B, OtoB = AlgAss(O, pF, char)
    k1_B = K1(B; do_units = do_units)
    k1_O = [ OtoB\x for x in k1_B ]
    if pF != qF
      append!(k1_O, _1_plus_p_mod_1_plus_q_generators(pF, qF))
    end
    elements_for_crt[i] = k1_O
  end
  # Make the generators coprime to the other ideals
  if length(moduli) != 0 # maybe O is maximal
    k1 = make_coprime(elements_for_crt, moduli)
  else
    k1 = elem_type(O)[]
  end

  return k1
end

@doc raw"""
    K1(A::AlgAss{<:FinFieldElem}) -> Vector{AbsAlgAssElem}

Given an algebra over a finite field, this function returns generators for $K_1(A)$.
"""
function K1(A::AlgAss{<:FinFieldElem}; do_units::Bool = false)
  # We use the exact sequence 1 + J -> K_1(A) -> K_1(B/J) -> 1
  J = radical(A)
  onePlusJ = _1_plus_j(A, J)

  B, AtoB = quo(A, J)
  k1B = K1_semisimple(B; do_units = do_units)
  k1 = append!(onePlusJ, [ AtoB\x for x in k1B ])
  return k1
end

# Computes generators for K_1(A) with A semisimple as described in
# Bley, Boltje "Computation of Locally Free Class Groups", p. 84.
function K1_semisimple(A::AlgAss{<:FinFieldElem}; do_units::Bool = false)

  Adec = decompose(A)
  k1 = Vector{elem_type(A)}()
  idems = [ BtoA(one(B)) for (B, BtoA) in Adec ]
  sum_idems = sum(idems)
  minus_idems = map(x -> -one(A)*x, idems)
  for i = 1:length(Adec)
    B, BtoA = Adec[i]
    C, CtoB = _as_algebra_over_center(B)
    F = base_ring(C)
    if do_units
      M, CtoM = _as_matrix_algebra(C)
      _gens = _unit_group_generators(M)
      gens = [CtoM\g for g in _gens]
    else
      # Consider C as a matrix algebra over F. Then the matrices with a one somewhere
      # on the diagonal are given by primitive idempotents (see also _as_matrix_algebra).
      prim_idems = _primitive_idempotents(C)
      a = primitive_element(F)
      # aC is the identity matrix with a at position (1, 1)

      aC = a*prim_idems[1]
      if dim(C) > 1
        for j = 2:length(prim_idems)
          aC = add!(aC, aC, prim_idems[j])
        end
      end
      gens = [aC]
    end
    for aC in gens
      aA = BtoA(CtoB(aC))
      # In the other components aA should be 1 (this is not mentioned in the Bley/Boltje-Paper)
      aA = add!(aA, aA, sum_idems)
      aA = add!(aA, aA, minus_idems[i])
      push!(k1, aA)
    end
  end
  return k1
end

# Generators for GL_n(K), taken from Taylor, Pairs of Generators for Matrix Groups. I
function _unit_group_generators(A::AlgMat{<:FinFieldElem})
  K = base_ring(A)
  @assert degree(A)^2 == dim(A)
  d = degree(A)
  res = dense_matrix_type(K)[]
  if order(K) == 2
    # GL_n(K) = SL_n(K)
    if d == 1
      push!(res, identity_matrix(K, 1))
    else
      g1 = identity_matrix(K, d)
      g1[1, 2] = 1
      g2 = zero_matrix(K, d, d)
      g2[1, d] = 1
      for i in 2:d
        g2[i, i - 1] = 1
      end
      @assert det(g1) == 1
      @assert det(g2) == 1
      push!(res, g1, g2)
    end
  else
    z = primitive_element(K)
    g1 = identity_matrix(K, d)
    g1[1, 1] = z
    g2 = zero_matrix(K, d, d)
    g2[1, 1] = -1
    g2[1, d] = 1
    for i in 2:d
      g2[i, i - 1] = -1
    end
    @assert is_unit(det(g1))
    @assert is_unit(det(g2))
    push!(res, g1, g2)
  end
  return map(A, res)
end

# Computes generators for 1 + J where J is the Jacobson Radical of A
function _1_plus_j(A::AlgAss{<:FinFieldElem}, jacobson_radical::AbsAlgAssIdl...)
  F = base_ring(A)

  if length(jacobson_radical) == 1
    J = jacobson_radical[1]
  else
    J = radical(A)
  end

  onePlusJ = Vector{elem_type(A)}()

  if iszero(J)
    return onePlusJ
  end

  # We use the filtration 1 + J \supseteq 1 + J^2 \subseteq ... \subseteq 1
  oneA = one(A)
  while !iszero(J)
    J2 = J^2
    Q, AtoQ = quo(J, J2)
    for i = 1:dim(Q)
      push!(onePlusJ, one(A) + AtoQ\Q[i])
    end
    J = J2
  end
  return onePlusJ
end

################################################################################
#
#  Discrete logarithm (for group rings)
#
################################################################################

# Assumes v_p(a) = 0.
# Constructs n, d integral with n/d = a and v_p(n) = v_p(d) = 0.
function coprime_num_and_den(a::nf_elem, p::NfAbsOrdIdl)
  K = parent(a)
  OK = maximal_order(K)
  facA = factor(a*OK)
  vals = Vector{Int}()
  primes = Vector{ideal_type(OK)}()
  for (q, e) in facA
    @assert q != p "a is not coprime to p"
    if e > 0
      continue
    end
    push!(primes, q)
    push!(vals, -e)
  end
  push!(primes, p)
  push!(vals, 0)
  d = approximate_nonnegative(vals, primes)
  n = OK(a*elem_in_nf(d, copy = false))
  return n, d
end

mutable struct DiscLogLocallyFreeClassGroup{S, T} <: Map{S, T, HeckeMap, DiscLogLocallyFreeClassGroup}
  header::MapHeader{S, T}
  RtoC::GrpAbFinGenMap # Map from the ray class group of the centre to the class group
  mR::MapRayClassGroupAlg
  FinZ::AlgAssAbsOrdIdl # Conductor of the order in the maximal order contracted to the centre
  FinKs::Vector{NfOrdIdl}
  primes_in_fields::Vector{Vector{Tuple{NfOrdIdl, ZZRingElem, NfOrdIdl}}}
  fields_and_maps
  ZtoA

  function DiscLogLocallyFreeClassGroup{S, T}(IdlSet::S, C::T, RtoC::GrpAbFinGenMap, mR::MapRayClassGroupAlg, FinZ::AlgAssAbsOrdIdl) where {S, T}
    m = new{S, T}()
    O = order(IdlSet)
    A = algebra(O)
    Z, ZtoA = center(A)
    m.ZtoA = ZtoA
    fields_and_maps = as_number_fields(Z)
    m.RtoC = RtoC
    m.mR = mR
    m.FinZ = FinZ
    m.fields_and_maps = fields_and_maps

    # Some precomputations
    #nf_idl_type = ideal_type(order_type(fields_and_maps[1][1]))
    nf_idl_type = ideal_type(order_type(AnticNumberField))
    FinKs = Vector{nf_idl_type}(undef, length(fields_and_maps))
    for i = 1:length(fields_and_maps)
      K, ZtoK = fields_and_maps[i]
      FinKs[i] = _as_ideal_of_number_field(FinZ, ZtoK)
    end
    m.FinKs = FinKs
    primes_in_fields = Vector{Vector{Tuple{nf_idl_type, ZZRingElem, nf_idl_type}}}(undef, length(fields_and_maps))
    for i = 1:length(fields_and_maps)
      FinK = FinKs[i]
      facFinK = factor(FinK)
      primes_in_fields[i] = Vector{Tuple{nf_idl_type, ZZRingElem, nf_idl_type}}()
      for (p, e) in facFinK
        push!(primes_in_fields[i], (p, e, p^e))
      end
    end
    m.primes_in_fields = primes_in_fields

    _image = x -> x

    m.header = MapHeader{S, T}(IdlSet, C, _image)
    return m
  end
end

function image(m::DiscLogLocallyFreeClassGroup, I::ModAlgAssLat)
  V = I.V
  O = I.base_ring
  @req order(domain(m)) === O "Order of lattice and locally free class group must be identical"
  A = algebra(V)
  Areg = regular_module(A)
  AregToA = x -> A(coordinates(x))
  fl, VToAreg = is_isomorphic_with_isomorphism(V, Areg)
  if !fl
    error("Ambient module of lattice must be free of rank one")
  end
  Ibmat = basis_matrix(I)
  II = ideal_from_lattice_gens(A, O, [AregToA(VToAreg(V(_eltseq(Ibmat[i, :])))) for i in 1:nrows(Ibmat)])
  return m(II)
end

function image(m::DiscLogLocallyFreeClassGroup, I::AlgAssAbsOrdIdl)
  O = order(I)
  A = algebra(O)

  RtoC = m.RtoC
  mR =  m.mR
  FinZ = m.FinZ
  fields_and_maps = m.fields_and_maps::Vector{Tuple{AnticNumberField, AbsAlgAssToNfAbsMor{AlgAss{QQFieldElem}, elem_type(AlgAss{QQFieldElem}), AnticNumberField, QQMatrix}}}
  ZtoA = m.ZtoA::morphism_type(AlgAss{QQFieldElem}, typeof(A))
  _T = _ext_type(elem_type(base_ring(A)))
  nf_idl_type = ideal_type(order_type(_T))
  primes_in_fields = m.primes_in_fields::Vector{Vector{Tuple{nf_idl_type, ZZRingElem, nf_idl_type}}}
  FinKs = m.FinKs

  @assert order(I) === order(domain(m))

  # Bley, Wilson: "Computations in relative algebraic K-groups"

  # The ideal must be principal, so let's do this
  d = denominator(I, O)
  I = d * I

  n = norm(I)
  primes = collect(keys(factor(numerator(n)).fac))
  C = codomain(RtoC)
  c = id(C)
  for p in primes
    x = locally_free_basis(I, p)
    gamma = normred_over_center(x, ZtoA)

    elts_in_R = Vector{GrpAbFinGenElem}(undef, length(fields_and_maps))
    for j = 1:length(fields_and_maps)
      K, ZtoK = fields_and_maps[j]
      OK = maximal_order(K)
      gammaK = OK(ZtoK(gamma))
      FinK = FinKs[j]
      primes_in_K = primes_in_fields[j]
      alphas = Vector{elem_type(OK)}()
      pi = one(OK)
      for i = 1:length(primes_in_K)
        if valuation(p, primes_in_K[i][1]) != 0
          push!(alphas, deepcopy(gammaK))
          pi *= uniformizer(primes_in_K[i][1])^valuation(gammaK, primes_in_K[i][1])
        else
          push!(alphas, one(OK))
        end
      end

      # This is now the "recipe" from p. 178 of Bley, Wilson "Computations
      # in relative algebraic K-groups".
      # Compute beta in K such that v_P(alpha[P]*beta - 1) \geq v_P(FinK) for all P | FinK
      piinv = inv(elem_in_nf(pi, copy = false))
      right_sides = Vector{elem_type(OK)}(undef, length(primes_in_K))
      moduli = Vector{ideal_type(OK)}(undef, length(primes_in_K))
      for i = 1:length(primes_in_K)
        pe = primes_in_K[i][3]
        moduli[i] = pe
        if isone(alphas[i])
          right_sides[i] = deepcopy(pi)
        end
        Q, OKtoQ = quo(OK, pe)
        G, GtoQ = unit_group(Q)
        t = alphas[i]*piinv
        n, d = coprime_num_and_den(t, primes_in_K[i][1])
        g = GtoQ\(OKtoQ(d)) - GtoQ\(OKtoQ(n))
        right_sides[i] = OKtoQ\(GtoQ(g))
      end
      y = crt(right_sides, moduli)
      beta = approximate(y*piinv, FinK, real_places(K))
      @assert is_totally_positive(beta)

      # Compute the ideal (prod_{P | p} P^v_P(gammaK))*(beta*OK)
      bases = Vector{ideal_type(OK)}()
      exps = Vector{ZZRingElem}()
      # The discrete logarithm of the ray class group does not like fractional ideals...
      beta_den = denominator(beta, OK)
      push!(bases, OK(beta_den*beta)*OK)
      push!(exps, ZZRingElem(1))
      push!(bases, OK(beta_den)*OK)
      push!(exps, ZZRingElem(-1))
      pdec = prime_decomposition(OK, p)
      for (q, e) in pdec
        v = valuation(gammaK, q)
        if iszero(v)
          continue
        end
        push!(bases, q)
        push!(exps, v)
      end
      b = FacElem(bases, exps)
      # simplify! makes this work with the ray class group
      simplify!(b)
      elts_in_R[j] = mR.groups_in_number_fields[j][2]\b
    end

    # Put the components together and map it to C
    G = codomain(mR.into_product_of_groups)
    r = mR.into_product_of_groups \ (GrpAbFinGenElem(G, reduce(hcat, [e.coeff for e in elts_in_R])))
    c += RtoC(r)
  end
  return c
end

function show(io::IO, m::DiscLogLocallyFreeClassGroup)
  @show_name(io, m)
  println(io, "Discrete logarithm of ")
  show(IOContext(io, :compact => true), domain(m))
  println(io, "into locally free class group ")
  show(IOContext(io, :compact => true), codomain(m))
end
