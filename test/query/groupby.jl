module TestGroupBy
using AbstractTables
using Base.Test

include("mytable.jl")

name = ["Niamh", "Roger", "Genevieve", "Aiden"]
age = [27, 63, 26, 17]
eye_color = ["green", "brown", "brown", "blue"]

tbl = MyTable(
    name = NullableArray(name),
    age = NullableArray(age),
    eye_color = NullableArray(eye_color)
)
_tbl = copy(tbl)

group_indices = Dict{Any, Vector{Int}}([
    ("brown",false) => [3],
    ("green",true)  => [1],
    ("brown",true)  => [2],
    ("blue",false)  => [4],
])

qrya = @query groupby(tbl, eye_color, age > 26)
qryb = @query tbl |> groupby(eye_color, age > 26)

tbl2a = collect(qrya)
tbl2b = collect(qryb)

@test isequal(tbl, _tbl)
@test isequal(tbl2a, tbl2b)
for (group_level, indices) in zip(
    [
        (Nullable("brown"), Nullable(false)),
        (Nullable("green"), Nullable(true)),
        (Nullable("brown"), Nullable(true)),
        (Nullable("blue"), Nullable(false))
    ],
    [
        [3],
        [1],
        [2],
        [4]
    ]
)
    @test isequal(tbl2a.group_indices[group_level], indices)
end

@test isequal(tbl2a.groupbys, qrya.graph.args)

end
