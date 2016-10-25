# TODO: Check if this function (which potentially has to do run-time method
# dispatch) is a bottleneck. If there were no uncertainty whether elements were
# going to be Nullable, that could be resolved.
# NOTE: Quick testing suggests this is not the bottleneck for most code.
@inline function hasnulls(itr::Any)::Bool
    res = false
    for el in itr
        if isa(el, Nullable)
            res |= isnull(el)
        end
    end
    return res
end

function pushrow!(columns, row)::Void
    # TODO: safety checks
    for (col, v) in zip(columns, row)
        push!(col, v)
    end
    return
end

"""
    subset(tpl::Tuple, I::Tuple)

Produce a subset of `tpl` based on the contents of `I` (assumed to be numeric
indices).
"""
@generated function subset{J}(tpl::Tuple, I::Tuple{Vararg{Int, J}})
    res = Expr(:tuple)
    idxs = map(j->Expr(:ref, :I, j), 1:J)
    els = map(k->Expr(:ref, :tpl, idxs[k]), 1:J)
    res.args = els
    return res
end
