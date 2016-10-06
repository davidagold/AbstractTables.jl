function SQ._collect(src, q::SQ.FilterNode)
    res = default(src)
    flds = fields(src)
    for (field, T) in zip(flds, map(eltype, eltypes(src, flds...)))
        res[field] = NullableVector{T}()
    end
    for h in q.helpers
        apply!(res, h, src)
    end
    return res
end

function apply!(res, h::SQ.FilterHelper, src)::Void
    f, arg_fields, = SQ.parts(h)
    row_itr = eachrow(src)
    _apply!(res, h, row_itr)
    return
end

function _apply!(res, h::SQ.FilterHelper, row_itr)::Void
    f, arg_fields = SQ.parts(h)
    cols = columns(res)
    idx = index(res)
    indices = [ idx[field] for field in arg_fields ]
    # TODO: Make sure following is safe (in case of error in push!ing)
    # TODO: Find out if iterating over whole rows and pushing rows that satisfy
    # filter predicate is more performant than iterating over rows derived only
    # from columns that are arguments to filter predicate and producing a list
    # of indices
    for whole_row in row_itr
        args = whole_row[indices]
        v = f(args)
        if isnull(v)
            continue
        elseif unsafe_get(v)
            for (j, v) in enumerate(whole_row)
                push!(cols[j], v)
            end
        else
            continue
        end
    end
    return
end
