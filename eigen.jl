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


XX4 = copy(XX)
using Arpack
eigs(XX4,nev=1)[1][1]


#1. no need to Symmetric(XX2), because Julia will detect whether it is Symmetric.
#2. eigmax: first do eigvals(), then return the maximum
#3. both eigen!() and eigvals!() use BLAS function LAPACK.sygvd! if input is symmetric.
#4. eigen!() is slower than eigvals!(). Why?

#5. eigs() in Arpack.jl is faster than eigvals() because eigs() use Arnoldi iterative methods for top eigen values, but eigvals() use LAPACK (QR algorithm). QR algotirhm will return all the eigen values.
#http://hua-zhou.github.io/teaching/biostatm280-2017spring/slides/16-eigsvd/eigsvd.html#Lanczos/Arnoldi-iterative-method-for-top-eigen-pairs
