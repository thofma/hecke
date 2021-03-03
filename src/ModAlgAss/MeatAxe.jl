export submodules, minimal_submodules, maximal_submodules, composition_series,
       composition_factors, meataxe

################################################################################
#
#  Tools for MeatAxe
#
################################################################################


function pivot(M::MatElem, i::Int)
  ind = 1
  while ind <= ncols(M) && iszero(M[i, ind])
    ind += 1
  end
  if ind > ncols(M)
    error("Zero row! Can't find a pivot")
  end
  return ind
end
#
# Given a matrix $M$ in echelon form and a vector, it returns
# the vector reduced with respect to $M$
#
function cleanvect(M::T, v::T) where {T}
  @assert nrows(v)==1
  w = deepcopy(v)
  return cleanvect!(M, w)
end

function cleanvect!(M::T, v::T) where T
  if v == M
    zero!(v)
    return v
  end
  w = v
  if iszero(v)
    return w
  end
  R = base_ring(M)
  for i = 1:nrows(M)
    ind = 1
    while ind <= ncols(M) && iszero(M[i, ind])
      ind += 1
    end
    if ind > ncols(M)
      continue
    end
    w1ind = w[1, ind]
    if iszero(w1ind)
      continue
    end
    mult = divexact(w1ind, M[i, ind])
    w[1, ind] = R(0)
    for k = ind+1:ncols(M)
      c = M[i, k]
      if !iszero(c)
        w[1,k] -= mult * c
      end
    end    
  end
  return v
end

function reduce_mod_rref(M::T, v::T) where T
  @assert nrows(v)==1
  v1 = deepcopy(v)
  reduce_mod_rref!(M, v1)
  return v1
end

function reduce_mod_rref!(M::T, w::T) where {T}
  @assert nrows(w)==1
  if iszero(w)
    return w
  end
  ind =1
  R = base_ring(M)
  for i=1:nrows(M)
    if iszero_row(M, i)
      break
    end
    while iszero(M[i, ind])
      ind += 1
    end
    if iszero(w[1, ind])
      continue
    end
    mult = divexact(w[1,ind], M[i,ind])
    w[1,ind] = zero(R)
    for k = ind+1:ncols(M)
      w[1,k] -= mult*M[i,k]
    end
  end
  return nothing
end

@doc Markdown.doc"""
    closure(C::T, G::Array{T,1}) where T <: MatElem

Given a matrix $C$ representing a subspace of $K^n$ and a list of matrices $G$ representing endomorphisms of $K^n$,
the function returns a matrix representing the closure of the subspace under the action, i.e. the smallest
subspace of $K^n$ invariant under the endomorphisms.
"""
function closure(C::T, G::Array{T,1}) where {T}
  if nrows(C) != 1
    rref!(C)
  else
    # Do the rref by hand
    for k in 1:ncols(C)
      c = C[1, k]
      if !iszero(c)
        if isone(c)
          break
        end
        C[1, k] = one(base_ring(C))
        cinv = inv(c)
        for j in (k + 1):ncols(C)
          C[1, j] = cinv * C[1, j]
        end
        break
      end
    end
  end
  i=1
  nc = ncols(C)
  while i <= nrows(C)
    w=view(C, i:i, 1:ncols(C))
    for j=1:length(G)
      res = cleanvect!(C, w*G[j]) # cleanvect(C, w*G[j]) but we
                                  # can do it inplace since w*G[j] is fresh
      if !iszero(res)
        C = vcat(C, res)  
        if nrows(C) == nc
          i = ncols(C)+1
          break
        end
      end 
    end  
    i+=1
  end

  if nrows(C) == 1
    r = 0
    for k in 1:ncols(C)
      c = C[1, k]
      if !iszero(c)
        r = 1
        if isone(c)
          break
        end
        C[1, k] = one(base_ring(C))
        cinv = inv(c)
        for j in (k + 1):ncols(C)
          C[1, j] = cinv * C[1, j]
        end
        break
      end
    end
    else
    r = rref!(C)
  end
  
  if r != nrows(C)
    C = sub(C, 1:r, 1:ncols(C))
  end
  return C
end


