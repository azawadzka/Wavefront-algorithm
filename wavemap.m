%--------------Practica 3----------------
% References
% 3D plotting https://www.mathworks.com/help/matlab/visualize/creating-3-d-plots.html
% Scatter plot https://www.mathworks.com/help/matlab/ref/scatter.html
% Struct data type https://www.mathworks.com/help/matlab/ref/struct.html

% default use of function as in the example // provided in the course
[pos obs] = ExtractPathScans('mydata2018_02_26_14_42_05.log', 45/180*pi);

nscans = length(obs.x);

% number of data entries collected in each scan
nentries = length(obs.x{1,1});

% plot the data: the route of the robot and all points detected by the scanner
% plot(pos.x, pos.y)
% hold on
% for i = 1:nscans
%     scatter(obs.x{1,i}, obs.y{1,i}, 10)
% end
% hold off

% precision in (0, 0.5>
precision = 0.5;
if precision <= 0 || precision > 5
    % stop execution due to unfulfilled conditions
    disp("Incorrect precision. The allowed precision range is (0, 0.5].");
    return
end
% size room 16 units on the positive and 2 units on the negative
size_room = 16 + 2;

for i = 1:nscans
    % 1. move each value 2 units to the positive value (lowest values reach -2)
    % 2. divide by precision
    % 3. floor to get number of the grid
    % 4. move each value 1 unit to the right to make the 1st index positive
    % 5. obs.xg, obs.yg - gridded values
    % Resulting values in <2,24>
    obs.xg{1, i} = floor((obs.x{1, i} + 2) / precision); 
    obs.yg{1, i} = floor((obs.y{1, i} + 2) / precision); 
end


% number of cells in each dimension of the grid
ngrid = size_room / precision;

% grid matrix represents areas in the room sized [precision x precision] of original units
% holds number of laser reads within each area
grid = zeros([ngrid ngrid]); 

% aggregate the data about points into grid matrix
 for i = 1:nscans
     for j = 1:nentries
         grid = put_to_grid(grid, obs.xg{1, i}(j), obs.yg{1, i}(j));
     end
 end

% normalise (divide by the largest element so the values fit in range <0,1>)
grid = grid / max(max(grid));

mesh(grid)


% Parameters
starting_point = [30 12];
final_point = [7 33];

wave_map = zeros(size(grid));
wave_map(grid > 0.01) = -1; % obstacles, the threshold value chosen based on observations

i = 1;
wave_map(starting_point(1), starting_point(2)) = i;

% Generate wave_map

while wave_map(final_point(1), final_point(2)) == 0

    [x y] = find(wave_map == i);
    i = i+1;
    for k = [x';y']
        % right
        ix = k(1) + 1;
        iy = k(2);
        if index_in_bounds(grid, ix, iy) && wave_map(ix, iy) == 0
            wave_map(ix, iy) = i;
        end
        % left
        ix = k(1) - 1;
        iy = k(2);
        if index_in_bounds(grid, ix, iy) && wave_map(ix, iy) == 0
            wave_map(ix, iy) = i;
        end
        % up
        ix = k(1);
        iy = k(2) + 1;
        if index_in_bounds(grid, ix, iy) && wave_map(ix, iy) == 0
            wave_map(ix, iy) = i;
        end
        % down
        ix = k(1);
        iy = k(2) - 1;
        if index_in_bounds(grid, ix, iy) && wave_map(ix, iy) == 0
            wave_map(ix, iy) = i;
        end
    end
end

% Generate path

steps_list = [];
list_end = 1;
steps_list(list_end, :) = final_point;
value = wave_map(final_point(1), final_point(2));

while value > 1
    value = value - 1;
    x = steps_list(list_end, 1);
    y = steps_list(list_end, 2);
    list_end = list_end + 1;
    % right
    if wave_map(x+1, y) == value
        steps_list(list_end, :) = [x+1, y];
    % left
    elseif wave_map(x-1, y) == value
        steps_list(list_end, :) = [x-1, y];
    % up
    elseif wave_map(x, y+1) == value
        steps_list(list_end, :) = [x, y+1];
    % down
    elseif wave_map(x, y-1) == value
        steps_list(list_end, :) = [x, y-1];
    end
end

% display map
s = size(steps_list);
wave_map(wave_map == -1) = s(1) + 10;

image(wave_map)
colorMap = jet(s(1) + 10);
colormap(colorMap);
colorbar;

hold on 
% display startinf and target points
scatter(starting_point(2), starting_point(1), 40, 'w', 'filled');
scatter(final_point(2), final_point(1), 40, 'k', 'filled');
% display line
for k = 1:s(1)-1
    dx = [steps_list(k,1), steps_list(k+1,1)];
    dy = [steps_list(k,2), steps_list(k+1,2)];
    line(dy, dx, 'Color', 'k');
end
hold off




