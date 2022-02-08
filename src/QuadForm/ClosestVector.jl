import AbstractAlgebra.Generic: FreeModuleElem

########################################################################################################

# Private functions (will eventually change these functions into internal/private functions)

########################################################################################################

@doc Markdown.doc"""
    projective_quadratic_triple(Q::MatrixElem{T}, L::MatrixElem{T}, c::T, k=nothing) -> Tuple

Returns a tuple, where the first item in the tuple is a kxk (positive definite)
symmetric matrix, the next entry is a column vector of length k and the last 
entry is a rational number. 

THEORY:
R, (x1,x2,x3) = PolynomialRing(QQ, ["x1", "x2", "x3"]) 
Given a Polynomial ring of n variables we proceed as follows:
Generate a list of projective quadratic triples of n-1, ..., 1 variables, 
given an n-variabled quadratic triple QT=[Q,L,c], where Q is a nxn symmetric
matrix, L is a column vector of length n and c is a rational number.
NOTE: if k is an int < n then it returns the k-variabled 
projective quadratic triple.
"""
function projective_quadratic_triple(Q::MatrixElem{T}, L::MatrixElem{T}, c::T, k=nothing) where T <: RingElem
  n = nrows(Q)
  r1 = []; m1 = [];
  Lqqt = []; pp1 = []; LL1 = [];
  for i in 1:n-1
    Q1 = Q[1:n-i, 1:n-i] #n-i symmetric matrix extracted from the matrix Q
    p1 = Q[1:n-i, n+1-i:n+1-i] #Q[ri:rj, ci:cj] returns enrties from a matrix in the respective rows r_ and columns c_
    L1 = L[1:n-i,1:1] #column vector of length n-i
    #--------------------------------------------
    push!(Lqqt, Q1)
    push!(pp1, p1)
    push!(LL1, L1)
    push!(r1, Q[n+1-i, n+1-i])
    push!(m1, L[n+1-i,1:1][1])
  end
  # pL =[Lqqt, pp1, LL1, r1, m1]
  #------------------------------------------------
  c1 = c; ppQT = []; ppLL = []; cc1 = [];
  for j in 1:size(Lqqt,1)
    pt1 = transpose(pp1[j])
    pQT = Lqqt[j] - r1[j]^-1 * (pp1[j] * pt1)
    pLL = LL1[j] - ((m1[j] * r1[j]^-1) * pp1[j])
    c1 = c1 - (m1[j]^2 * r1[j]^-1) #rational number
    push!(ppQT, pQT)
    push!(ppLL, pLL)
    push!(cc1, c1)
  end
  Lqt = ppQT, ppLL, cc1 # set of n-1, ..., 1 variabled (projection) quadratic triple
  #------------------------------------------------
  if k === nothing
    return Lqt
  else
    if k < n
      while k >= 1
        return Lqt[1][n-k], Lqt[2][n-k], Lqt[3][n-k]
        break
      end
    else
      return Q, L, c #since k = n the result will be the input quadratic triple
    end
  end
end
  
