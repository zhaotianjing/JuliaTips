```
open("D:\\IIBLMM_data\\geno_ztj.txt", "w") do io
    writedlm(io, geno_array)
end
```

```
writedlm(io, geno_array,',')
writedlm(io, geno_array,' ')
```

Same size with `','`,`' '` or `'\t'`

```
readdlm("delim_file.txt", ',')
```

save many variables at one time, instead of one at a time. There is no `data["a"] ` and `data["b"]` here.
```
using JLD
a=zeros(2,3)
save("D:\\IIBLMM_data\\t.jld","a",a)

b=ones(2,4)
save("D:\\IIBLMM_data\\t.jld","b",b)

c=randn(2,2)
save("D:\\IIBLMM_data\\t.jld","c",c)

data_path = "D:\\IIBLMM_data\\t.jld"
data      = load(data_path);

data["c"] 
```
