# Adapted from
# https://github.com/JuliaData/AbstractTables.jl/blob/e5afc569504ecf08ec769fd52a78da4027eab35f/src/AbstractTable/show.jl

let
    local io = IOBuffer(Array(UInt8, 80), true, true)
    global ourstrwidth
    function ourstrwidth(x::Any)::Int
        truncate(io, 0)
        ourshowcompact(io, x)
        return position(io)
    end
    ourstrwidth(x::AbstractString) = strwidth(x) + 2 # -> Int
    # myconv = VERSION < v"0.4-" ? convert : Base.unsafe_convert
    ourstrwidth(s::Symbol) =
        @compat Int(
            ccall(:u8_strwidth, Csize_t, (Ptr{UInt8}, ),
            Base.unsafe_convert(Ptr{UInt8}, s))
        )
end

ourshowcompact(io::IO, x::Any)::Void = showcompact(io, x)
ourshowcompact(io::IO, x::AbstractString)::Void = showcompact(io, x)
ourshowcompact(io::IO, x::Symbol)::Void = print(io, x)

function getmaxwidths(tbl::AbstractTable, rowlabel, limit, offset)::Vector{Int}
    ncols = ncol(tbl)
    widths = [ Vector{Int}() for j in 1:ncols ]
    maxwidths = Array{Int}(ncol(tbl) + 1)
    undefstrwidth = ourstrwidth(Base.undef_ref_str)

    rows = eachrow(tbl)
    st = start(rows)
    i = 1
    while (i <= offset) & (!done(rows, st))
        row, st = next(rows, st)
        i += 1
    end
    while (i <= offset + limit) & (!done(rows, st))
        row, st = next(rows, st)
        for (j, v) in enumerate(row)
            try
                push!(widths[j], ourstrwidth(v))
            catch
                push!(widths[j], undefstrwidth)
            end
        end
        i += 1
    end
    flds = fields(tbl)
    for j in 1:ncols
        if isempty(widths[j])
            maxwidths[j] = ourstrwidth(flds[j])
        else
            maxwidths[j] = max(maximum(widths[j]), ourstrwidth(flds[j]))
        end
    end
    maxwidths[end] = max(ourstrwidth(rowlabel), ndigits(limit)+1)
    return maxwidths
end

function getprintedwidth(maxwidths::Vector{Int})::Int
    # Include length of line-initial |
    totalwidth = 1
    for i in 1:length(maxwidths)
        # Include length of field + 2 spaces + trailing |
        totalwidth += maxwidths[i] + 3
    end
    return totalwidth
end

pad(io, padding)::Void = print(io, " "^padding)

function print_bounding_line(io, maxwidths, j_left, j_right)::Void
    rowmaxwidth = maxwidths[end]
    print(io, '├')
    print(io, "─"^(rowmaxwidth + 2))
    print(io, '┼')
    for j in j_left:j_right
        print(io, "─"^(maxwidths[j] + 2))
        if j < j_right
            print(io, '┼')
        else
            print(io, '┤')
        end
    end
    print(io, '\n')
end

# NOTE: returns a Bool indicating whether or not there are more rows than what
# has printed
function print_tbl_rows(
    io, tbl, maxwidths, j_left, j_right, rowlabel, limit, offset
)::Bool
    rowmaxwidth = maxwidths[end]
    flds = fields(tbl)
    rows = eachrow(tbl, flds[j_left:j_right]...)
    st = start(rows)
    i = 1
    while (i <= offset) & (!done(rows, st))
        row, st = next(rows, st)
        i += 1
    end
    while (i <= offset + limit) & (!done(rows, st))
        row, st = next(rows, st)
        @printf(io, "│ %d", i)
        pad(io, rowmaxwidth - ndigits(i))
        print(io, " │ ")
        # print table entry
        for j in j_left:j_right
            v = row[j]
            strlen = ourstrwidth(v)
            ourshowcompact(io, v)
            pad(io, maxwidths[j] - strlen)
            if j == j_right
                if i == (limit+offset)
                    print(io, " │")
                else
                    print(io, " │\n")
                end
            else
                print(io, " │ ")
            end
        end
        i += 1
    end
    return (i > (limit+offset)) & (!done(rows, st))
end

function print_tbl_footer(
    io, tbl::AbstractTable, ::RowDimUnknown, more_rows, j_right, limit, offset
)::Void
    println(io, "\n⋮")
    ncols = ncol(tbl)
    if j_right < ncols
        flds = fields(tbl)
        @printf(io, "with more rows and %d more columns: ", ncols - j_right)
        for j in j_right+1:(ncol-1)
            field = flds[j]
            print(io, "$field, ")
        end
        print(io, "$field.")
    else
        print(io, "with more rows.")
    end
end

