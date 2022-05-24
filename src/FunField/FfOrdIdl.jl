
using Hecke
using  Hecke.GenericRound2
import Hecke.GenericRound2: radical_basis_power, radical_basis_trace, radical_basis_power_non_perfect
export FfOrdIdl

################################################################################
#
#  Constructors
#
################################################################################


mutable struct FfOrdIdl
  order::GenericRound2.Order
  basis::Vector{GenericRound2.OrderElem}
  basis_matrix::MatElem
  basis_mat_inv::FakeFracFldMat
  norm::RingElem
  minimum::RingElem
  is_prime::Int            # 0: don't know
                           # 1 known to be prime
                           # 2 known to be not prime
  iszero::Int              # as above
  is_principal::Int        # as above

  gen_one::RingElem
  gen_two::GenericRound2.OrderElem

  princ_gen::GenericRound2.OrderElem

  splitting_type::Tuple{Int, Int}
                         #ordered as ramification index, inertia degree


  function FfOrdIdl(O::GenericRound2.Order)
    r = new()
    r.order = O
    r.is_prime = 0
    r.iszero = 0
    r.is_principal = 0
    return r
  end

  function FfOrdIdl(O::GenericRound2.Order, M::MatElem)
    # create ideal of O with basis_matrix M
    r = FfOrdIdl(O)
    r.basis_matrix = M
    r.basis_mat_inv = FakeFracFldMat(pseudo_inv(M))
    return r
  end

  function FfOrdIdl(O::GenericRound2.Order, x::GenericRound2.OrderElem)
    # create ideal of O generated by x
    r = FfOrdIdl(O)
    r.princ_gen = x
    r.is_principal = 1

    if iszero(x)
       r.iszero = 1
    end

    r.norm = O.R(norm(O.F(x)))
    r.gen_one = r.norm
    r.gen_two = x
    return r
  end

  function FfOrdIdl(O::GenericRound2.Order, x::RingElem)
    return FfOrdIdl(O,O(x))
  end

  function FfOrdIdl(O::GenericRound2.Order, T:: Vector)
  V = hnf(vcat([representation_matrix(O(O.F(x))) for x in T]),:lowerleft)
  d = ncols(V)
  n = length(T)
  return FfOrdIdl(O, V[(n-1)*d+1:n*d,1:d])
  end

  function FfOrdIdl(O::GenericRound2.Order, p::RingElem, a::GenericRound2.OrderElem)
    #  create ideal of O generated by x
    r = FfOrdIdl(O)
    r.gen_one = p
    r.gen_two = a
    return r
  end

end

function AbstractAlgebra.zero(a::FfOrdIdl)
  O = a.order
  return FfOrdIdl(O,O(0))
end

AbstractAlgebra.iszero(I::FfOrdIdl) = (I.iszero == 1)

has_2_elem(A::FfOrdIdl) = isdefined(A, :gen_two)

################################################################################
#
#  Basic field access
#
################################################################################

@doc Markdown.doc"""
    order(x::FfOrdIdl) -> Order

Return the order, of which $x$ is an ideal.
"""
Hecke.order(a::FfOrdIdl) = a.order


###########################################################################################
#
#   Basis
#
###########################################################################################

@doc Markdown.doc"""
    has_basis(A::FfOrdIdl) -> Bool

Return whether $A$ has a basis already computed.
"""
has_basis(A::FfOrdIdl) = isdefined(A, :basis)

function assure_has_basis(A::FfOrdIdl)
  if isdefined(A, :basis)
    return nothing
  else
    assure_has_basis_matrix(A)
    O = order(A)
    M = A.basis_matrix
    Ob = basis(O)
    B = Vector{elem_type(O)}(undef, degree(O))
    y = O()
    for i in 1:degree(O)
      z = O()
      for k in 1:degree(O)
        mul!(y,O(M[i, k]), Ob[k])
        add!(z, z, y)
      end
      B[i] = z
    end
    A.basis = B
    return nothing
  end
end

@doc Markdown.doc"""
    basis(A::FfOrdIdl) -> Vector{OrderElem}

Return the basis of $A$.
"""
function Hecke.basis(A::FfOrdIdl; copy::Bool = true)
  assure_has_basis(A)
  if copy
    return deepcopy(A.basis)
  else
    return A.basis
  end
end


