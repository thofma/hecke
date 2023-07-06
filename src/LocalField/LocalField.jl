export local_field, inertia_degree, absolute_inertia_degree, absolute_ramification_index,
        eisenstein_extension, unramified_extension

################################################################################
#
#  Show function
#
################################################################################

function show(io::IO, a::LocalField{S, EisensteinLocalField}) where S
  print(io, "Eisenstein extension with defining polynomial ", defining_polynomial(a))
  print(io, " over ", base_field(a))
end

function show(io::IO, a::LocalField{S, UnramifiedLocalField}) where S
  print(io, "Unramified extension with defining polynomial ", defining_polynomial(a))
  print(io, " over ", base_field(a))
end

function show(io::IO, a::LocalField{S, GenericLocalField}) where S
  print(io, "Extension with defining polynomial ", defining_polynomial(a))
  print(io, " over ", base_field(a))
end

################################################################################
#
#  Characteristic
#
################################################################################

characteristic(K::LocalField) = characteristic(base_field(K))
prime(K::LocalField) = prime(base_field(K))

################################################################################
#
#  Type derivation
#
################################################################################

base_field_type(K::LocalField{S, T}) where {S <: FieldElem, T <: LocalFieldParameter} = parent_type(S)
base_field_type(::Type{LocalField{S, T}}) where {S <: FieldElem, T <: LocalFieldParameter} = parent_type(S)

elem_type(K::LocalField{S, T}) where {S <: FieldElem, T <: LocalFieldParameter} = LocalFieldElem{S, T}
elem_type(::Type{LocalField{S, T}}) where {S <: FieldElem, T <: LocalFieldParameter} = LocalFieldElem{S, T}

dense_matrix_type(K::LocalField{S, T}) where {S <: FieldElem, T <: LocalFieldParameter} =  Generic.MatSpaceElem{LocalFieldElem{S, T}}
dense_matrix_type(::Type{LocalField{S, T}}) where {S <: FieldElem, T <: LocalFieldParameter} =  Generic.MatSpaceElem{LocalFieldElem{S, T}}

dense_poly_type(K::LocalField{S, T}) where {S <: FieldElem, T <: LocalFieldParameter} = Generic.Poly{LocalFieldElem{S, T}}
dense_poly_type(::Type{LocalField{S, T}}) where {S <: FieldElem, T <: LocalFieldParameter} = Generic.Poly{LocalFieldElem{S, T}}

################################################################################
#
#  Basic predicates
#
################################################################################

is_domain_type(::Type{S}) where S <: LocalField = true
is_exact_type(::Type{S}) where S <: LocalField = false
isfinite(K::LocalField) = isfinite(base_field(K))

################################################################################
#
#  Generating polynomials properties
#
################################################################################

function is_eisenstein_polynomial(f::PolyElem{S}) where S <: Union{padic, qadic, LocalFieldElem}
  if !iszero(valuation(leading_coefficient(f)))
    return false
  end
  if !isone(absolute_ramification_index(base_ring(f))*valuation(constant_coefficient(f)))
    return false
  end
  for i = 1:degree(f)-1
    c = coeff(f, i)
    if !iszero(c) && valuation(c) <= 0
      return false
    end
  end
  return true
end

function is_eisenstein_polynomial(f::T, p::S) where {T <: Union{QQPolyRingElem, ZZPolyRingElem}, S<: Union{ZZRingElem, Int}}
  @assert is_prime(p)
  if !iszero(valuation(leading_coefficient(f), p))
    return false
  end
  if !isone(valuation(constant_coefficient(f), p))
    return false
  end
  for i = 1:degree(f)-1
    c = coeff(f, i)
    if !iszero(c) && valuation(c, p) <= 0
      return false
    end
  end
  return true
end

function is_eisenstein_polynomial(f::PolyElem{<:NumFieldElem}, p::NumFieldOrdIdl)
  @assert is_prime(p)
  if !iszero(valuation(leading_coefficient(f), p))
    return false
  end
  if !isone(valuation(constant_coefficient(f), p))
    return false
  end
  for i = 1:degree(f)-1
    c = coeff(f, i)
    if !iszero(c) && valuation(c, p) <= 0
      return false
    end
  end
  return true
end

