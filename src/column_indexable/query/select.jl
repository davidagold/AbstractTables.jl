function StructuredQueries._collect(src::AbstractTable, q::StructuredQueries.SelectNode)
    res = default(src)
    for h in q.helpers
        apply!(res, h, src)
    end
    return res
end

function apply!(res, h::SQ.SelectHelper, src)::Void
    res_field, f, arg_fields, = SQ.parts(h)
    row_itr = eachrow(src, arg_fields...)
    inner_eltypes = map(
        eltype,
        eltypes(src, arg_fields...)
    )

    # TODO: check for non-leaf types and follow slow path
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...},))
    res_column = NullableVector{T}()

    _apply!(res_column, h, row_itr)
    res[res_field] = res_column
    return
end

function _apply!(res_column, h::SQ.SelectHelper, row_itr)::Void
    T = eltype(res_column)
    f = h.f
    for row in row_itr
        if hasnulls(row)
            push!(res_column, Nullable{T}())
        else
            v = f(map(unsafe_get, row))
            push!(res_column, v)
        end
    end
    return
end
