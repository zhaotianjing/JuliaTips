### 1.
@async will return a "Task" type.
Use `fetch()` to get value. 

```
t = @async 1+1
```
#>>Task (done) @0x00007f64619e8550

```
fetch(t)
```
#>>2


### 2.
Fucntion to calculate pi:
```
function work(N)
    series = 1.0
    for i in 1:N
        series += (isodd(i) ? -1 : 1) / (i*2+1)
    end
    return 4*series
end
```

```
#precompile
work(100)
```
```
@time work(100_000_000)
```
#>>0.178186 seconds (5 allocations: 176 bytes)

### 3. do each task one-by-one. 
```
@time @sync for i in 1:10
    @async work(100_000_000)
end
```
#>>1.844235 seconds (77.87 k allocations: 3.771 MiB)

Time is the same as for-loop
```
@time for i in 1:10
    t = @async work(100_000_000)
    fetch(t)
end
```
#>>1.714652 seconds (24.96 k allocations: 1.349 MiB)
or
```
@time  for i in 1:10
     work(100_000_000)
end
```
#>>1.721287 seconds

### 4.
* @async creates and starts running a task
* @sync waits for them to all complete
```
@time for i in 1:10
    t = @async work(100_000_000)
end
```
#>> 0s

But this code makes no sense because we always want to know the answer.


### 5. Sleep() is special because sleep is nicely cooperating with tasks. Avoid testing with sleep().
```
@time @sync for i in 1:10
    @async sleep(1)
end
```
#>>1.007097 seconds (2.02 k allocations: 133.505 KiB)

