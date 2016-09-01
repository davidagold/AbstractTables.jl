function jplyr._collect{T<:AbstractTable}(
    g_tbl::Grouped{T},
    g::jplyr.SummarizeNode
)
    ngroupbys = length(g_tbl.groupbys)
    return group_summarize(Val{ngroupbys}(), g_tbl, g)
end

new_groupby_column(groupby_field, tbl) = similar(tbl[groupby_field], 0)

function build_groupby_resources{T<:AbstractTable}(g_tbl::Grouped{T})
    groupby_columns = Dict{Symbol, Vector}()
    groupby_fields = map(
        x -> isa(x, Symbol) ? x : g_tbl.predicate_aliases[x],
        g_tbl.groupbys
    )
    for groupby_field in groupby_fields
        groupby_column = new_groupby_column(groupby_field, g_tbl.source)
        groupby_columns[groupby_field] = groupby_column
    end
    return groupby_fields, groupby_columns
end

@generated function group_summarize{N}(::Val{N}, g_tbl, node)
    # generate expression for (group_1, ..., group_n) inner loop variables
    group_tuple_ex = Expr(:tuple)
    for i in 1:N
        push!(group_tuple_ex.args, Symbol("group_$i"))
    end

    return quote
        groupby_fields, groupby_columns  = build_groupby_resources(g_tbl)
        res_columns = Dict{Symbol, Vector}()
        group_levels = g_tbl.group_levels

        @nloops $N group group_levels begin
            if !haskey(g_tbl.group_indices, $group_tuple_ex)
                continue
            end

            # push group levels to appropriate groupby columns
            @nexprs $N j-> push!(groupby_columns[groupby_fields[j]], group_j)

            # compute each summarization and insert into appropriate
            # result column
            for helper in node.helpers
                res_field, f, g, arg_fields = jplyr.parts(helper)
                if haskey(res_columns, res_field)
                    push!(
                        res_columns[res_field],
                        rhs_summarize(f, g, arg_fields, g_tbl, $group_tuple_ex)
                    )
                else
                    res_columns[res_field] =
                        [rhs_summarize(f, g, arg_fields, g_tbl, $group_tuple_ex)]
                end
            end
        end

        new_tbl = default(g_tbl.source)
        new_tbl.metadata[:groupby_predicates] = g_tbl.predicate_aliases
        for groupby_field in groupby_fields
            new_tbl[groupby_field] = groupby_columns[groupby_field]
        end
        for helper in node.helpers
            res_field, f, g, arg_fields = jplyr.parts(helper)
            new_tbl[res_field] = res_columns[res_field]
        end
        return new_tbl
    end
end

function rhs_summarize(f, g, arg_fields, g_tbl, key)
    T, row_itr = _preprocess(f, arg_fields, g_tbl, key)

    # Allocate a temporary column.
    temporary = Array(T, 0)

    # Fill the new column in row-by-row, skipping nulls.
    grow_nonnull_output!(temporary, f, row_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