function _generates_unramified_extension(f::PolyElem{S}) where S <: Union{padic, qadic, LocalFieldElem}
  K = base_ring(f)
  F, mF = residue_field(K)
  g = map_coefficients(mF, f)
  return is_irreducible(g)
end

var(a::LocalField) = a.S


function gen(K::LocalField)
  g = gen(parent(defining_polynomial(K)))
  el = K(g)
  return setprecision!(el, precision(K))
end


################################################################################
#
#  Subfields
#
################################################################################

function prime_field(L::Union{FlintQadicField, LocalField})
  L = base_ring(defining_polynomial(L))
  while typeof(L) != FlintPadicField
    L = base_ring(defining_polynomial(L))
  end
  return L
end


function base_field(L::LocalField)
  return base_ring(defining_polynomial(L))
end

function absolute_base_field(L::LocalField)
  return absolute_base_field(base_field(L))
end

absolute_base_field(L::FlintPadicField) = L
absolute_base_field(L::FlintQadicField) = base_field(L)

################################################################################
#
#  Degree
#
################################################################################

function degree(K::LocalField)
  return degree(defining_polynomial(K, 1)) #inf. recursion loos otherwise
end

function absolute_degree(::FlintPadicField)
  return 1
end

function absolute_degree(K::FlintQadicField)
  return degree(K)
end
function absolute_degree(K::LocalField)
  return degree(K)*absolute_degree(base_field(K))
end

################################################################################
#
#  Traces
#
################################################################################

function assure_traces(K::LocalField{S, T}, n::Int = precision(K)) where {S <: FieldElem, T <: LocalFieldParameter}

  if haskey(K.traces_basis, n)
    return K.traces_basis[n]
  end
  res = S[base_field(K)(degree(K))]
  append!(res, polynomial_to_power_sums(defining_polynomial(K, n), degree(K)-1))
  K.traces_basis[n] = res
  return res
end

################################################################################
#
#  Ramification index
#
################################################################################

function ramification_index(K::FlintPadicField)
  return 1
end

function ramification_index(K::FlintQadicField)
  return 1
end

function ramification_index(K::LocalField{S, EisensteinLocalField}) where S <: FieldElem
  return degree(K)
end

function ramification_index(K::LocalField{S, UnramifiedLocalField}) where S <: FieldElem
  return 1
end

function ramification_index(K::LocalField{S, GenericLocalField}) where S <: FieldElem
  error("Not yet implemented")
end

absolute_ramification_index(K::PadicField) = 1
absolute_ramification_index(K::QadicField) = 1

function absolute_ramification_index(K::LocalField{S, T}) where {S <: FieldElem, T <: LocalFieldParameter}
  return ramification_index(K)*absolute_ramification_index(base_field(K))
end

function ramification_index(L::LocalField, K::Union{FlintPadicField, FlintQadicField, LocalField})
  ri = 1
  while absolute_degree(L) >= absolute_degree(K)
    ri *= ramification_index(L)
    L = base_field(L)
    L === K && return ri
  end
  if L === K
    return ri
  end
  error("bad tower")
end

################################################################################
#
#  Inertia degree
#
################################################################################

function inertia_degree(K::FlintPadicField)
  return 1
end

function inertia_degree(K::FlintQadicField)
  return degree(K)
end

function inertia_degree(K::LocalField{S, EisensteinLocalField}) where S
  return 1
end

function inertia_degree(K::LocalField{S, UnramifiedLocalField}) where S
  return degree(K)
end

function inertia_degree(L::LocalField, K::LocalField)
  if base_field(L) === K
    return inertia_degree(L)
  else
    return inertia_degree(L)*inertia_degree(base_field(L), K)
  end
end

function absolute_inertia_degree(L::LocalField)
  return inertia_degree(L)*absolute_inertia_degree(base_field(L))
end

absolute_inertia_degree(::PadicField) = 1
absolute_inertia_degree(K::QadicField) = degree(K)

################################################################################
#
#  Basis
#
################################################################################

function basis(K::Union{FlintQadicField, LocalField})
  return powers(gen(K), degree(K)-1)
end

function absolute_basis(K::LocalField)
  Bk = absolute_basis(base_field(K))
  BKr = basis(K)
  BK = Vector{elem_type(K)}()
  for i = 1:length(BKr)
    for j = 1:length(Bk)
      push!(BK, BKr[i]*K(Bk[j]))
    end
  end
  return BK
