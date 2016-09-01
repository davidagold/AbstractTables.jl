# function _collect(src, ::Iterable, q::SelectNode)

"""
Required interface:

    * `default(src)`
    * `eachrow(src [, fields...])`
    * `eltypes(src [, fields...])`

Note that `default` must return a type that satisfies the column indexable
interface
"""
function jplyr._collect(src::AbstractTable, q::jplyr.SelectNode)
    # TODO: Figure out interplay between `empty` and `default`
    # res = empty(default(src))
    res = default(src)
    for helper in q.helpers
        apply!(res, helper, src)
    end
    return res
end

function apply!(res, helper::jplyr.SelectHelper, src)
    res_field, f, arg_fields, = jplyr.parts(helper)
    row_itr = eachrow(src, arg_fields...)
    inner_eltypes = map(
        eltype,
        eltypes(src, arg_fields...)
    )

    # TODO: check for non-leaf types and follow slow path
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...},))
    res_column = NullableVector{T}()

    _apply_select!(res_column, f, row_itr)
    res[res_field] = res_column
    return
end

function _apply_select!(res_column, f, row_itr)
    T = eltype(res_column)
    for row in row_itr
        if hasnulls(row)
            push!(res_column, Nullable{T}())
        else
            v = f(map(unwrap, row))
            push!(res_column, v)
        end
    end
    return
end