#
#  Function to obtain the action of G on the quotient and on the submodule
#
function clean_and_quotient(M::T, N::T, pivotindex::Set{Int}) where {T}
  coeff = zero_matrix(base_ring(M), nrows(N), nrows(M))
  for i=1:nrows(N)
    for j=1:nrows(M)
      if iszero_row(M,j)
        continue
      end
      ind=1
      while iszero(M[j,ind])
        ind+=1
      end
      coeff[i,j]=divexact(N[i,ind], M[j,ind])
      for s=1:ncols(N)
        N[i,s]-=coeff[i,j]*M[j,s]
      end
    end
  end 
  vec= zero_matrix(base_ring(M), nrows(N), ncols(M)-length(pivotindex))
  for i=1:nrows(N)  
    pos=0
    for s=1:ncols(M)
      if !(s in pivotindex)
        pos+=1
        vec[i,pos]=N[i,s]
      end 
    end
  end
  return coeff, vec
end

function clean_and_quotient_quo(M::T, N::T, pivotindex::Set{Int}) where {T}
  for i=1:nrows(N)
    for j=1:nrows(M)
      if iszero_row(M, j)
        continue
      end
      ind=1
      while iszero(M[j,ind])
        ind+=1
      end
      r = divexact(N[i,ind], M[j,ind])
      N[i, ind] = 0
      for s=ind+1:ncols(N)
        N[i,s] -= r*M[j,s]
      end
    end
  end 
  vec = zero_matrix(base_ring(M), nrows(N), ncols(M)-length(pivotindex))
  for i=1:nrows(N)  
    pos=0
    for s=1:ncols(M)
      if !(s in pivotindex)
        pos+=1
        vec[i,pos]=N[i,s]
      end
    end
  end
  return vec
end


#  Restriction of the action to the submodule generated by C and the quotient
function __split(C::T, G::Vector{T}) where T <: MatElem
  action_sub = Vector{T}(undef, length(G))
  action_quo = Vector{T}(undef, length(G))
  pivotindex = Set{Int}()
  non_zero_rows = Int[]
  for i = 1:nrows(C)
    if iszero_row(C, i)
      continue
    end
    push!(non_zero_rows, i)
    ind = 1
    while iszero(C[i, ind])
      ind += 1
    end
    push!(pivotindex, ind)
  end
  N = zero_matrix(base_ring(C), ncols(C), ncols(C))
  ind = 1
  for i in non_zero_rows
    _copy_matrix_into_matrix(N, ind, 1, view(C, i:i, 1:ncols(C)))
    ind += 1
  end
  for j = 1:ncols(C)
    if j in pivotindex
      continue
    end
    N[ind, j] = 1
    ind += 1
  end
  Ninv = inv(N)
  for i = 1:length(G)
    Mat = N*G[i]*Ninv
    action_sub[i] = view(Mat, 1:length(pivotindex), 1:length(pivotindex))
    action_quo[i] = view(Mat, length(pivotindex)+1:ncols(C), length(pivotindex)+1:ncols(C))
  end
  return ModAlgAss(action_sub), ModAlgAss(action_quo), pivotindex
end


#  Restriction of the action to the submodule generated by C
function _actsub(C::T, G::Vector{T}) where {T <: MatElem}
  esub = Vector{T}(undef, length(G))
  pivotindex = Set{Int}()
  for i=1:nrows(C)
    ind = 1
    while iszero(C[i, ind])
      ind += 1
    end
    push!(pivotindex, ind)
  end
  for a=1:length(G)
    subm, vec = clean_and_quotient(C, C*G[a], pivotindex)
    esub[a] = subm
  end
  return ModAlgAss(esub)
end

#  Restriction of the action to the quotient by the submodule generated by C
function _actquo(C::T, G::Vector{T}) where {T <: MatElem}
  equot = Vector{T}(undef, length(G))
  pivotindex = Set{Int}()
  for i=1:nrows(C)
    ind = 1
    while iszero(C[i,ind])
      ind += 1
    end
    push!(pivotindex,ind)
  end
  for a=1:length(G)
    s = zero_matrix(base_ring(C), ncols(G[1]) - length(pivotindex), ncols(G[1]) - length(pivotindex))
    pos = 0
    for i=1:nrows(G[1])
      if !(i in pivotindex)
        vec = clean_and_quotient_quo(C, sub(G[a], i:i, 1:nrows(G[1])), pivotindex)
        for j=1:ncols(vec)
          s[i - pos, j] = vec[1, j]
        end
      else
        pos += 1
      end
    end
    equot[a] = s
  end
  return ModAlgAss(equot), pivotindex
end

