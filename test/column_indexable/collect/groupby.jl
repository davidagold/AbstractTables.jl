module TestGroupBy

using AbstractTables
using TestCollect
using Base.Test

name = ["Niamh", "Roger", "Genevieve", "Aiden"]
age = [27, 63, 26, 17]
eye_color = ["green", "brown", "brown", "blue"]

people = MyTable(
    name = NullableArray(name),
    age = NullableArray(age),
    eye_color = NullableArray(eye_color)
)
_people = copy(people)

group_indices = Dict{Any, Vector{Int}}([
    ("brown",false) => [3],
    ("green",true)  => [1],
    ("brown",true)  => [2],
    ("blue",false)  => [4],
])

q = @query groupby(people, eye_color, age > 26)
res = collect(q)

@test isequal(people, _people)
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
    @test isequal(res.group_indices[group_level], indices)
end

@test isequal(res.groupbys, q.graph.args)

end
