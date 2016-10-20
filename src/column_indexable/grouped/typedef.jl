type Grouped{T, I} <: AbstractTable
    source::T
    group_indices::I
    groupbys::Vector{Symbol}
    group_levels::Vector{Tuple}
    metadata::Dict{Symbol, Any}
end