function print_tbl_footer(
    io, tbl::AbstractTable, ::HasRowDim, more_rows, j_right, limit, offset
)::Void
    ncols = ncol(tbl)
    if more_rows
        println(io, "\n⋮")
        if j_right < ncols
            if offset > 0
                @printf(
                    io,
                    "with %d more rows (skipped the first %d rows) and %d more columns: ",
                    nrow(tbl)-(limit+offset),
                    offset,
                    ncols - j_right
                )
            else
                @printf(
                    io,
                    "with %d more rows and %d more columns: ",
                    nrow(tbl)-limit,
                    ncols - j_right
                )
            end
            flds = fields(tbl)
            for j in j_right+1:(ncols-1)
                field = flds[j]
                print(io, "$field, ")
            end
            field = flds[ncols]
            print(io, "$field.")
        else
            if offset > 0
                @printf(
                    io,
                    "with %d more rows (skipped the first %d rows).",
                    nrow(tbl)-(limit+offset),
                    offset
                )
            else
                @printf(io, "with %d more rows.", nrow(tbl)-limit)
            end
        end
    else
        if j_right < ncols
            println(io, "\n⋮")
            @printf(io, "with %d more columns: ", ncols - j_right)
            flds = fields(tbl)
            for j in j_right+1:(ncols-1)
                field = flds[j]
                print(io, "$field, ")
            end
            field = flds[ncols]
            print(io, "$field.")
        end
    end
    return
end

function print_tbl_header(io, tbl, maxwidths, j_left, j_right, rowlabel)::Void
    rowmaxwidth = maxwidths[end]
    flds = fields(tbl)
    @printf(io, "│ %s", rowlabel)
    pad(io, rowmaxwidth - ourstrwidth(rowlabel))
    print(io, " │ ")
    for j in j_left:j_right
        field = flds[j]
        ourshowcompact(io, field)
        pad(io, maxwidths[j] - ourstrwidth(field))
        j == j_right ? print(io, " │\n") : print(io, " │ ")
    end
    print_bounding_line(io, maxwidths, j_left, j_right)
    return
end

function getchunkbounds(
    io, maxwidths::Vector{Int}, splitchunks::Bool,
    availablewidth::Int=displaysize(io)[2]
)::Vector{Int}
    ncols = length(maxwidths) - 1
    rowmaxwidth = maxwidths[end]
    if splitchunks
        chunkbounds = [0]
        # Include 2 spaces + 2 | characters for row/col label
        totalwidth = rowmaxwidth + 4
        for j in 1:ncols
            # Include 2 spaces + | character in per-column character count
            totalwidth += maxwidths[j] + 3
            if totalwidth > availablewidth
                push!(chunkbounds, j - 1)
                totalwidth = rowmaxwidth + 4 + maxwidths[j] + 3
            end
        end
        push!(chunkbounds, ncols)
    else
        chunkbounds = [0, ncols]
    end
    return chunkbounds
end

# 1 space for line-initial | + length of field + 2 spaces + trailing |
printedwidth(maxwidths)::Void = foldl((x,y)->x+y+3, 1, maxwidths)

function show_ci_tbl(
    io, tbl::AbstractTable, rowlabel = :Row, displaysummary = true,
    splitchunks = true, showall = false, limit = 10, offset = 0
)::Void
    ncols = ncol(tbl)
    if ncols > 0
        displaysummary && println(io, summary(tbl))
        maxwidths = getmaxwidths(tbl, rowlabel, limit, offset)
        chunkbounds = getchunkbounds(io, maxwidths, splitchunks | !showall)
        if !showall
            j_left, j_right = 1, chunkbounds[2]
            print_tbl_header(io, tbl, maxwidths, j_left, j_right, rowlabel)
            more_rows = print_tbl_rows(
                io, tbl, maxwidths, j_left, j_right, rowlabel, limit, offset
            )
            print_tbl_footer(
                io, tbl, tblrowdim(tbl), more_rows, j_right, limit, offset
            )
        else
            nchunks = length(chunkbounds) - 1
            more_rows = false
            for r in 1:nchunks
                j_left = chunkbounds[r] + 1
                j_right = chunkbounds[r + 1]

                print_tbl_header(io, tbl, maxwidths, j_left, j_right, rowlabel)
                more_rows |= print_tbl_rows(
                    io, tbl, maxwidths, j_left, j_right, rowlabel, limit, offset
                )
            end
            print_tbl_footer(
                io, tbl, tblrowdim(tbl), more_rows, false, limit, offset
            )
        end
    else
        @printf(io, "An empty %s", typeof(tbl))
    end
    return
end

show_ci_tbl(tbl::AbstractTable, limit, offset)::Void =
    show(STDOUT, tbl, :Row, true, limit, offset)
