function SQ._collect(
    src1::AbstractTable, src2::AbstractTable, q::SQ.InnerJoinNode
)
    build, probe = plan(src1, src2)
    bucket = Dict{}()

    res = default(src1, src2)

    f_build = q.f
    arg_fields_build = q.arg_fields1
    build_itr = eachrow(build, arg_fields_build...)

    for (i, tpl) in enumerate(build_itr)
        v = f_build(tpl)
        rows = get!(bucket, v, Vector{Int}())
        row = ( ... )
        push!(rows, row)
    end

    f_probe = q.g
    arg_fields_probe = q.arg_fields2
    probe_itr = eachrow(probe, arg_fields_probe)
    for tpl in probe_itr
        v = f_probe(tpl)
        if haskey(bucket, v)
            rows = bucket[v]
            for row in rows
                ...
            end
        end
    end

    return res
end

function apply

end


# TODO: implement actual criteria for deciding which source should be build
#       source, which should be probe source
plan(src1, src2) = src1, src2
