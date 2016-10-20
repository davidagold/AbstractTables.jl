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

indices0 = find(x->x==0, C)
indices1 = find(x->x==1, C)
_A0 = A[indices0]
_A1 = A[indices1]
avg_A0 = mean(_A0)
avg_A1 = mean(_A1)
_res = MyTable(
    C = NullableArray([0, 1]),
    avg = NullableArray([avg_A0, avg_A1]),
)

res = @collect groupby(src, C) |>
    summarize(avg = mean(A))

end
