function SQ._collect(src::AbstractTable, g::SQ.SummarizeNode)
    res = default(src)
    for h in g.helpers
        apply!(res, h, src)
    end
    return res
end

function apply!(tbl, h::SQ.SummarizeHelper, src)::Void
    res_field, f, g, arg_fields = SQ.parts(h)
    T, row_itr = _preprocess(f, src, arg_fields)
    temp = Vector{T}()
    grow_nonnull_output!(temp, f, row_itr)
    tbl[res_field] = NullableArray([g(temp)])
    return
end

@noinline function grow_nonnull_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if !hasnulls(tpl)
            push!(output, f(map(unsafe_get, tpl)))
        end
    end
    return
end
