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
        eltype, eltypes(src, arg_fields...)
    )

    # TODO: check for non-leaf types and follow slow path
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...},))
    # FIXME: selections don't have any function calls to lift, so return type
    # is not `Nullable`, whereas transformations have lifted calls and so return
    # `Nullable` types
    T = ifelse(T <: Nullable, eltype(T), T)
    res_column = NullableVector{T}()

    _apply!(res_column, h, row_itr)
    res[res_field] = res_column
    return
end

function _apply!(res_column, h::SQ.SelectHelper, row_itr)::Void
    f = h.f
    for row in row_itr
        push!(res_column, f(row))
    end
    return
end
