add_verbosity_scope(:AbsNumFieldOrder)
add_assertion_scope(:AbsNumFieldOrder)

#set_verbosity_level(:NfOrd, 1)

include("NfOrd/NfMaxOrd.jl")
include("NfOrd/Ideal.jl")
include("NfOrd/Zeta.jl")
include("NfOrd/FracIdl.jl")
include("NfOrd/Clgp.jl")
include("NfOrd/Unit.jl")
include("NfOrd/ResidueField.jl")
include("NfOrd/ResidueRing.jl")
include("NfOrd/ResidueRingMultGrp.jl")
include("NfOrd/FactorBaseBound.jl")
include("NfOrd/FacElem.jl")
include("NfOrd/LinearAlgebra.jl")
include("NfOrd/IdealLLL.jl")
include("NfOrd/Narrow.jl")
include("NfOrd/norm_eqn.jl")
include("NfOrd/RayClass.jl")
include("NfOrd/RayClassFacElem.jl")
