function jplyr._collect(src, q::jplyr.FilterNode)
    res = empty(default(src))
    flds = fields(src)
    for (field, T) in zip(flds, map(eltype, eltypes(src, flds...)))
        res[field] = NullableVector{T}()
    end
    for helper in q.helpers
        apply!(res, helper, src)
    end
    return res
end

function apply!(res, helper::jplyr.FilterHelper, src)::Void
    f, arg_fields, = jplyr.parts(helper)
    row_itr = eachrow(src)
    _apply!(res, helper, row_itr)
    return
end

function _apply!(res, helper::jplyr.FilterHelper, row_itr)::Void
    f, arg_fields = jplyr.parts(helper)
    cols = columns(res)
    indices = [ index(res)[field] for field in arg_fields ]
    # TODO: Make sure following is safe (in case of error in push!ing)
    for whole_row in row_itr
        args = whole_row[indices]
        if jplyr.hasnulls(args)
            continue
        elseif f(map(jplyr.unsafe_get, args))
            for (j, v) in enumerate(whole_row)
                push!(cols[j], v)
            end
        else
            continue
        end
    end
    return
end
