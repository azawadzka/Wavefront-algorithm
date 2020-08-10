function [grid] = put_to_grid(grid, x, y)
    %PUT_TO_GRID Increase the field of the grid on the location x,y by 1
    % if any value is NaN, ignore
    if ~isnan(x) & ~isnan(y)
        grid(x,y) = grid(x,y) + 1;
    end
end

