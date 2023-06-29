import Nemo.characteristic, Nemo.gen, Nemo.size
export gen, characteristic, size, elem_to_mat_row!, rand

function gen(R::Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T<:PolyElem
  return R(gen(base_ring(R)))
end

function gen(R::Union{Generic.ResidueRing{fqPolyRepPolyRingElem},Generic.ResidueField{fqPolyRepPolyRingElem}}) ## this is not covered by above
  return R(gen(base_ring(R)))              ## and I don't know why
end

function gen(R::Union{Generic.ResidueRing{zzModPolyRingElem},Generic.ResidueField{zzModPolyRingElem}})
  return R(gen(base_ring(R)))
end

function characteristic(R::Union{Generic.ResidueRing{Nemo.ZZRingElem},Generic.ResidueField{Nemo.ZZRingElem}})
  return modulus(R)
end

function characteristic(R::Union{Generic.ResidueRing{zzModPolyRingElem},Generic.ResidueField{zzModPolyRingElem}})
  return characteristic(base_ring(base_ring(R)))
end

function characteristic(R::Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T<:PolyElem
  return characteristic(base_ring(base_ring(R)))
end

# discuss: size = order? order = size?
function size(R::Nemo.Union{Generic.ResidueRing{Nemo.zzModPolyRingElem},Generic.ResidueField{Nemo.zzModPolyRingElem}})
  return characteristic(R)^degree(modulus(R))
end

function size(R::Nemo.Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T <: ResElem
  return size(base_ring(base_ring(R)))^degree(modulus(R))
end

function size(R::Nemo.Union{Generic.ResidueRing{ZZRingElem},Generic.ResidueField{ZZRingElem}})
  return modulus(R)
end

function size(R::Nemo.Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T<:PolyElem
  return size(base_ring(base_ring(R)))^degree(R.modulus)
end

function size(R::Nemo.Union{Generic.ResidueRing{fqPolyRepPolyRingElem},Generic.ResidueField{fqPolyRepPolyRingElem}})
  return size(base_ring(base_ring(R)))^degree(R.modulus)
end

function size(R::FqPolyRepField)
  return order(R)
end

function size(R::fqPolyRepField)
  return order(R)
end

function size(F::fpField)
  return order(F)
end

function size(F::Nemo.FpField)
  return order(F)
end

function order(R::Nemo.zzModRing)
  return ZZRingElem(R.n)
end

#################################################
# in triplicate.... and probably cases missing...
function elem_to_mat_row!(M::MatElem, i::Int, a::ResElem{T}) where T <: PolyElem
  z = zero(parent(M[1,1]))
  for j=0:degree(a.data)
    M[i,j+1] = coeff(a.data, j)
  end
  for j=degree(a.data)+2:ncols(M)
    M[i,j] = z
  end
end
function elem_to_mat_row!(M::MatElem, i::Int, a::ResElem{FqPolyRepPolyRingElem})
  z = zero(parent(M[1,1]))
  for j=0:degree(a.data)
    M[i,j+1] = coeff(a.data, j)
  end
  for j=degree(a.data)+2:ncols(M)
    M[i,j] = z
  end
end
function elem_to_mat_row!(M::MatElem, i::Int, a::ResElem{fqPolyRepPolyRingElem})
  z = zero(parent(M[1,1]))
  for j=0:degree(a.data)
    M[i,j+1] = coeff(a.data, j)
  end
  for j=degree(a.data)+2:ncols(M)
    M[i,j] = z
  end
end

function rand(R::Union{Generic.ResidueRing{ZZRingElem},Generic.ResidueField{ZZRingElem}})
  return R(rand(ZZRingElem(0):(size(R)-1)))
end

function rand(R::Generic.ResidueField{ZZRingElem})
  return R(rand(ZZRingElem(0):(order(R)-1)))
end

function rand(R::Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T<:PolyElem
  r = rand(base_ring(base_ring(R)))
  g = gen(R)
  for i=1:degree(R.modulus)
    r = r*g + rand(base_ring(base_ring(R)))
  end
  return r
end

function rand(R::Union{Generic.ResidueRing{fqPolyRepPolyRingElem},Generic.ResidueField{fqPolyRepPolyRingElem}})
  r = rand(base_ring(base_ring(R)))
  g = gen(R)
  for i=1:degree(R.modulus)
    r = r*g + rand(base_ring(base_ring(R)))
  end
  return r
end

function rand(R::Union{Generic.ResidueRing{FqPolyRepPolyRingElem},Generic.ResidueField{FqPolyRepPolyRingElem}})
  r = rand(base_ring(base_ring(R)))
  g = gen(R)
  for i=1:degree(R.modulus)
    r = r*g + rand(base_ring(base_ring(R)))
  end
  return r
end

function rand(R::Union{Generic.ResidueRing{zzModPolyRingElem},Generic.ResidueField{zzModPolyRingElem}})
  r = rand(base_ring(base_ring(R)))
  g = gen(R)
  for i=1:degree(R.modulus)
    r = r*g + rand(base_ring(base_ring(R)))
  end
  return r
end


#######################################################
##
##
##
#######################################################

function gens(R::Union{Generic.ResidueRing{T},Generic.ResidueField{T}}) where T<:PolyElem ## probably needs more cases
                                          ## as the other residue functions
  g = gen(R)
  r = Vector{typeof(g)}()
  push!(r, one(R))
  if degree(R.modulus)==1
    return r
  end
  push!(r, g)
  for i=2:degree(R.modulus)-1
    push!(r, r[end]*g)
  end
  return r
end

function gens(R::Union{Generic.ResidueRing{zzModPolyRingElem},Generic.ResidueField{zzModPolyRingElem}})
  g = gen(R)
  r = Vector{typeof(g)}()
  push!(r, one(R))
  if degree(R.modulus)==1
    return r
  end
  push!(r, g)
  for i=2:degree(R.modulus)-1
    push!(r, r[end]*g)
  end
  return r
end

function rem!(f::Nemo.zzModPolyRingElem, g::Nemo.zzModPolyRingElem, h::Nemo.zzModPolyRingElem)
  ccall((:nmod_poly_rem, libflint), Nothing, (Ref{Nemo.zzModPolyRingElem}, Ref{Nemo.zzModPolyRingElem}, Ref{Nemo.zzModPolyRingElem}), f, g, h)
  return f
end

function gcd!(f::Nemo.zzModPolyRingElem, g::Nemo.zzModPolyRingElem, h::Nemo.zzModPolyRingElem)
  ccall((:nmod_poly_gcd, libflint), Nothing, (Ref{Nemo.zzModPolyRingElem}, Ref{Nemo.zzModPolyRingElem}, Ref{Nemo.zzModPolyRingElem}), f, g, h)
  return f
end

function gcd!(f::Nemo.fpPolyRingElem, g::Nemo.fpPolyRingElem, h::Nemo.fpPolyRingElem)
  ccall((:nmod_poly_gcd, libflint), Nothing, (Ref{Nemo.fpPolyRingElem}, Ref{Nemo.fpPolyRingElem}, Ref{Nemo.fpPolyRingElem}), f, g, h)
  return f
end