#  Function that determine if two modules are isomorphic, provided that the first is irreducible
function isisomorphic(M::ModAlgAss{S, T, V}, N::ModAlgAss{S, T, V}) where {S, T, V}
  @assert M.isirreducible == 1
  @assert base_ring(M) == base_ring(N)
  @assert length(M.action) == length(N.action)
  if dimension(M) != dimension(N)
    return false
  end

  if M.dimension==1
    return M.action==N.action
  end

  K = base_ring(M)
  Kx, x = PolynomialRing(K, "x", cached=false)

  if length(M.action) == 1
    f = charpoly(Kx, M.action[1])
    g = charpoly(Kx, N.action[1])
    if f==g
      return true
    else
      return false
    end
  end
  rel = _relations(M,N)
  return iszero(rel[N.dimension, N.dimension])

end

function dual_space(M::ModAlgAss{S, T, V}) where {S, T, V}
  G = T[transpose(g) for g in M.action]
  return ModAlgAss(G)
end

function _subst(f::Nemo.PolyElem{T}, a::MatElem{T}) where {T <: Nemo.RingElement}
   n = degree(f)
   if n < 0
      return similar(a)
   elseif n == 0
      return coeff(f, 0) * identity_matrix(base_ring(a), nrows(a))
   elseif n == 1
      return coeff(f, 0) * identity_matrix(base_ring(a), nrows(a)) + coeff(f, 1)*a
   end
   d1 = isqrt(n)
   d = div(n, d1)
   A = powers(a, d)
   s = coeff(f, d1*d)*A[1]
   for j = 1:min(n - d1*d, d - 1)
      c = coeff(f, d1*d + j)
      if !iszero(c)
         s += c*A[j + 1]
      end
   end
   for i = 1:d1
      s *= A[d + 1]
      s += coeff(f, (d1 - i)*d)*A[1]
      for j = 1:min(n - (d1 - i)*d, d - 1)
         c = coeff(f, (d1 - i)*d + j)
         if !iszero(c)
            s += c*A[j + 1]
         end
      end
   end
   return s
end

#################################################################
#
#  MeatAxe
#
#################################################################

@doc Markdown.doc"""
    meataxe(M::ModAlgAss) -> Bool, MatElem

Given a module $M$, returns `true` if the module is irreducible (and the identity matrix) and `false` if the space is reducible, together with a basis of a submodule.
"""
function meataxe(M::ModAlgAss{S, T, V}) where {S, T, V}

  K = base_ring(M)
  Kx, x = PolynomialRing(K, "x", cached = false)
  n = dimension(M)
  @assert n > 0
  H = M.action
  if n == 1
    M.isirreducible = 1
    return true, identity_matrix(K, n)
  end


   G = T[x for x in H if !iszero(x)]
  @assert typeof(G) == typeof(H)

  if isempty(G)
    return false, matrix(K, 1, n, V[one(K) for i = 1:n])
  end

  if isone(length(G))
    A = G[1]
    poly = minpoly(Kx, A)
    sq = factor_squarefree(poly)
    lf = factor(first(keys(sq.fac)))
    t = first(keys(lf.fac))
    if degree(t)==n
      M.isirreducible = 1
      return true, identity_matrix(K, n)
    else
      N = _subst(t, A)
      null, kern = kernel(N, side = :left)
      B = closure(sub(kern, 1:1, 1:n), G)
      return false, B
    end
  end

  #  Adding generators to obtain randomness
  Gt = T[transpose(x) for x in G]
  cnt = 0
  while true
    cnt += 1
    if cnt > 1000
      error("Too many attempts")
    end
    # At every step, we add a generator to the group.
    new_gen = G[rand(1:length(G))]*G[rand(1:length(G))]
    while iszero(new_gen)
      mul!(new_gen, G[rand(1:length(G))], G[rand(1:length(G))])
    end
    push!(G, new_gen)

    # Choose a random combination of the generators of G
    A = zero_matrix(K, n, n)
    for i = 1:length(G)
      add!(A, A, rand(K)*G[i])
    end

    # Compute the characteristic polynomial and, for irreducible factor f, try the Norton test
    poly = minpoly(Kx, A)
    sqfpart = keys(factor_squarefree(poly).fac)
    for el in sqfpart
      sq = el
      i = 1
      while !isone(sq)
        f = gcd(powmod(x, order(K)^i, sq)-x,sq)
        sq = divexact(sq, f)
        lf = factor(f)
        for t in keys(lf.fac)
          N = _subst(t, A)
          a, kern = kernel(N, side = :left)
          @assert a > 0
          #  Norton test
          B = closure(sub(kern, 1:1, 1:n), M.action)
          if nrows(B) != n
            M.isirreducible= 2
            return false, B
          end
          aa, kernt = kernel(transpose(N), side = :left)
          @assert aa == a
          Bt = closure(sub(kernt, 1:1, 1:n), Gt)
          if nrows(Bt) != n
            aa, Btnu = kernel(Bt)
            subst = transpose(Btnu)
            #@assert nrows(subst)==nrows(closure(subst,G))
            M.isirreducible = 2
            return false, subst
          end
          if degree(t) == a
            # f is a good factor, irreducibility!
            M.isirreducible = 1
            return true, identity_matrix(K, n)
          end
        end
        i += 1
      end
    end
  end
