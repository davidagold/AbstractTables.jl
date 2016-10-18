type Grouped{T, I} <: AbstractTable
    source::T
    group_indices::I
    group_levels
    groupbys
    predicate_aliases
end

type GroupLevels
    levels::Vector{Vector}
end

Base.indices(group_levels::GroupLevels, j) = group_levels.levels[j]

function Base.isequal(grouped1::Grouped, grouped2::Grouped)
    isequal(grouped1.source, grouped2.source) || return false
    isequal(grouped1.group_indices, grouped2.group_indices) || return false
    isequal(grouped1.groupbys, grouped2.groupbys) || return false
    return true
end

function Base.hash(grouped::Grouped)
    h = hash(grouped.source) + 1
    h = hash(grouped.indices, h)
    h = hash(grouped.groupbys, h)
    return @compat UInt(h)
end
