clc;clear;
tic;
input_image = im2double(imread('161.png'));
mask_image = im2double(rgb2gray(imread('161_mask.png')));
window_size = 17;
half_window = floor(window_size / 2);
[num_rows, num_cols, num_channels] = size(input_image);
[output_image, filled_map] = generate_filled_map(input_image,mask_image );

figure();
imshow(input_image);

ref_y1=1;ref_x1=1;
ref_y2=128;ref_x2=128;

ref_image = input_image(ref_x1:ref_x2,ref_y1:ref_y2,:);
num_horiz_candidates = ref_x2 - ref_x1 - window_size + 2;
num_vert_candidates = ref_y2 - ref_y1 - window_size + 2;
candidates = zeros(window_size^2, num_horiz_candidates * num_vert_candidates, num_channels);

for channel = 1:num_channels
    can_size = 0;
    for j = ref_y1 + half_window : ref_y2 - half_window
        for i = ref_x1 + half_window : ref_x2 - half_window
               can_size = can_size + 1;
               checkwindow = filled_map(i-half_window:i+half_window,j-half_window:j+half_window);
               if (all(checkwindow==1))
                   temp_window = input_image(i-half_window:i+half_window,j-half_window:j+half_window,channel);
                   candidates(:,can_size,channel)=temp_window(:);
               end
        end
    end
end
permuted_candidates = permute(candidates,[1 3 2]);
stacked_candidate_channels = reshape(permuted_candidates,[],size(candidates,2),1);
sigma = 6.4;
gaussian = fspecial('gaussian', [window_size window_size], window_size / sigma);
gaussian_vec = reshape(gaussian, [], 1);
gaussian_vec = repmat(gaussian_vec, size(candidates, 3), 1);


figure();
imshow(output_image);
figure();
error_threshold = 0.1;
max_error_threshold = 0.3;

while ~all(all(filled_map))

    found_match = false;
    unfilled_pixels = getUnfilledPixels(filled_map);
    for pixel = unfilled_pixels
        [pix_row, pix_col] = ind2sub(size(filled_map), pixel);
        
        [neighbourhood, mask] = getNeighbourhood(output_image, filled_map, pix_row, pix_col, window_size);
        
        neighbourhood_vec = reshape(neighbourhood, [], 1);
        neighbourhood_rep = repmat(neighbourhood_vec, 1, size(candidates, 2));
        
        mask_vec = reshape(mask, [], 1);
        mask_vec = repmat(mask_vec, size(candidates, 3), 1);
        weight = sum(mask_vec .* gaussian_vec);
        gaussian_mask = ((gaussian_vec .* mask_vec) / weight)';
        
        distances = gaussian_mask * ((stacked_candidate_channels - neighbourhood_rep) .^ 2);
        min_value = min(distances);
        min_threshold = min_value * (1 + error_threshold);
        min_positions = find(distances <= min_threshold);
        
        random_col = randi(length(min_positions));
        selected_patch = min_positions(random_col);
        selected_error = distances(selected_patch);
        
        if selected_error < max_error_threshold
           [matched_row, matched_col] = ind2sub([num_horiz_candidates,num_vert_candidates], selected_patch);

           matched_row = matched_row + half_window;
           matched_col = matched_col + half_window;

           output_image(pix_row, pix_col, :) = ref_image(matched_row, matched_col, :);

           filled_map(pix_row, pix_col) = 1;
           found_match = true;
        end 
        
    end
    imshow(output_image);
    
    if ~found_match
        max_error_threshold = max_error_threshold * 1.1;
    end
    
end
toc;