end

################################################################################
#
#  Composition series
#
################################################################################

@doc Markdown.doc"""
    composition_series(M::ModAlgAss) -> Array{MatElem,1}

Given a Fq[G]-module $M$, it returns a composition series for $M$, i.e. a
sequence of submodules such that the quotient of two consecutive elements is irreducible.
"""
function composition_series(M::ModAlgAss{S, T, V}) where {S, T, V}

  if M.isirreducible == 1 || M.dimension == 1
    return [identity_matrix(base_ring(M.action[1]), dimension(M))]
  end


  bool, C = meataxe(M)
  #
  #  If the module is irreducible, we return a basis of the space
  #
  if bool
    return [identity_matrix(base_ring(M.action[1]), dimension(M))]
  end
  #
  #  The module is reducible, so we call the algorithm on the quotient and on the subgroup
  #
  G = M.action
  K = M.base_ring

  rref!(C)

  esub,equot,pivotindex=__split(C,G)
  sub_list = composition_series(esub)
  quot_list = composition_series(equot)
  #
  #  Now, we have to write the submodules of the quotient and of the submodule in terms of our basis
  #
  list=Vector{T}(undef, length(sub_list)+length(quot_list))
  for i=1:length(sub_list)
    list[i]=sub_list[i]*C
  end
  for z=1:length(quot_list)
    s=zero_matrix(K,nrows(quot_list[z]), ncols(C))
    for i=1:nrows(quot_list[z])
      pos=0
      for j=1:ncols(C)
        if j in pivotindex
          pos+=1
        else
          s[i,j]=quot_list[z][i,j-pos]
        end
      end
    end
    list[length(sub_list)+z]=vcat(C,s)
  end
  return list
end

################################################################################
#
#  Composition factors
#
################################################################################

function _composition_factors_cyclic(M::ModAlgAss{S, T, V}; dimension::Int = -1) where {S, T, V}
  @assert length(M.action) == 1
  mat = M.action[1]
  pols, basis_transf, gens = _rational_canonical_form_setup(mat)
  factors, gens_polys_mults = refine_for_jordan(pols, gens, mat)
  mats = Tuple{T, Int}[]
  for i = 1:length(factors)
    for j = 1:length(gens_polys_mults)
      el = gens_polys_mults[j]
      if el[2] != factors[i]
        continue
      end
      if dimension != -1 && degree(factors[i]) != dimension
        continue
      end
      push!(mats, (jordan_block(factors[i], 1), el[3]))
    end
  end
  res = Tuple{typeof(M), Int}[]
  done = falses(length(mats))
  for i = 1:length(mats)
    if done[i]
      continue
    end
    done[i] = false
    m = mats[i][2]
    for j = i+1:length(mats)
      if mats[i][1] == mats[j][1]
        done[j] = true
        m += mats[j][2]
      end
    end
    AA = ModAlgAss(T[mats[i][1]])
    AA.isirreducible = 1
    push!(res, (AA, m))
  end
  return res
end


