clc
clear

fidR = fopen('index_point.txt',   'r');
fidG = fopen('index_cluster.txt', 'r');

load('lref')

% get indexes and clusters into vectors
  index_point   = fscanf(fidR,'%d');  
  index_cluster = fscanf(fidG,'%d');  
  
fclose(fidR);
fclose(fidG);

N = length(index_point)
num_cluster = index_cluster(N)
l = cell(num_cluster,1);
% ls = cell(num_cluster,1);
m = 1;
n = 1;
for i = 1: N
    if(index_cluster(i) == m)
    l{m, n} = index_point(i);
    n = n + 1;
    else 
    m = m + 1;
    n = 1;
    l{m, n} = index_point(i);
    n = n + 1;
    end
end

% sort
ls = cell(num_cluster,1);
g = zeros(1, N);
for k = 1: num_cluster
    g = sort(cell2mat( l(k, :)));
    for ln = 1 : length(g)
        ls{k, ln} = g(ln);
    end
end

error = 0;
% compare
for k = 1: num_cluster
    g = sort(cell2mat( l(k, :)));
    for ln = 1 : length(g)
        if(ls{k, ln} ~= lref{k, ln})
           error = error + 1 ;
        end
    end
end
error
