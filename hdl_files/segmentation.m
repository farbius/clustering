%% segmentation algorithm
% A Rostov 12/06/2018
% a.rostov@riftek.com
%%
clc
clear

% формирование массива входных данных 
N = 21; % количество точек доступных для кластеризации
 x = randi(255, 1, N);
% x = [99 166 195 147 162 71 215 109 162 213 69 103 142 114 24 190 9 110 10 249 134 232 98 226 66 232 229 102 160 145 229 55 1 225 60 63 164 78];
 y = randi(255, 1, N);
% y = [211 226 242 100 205 41 160 179 22 136 227 68 60 215 127 39 59 168 144 75 159 183 72 106 93 200 35 231 74 128 200 173 39 178 33 242 227 132];
D = 100; % дистанция для критерия при сортировке

fdata = fopen('x_point.txt','w');
for i = 1:N 
    fprintf(fdata,'%x\n', x(i));     
end
fclose(fdata);

fdata = fopen('y_point.txt','w');
for i = 1:N 
    fprintf(fdata,'%x\n', y(i));     
end
fclose(fdata);


cluster_number = -1*ones(1, N);

list_output = cell(10 ,2); % выходной массив  [Кластер, [индексы точек]]
list_input  = cell(1,  N); % входной массив (good matches) [X Y]
for i = 1 : N 
    list_input{1,i} = cat(2, x(i), y(i));
    list_output{i}{2}(:) = zeros(1, N);
    list_output{i}{1}(:) = 0;
end

%% таблица расстояний
dist = zeros (N, N);
for i = 1 : N
    for j = 1 : N
        dist(i, j) = (sqrt((list_input{i}(1) - list_input{j}(1))^2 + (list_input{i}(2) - list_input{j}(2))^2));
    end
end

dist_sq = floor(dist.^2./2);
for i = 1 : N
    for j = 1 : N
        dist(i, j) = floor(sqrt((list_input{i}(1) - list_input{j}(1))^2 + (list_input{i}(2) - list_input{j}(2))^2));
    end
end
%% минимальное расстояние между точками
n         = 0;        % номер координаты
m         = 1;        % номер кластера
best_pair = cell(1);  % список для двух пар координат
vector_index = zeros(1, N);
while(n <  N) 
    min_dist  = 1e5;
    for i = 1 : N
        for j = 1 : N
            if(dist(i, j) > 0 && dist(i, j) < min_dist)
                min_dist = dist(i, j);
                best_pair{1} = [i j];
            end        
        end
    end
        dist(best_pair{1}(1), best_pair{1}(2)) = -1;
        dist(best_pair{1}(2), best_pair{1}(1)) = -1;
    if(min_dist < D)
        cluster_number(best_pair{1}(1)) = m;
        cluster_number(best_pair{1}(2)) = m;
        n = n + 2;  
        vector_index = [best_pair{1}(1), vector_index(1:N-1)];
        vector_index = [best_pair{1}(2), vector_index(1:N-1)];       
    for j = 1 : N % заполняем текущий кластер 
        % анализ строк
        if(dist(best_pair{1}(1), j) > 0 && dist(best_pair{1}(1), j) < D && cluster_number(j) == -1)
            cluster_number(j) = m;
            vector_index = [j, vector_index(1:N-1)];
            dist(best_pair{1}(1), j) = -1; % расстояние до использованных точек помечаю -1
            dist( j, best_pair{1}(1)) = -1; % расстояние до использованных точек помечаю -1
            n = n + 1;
        end      
        % анализ столбцов
        if(dist(j, best_pair{1}(2)) > 0 && dist(j, best_pair{1}(2)) < D && cluster_number(j) == -1)
            cluster_number(j) = m;
            vector_index = [j, vector_index(1:N-1)];
            dist(j, best_pair{1}(2)) = -1; % расстояние до использованных точек помечаю -1
            dist(best_pair{1}(2), j) = -1; % расстояние до использованных точек помечаю -1
            n = n + 1; % увеличиваем количество использованных точек
        end        
    end    
    for j = 1 : N
        if(cluster_number(j) ~= -1)
            dist(j, :) = -1;
            dist(:, j) = -1;
        end    
    end
        list_output{m} = {m, vector_index};
        vector_index   = zeros(1, N);
        m = m + 1; % инкрементируем номер кластера    
    else %   min_dist < D     
        for j = 1 : N % заполняем текущий кластер 
            if(cluster_number(j) == -1)
                cluster_number(j) = m;
                vector_index = [j, vector_index(1:N-1)];
                list_output{m} = {m, vector_index};
                vector_index   = zeros(1, N);
                n = n + 1; % увеличиваем количество использованных точек
                m = m + 1; % инкрементируем номер кластера
                dist(j, :) = -1;
            end            
        end            
    end   %  ! min_dist < D          
end       %% n точек 
%% вычисление центров кластеров и поиск текущего лучшего кластера 
max = 0;
best_claster = {1};
center = 0;
for i = 1 : N
    n = 0;
    for j = 1 : N
       if(list_output{i}{2}(j) ~= 0) 
          n = j;   % размер текущего кластера
       end
    end  
        if(n > max)
            max = n;
            x_sum = 0;
            y_sum = 0;
            best_claster{1} = [n list_output{i}{1}];   % записываю размер и индекс наилучшего кластера
            for k = 1 : n
                x_sum = x_sum + list_input{(list_output{i}{2}(k))}(1);
                y_sum = y_sum + list_input{(list_output{i}{2}(k))}(2);
            end           
             x_sum = floor (x_sum / n);
             y_sum = floor (y_sum / n);
        end    
end
x_sum
y_sum


lref = cell(m - 1,2);
n = 1;

for r = 1 : m - 1
    for k = 1 : N
      if(cluster_number(k) == r)  
        lref{r, n} = k - 1;
        n = n + 1;
      end
    end
    n = 1;
end

save('lref');