@doc Markdown.doc"""
    composition_factors(M::ModAlgAss)

Given a Fq[G]-module $M$, it returns, up to isomorphism, the composition factors of $M$ with their multiplicity,
i.e. the isomorphism classes of modules appearing in a composition series of $M$.
"""
function composition_factors(M::ModAlgAss{S, T, V}; dimension::Int=-1) where {S, T, V}
  if M.isirreducible == 1 || M.dimension == 1
    if dimension != -1
      if M.dimension == dimension
        return Tuple{typeof(M), Int}[(M,1)]
      else
        return Tuple{typeof(M), Int}[]
      end
    else
      return Tuple{typeof(M), Int}[(M,1)]
    end
  end


  if isone(length(M.action))
    return _composition_factors_cyclic(M, dimension = dimension)
  end

  K = base_ring(M)
  bool, C = meataxe(M)
  #  If the module is irreducible, we just return a basis of the space
  if bool
    if dimension != -1
      if M.dimension==dimension
        return Tuple{typeof(M), Int}[(M,1)]
      else
        return Tuple{typeof(M), Int}[]
      end
    else
      return Tuple{typeof(M), Int}[(M,1)]
    end
  end
  G = M.action

  #  The module is reducible, so we call the algorithm on the quotient and on the subgroup
  rref!(C)
  sub, quot, pivotindex = __split(C, G)
  sub_list = composition_factors(sub, dimension = dimension)
  quot_list = composition_factors(quot, dimension = dimension)
  #  Now, we check if the factors are isomorphic
  done = falses(length(quot_list))
  for i = 1:length(sub_list)
    for j = 1:length(quot_list)
      if !done[j] && isisomorphic(sub_list[i][1], quot_list[j][1])
        sub_list[i]=(sub_list[i][1], sub_list[i][2]+quot_list[j][2])
        done[j] = true
        break
      end
    end
  end
  for j = 1:length(done)
    if !done[j]
      push!(sub_list, quot_list[j])
    end
  end
  return sub_list

end

function eigenspace_as_matrix(M::MatElem{T}, lambda::T) where T <: FieldElem
  N = sub(M, 1:nrows(M), 1:ncols(M))
  for i = 1:ncols(N)
    N[i, i] -= lambda
  end
  d, res = Hecke.left_kernel(N)
  return view(res, 1:d, 1:ncols(res))
end

                     
function _relations_dim_1(M::ModAlgAss{S, T, V}, N::ModAlgAss{S, T, V}) where {S, T, V}
  @assert M.isirreducible == 1
  @assert dimension(M) == 1

  K = base_ring(M)
  G = M.action
  H = N.action
  subs = eigenspace_as_matrix(H[1], G[1][1, 1])
  if iszero(nrows(subs))
    return zero_matrix(K, 0, dimension(N))
  end
  for i = 2:length(H)
    newsubs = eigenspace_as_matrix(H[i], G[i][1, 1])
    if iszero(nrows(newsubs))
      return zero_matrix(K, 0, dimension(N))
    end
    subs = _intersect(subs, newsubs)
    if iszero(nrows(subs))
      return zero_matrix(K, 0, dimension(N))
    end
  end
  return subs

end

function _relations(M::ModAlgAss{S, T, V}, N::ModAlgAss{S, T, V}) where {S, T, V}
  @assert M.isirreducible == 1
  G = M.action
  H = N.action
  K = base_ring(M)
  n = dimension(M)

  B = zero_matrix(K, n, n)
  B[1,1] = K(1)
  sys = zero_matrix(K,2*dimension(N),dimension(N))
  matrices = T[identity_matrix(K, dimension(N))]

  X = zero_matrix(K, n, n)
  X[1,1] = K(1)
  i = 1
  k = 1
  while i <= k
    w = sub(B, i:i, 1:n)
    for j = 1:length(G)
      v = w*G[j]
      res = cleanvect(X, v)#reduce_mod_rref(X, v)
      if !iszero(res)
        k += 1
        for s = 1:n
          X[k, s] = res[1, s]
          B[k, s] = v[1, s]
        end
        rref!(X)
        push!(matrices, matrices[i]*H[j])
      else
        fl, x = can_solve_with_solution(B, v, side = :left)
        @assert fl
        A = sum(T[x[1, q]*matrices[q] for q = 1:k])
        A = sub!(A, A, matrices[i]*H[j])
        for s = 1:N.dimension
          for t = 1:N.dimension
            sys[N.dimension+s, t] = A[t,s]
          end
        end
        rref!(sys)
      end
    end
    if !iszero(sys[N.dimension, N.dimension])
      break
    end
    i += 1
  end
  return view(sys, 1:N.dimension, 1:N.dimension)
end


