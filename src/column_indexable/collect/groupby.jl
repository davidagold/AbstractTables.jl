function SQ._collect(_src::AbstractTable, q::SQ.GroupbyNode)
    # Make a copy, don't mutate
    src = copy(_src)
    # Map from predicates (e.g. `A > .5`) to aliasing column names (e.g. `pred_1`)
    predicates = Dict{Symbol, Expr}()
    groupbys = pre_groupby!(src, q, predicates)
    return groupby(src, groupbys, predicates)
end

"""
    pre_groupby!(src, q, predicate_aliases)

(i) push predicate aliases (e.g. `:(A > .5) => :pred_1`) to `predicate_aliases`;
(ii) mutate src to include predicate transformations.
"""
function pre_groupby!(src, q, predicates)
    _groupbys = copy(q.args)
    groupbys = Vector{Symbol}(length(_groupbys))
    i = 1 # count number of predicates encountered
    for (h, (j, groupby)) in zip(q.helpers, enumerate(_groupbys))
        is_predicate, f, arg_fields = SQ.parts(h)
        if is_predicate
            alias = Symbol("pred_$i")
            predicates[alias] = groupby
            groupbys[j] = alias
            # include the result of applying the predicate as a new column
            apply!(src, SQ.SelectHelper(alias, f, arg_fields), src)
            i += 1
        else
            groupbys[j] = Symbol(groupby)
        end
    end
    return groupbys
end

"""
    groupby{T<:AbstractTable}(src::T, groupbys, predicate_aliases)::Grouped{T}


"""
function groupby{T<:AbstractTable}(src::T, groupbys, predicates)::Grouped
    metadata = Dict{Symbol, Any}()
    metadata[:predicates] = predicates
    # obtain the field names of the groupbys (either the names of the selected
    # columns or the predicate aliases given to groupby predicates)
    # groupbys = map(x->isa(x, Symbol) ? x : aliases[x], groupbys)
    group_indices, group_levels = build_group_data(src, groupbys)
    # TODO: work out this collect(src) hack
    return Grouped(collect(src), group_indices, groupbys, group_levels, metadata)
    # return Grouped(src, group_indices, groupbys, group_levels, metadata)
end

"""
    build_group_data(src, groupbys)
"""
function build_group_data(src, groupbys)
    row_itr = eachrow(src, groupbys...)
    # TODO: type this more strongly
    group_indices = Dict{Any, Vector{Int}}()
    group_levels = grow_indices!(group_indices, row_itr)
    return group_indices, group_levels
end

@noinline function grow_indices!(group_indices, row_itr)::Vector{Tuple}
    group_levels = Vector{Tuple}()
    for (i, row) in enumerate(row_itr)
        # the row is the group level
        if haskey(group_indices, row)
            push!(group_indices[row], i)
        else
            group_indices[row] = [i]
            push!(group_levels, row)
        end
    end
    return group_levels
end
