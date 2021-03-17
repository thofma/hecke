struct ZZIdl
  gen::fmpz

  function ZZIdl(x::fmpz)
    if x < 0
      return new(abs(x))
    else
      return new(x)
    end
  end
end

struct ZZFracIdl
  gen::fmpq

  function ZZFracIdl(x::fmpq)
    if x < 0
      return new(abs(x))
    else
      return new(x)
    end
  end
end

# constructors
*(::FlintIntegerRing, x::Union{Integer,fmpz}) = ideal(ZZ, x)

*(x::Union{Integer,fmpz}, ::FlintIntegerRing) = ideal(ZZ, x)

ideal(::FlintIntegerRing, x::fmpz) = ZZIdl(x)

ideal(::FlintIntegerRing, x::Integer) = ZZIdl(fmpz(x))

fractional_ideal(::FlintIntegerRing, x::fmpq) = ZZFracIdl(x)

fractional_ideal(::FlintIntegerRing, x::RingElement) = ZZFracIdl(fmpq(x))

*(x::fmpq, ::FlintIntegerRing) = ZZFracIdl(x)

*(::FlintIntegerRing, x::fmpq) = ZZFracIdl(x)

# printing
function Base.show(io::IO, x::ZZIdl)
  print(io, "$(x.gen)ZZ")
end

function Base.show(io::IO, x::ZZFracIdl)
  print(io, "Fractional ideal $(x.gen)ZZ")
end

# comparison
function ==(I::ZZIdl, J::ZZIdl)
  return I.gen == J.gen
end

# access
gen(I::ZZIdl) = I.gen

gens(I::ZZIdl) = fmpz[I.gen]


gen(I::ZZFracIdl) = I.gen
gens(I::ZZFracIdl) = fmpq[I.gen]

#TODO

# arithmetic

function +(I::ZZIdl, J::ZZIdl)
  g = gcd(I.gen, J.gen)
  return ZZIdl(g)
end

function *(s::fmpz, J::ZZIdl)
  return ZZIdl(s*J.gen)
end

function (J::ZZIdl, s::fmpz)
  return ZZIdl(s*J.gen)
end

# TODO

maximal_order(::FlintRationalField) = ZZ

ideal_type(::FlintIntegerRing) = ZZIdl
order_type(::FlintRationalField) = FlintIntegerRing

fractional_ideal_type(::FlintRationalField) = ZZFracIdl

# Infinite places

isreal(::PosInf) = true
iscomplex(::PosInf) = false

infinite_places(::FlintRationalField) = [inf]
infinite_place(::FlintRationalField) = inf

function infinite_place(::FlintRationalField, i::Int)
  i !=1 && error("Index must be 1")
  return inf
end

real_places(::FlintRationalField) = PosInf[inf]

complex_places(::FlintRationalField) = PosInf[]

function sign(x::Union{fmpq,fmpz},p::PosInf)
  return sign(x)
end

function signs(a::Union{fmpq,fmpz}, l::Array{PosInf, 1})
  return Dict((inf, sign(a)))
end

function ispositive(x::Union{fmpq,fmpz},p::PosInf)
  return x > 0
end

function istotally_positive(x::Union{fmpq,fmpz},p::PosInf)
  return x > 0
end

function isnegative(x::Union{fmpq,fmpz},p::PosInf)
  return x < 0
end

number_field(::PosInf) = QQ

uniformizer(::PosInf) = QQ(-1)

infinite_places_uniformizers(::FlintRationalField) = fmpq[QQ(1)]
