module TestSelect

using AbstractTables
using TestCollect
using Base.Test

A = [1, 2, 3]
B = [4, 5, 6]
C = ["a", "b", "c"]
D = [:a, :b, :c]

src = MyTable(
    A = NullableArray(A),
    B = NullableArray(B),
    C = NullableArray(C),
    D = NullableArray(D)
)
_src = copy(src)

for (field, col) in eachcol(src)
    @eval res = @collect select(src, $field)
    @test isequal(src, _src)
    @test isequal(
        res,
        @eval MyTable($field = $col)
    )
end

F = [ A[i] * B[i] for i in eachindex(A) ]
_res = MyTable(F = NullableArray(F))
res = @collect select(src, F = A * B)
@test isequal(src, _src)
@test isequal(res, _res)

# non-standard lifting semantics

# isnull(x)
src = MyTable(
    A = NullableArray(collect(1:5), [true, false, true, false, true])
)
_res = MyTable(
    B = NullableArray([true, false, true, false, true])
)

res = @collect select(src, B = isnull(A))
@test isequal(res, _res)

end