#Finds the irreducible submodules of N isomorphic to M
#M must be irreducible
function irreducible_submodules(N::ModAlgAss{S, T, V}, M::ModAlgAss{S, T, V}) where {S, T, V}
  @assert M.isirreducible == 1
  K = M.base_ring
  if dimension(M) == 1
    kern = _relations_dim_1(M, N)
    a = rref!(kern)
    #@assert closure(kern, N.action) == kern
    if iszero(a)
      return T[]
    elseif isone(a)
      kern = view(kern, 1:a, 1:ncols(kern))
      return T[kern]
    end
  else
    rel = _relations(M,N)
    if !iszero(rel[N.dimension, N.dimension])
      return T[]
    end
    a, kern = nullspace(rel)
    kern = transpose(kern)
    if a == 1
      return T[closure(kern, N.action)]
    end
  end  
  vects = T[sub(kern, i:i, 1:N.dimension) for i=1:a]
  if dimension(M) == 1
    return _submodules_direct_sum_dim_1(vects, N)
  end
  #First sieve: The vectors may be dependent when considering the structure of G-module.
  #So I reduce the number of vectors by looking at the subspace they generate.
  #If there is an inclusion, then I can remove them.
  to_reduce = closure(vects[1], N.action)
  final_vect_list = T[vects[1]]
  for i = 2:length(vects)
    w = cleanvect(to_reduce, vects[i])
    if !iszero(w)
      push!(final_vect_list, vects[i])
      #to_reduce = vcat(vects[i], to_reduce)
      to_reduce = closure(vcat(vects[i], to_reduce), N.action)
    end
  end
  if isone(length(final_vect_list))
    return T[closure(final_vect_list[1], N.action)]
  end
  # Now, I have a list of generators as G-modules.
  # Therefore I need to consider combinations as G-modules
  return _submodules_direct_sum(final_vect_list, N)

end

function _all_combinations(M::MatElem{T}) where T
  K = base_ring(M)
  els = collect(x for x in K)
  @assert fits(Int, fmpz(length(els))^nrows(M))
  res = Vector{typeof(M)}(undef, length(els)^nrows(M))
  ind = 1
  m = zero_matrix(K, 1, nrows(M))
  it = cartesian_product_iterator([1:length(els) for i in 1:nrows(M)], inplace = true)
  for i in it
    for j = 1:nrows(M)
      m[1, j] = els[i[j]]
    end
    res[ind] = m * M
    ind += 1
  end  
  return res
end


function _isclosed_dim1(C, G)
  # Do the rref by hand
  for k in 1:ncols(C)
    c = C[1, k]
    if !iszero(c)
      if isone(c)
        break
      end
      C[1, k] = one(base_ring(C))
      cinv = inv(c)
      for j in (k + 1):ncols(C)
        C[1, j] = cinv * C[1, j]
      end
      break
    end
  end
  n = similar(C)
  for i = 1:length(G)
    n = mul!(n, C, G[i])
    cleanvect!(C, n)
    if !iszero(n)
      return false
    end
  end
  return true
end

function _submodules_direct_sum_dim_1(gens::Vector{T}, N::ModAlgAss{S, T, V}) where {S, T, V}
  K = base_ring(N)
  #The module I am working with is the direct sum of the submodules of N generated by the vectors in gens
  #I list all the vectors of the subspaces
  all_combinations = Vector{T}[_all_combinations(x) for x in gens]
  res = Vector{T}()
  for i = 1:length(gens)-1
    #I have to list all the elements that have 1 in the first component and all the possible elements in the other.
    it = cartesian_product_iterator([1:length(all_combinations[j]) for j = i+1:length(gens)], inplace = true)
    non_zero_el = all_combinations[i][1]
    ind = 2
    while iszero(non_zero_el)
      non_zero_el = all_combinations[i][ind]
      ind += 1
    end
    for I in it
      m = non_zero_el
      for s = 1:length(I)
        m += all_combinations[i+s][I[s]]
      end
      push!(res, m)
    end
  end
  non_zero_el = all_combinations[length(gens)][1]
  ind = 2
  while iszero(non_zero_el)
    non_zero_el = all_combinations[length(gens)][ind]
    ind += 1
  end
  push!(res, non_zero_el)
  return res
end