###########################################################################################
#
#   Basis Matrix
#
###########################################################################################

@doc Markdown.doc"""
    basis_matrix(A::FfOrdIdl) -> Mat

Return the basis matrix of $A$.
"""
function Hecke.basis_matrix(A::FfOrdIdl; copy::Bool = true)
  assure_has_basis_matrix(A)
  if copy
    return deepcopy(A.basis_matrix)
  else
    return A.basis_matrix
  end
end

function assure_has_basis_matrix(A::FfOrdIdl)
  if isdefined(A, :basis_matrix)
    return nothing
  end
  O = order(A)
  n = degree(O.F)

  if iszero(A)
    A.basis_matrix = zero_matrix(base_ring(O), n, n)
    return nothing
  end

  if has_princ_gen(A)
    A.basis_matrix = representation_matrix(A.princ_gen)
    return nothing
  end

  @hassert :NfOrd 1 has_2_elem(A)

  V = hnf(vcat([representation_matrix(x) for x in [O(A.gen_one),A.gen_two]]),:lowerleft)
  d = ncols(V)
  A.basis_matrix = V[d+1:2*d,1:d]
  return nothing
end

################################################################################
#
#  Basis matrix inverse
#
################################################################################

@doc Markdown.doc"""
    has_basis_mat_inv(A::FfOrdIdl) -> Bool

Return whether $A$ knows its inverse basis matrix.
"""
has_basis_mat_inv(A::FfOrdIdl) = isdefined(A, :basis_mat_inv)

@doc Markdown.doc"""
    basis_mat_inv(A::FfOrdIdl) -> FakeFracFldMat

Return the inverse of the basis matrix of $A$.
"""
function Hecke.basis_mat_inv(A::FfOrdIdl; copy::Bool = true) where T
  assure_has_basis_mat_inv(A)
  if copy
    return deepcopy(A.basis_mat_inv)
  else
    return A.basis_mat_inv
  end
end

function assure_has_basis_mat_inv(A::FfOrdIdl)
  if isdefined(A, :basis_mat_inv)
    return nothing
  else
    A.basis_mat_inv = FakeFracFldMat(pseudo_inv(basis_matrix(A)))
    return nothing
  end
end

###########################################################################################
#
#   Misc
#
###########################################################################################


(O::GenericRound2.Order)(p::PolyElem) = O(O.F(p))
Hecke.is_commutative(O::GenericRound2.Order) = true

Nemo.elem_type(::Type{GenericRound2.Order}) = GenericRound2.OrderElem

function Hecke.hnf(x::T, shape::Symbol =:upperright) where {T <: MatElem}
  if shape == :lowerleft
    h = hnf(reverse_cols(x))
    reverse_cols!(h)
    reverse_rows!(h)
    return h::T
  end
  return hnf(x)::T
end


################################################################################
#
#  Binary Operations
#
################################################################################


function Base.:(+)(a::FfOrdIdl, b::FfOrdIdl)
  check_parent(a, b)
  O = order(a)

  if iszero(a)
    return b
  end
  if iszero(b)
    return a
  end

  V = hnf(vcat(basis_matrix(a),basis_matrix(b)),:lowerleft)
  d = ncols(V)
  return FfOrdIdl(a.order, V[d+1:2*d,1:d])
end

Base.:(==)(a::FfOrdIdl, b::FfOrdIdl) = hnf(basis_matrix(a),:lowerleft) == hnf(basis_matrix(b),:lowerleft)
Base.isequal(a::FfOrdIdl, b::FfOrdIdl) = a == b

function Base.:(*)(a::FfOrdIdl, b::FfOrdIdl)
  O = order(a)
  Ma = basis_matrix(a)
  Mb = basis_matrix(b)
  V = hnf(vcat([Mb*representation_matrix(O([Ma[i,o] for o in 1:ncols(Ma)])) for i in 1:ncols(Ma)]),:lowerleft)
  d = ncols(V)
  return FfOrdIdl(O, V[d*(d-1)+1:d^2,1:d])
end

@doc Markdown.doc"""
    intersect(x::FfOrdIdl, y::FfOrdIdl) -> FfOrdIdl

Returns $x \cap y$.
"""
#TODO: Check for new hnf
function Base.intersect(a::FfOrdIdl, b::FfOrdIdl)
  M1 = hcat(basis_matrix(a), basis_matrix(a))
  d = nrows(M1)
  M2 = hcat(basis_matrix(b), zero_matrix(M1.base_ring,d,d))
  M = vcat(M1, M2)
  H = sub(hnf(M), d+1:2*d, d+1:2*d)
  return FfOrdIdl(a.order, H)
