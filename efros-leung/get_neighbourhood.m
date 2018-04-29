function [neighbourhood, mask] = get_neighbourhood(output_image, filled_map, pix_row, pix_col, window_size)


half_window = floor(window_size / 2);

neighbourhood = output_image(pix_row-half_window:pix_row+half_window, pix_col-half_window:pix_col+half_window, :);
mask = filled_map(pix_row-half_window:pix_row+half_window, pix_col-half_window:pix_col+half_window);
end