@doc Markdown.doc"""
    range_ellipsoid_dim1(Q::MatrixElem{T}, L::MatrixElem{T}, c::T) ->  StepRange{fmpz, fmpz}
  
Returns a finite set of integers for which the inhomogeneous quadratic function, 
given a one variabled quadratic triple, is less than or equal to zero.
"""
function range_ellipsoid_dim1(Q::MatrixElem{T}, L::MatrixElem{T}, c::T) where T <: RingElem
  if nrows(Q) > 1
    throw(ArgumentError("The input quadratic triple is not one variabled."))
  end
  if L[1]^2 - Q[1]*c < 0
    throw(DomainError("The inhomogeneous quadratic function has no real solutions"))
  end
  #x1, x2 are roots of q s.t x1 <= x2
  #x1 = (-L[1] - sqrt(L[1]^2 - Q[1]*c)) / Q[1]
  #x2 = (-L[1] + sqrt(L[1]^2 - Q[1]*c)) / Q[1]
  # return the integers in the interval [x1,x2]
  sqrt_floor(a::fmpz) = isqrt(a)
  a = -L[1] // Q[1]; b = (L[1]^2 - Q[1]*c) // Q[1]^2;
  cc = lcm(denominator(a), denominator(b))
  aa = FlintZZ(a * cc); bb = FlintZZ(b * cc^2);
  l = round(fmpz, (aa - sqrt_floor(bb))//cc, RoundUp)
  r = round(fmpz, (aa + sqrt_floor(bb))//cc, RoundDown)
  return l:r
end
  
@doc Markdown.doc"""
    positive_quadratic_triple(a::fmpz, Q::MatrixElem{T}, L::MatrixElem{T}, c::T) -> Tuple
  
  
This function computes a n-1 variabled quadraric triple i*(a, QT), given an n>1
variabled projective quadratic triple QT and an integer a.
Return value: an n-1 variabled positive quadratic triple i*(a, QT)
"""
function positive_quadratic_triple(a::fmpz, Q::MatrixElem{T}, L::MatrixElem{T}, c::T) where T <: RingElem
  n = nrows(Q)
  r1 = []; m1 = []; Lqqt = []; pp1 = []; LL1 = [];
  #------------------------------------------------
  if n == 1
    throw(ArgumentError("The input should be a positive quadratic triple of n variables, for n > 1."))
  end
  for i in 2:n
    Q1 =  Q[i:n, i:n] #n-i symmetric matrix extracted from the matrix Q
    p1 = Q[i:n, i-1:i-1] #Q[ri:rj, ci:cj] returns enrties from a matrix in the respective rows r_ and columns c_
    L1 = L[i:n,1:1] #column vector of length n-i
    #--------------------------------------------
    push!(Lqqt, Q1)
    push!(pp1, p1)
    push!(LL1, L1)
    push!(r1, Q[i-1, i-1])
    push!(m1, L[i-1])
  end
  # pL =[Lqqt, pp1, LL1, r1, m1]
  #------------------------------------------------
  pQT = Lqqt[1]
  pLL = a * pp1[1] + LL1[1]
  c1 = a^2 * r1[1] + 2 * a * m1[1] + c #rational number
  #------------------------------------------------
  return Lqt = pQT, pLL, c1 #n-1 variabled quadratic triple
end
  
@doc Markdown.doc"""
    positive_quadratic_triple2(aa::Vector{fmpz}, Q::MatrixElem{T}, 
                               L::MatrixElem{T}, c::T) -> Tuple
  
NOTE: aa is an array of length k.

This function computes an n-k variabled quadratic triple i*(aa, QT), given an n
variabled quadratic triple QT and a tuple aa = {a1, ..., ak}, where k < n.
Return value: an n-k variabled positive quadratic triple i*(aa, QT).
"""
function positive_quadratic_triple2(aa::Vector{fmpz}, Q::MatrixElem{T}, L::MatrixElem{T}, c::T) where T <: RingElem 
  QT = Q, L, c
  k = length(aa)
  @req k < length(L) "The first input parameter should have length one less than the third input parameter"
  for i in 1:k
    R = positive_quadratic_triple(aa[i], QT[1], QT[2], QT[3])
    QT = R[1], R[2], R[3]
  end
  # the line below should change later in te optimisation phase
  if typeof(QT[1]) != Char
    return QT
  else
    error("The input QT = {Q, L, c} should be at least 2 variabled.")
  end
end
  
@doc Markdown.doc"""
    list_positive_quadratic_triple(aa::Vector{fmpz}, Q::MatrixElem{T}, 
                                   L::MatrixElem{T}, c::T) -> Array
  
  
Computes a list (for v = 1) QT_m^1 == i*(aa, QT_m^0), for aa in E(QT_1^0) 
"""
function list_positive_quadratic_triple(aa::Vector{fmpz}, Q::MatrixElem{T}, L::MatrixElem{T}, c::T) where T <: RingElem   
  n = nrows(Q)
  v = length(aa)+1
  ListI = []
  for m in v:n
    P = projective_quadratic_triple(Q, L, c, m) #QT_m^0
    Li = positive_quadratic_triple2(aa, P[1], P[2], P[3])
    push!(ListI, Li)
  end
  return ListI
end
  

@doc Markdown.doc"""
    list_positive_quadratic_triple2(b::fmpz, ListIv::Vector{Any}) -> Array
  
  
For a fixed v, this function computes a list of QT_m^v := i*(b, QT_m^{v-1}), 
where b is in E(QT_v^{v-1}).
"""
function list_positive_quadratic_triple2(b::fmpz, ListIv::Vector{Any}) #ListIv is the list of quadratic triples QT_m^{v-1}
  LL = [];
  for i in 1:size(ListIv,1)-1
    L = positive_quadratic_triple(b, ListIv[i+1][1], ListIv[i+1][2], ListIv[i+1][3])
    push!(LL, L)
  end
  return LL
end
  
@doc Markdown.doc"""
    posQuadTriple_intVectors(QT::Vector{Any}, E::Vector{Any}) -> Tuple
  
  
INPUT: 
  A list of quadratic triples QT a list of tuples E of the form {a_1, ..., a_k}
OUTPUT: 
  A new list of quadratic triples in the one dimension higher, and an updated 
  list E of the form {a_1, ..., a_k, a_{k+1}}
"""
function posQuadTriple_intVectors(QT::Vector{Any}, E::Vector{Any})
  QTT1 = [];
  EE = E;
  QTT = Array{Array}(undef, size(QT, 1))
  bbb = [];
  for j in 1:size(QT,1) #for a fixed v
    b = range_ellipsoid_dim1(QT[j][1][1], QT[j][1][2], QT[j][1][3]) #E(QT_v^{v-1}) = {b_1, ..., b_N}
    QT1 = Array{Array}(undef, BigInt(size(b, 1)))
    for k in 1:BigInt(size(b, 1))
      QT1[k] = list_positive_quadratic_triple2(b[k], QT[j]) #QT_m^v for m = v+1, ..., n
      for kk in EE
        push!(bbb,vcat(kk,b[k])) #bb is now a list of tuples [x_1, ..., x_{v-1},b[k]] that satisfiy a inhomogeneous quad function for a v variabled quad triple 
      end
    end
    QTT[j] = QT1
  end
  for j in 1:size(QT, 1)
    append!(QTT1, QTT[j])
  end
  EEE = unique!(bbb)
  return QTT1, EEE 
end

########################################################################################################

# Public functions

########################################################################################################

@doc Markdown.doc"""
    convert_type(G::MatrixElem{T}, K::MatrixElem{T}, d::T) -> Tuple{ZLat, MatrixElem{T}, T}
Where T is a concrete type, e.g. fmpz, fmpq, etc.
Converts a quadratic triple QT = [Q, K, d] to the input values required for closest vector problem (CVP). 
"""
function convert_type(G::MatrixElem{T}, K::MatrixElem{T}, d::T) where T <: RingElem
  if G[1,1] > 0
    Q = G
  else
    Q = -G
  end
  vector = -inv(Q) * K
  upperbound = (-transpose(K) * inv(Q) * -K)[1] - d
  Lattice = Zlattice(gram = Q)
  return Lattice, vector, upperbound
end
  
@doc Markdown.doc"""
    convert_type(L::ZLat, v::MatrixElem{T}, c::T) -> Tuple{fmpq_mat, fmpq_mat, fmpq}
  
Where T is a concrete type, e.g. fmpz, fmpq, etc.
Converts the input values from closest vector enumeration (CVE) to the corresponding quadratic triple QT = [Q, K, d].
"""
function convert_type(L::ZLat, v::MatrixElem{T}, c::T) where T <: RingElem
  V = ambient_space(L)
  Q = gram_matrix(V)
  K = -Q*v
  v = vec([i for i in v])
  d = inner_product(V,v,v)-c
  return Q, K, d
end


@doc Markdown.doc"""
    closest_vectors(Q::MatrixElem{T}, L::MatrixElem{T}, c::T; equal::Bool=false, sorting::Bool=false)
                                                    -> Vector{Vector{fmpz}}
  
  
Return all the integer vectors `x` of length n such that the inhomogeneous 
quadratic function `q_{QT}(x) := xQx + 2xL + c <= 0` corresponding to an n variabled
quadratic triple. If the optional argument ``equal = true``, it return
all vectors `x` such that `q_{QT}(x) = 0`. By default ``equal = false``.
If the argument ``sorting = true``, then we get a a list of sorted vectors.
The Default value for ``sorting`` is set to ``false``.
"""
function closest_vectors(G::MatrixElem{T}, L::MatrixElem{T}, c::T; equal::Bool=false, sorting::Bool=false) where T <: RingElem 
  #1 < v <= n+1, a = [a_1, ..., a_{v-1}] int tuple & 
  if G[1,1] > 0
    Q = G
  else 
    Q = -G
  end
  if det(Q) == 0
    throw("the symmetric matrix is not definite")
  end
  n = nrows(Q)
  QT = []; QTT = []; bbb = []; EE = Array{Array{fmpz,1},1}();
  P = projective_quadratic_triple(Q, L, c, 1)
  aa = range_ellipsoid_dim1(P[1], P[2], P[3]) # E(QT_1^0) from Shimada's paper
  for i in 1:size(aa,1)
    qt = list_positive_quadratic_triple(fmpz[aa[i]], Q, L, c) #List  QT_m^1 i*(aa[i], QT_m^0) for m = 2,...,n. Here v = 1
    push!(QT, qt)
  end
  for j in 1:size(QT,1) # v=2
    b = range_ellipsoid_dim1(QT[j][1][1], QT[j][1][2], QT[j][1][3]) # E(QT_2^1) = {b_1, ..., b_N}
    QT1 = Array{Array}(undef, BigInt(size(b, 1)))
    for kk in 1:size(aa, 1)
      for k in 1:BigInt(size(b, 1))
        QT1[k] = list_positive_quadratic_triple2(b[k], QT[j]) # QT_m^2 for m = 3, ..., n
        bb = [aa[kk], b[k]]
        push!(bbb,bb) # bbb is a list of tuples [a,b] that satisfiy a inhomogeneous quad function for a 2 variabled quad triple 
      end
    end
    QT[j] = QT1
  end
  for j in 1:size(QT, 1)
    append!(QTT, QT[j])
  end
  QTT1 = QTT;
  E = unique!(bbb)
  for v in 3:n      
    R1 = posQuadTriple_intVectors(QTT1, E)
    QTT1 = R1[1] 
    E = R1[2] 
  end
  if !equal
    for k in E
      if (transpose(matrix(QQ,size(k,1),1,k))*Q*matrix(QQ,size(k,1),1,k))[1] + (2*transpose(matrix(QQ,size(k,1),1,k))*L)[1] + c <= 0
        push!(EE, k)
      end
    end
    if !sorting
      return EE
    else
      return sort!(EE)
    end
  else
    for k in E
      if (transpose(matrix(QQ,size(k,1),1,k))*Q*matrix(QQ,size(k,1),1,k))[1] + (2*transpose(matrix(QQ,size(k,1),1,k))*L)[1] + c == 0
        push!(EE, k)
      end
    end
    if !sorting
      return EE
    else
      return sort!(EE)
    end
  end
end


@doc Markdown.doc"""
    closest_vectors(L:ZLat, v:MatrixElem{T}, upperbound::T; equal::Bool=false, sorting::Bool=false)
                                                    -> Vector{Vector{fmpz}}
  
  
Return all vectors `x` in `L` such that `b(v-x,v-x) <= c`, where `b` is the bilinear form on `L`.
If the optional argument ``equal = true`` then it return all vectors `x` in `L` such that `b(v-x,v-x) = c`.
By default ``equal = false``. If the argument ``sorting = true``, then we get a a list of sorted vectors.
The Default value for ``sorting`` is set to ``false``.
"""
function closest_vectors(L::ZLat, v::MatrixElem{T} , upperbound::T; equal::Bool=false, sorting::Bool=false) where T <: RingElem
  epsilon = QQ(1//10)   # some number > 0, not sure how it influences performance
  d = size(v)[1]
  if isdefinite(L) == false
    throw("Zlattice is indefinite.")
  end
  if rank(L) != d
    throw("Zlattice must have the same rank as the length of the vector in the second argument.")
  end
  g1 = gram_matrix(L)
  if g1[1,1] > 0
    G1 = g1
  else
    G1 = -g1
  end
  e = matrix(QQ, 1, 1, [upperbound//3+epsilon])
  G = diagonal_matrix(G1, e)
  B = diagonal_matrix(basis_matrix(L),matrix(QQ,1,1,[1]))
  for i in 1:d
    B[end,i] = -v[i]
  end
  N = Zlattice(B,gram=G)
  
  delta = QQ(4//3)*upperbound + epsilon
  sv = Hecke.short_vectors(N, delta)
  cv = Array{Array{fmpz,1},1}()
  for a in sv
    a = a[1]
    if a[end] == 0
    continue
    end
    if a[end] == -1
      a = -a
    end
    x = a[1:end-1]
    push!(cv, x)
  end
  V = ambient_space(L)
  v1 = Vector{T}()
  for i in v
    push!(v1, i)
  end
  cv2 = Array{Array{fmpz,1},1}()
  if !equal
    for x in cv
      t = x - v1
      dist = inner_product(V,t,t)
      if dist <= upperbound
          push!(cv2,x)
      end
    end
    if !sorting
      return cv2
    else
      return sort!(cv2)
    end
  else
    for x in cv
      t = x - v1
      dist = inner_product(V,t,t)
      if dist == upperbound
        push!(cv2,x)
      end
    end
    if !sorting
      return cv2
    else
      return sort!(cv2)
    end
  end
end