end

################################################################################
#
#  Powering
#
################################################################################

function Base.:(^)(A::FfOrdIdl, e::Int)
  O = order(A)
  if e == 0
    return FfOrdIdl(O, one(O))
  elseif e == 1
    return A
  end
    return Base.power_by_squaring(A, e)
end


################################################################################
#
#  Ad hoc multiplication
#
################################################################################

function Base.:*(x::GenericRound2.OrderElem, y::FfOrdIdl)
  parent(x) !== order(y) && error("Orders of element and ideal must be equal")
  return FfOrdIdl(parent(x), x) * y
end

Base.:*(x::FfOrdIdl, y::GenericRound2.OrderElem) = y * x


function Hecke.colon(a::FfOrdIdl, b::FfOrdIdl)

  O = order(a)
  n = degree(O)
  if isdefined(b, :gens)
    B = b.gens
  else
    B = basis(b)
  end

  bmatinv = basis_mat_inv(a, copy = false)

  n = representation_matrix(B[1])*bmatinv
  m = numerator(n)
  d = denominator(n)
  for i in 2:length(B)
    n = representation_matrix(B[i])*bmatinv
    mm = n.num
    dd = n.den
    l = lcm(dd, d)
    if l == d && l == dd
      m = hcat(m, mm)
    elseif l == d
      m = hcat(m, div(d, dd)*mm)
    elseif l == dd
      m = hcat(div(dd, d)*m, mm)
      d = dd
    else
      m = hcat(m*div(l, d), mm*div(l, dd))
      d = l
    end
  end
  m = transpose(m)
  m = hnf(m)
  # m is upper right HNF
  m = transpose(sub(m, 1:degree(O), 1:degree(O)))
  b = inv(FakeFracFldMat(m, d))
  return FfOrdFracIdl(O, b)
end

################################################################################
#
#  Exact Division
#
################################################################################


function Hecke.divexact(A::FfOrdIdl, b::RingElem)
  if iszero(A)
    return A
  end
  O = order(A)
  b = Hecke.AbstractAlgebra.MPolyFactor.make_monic(b)

  B = FfOrdIdl(O, divexact(basis_matrix(A), b))
  if false && has_basis_mat_inv(A)
    error("not defined at all")
    B.basis_mat_inv = b*A.basis_mat_inv
  end
  if has_princ_gen(A)
    B.princ_gen = O(divexact(O.F(A.princ_gen), b))
  end

  return B
end


function has_minimum(A::FfOrdIdl)
  return isdefined(A, :minimum)
end

function Hecke.minimum(A::FfOrdIdl; copy::Bool = true)
  assure_has_minimum(A)
  if copy
    return deepcopy(A.minimum)
  else
    return A.minimum
  end
end

