using LinearAlgebra

X = randn(40_000,40_000);
XX = X'X;

XX1 = copy(XX)
@time F1 = eigen(XX1)
@show F1.values[end]


XX2 = copy(XX)
@time F2 = eigvals(XX2)
@show F2[end]


XX3 = copy(XX)
@time F3 = LAPACK.syev!('N', 'U', XX3) #!! will change XX3 inplace
@show F3[end]