function _submodules_direct_sum(gens::Vector{T}, N::ModAlgAss{S, T, V}) where {S, T, V}
  K = base_ring(N)
  #The module I am working with is the direct sum of the submodules of N generated by the vectors in gens
  closures = T[closure(x, N.action) for x in gens]
  #I list all the vectors of the subspaces
  all_combinations = Vector{T}[_all_combinations(x) for x in closures]
  res = Vector{T}()
  for i = 1:length(gens)-1
    #I have to list all the elements that have 1 in the first component and all the possible elements in the other.
    it = cartesian_product_iterator([1:length(all_combinations[j]) for j = i+1:length(gens)], inplace = true)
    non_zero_el = all_combinations[i][1]
    ind = 2
    while iszero(non_zero_el)
      non_zero_el = all_combinations[i][ind]
      ind += 1
    end
    for I in it
      m = non_zero_el
      for s = 1:length(I)
        m += all_combinations[i+s][I[s]]
      end
      candidate = closure(m, N.action)
      if nrows(candidate) == nrows(closures[1])
        push!(res, candidate)
      end
    end
  end
  non_zero_el = all_combinations[length(gens)][1]
  ind = 2
  while iszero(non_zero_el)
    non_zero_el = all_combinations[length(gens)][ind]
    ind += 1
  end
  push!(res, closure(non_zero_el, N.action))
  return res
end


function _minimal_submodules(M::ModAlgAss{S, T, V}, dim::Int=M.dimension+1, lf = Tuple{ModAlgAss{S, T, V}, Int}[]) where {S, T, V}
  K = base_ring(M)
  n = dimension(M)
  if isone(M.isirreducible)
    if dim >= n
      return Tuple{T, ModAlgAss{S, T, V}}[(identity_matrix(K, n), M)]
    else
      return Tuple{T, ModAlgAss{S, T, V}}[]
    end
  end
  if isempty(lf)
    lf = composition_factors(M)
  end
  if meataxe(M)[1]
    if dim >= n
      return Tuple{T, ModAlgAss{S, T, V}}[(identity_matrix(K, n), M)]
    else
      return Tuple{T, ModAlgAss{S, T, V}}[]
    end
  end
  if dim != n+1
    lf = Tuple{ModAlgAss{S, T, V}, Int}[x for x in lf if x[1].dimension == dim]
  end
  list = Tuple{T, ModAlgAss{S, T, V}}[]
  for x in lf
    irr_subs = irreducible_submodules(M, x[1])
    for y in irr_subs
      push!(list, (y, x[1]))
    end
  end
  return list
end


@doc Markdown.doc"""
    minimal_submodules(M::ModAlgAss)
                                                 
Given a Fq[G]-module $M$, it returns all the minimal submodules of $M$.
"""
function minimal_submodules(M::ModAlgAss{S, T, V}, dim::Int=M.dimension+1, lf = Tuple{ModAlgAss{S, T, V}, Int}[]) where {S, T, V}
  return T[x[1] for x in _minimal_submodules(M, dim, lf)]
end
                                                 

@doc Markdown.doc"""
    maximal_submodules(M::ModAlgAss)

Given a $G$-module $M$, it returns all the maximal submodules of $M$.
"""
function maximal_submodules(M::ModAlgAss{S, T, V}, index::Int=M.dimension, lf = Tuple{ModAlgAss{S, T, V}, Int}[]) where {S, T, V}

  M_dual = dual_space(M)
  minlist = minimal_submodules(M_dual, index+1, lf)
  maxlist = Array{T, 1}(undef, length(minlist))
  for j=1:length(minlist)
    maxlist[j]=transpose(nullspace(minlist[j])[2])
  end
  return maxlist

end

@doc Markdown.doc"""
    submodules(M::ModAlgAss)

Given a $G$-module $M$, it returns all the submodules of $M$.

"""
function submodules(M::ModAlgAss{S, T, V}) where {S, T, V}

  K = base_ring(M)
  list = T[]
  if iszero(dimension(M))
    return list
  end
  if M.dimension == 1
    return T[zero_matrix(K, 1, 1), identity_matrix(K, 1)]
  end
  lf = composition_factors(M)
  minlist = minimal_submodules(M, M.dimension+1, lf)
  for x in minlist
    rref!(x)
    N, pivotindex = _actquo(x, M.action)
    ls = submodules(N)
    for a in ls
      s=zero_matrix(K,nrows(a), M.dimension)
      for t=1:nrows(a)
        pos=0
        for j=1:M.dimension
          if j in pivotindex
            pos+=1
          else
            s[t,j]=a[t,j-pos]
          end
        end
      end
      push!(list,vcat(x,s))
    end
  end
  for i = 1:length(list)
    x = list[i]
    rk = rref!(x)
    if rk < nrows(x)
      nx = sub(x, 1:rk, 1:ncols(x))
      list[i] = nx
    end
  end
  push!(list, zero_matrix(K, 0, M.dimension))
  push!(list, identity_matrix(K, M.dimension))
  append!(list, minlist)
  res = T[list[1]]
  for i = 2:length(list)
    x = list[i]
    found = false
    for j = 1:length(res)
      if x == res[j]
        found = true
        break
      end
    end
    if !found
      push!(res, x)
    end
  end
  return res

