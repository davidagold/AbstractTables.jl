function SQ._collect(src::AbstractTable, g::SQ.SummarizeNode)
    res = default(src)
    for h in g.helpers
        apply!(res, h, src)
    end
    return res
end

function apply!(tbl, h::SQ.SummarizeHelper, src)::Void
    res_field, f, g, arg_fields = SQ.parts(h)
    T, tpl_itr = _preprocess(f, src, arg_fields)
    temp = Vector{T}()
    _apply!(temp, h, tpl_itr)
    tbl[res_field] = NullableArray([g(temp)])
    return
end

@noinline function _apply!(output, h::SQ.SummarizeHelper, tpl_itr)::Void
    f = h.f
    for (i, tpl) in enumerate(tpl_itr)
        v = f(tpl)
        !isnull(v) ? push!(output, unsafe_get(v)) : nothing
    end
    return
end
