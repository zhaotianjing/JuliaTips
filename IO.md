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
