function SQ._collect(
    src1, src2, q::SQ.InnerJoinNode
)
    build, probe = plan(src1, src2)
    bucket = Dict{}()
    res = default(src1, src2)

    h = q.helpers[1]
    f_build = h.f
    arg_fields_build = h.arg_fields1
    build_itr = eachrow(build)
    arg_idxs = tuple(map(field -> index(build)[field], arg_fields_build)...)
    for i in build_itr
        v = f_build(subset(i, arg_idxs))
        isnull(v) && continue # skip null values
        rows = get!(bucket, v, Vector{Tuple}())
        push!(rows, i)
    end

    f_probe = h.g
    arg_fields_probe = h.arg_fields2
    # map fields to numeric indices
    arg_idxs = tuple(map(field -> index(probe)[field], arg_fields_probe)...)
    probe_itr = eachrow(probe)
    res_cols = [
        NullableVector{eltype(T)}() for T in vcat(eltypes(probe), eltypes(build))
    ]
    ni = ncol(probe)
    nj = ncol(build)
    for i in probe_itr
        v = f_probe(subset(i, arg_idxs))
        isnull(v) && continue # skip null values
        if haskey(bucket, v) # There's a match
            bucket[v]
            for j in bucket[v]
                # join probe row to bucket row and push!
                joinpush!(res_cols, i, ni, j, nj)
            end
        end
    end

    for (fld, col) in zip(vcat(fields(probe), fields(build)), res_cols)
        res[fld] = col
    end
    return res
end

function joinpush!(columns, i, ni, j, nj)::Void
    for s in 1:ni
        push!(columns[s], i[s])
    end
    for s in 1:nj
        push!(columns[s+ni], j[s])
    end
end

# TODO: implement actual criteria for deciding which source should be build
#       source, which should be probe source
plan(src1, src2) = src1, src2