end

absolute_basis(K::FlintQadicField) = basis(K)
absolute_basis(K::FlintPadicField) = padic[one(K)]

################################################################################
#
#  Constructors
#
################################################################################

#=
function find_irreducible_polynomial(K, n::Int)
  Zx, x = polynomial_ring(FlintZZ, "x", cached = false)
  f = cyclotomic(ppio(degree(K), n)*n, x)
  lf = factor(f, K)
  return first(keys(lf[1]))
end

function unramified_extension(L::LocalField, n::Int, prec::Int, s::String = "z")
  K, mK = residue_field(L)
  f = find_irreducible_polynomial(K, n)
  coeffs =
  return local
end
=#

function eisenstein_extension(f::Generic.Poly{S}, s::String = "a"; check::Bool = true, cached::Bool = true) where S
  return local_field(f, s, EisensteinLocalField, check = check, cached = cached)
end

function unramified_extension(f::Generic.Poly{S}, s::String = "a"; check::Bool = true, cached::Bool = true) where S
  return local_field(f, s, UnramifiedLocalField, check = check, cached = cached)
end

function local_field(f::Generic.Poly{S},::Type{T}; check::Bool = true, cached::Bool = true) where {S <: FieldElem, T <: LocalFieldParameter}
  return local_field(f, "a", T, check = check, cached = cached)
end

function local_field(f::Generic.Poly{S}, s::String, ::Type{EisensteinLocalField}; check::Bool = true, cached::Bool = true) where {S <: FieldElem}
  symb = Symbol(s)
  if check && !is_eisenstein_polynomial(f)
    error("Defining polynomial is not Eisenstein")
  end
  K = LocalField{S, EisensteinLocalField}(f, symb)
  return K, gen(K)
end

function local_field(f::Generic.Poly{S}, s::String, ::Type{UnramifiedLocalField}; check::Bool = true, cached::Bool = true) where {S <: FieldElem}
  symb = Symbol(s)
  if check && !_generates_unramified_extension(f)
    error("Defining polynomial is not irreducible over the residue field!")
  end
  K = LocalField{S, UnramifiedLocalField}(f, symb)
  return K, gen(K)
end

function local_field(f::Generic.Poly{S}, s::String, ::Type{T} = GenericLocalField; check::Bool = true, cached::Bool = true) where {S <: FieldElem, T <: LocalFieldParameter}
  symb = Symbol(s)
  if check && !is_irreducible(f)
    error("Defining polynomial is not irreducible")
  end
  K = LocalField{S, T}(f, symb)
  return K, gen(K)
end

function local_field(f::QQPolyRingElem, p::Int, precision::Int, s::String, ::Type{T} = GenericLocalField; check::Bool = true, cached::Bool = true) where T <: LocalFieldParameter
  @assert is_prime(p)
  K = PadicField(p, precision)
  fK = map_coefficients(K, f)
  return local_field(fK, s, T, cached = cached, check = check)
end

function defining_polynomial(K::LocalField, n::Int = ceil(Int, precision(K)/ramification_index(K)))
  if !haskey(K.def_poly_cache, n)
    K.def_poly_cache[n] = K.def_poly(n)
  end
  return K.def_poly_cache[n]
end

function precision(K::LocalField)
  return K.precision*ramification_index(K)
end

function setprecision!(K::LocalField, n::Int)
  K.precision = ceil(Int, n/ramification_index(K))
  return nothing
end

function setprecision(f::Function, K::Union{LocalField, FlintPadicField, FlintQadicField}, n::Int)
  old = precision(K)
#  @assert n>=0
  setprecision!(K, n)
  v = try 
        setprecision(f, base_field(K), ceil(Int, n/ramification_index(K)))
      finally
        setprecision!(K, old)
      end
  return v
end


################################################################################
#
#  Uniformizer
#
################################################################################

function uniformizer(K::LocalField{S, EisensteinLocalField}) where S <: FieldElem
  return gen(K)
end

function uniformizer(K::LocalField{S, UnramifiedLocalField}) where S <: FieldElem
  return K(uniformizer(base_field(K)))
end

function uniformizer(K::LocalField{S, GenericLocalField}) where S <: FieldElem
  error("Not yet implemented")
