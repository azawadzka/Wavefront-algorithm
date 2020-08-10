function [bool] = index_in_bounds(grid, x,y)
    bool = true;
    if x < 1 || y < 1
        bool = false;
    end
    s = size(grid);
    if x > s(1) || y > s(2)
        bool = false;
    end
end

