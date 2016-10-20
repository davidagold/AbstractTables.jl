module TestGroupedSummarize

using AbstractTables
using TestCollect
using Base.Test

n = 100
A = rand(n)
B = rand(n)
C = rand(1:2, n)
src = MyTable(
    A = NullableArray(A),
    B = NullableArray(B),
    C = NullableArray(C),
)

indices1 = find(x->x==1, C)
indices2 = find(x->x==2, C)
_A1 = A[indices1]
_A2 = A[indices2]
avg_A1 = mean(_A1)
avg_A2 = mean(_A2)
_res = MyTable(
    C = NullableArray([1, 2]),
    avg = NullableArray([avg_A1, avg_A2]),
)
res = @collect groupby(src, C) |>
    summarize(avg = mean(A))

# Test Sets because summarize doesn't guarantee ordering.
# TODO: Better workaround for above.
@test isequal(Set(_res[:C]), Set(res[:C]))
@test isequal(Set(_res[:avg]), Set(res[:avg]))

end