end


@doc Markdown.doc"""
    submodules(M::ModAlgAss, index::Int)

Given a $G$-module $M$, it returns all the submodules of $M$ of index $q$^index, where $q$ is the order of the field.
"""
function submodules(M::ModAlgAss{S, T, V}, index::Int; comp_factors = Tuple{ModAlgAss{S, T, V}, Int}[]) where {S, T, V}
  K = base_ring(M)
  if index == M.dimension
    return T[zero_matrix(K, 1, M.dimension)]
  end
  list = T[]
  list_hash = UInt64[]
  if index >= div(M.dimension, 2)
    if index == M.dimension-1
      if isempty(comp_factors)
        lf = composition_factors(M, dimension = 1)
      else
        lf = comp_factors
      end
      list = minimal_submodules(M, 1, lf)
      return list
    end
    if isempty(comp_factors)
      lf=composition_factors(M)
    else
      lf=comp_factors
    end
    if length(lf) == 1 && dimension(lf[1][1]) == 1
      return _submodules_primary(M, M.dimension-index, lf[1][1])
    end
    for i=1:M.dimension-index-1
      minlist = _minimal_submodules(M, i, lf)
      for X in minlist
        x, Sub = X
        N, pivotindex = _actquo(x, M.action)
        #  Recover the composition factors of the quotient
        lf1 = Tuple{ModAlgAss{S, T, V}, Int}[]
        found = false
        for j = 1:length(lf)
          if !found && isisomorphic(lf[j][1], Sub)
            if !isone(lf[j][2])
              push!(lf1, (lf[j][1], lf[j][2]-1))
            end
            found = true
          else
            push!(lf1, lf[j])
          end
        end
        #  Recursively ask for submodules and write their bases in terms of the given set of generators
        ls = submodules(N, index, comp_factors = lf1)
        length_list = length(list)
        for a in ls
          s = _lift(a, x, pivotindex)
          rref!(s)
          k = hash(s)
          found = false
          for j = 1:length_list
            if k == list_hash[j] && list[j] == s
              found = true
              break
            end
          end
          if !found
            push!(list, s)
            push!(list_hash, k)
          end
        end
      end
    end
    append!(list, minimal_submodules(M, M.dimension-index, lf))
  else
  #  Duality
    M_dual=dual_space(M)
    dlist=submodules(M_dual, M.dimension-index)
    list=T[transpose(nullspace(x)[2]) for x in dlist]
  end
  return list

end

function _lift(a::T, x::T, pivotindex::Set{Int}) where T
  s = zero_matrix(base_ring(a), nrows(a)+nrows(x), ncols(x))
  for t = 1:nrows(a)
    pos = 0
    #Using that a in in rref
    for j = 1:ncols(x)
      if j in pivotindex
        pos += 1
      elseif j >= t
        s[t, j] = a[t, j-pos]
      end
    end
  end
  for t = nrows(a)+1:nrows(s)
    for j = 1:ncols(s)
      s[t, j] = x[t-nrows(a), j]
    end
  end
return s
end

function _submodules_primary(M::ModAlgAss{S, T, V}, dimension::Int, composition_factor::ModAlgAss{S, T, V}) where {S, T, V}
  list = irreducible_submodules(M, composition_factor)
  K = base_ring(M)
  for i = 2:dimension
    list_new = Set{T}()
    for x in list
      N, pivotindex = _actquo(x, M.action)
      subs = irreducible_submodules(N, composition_factor)
      length_list = length(list_new)
      for a in subs
        s = _lift(a, x, pivotindex)
        rref!(s)
        push!(list_new, s)
      end
    end
    list = collect(list_new)
  end
  return list
end


function powmod(f::Zmodn_poly, e::fmpz, g::Zmodn_poly)
  if fits(Int, e)
    return powmod(f, Int(e), g)
  else
    _e = BigInt()
    z = parent(f)()
    ccall((:fmpz_get_mpz, libflint), Nothing, (Ref{BigInt}, Ref{fmpz}), _e, e)
    ccall((:nmod_poly_powmod_mpz_binexp, libflint), Nothing,
          (Ref{Zmodn_poly}, Ref{Zmodn_poly}, Ref{BigInt}, Ref{Zmodn_poly}),
           z, f, e, g)
    return z
  end
end