function assure_has_minimum(A::FfOrdIdl)
  if has_minimum(A)
    return nothing
  end

  O = order(A)
  M = basis_matrix(A, copy = false)
  d = prod([M[i, i] for i = 1:nrows(M)])
  v = change_base_ring(O.R, coordinates(O(d)))
  fl, s = can_solve_with_solution(M, v, side = :left)
  @assert fl
  den = denominator(s[1]//d)
  for i = 2:ncols(s)
    den = lcm(den, denominator(s[i]//d))
  end
  A.minimum = Hecke.AbstractAlgebra.MPolyFactor.make_monic(den)
  return nothing
end

################################################################################
#
#  Norm
#
################################################################################

@doc Markdown.doc"""
    has_norm(A::FfOrdIdl) -> Bool

Return whether $A$ knows its norm.
"""
function has_norm(A::FfOrdIdl)
  return isdefined(A, :norm)
end

function assure_has_norm(A::FfOrdIdl)
  if has_norm(A)
    return nothing
  end

  if isdefined(A, :basis_matrix)
    A.norm = Hecke.AbstractAlgebra.MPolyFactor.make_monic(det(basis_matrix(A)))
    return nothing
  end

  if has_princ_gen(A)
    A.norm = Hecke.AbstractAlgebra.MPolyFactor.make_monic(norm(A.princ_gen))
    return nothing
  end

  assure_has_basis_matrix(A)
  A.norm = Hecke.AbstractAlgebra.MPolyFactor.make_monic(det(basis_matrix(A)))
  return nothing
end

@doc Markdown.doc"""
    norm(A::FfOrdIdl) -> RingElem

Return the norm of $A$, that is, the cardinality of $\mathcal O/A$, where
$\mathcal O$ is the order of $A$.
"""
function Hecke.norm(A::FfOrdIdl; copy::Bool = true)
  assure_has_norm(A)
  if copy
    return deepcopy(A.norm)
  else
    return A.norm
  end
end

################################################################################
#
#  Numerator and Denominator
#
################################################################################

function Hecke.numerator(a::Generic.FunctionFieldElem, O::GenericRound2.Order)
  return integral_split(a,O)[1]
end

function Hecke.denominator(a::Generic.FunctionFieldElem, O::GenericRound2.Order)
  return integral_split(a,O)[2]
end

################################################################################
#
#  Principal Generator
#
################################################################################

@doc Markdown.doc"""
    has_princ_gen(A::FfOrdIdl) -> Bool

Returns whether $A$ knows if it is generated by one element.
"""
function has_princ_gen(A::FfOrdIdl)
  return isdefined(A, :princ_gen)
end



################################################################################
#
#  Reduction of element modulo ideal
#
################################################################################

function Hecke.mod(x::GenericRound2.OrderElem, y::FfOrdIdl)
  parent(x) !== order(y) && error("Orders of element and ideal must be equal")
  # this function assumes that HNF is lower left
  # !!! This must be changed as soon as HNF has a different shape

  O = order(y)
  d = degree(O)
  a = change_base_ring(O.R,coordinates(x)).entries

  c = basis_matrix(y)
  t = O.R(0)
  for i in 1:d
    t = div(a[i], c[i,i])
    for j in 1:i
      a[j] = a[j] - t*c[i,j]
    end
  end
  z = O([a[i] for i in 1:lenth(a)])
  return z
end

################################################################################
#
#  Residue field
#
################################################################################


function Hecke.ResidueField(R::GFPPolyRing, p::gfp_poly)
  K, _ = FiniteField(p,"o")
  return K, MapFromFunc(x->K(x), y->R(y), R, K)
end

################################################################################
#
#  Factorization
#
################################################################################

function Hecke.index(O::GenericRound2.Order)
  index = O.R(1)
  if isdefined(O, :itrans)
    index = O.R(det(O.itrans))
  end
  return index
end

function prime_dec_nonindex(O::GenericRound2.Order, p::PolyElem, degree_limit::Int = 0, lower_limit::Int = 0)
  K = ResidueField(parent(p),p)[1]
  fact = factor(poly_to_residue(K,O.F.pol))
  result = []
  for (fac,e) in fact
    facnew = change_coefficient_ring(O.F.base_ring, fac)
    I = FfOrdIdl(O,p,O(facnew))
    I.is_prime = 1
    f = degree(fac)
    I.splitting_type = e, f
    I.norm = p^f
    I.minimum = p
    push!(result,(I,e))
  end
  return result
end


function poly_to_residue(K::AbstractAlgebra.Field, poly:: AbstractAlgebra.Generic.Poly{AbstractAlgebra.Generic.Rat{T}}) where T
  if poly == 0
    return K(0)
  else
    P, y = PolynomialRing(K,"y")
    coeffs = coefficients(poly)
    return sum([K(numerator(coeffs[i]))//K(denominator(coeffs[i]))*y^i for i in (0:length(poly)-1)])
  end
end


function Hecke.valuation(p::FfOrdIdl,A::FfOrdIdl)
  O = order(A)
  e = 0
  if has_2_elem(p)
    beta = Hecke.numerator(inv(O.F(p.gen_two)),O)
    newA = FfOrdFracIdl(beta*A,p.gen_one)
    while is_integral(newA)
      e += 1
      newA = FfOrdFracIdl(numerator(beta*newA),p.gen_one)
    end
  else
    newA = Hecke.colon(A,p)
    while is_integral(newA)
      e+=1
      newA = Hecke.colon(newA,FfOrdFracIdl(p))
    end
  end
  return e
end


function Hecke.factor(A::FfOrdIdl)
  O = A.order
  N = norm(A)
  factors = factor(N)
  primes = Dict{FfOrdIdl,Int}()
  for (f,e) in factors
    for (p,r) in prime_decomposition(O,f)
      primes[p] = valuation(p,A)
    end
  end
  return primes
end

function Hecke.prime_decomposition(O::GenericRound2.Order, p::RingElem, degree_limit::Int = degree(O), lower_limit::Int = 0; cached::Bool = true)
  if !(divides(index(O), p)[1])
    return prime_dec_nonindex(O, p, degree_limit, lower_limit)
  else
    return prime_dec_gen(O, p, degree_limit, lower_limit)
  end
end

function prime_dec_gen(O::GenericRound2.Order, p::RingElem, degree_limit::Int = degree(O), lower_limit::Int = 0)
  Ip = pradical(O, p)
  lp = _decomposition(O, FfOrdIdl(O, p), Ip, FfOrdIdl(O, one(O)), p)
  #=z = Tuple{ideal_type(O), Int}[]
  for (Q, e) in lp
    if degree(Q) <= degree_limit && degree(Q) >= lower_limit
      push!(z, (Q, e))
    end
  end
  return z
  =#
  return lp
end

function Hecke.pradical(O::GenericRound2.Order, p::RingElem)

  t = ResidueField(parent(p), p)

  if isa(t, Tuple)
    R, mR = t
  else
    R = t
    mR = MapFromFunc(x->R(x), y->lift(y), parent(p), R)
  end
#  @assert characteristic(F) == 0 || (isfinite(F) && characteristic(F) > degree(O))
  if characteristic(R) == 0 || characteristic(R) > degree(O)
    @vprint :NfOrd 1 "using trace-radical for $p\n"
    rad = radical_basis_trace
  elseif isa(R, Generic.RationalFunctionField)
    @vprint :NfOrd 1 "non-perfect case for radical for $p\n"
    rad = radical_basis_power_non_perfect
  else
    @vprint :NfOrd 1 "using radical-by-power for $p\n"
    rad = radical_basis_power
  end
  return FfOrdIdl(O,rad(O,p))
end

function _decomposition(O::GenericRound2.Order, I::FfOrdIdl, Ip::FfOrdIdl, T::FfOrdIdl, p::RingElem)
  #I is an ideal lying over p
  #T is contained in the product of all the prime ideals lying over p that do not appear in the factorization of I
  #Ip is the p-radical
  Ip1 = Ip + I
  A, OtoA = AlgAss(O, Ip1, p)
  AtoO = pseudo_inv(OtoA)
  ideals , AA = _from_algs_to_ideals(A, OtoA, AtoO, Ip1, p)
  for j in 1:length(ideals)
    P = ideals[j][1]
    f = P.splitting_type[2]
    e = valuation(P,FfOrdIdl(O,p))
    P.splitting_type = e, f
    ideals[j] = (P,e)
  end
  return ideals
end

function Hecke.AlgAss(O::GenericRound2.Order, I::FfOrdIdl, p::RingElem)
  @assert order(I) === O

  n = degree(O)
  bmatI = basis_matrix(I)

  basis_elts = Vector{Int}()
  for i = 1:n
    if is_coprime(bmatI[i, i], p)
      continue
    end

    push!(basis_elts, i)
  end

  r = length(basis_elts)
  FQ, phi = ResidueField(O.R,p)
  phi_inv = inv(phi)


  if r == 0
    A = _zero_algebra(FQ)

    local _image_zero

    let A = A
      function _image_zero(a::GenericRound2.OrderElem)
        return A()
      end
    end

    local _preimage_zero

    let O = O
      function _preimage_zero(a::AlgAssElem)
        return O()
      end
    end

    OtoA = Hecke.AbsOrdToAlgAssMor{typeof(O), elem_type(FQ)}(O, A, _image_zero, _preimage_zero)
    return A, OtoA
  end

  BO = basis(O)
  mult_table = Array{elem_type(FQ), 3}(undef, r, r, r)
  for i = 1:r
    M = representation_matrix(BO[basis_elts[i]])
    #TODO: write version of reduce rows mod hnf
    if r != degree(O)
      M = reduce_rows_mod_hnf!(M, bmatI, basis_elts)
    end
    for j = 1:r
      for k = 1:r
        mult_table[i, j, k] = FQ(M[basis_elts[j], basis_elts[k]])
      end
    end
  end

  if isone(BO[1])
    one = zeros(FQ, r)
    one[1] = FQ(1)
    A = AlgAss(FQ, mult_table, one)
  else
    A = AlgAss(FQ, mult_table)
  end
  if is_commutative(O)
    A.is_commutative = 1
  end

  local _image

  let I = I, A = A, basis_elts = basis_elts, FQ = FQ
    function _image(a::GenericRound2.OrderElem)
      c = coordinates(mod(a, I))
      return A([ FQ(numerator(c[i]))//FQ(denominator(c[i])) for i in basis_elts ])
    end
  end

  local _preimage

  let BO = BO, basis_elts = basis_elts, r = r
    function _preimage(a::AlgAssElem)
      return O(coefficients(a))
    end
  end

  OtoA = OrderToAlgAssMor{typeof(O), elem_type(FQ)}(O, A, _image, _preimage)

  return A, OtoA
end

# Reduces the rows of M in `rows` modulo N in place.
# Assumes that N is in lowerleft HNF.
function reduce_rows_mod_hnf!(M::MatElem, N::MatElem, rows::Vector{Int})
  for i in rows
    for j = ncols(M):-1:1
      if iszero(M[i, j])
        continue
      end

      t = div(M[i, j], N[j, j])
      for k = 1:j
        M[i, k] = M[i, k] - t*N[j, k]
      end
    end
  end
  return M
end

###############################################################################
#
#  Decomposition type using polygons
#
###############################################################################

function _from_algs_to_ideals(A::AlgAss{T}, OtoA::Map, AtoO::Map, Ip1, p::RingElem) where {T}

  O = order(Ip1)
  n = degree(O)
  R = O.R
  @vprint :NfOrd 1 "Splitting the algebra\n"
  AA = Hecke.decompose(A)
  @vprint :NfOrd 1 "Done \n"
  ideals = Vector{Tuple{typeof(Ip1), Int}}(undef, length(AA))
  N = basis_matrix(Ip1, copy = false)
  list_bases = Vector{Vector{Vector{elem_type(R)}}}(undef, length(AA))
  for i = 1:length(AA)
    l = Vector{Vector{elem_type(R)}}(undef, dim(AA[i][1]))
    for j = 1:length(l)
      v = change_base_ring(O.R,coordinates(AtoO(AA[i][2](AA[i][1][j]))))
      l[j] = [v[o] for o in 1:length(v)]
    end
    list_bases[i] = l
  end
  for i = 1:length(AA)
    B = AA[i][1]
    BtoA = AA[i][2]
    #we need the kernel of the projection map from A to B.
    #This is given by the basis of all the other components.
    f = dim(B)
    N1 = vcat(N, zero_matrix(R, dim(A) - f, n))
    t = 1
    for j = 1:length(AA)
      if j == i
        continue
      end
      for s = 1:length(list_bases[j])
        b = list_bases[j][s]
        for j = 1:degree(O)
          N1[n + t, j] = b[j]
        end
        t += 1
      end
    end
    N1 = view(hnf(N1, :lowerleft), nrows(N1) - degree(O) + 1:nrows(N1), 1:degree(O))
    P = FfOrdIdl(O, N1)
    P.minimum = p
    P.norm = p^f
    P.splitting_type = (0, f)
    P.is_prime = 1
    fromOtosimplealgebra = compose(OtoA, pseudo_inv(BtoA))
    #compute_residue_field_data!(P, fromOtosimplealgebra)
    ideals[i] = (P, 0)
  end
  return ideals, AA
end


################################################################################
#
#  OrderToAlgAssMor type
#
################################################################################

mutable struct OrderToAlgAssMor{S, T} <: Map{S, AlgAss{T}, Hecke.HeckeMap, OrderToAlgAssMor}
  header::Hecke.MapHeader

  function OrderToAlgAssMor{S, T}(O::S, A::AlgAss{T}, _image::Function, _preimage::Function) where {S <: GenericRound2.Order, T}
    z = new{S, T}()
    z.header = Hecke.MapHeader(O, A, _image, _preimage)
    return z
  end
end

function OrderToAlgAssMor(O::GenericRound2.Order, A::AlgAss{T}, _image, _preimage) where {T}
  return AbsOrdToAlgAssMor{typeof(O), T}(O, A, _image, _preimage)
end
