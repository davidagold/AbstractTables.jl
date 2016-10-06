module TestFilter

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

# basic functionality

_res = MyTable(
    A = NullableArray([3]),
    B = NullableArray([6]),
    C = NullableArray(["c"]),
    D = NullableArray([:c])
)
res = @collect filter(src, A > 2)
@test isequal(src, _src)
@test isequal(res, _res)

# non-standard lifting semantics

# three-valued logic semantics for |
src = MyTable(
    A = NullableArray([true, true, false, false]),
    B = NullableArray([false, false, true, true], [true, false, true, false])
)
_src = copy(src)
_res = MyTable(
    A = NullableArray([true, true, false]),
    B = NullableArray([false, false, true], [true, false, false])
)
res = @collect filter(src, A | B)
@test isequal(src, _src)
@test isequal(res, _res)

# three-valued logic semantics for &
src = MyTable(
    A = NullableArray([true, true, false, false]),
    B = NullableArray([true, true, false, false], [true, false, true, false])
)
_src = copy(src)

_res = MyTable(
    A = NullableArray([true]),
    B = NullableArray([true], [false])
)
res = @collect filter(src, A & B)
@test isequal(src, _src)
@test isequal(res, _res)

# isnull(x)

src = MyTable(
    A = NullableArray([true, true, false, false]),
    B = NullableArray([true, true, false, false], [true, false, true, false])
)
_src = copy(src)

_res = MyTable(
    A = NullableVector{Bool}(),
    B = NullableVector{Bool}()
)
res = @collect filter(src, isnull(A))
@test isequal(src, _src)
@test isequal(res, _res)

_res = MyTable(
    A = NullableArray([true, true, false, false]),
    B = NullableArray([true, true, false, false], [true, false, true, false])
)
res = @collect filter(src, !isnull(A))
@test isequal(src, _src)
@test isequal(res, _res)

_res = MyTable(
    A = NullableArray([true, false]),
    B = NullableArray([true, false], [true, true])
)
res = @collect filter(src, isnull(B))
@test isequal(src, _src)
@test isequal(res, _res)



end
