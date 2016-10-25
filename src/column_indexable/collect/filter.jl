# function start(q)


function SQ._collect(srcs, q::SQ.Node{:filter})

    # assume there's only one source
    # Following is not generic over multiple sources, but that's okay for now

    # @show srcs
    src = first(srcs)
    res = default(src)
    col_index = index(src)

    _predicates = []
    arg_idxs = Vector{Tuple{Vararg{Int}}}()
    for h in q.helpers
        f, arg_fields = h.parts
        push!(_predicates, f)
        push!(arg_idxs, tuple([ col_index[field] for field in arg_fields[:i] ]...))
    end
    predicates = tuple(_predicates...)

    # res = default(srcs)
    # arg_idxs = Dict{Symbol, Tuple{Vararg{Int}}}()
    # src_indexes = Dict{Symbol, Dict{Symbol, Int}}()
    # src_indexes = [ index(src) for src in srcs ]
    # for token in keys(arg_fields)
    #     arg_idxs[token] =
    #         tuple([ src_indexes[token][field] for field in arg_fields[token] ]...)
    # end

    for (field, T) in zip(fields(src), eltypes(src))
        res[field] = NullableVector{eltype(T)}()
    end

    cols = columns(res)
    rows = eachrow(src)
    #
    # for token in keys(arg_fields)
    #     idxs = arg_idxs[token]
    #     rows = eachrow(srcs[token])

    # idxs = arg_idxs_map
    for i in rows
        v = Nullable(true)
        for (p, idx) in zip(predicates, arg_idxs)
            args = subset(i, idx)
            v = SQ.lift(&, v, p(args))
            ifelse(v.hasvalue, v.value, false) || break
        end
        ifelse(v.hasvalue, v.value, false) && pushrow!(cols, i)
    end
    return res
end