end

################################################################################
#
#  residue_field
#
################################################################################

function residue_field(K::LocalField{S, EisensteinLocalField}) where {S <: FieldElem}
  if isdefined(K, :residue_field_map)
    mp = K.residue_field_map
    return codomain(mp), mp
  end
  k = base_field(K)
  ks, mks = residue_field(k)

  function proj(a::LocalFieldElem)
    @assert parent(a) === K
    for i = 1:degree(a.data)
      if valuation(coeff(a, i)) < 0
        error("The projection is not well defined!")
      end
    end
    return mks(coeff(a, 0))
  end

  function lift(a)
    @assert parent(a) === ks
    return setprecision(K(mks\(a)), precision(K))
  end
  mp = MapFromFunc(proj, lift, K, ks)

  K.residue_field_map = mp

  return ks, mp
end

 ########### Residue field of unramified local field ext ################
function residue_field(K::LocalField{S, UnramifiedLocalField}) where {S <: FieldElem}
   if isdefined(K, :residue_field_map)
     mp = K.residue_field_map
     return codomain(mp), mp
   end
   k = base_field(K)
   ks, mks = residue_field(k)
   Fpt = polynomial_ring(ks, cached = false)[1]
   g = defining_polynomial(K)
   f = Fpt([ks(mks(coeff(g, i))) for i=0:degree(K)])
   kk = Native.FiniteField(f)[1]
   bas = basis(K)
   u = gen(kk)
   function proj(a::Hecke.LocalFieldElem)
     col = typeof(kk(1))[]
     v = one(kk)
     for i = 0:degree(K)-1
       push!(col, mks(coeff(a,i)) * v )
       v *= u
     end
     return sum(col)
   end
   function lift(b::Hecke.FinFieldElem)
     col = typeof(K(1))[]
     for i = 0:degree(kk)-1
       #coerce to ks as fqPolyRepFieldElem have coeffs UInt, thus preimage would fail
       push!(col, K(mks\(ks(coeff(b,i)))) * bas[i+1] )
     end
     return sum(col)
   end
   mp = MapFromFunc(proj, lift, K, kk)
   K.residue_field_map = mp
  return kk, mp
end

 ################### unramified extension over local field L of a given degree n ####################

 function unramified_extension(L::Union{FlintPadicField, FlintQadicField, LocalField}, n::Int)
   R, mR = residue_field(L)
   f = polynomial(R, push!([rand(R) for i = 0:n-1], one(R)))
   while !is_irreducible(f)
     f = polynomial(R, push!([rand(R) for i = 0:n-1], one(R)))
   end
   f_L = polynomial(L, [mR\(coeff(f, i)) for i = 0:degree(f)])
   return unramified_extension(f_L)
 end

@doc raw"""
    image_of_logarithm_one_units(K::NonArchLocalField) -> (Int, Vector)

Returns a tuple `(n, x)` consisting of a positive integer `n` and a list of elements of `K`,
sucht that image of the one units under `log` is the union of the cosets of the `x[i]` with
respect to `P^n`.
"""
function image_of_logarithm_one_units(K::NonArchLocalField)
  e = absolute_ramification_index(K)
  p = prime(K)
  if p - 1 > e
    # log and exp inverse to each other on U^(1) and P
    return 1, [zero(K)]
  end

  if mod(e, p - 1) == 0
    n = Int(div(e, p - 1) + 1)
  else
    n = ceil(Int, e//(p - 1))
  end

  # Thus U^(n) -> P^n is an isomorphism by the usual result, see e.g. Neukirch.
  # Lets compute representatives for U^(1)/U^(n)
  F, KtoF = residue_field(K)
  reps = elem_type(K)[KtoF\a for a in F]
  C = cartesian_product_iterator(reps, n - 1)
  pi = uniformizer(K)
  pipowers = [pi^i for i in 1:(n - 1)]
  res = elem_type(K)[]
  for c in C
    logg = log(1 + sum(c[i] * pipowers[i] for i in 1:(n - 1)))
    if any(x -> iszero(x - logg) || e * valuation(x - logg) >= n, res)
      continue
    end
    push!(res, logg)
  end
  if length(C) == length(res)
    return 1, [zero(K)]
  else
    return n, res
  end
end
