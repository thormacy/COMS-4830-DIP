clc;clear all;
tic;
%% do image inpainting
[i1,i2,i3,c,d] = inpaint('sea.png','sea_mask.png');

%% display results
figure;
subplot(131);imshow(uint8(i2)); title('Original Image');
subplot(132);imshow(uint8(i3)); title('Masked Image');
subplot(133);imshow(uint8(i1)); title('Inpainted Image');
toc;