function jplyr._collect(tbl::AbstractTable, g::jplyr.SummarizeNode)
    new_tbl = empty(tbl)
    for helper in g.helpers
        res_fld, f, g, arg_fields = jplyr.parts(helper)
        new_tbl[res_fld] = rhs_summarize(f, g, tbl, arg_fields)
    end
    return new_tbl
end


@noinline function rhs_summarize(f, g, tbl, arg_flds)
    # Pre-process table w/r/t row kernel and argument column names
    T, row_itr = _preprocess(f, tbl, arg_flds)

    # Allocate a temporary column.
    temporary = Array(T, 0)

    # Fill the new column in row-by-row, skipping nulls.
    grow_nonnull_output!(temporary, f, row_itr)

    # Return the summarization function applied to the temporary.
    return NullableArray([g(temporary)])
end

"""
Grow non-null values.
"""
@noinline function grow_nonnull_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if !jplyr.hasnulls(tpl)
            push!(output, f(map(jplyr.unsafe_get, tpl)))
        end
    end
    return
end
