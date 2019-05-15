srun -N 4 -n 4 -t 1   
-N 4 means 4 nodes, -n 4 means 4 disks.  So you get 1 task per node.  

"c10-76" and "c10-77" mean?  
Those all are hostnames.  


I'd recommend scontrol show job <job number>  

Nodes can have more than one job, which makes it really confusing if you don't
look at the job info.  Additionally a single job can use more than one node,
making it a doubly good idea that you look at the job info, not the node info.


But with slurm you specify the number of MPI
processes you want with -n, which specifies the number of tasks.  Then you
specify the number of processes you want per MPI task with -c.

So -n 8 -c 1 starts 8 MPI processes that launches a process for each MPI task.

But -n 8 -c 4 starts 8 MPI processes, but each one is allocated 4 CPUs.

module load julia   
tianjing@farm:~/MPI.jl/examples$ srun -N 1 -n 3 -t 1 julia ./01-hello.jl  

MPI is pretty poor for anything embarrassingly parallel.  Keep in mind that 10
CPUs using MPI is often much slower than 10 times faster than 1.  But
embarrassingly parallel use is often 10 times faster.

Srun isn't assigning work, that's up to your job.  So I'd just say:
srun -N 1 -n 10 ./MPI_mv.jl

Then have your MPI code load each piece sequentially.

But if you are using MPI to load each piece on a single CPU you are basically
doing it wrong.

If your code uses a single CPU to process a single piece, then I'd just do
srun --array=1-200 ./julia

Then your julia code just processes that piece and exits.  Compared to MPI:
* It's more efficient than MPI
* It's more robust than MPI
* the job size can increases (unlike MPI)
* the job size can decrease (unlike MPI)
* the job can launch as soon as any resources are available (unlike MPI).
* If one job dies, the other will finish (unlike MPI)



high is best, bmh are intended for large memory jobs that run on a single node.
 Generally codes will scale much better in the parallel partition than they will
in the bmh partition.


You now have:
#SBATCH --nodes=1

That's less than ideal as well.  The less you specify the faster your job runs.

Just ask for the number of tasks and ram you want and let slurm find those spare resources for you.



Are you sure you need multiple nodes?  It does add significant complexity and today's nodes are
quite impressive performance wise.

Well Julia is in the family of interpreted languages like R and Python.  Typically for the code YOU
write they are quite slow.  But when you make a function call for machine learning, linear algebra,
various large libraries for just about anything you name, they can be quite efficient.  So if
there's an library implementation for what you need they can be great.  If you need to write a
substantial amount of new low level code it can be horribly inefficient.  For that reasons often the
heavy lifting for R, Python, and Julia are done by libraries... written in C, C++, or Fortran.

Often the bottleneck in a new project is programmer time, not CPU efficiency.  So the higher level
languages can help get something working more quickly.

Have you checked out Julia's native message passing?  They have native support for message passing
(without MPI) and are generally simpler to use than MPI.  I've taught a graduate level course in MPI
programming, and I can assure you it's quite complex.  I've done quite a bit of programming over the
last few decades and MPI programming is by far the most difficult.

As far as efficiency goes, keep in mind that you should partition the work at the highest possible
level.  Communications are EXTREMELY expensive and should be minimized both in number and in size.
If your code is "embarassingly" parallel you should NOT use MPI or message passing.  Instead you
should split your problem into N pieces and run N jobs on it.

For instance sending a single integer between nodes, which takes around 1 millionth of a second.  In
that time the bm nodes (that you mentioned earlier) can run 280m instructions!

>> Can you cut/paste the prompt, command, arguments, and job number for the
> working case and the non-working?
> 
> I will reply to you later. I want to try more things.
> 
> Question: Could you please tell me what is the usual way to run code on
> multi-node? using MPI with C language?

There's many approaches.  I'd make sure you need multiple nodes first.  Most MPI codes are C, C++,
or Fortran (or a hybrid of those languages).  Embarassingly parallel jobs often use slurm job arrays
to split the data and calculate on a piece or shared separately.  Julia isn't particularly common
yet, but it is gaining traction.  Most of the julia code I've seen if using up to a full node, but
not multiple nodes.

The more fine grained your parallelism and the more custom your code the more likely you'll need C,
C++, and/or Fortran and MPI.  However it's a very efficient, but also a very labor intensive
approach.  Typically this effort is made for large codes intended to run on large clusters, where
anything less would not return reasonable results within reasonable time frames.  Things like
weather simulations, large molecular dynamics simulations, Computational fluid dynamics codes, and
related.

But for more network intensive things like network services, the go language is quite popular and
has native support for supporting multiple CPUs, and has popular support for communicating
efficiently between nodes with various APIs like gRPC, Protobufs, and related.

So basically there's tons of options, it depends on exactly what you are doing.

tianjing@farm:~$ srun -p bmh -N 1 -n 2 -t 1 julia ./simu.jl

> But when I enter into a worker node (eg. bm1), I can run `srun -N 1 -n 2 -t
> 1 julia ./simu.jl`  without error.

I suspect it's picking a different partition by default, it's best to name the
partition as I did above.

> Could you please me what's the difference between `srun` in the head
> node(@farm) and in worker node?

Just different default partitions, it's best to just name the partition.

To run this you'll need 20GB per task.  So instead of trying to do the math ahead of time I'd just
use --mem-per-cpu=21G or similar.


If you launch 8 MPI processes, all 8 run all lines of code in program.  So if
you want rank 0 to be the only one to read from disk, and the only one to
generate a bunch of random numbers, then you need to do something like:
if (rank == 0)
{
     read_file(...
     send_buffer = allocate_20GB
     generate_random(...
} else {
        rec_buffer = allocate_mem(20GB/NumProcesses)
}

Does that make sense?

Although keep in mind this will not scale well, since you have a single process
(rank 0) that needs to allocate all memory.  It would be MUCH better to say
generate 5GB and send it to rank 1, then 5GB and send it to rank 2, etc.

That way even with 1000 processes you wouldn't bottleneck on the rank 0 maximum
memory.

In the parallel queue you can use up to 4 nodes/128 CPUs, or more nodes with less CPUs.

In the BM partitions (bml, bmm, and bmh) you can use 1 node/96 CPUs, but it's not really designed
for parallel/multinode use, so I think I limit it to a single node.  There's a large cost to the
network to allow multi-node scaling and generally we don't expect the bm nodes to be used that way.

Generally I think what you are trying to do would be better with something like:
$ sbatch -N 1 -n 1 -c 4

You don't need to ask 
for 1 node if you are only asking for 1 cpu and you don't need ntasks-per-node when asking for 1 core.


