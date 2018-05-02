close all;
clc;
clear;

imgoriginal=imread('lena_color.bmp'); 

figure(1);
subplot(131);
imshow(imgoriginal); 
xlabel('Original Image');
[width,height] = size(imgoriginal); 
img= double(imgoriginal); 

mask = zeros(width,height/3,3); 
for j = 1:height/3
    for i = 1:width
        if ((imgoriginal(i,j,1) >200)&&(imgoriginal(i,j,2) >190)&&(imgoriginal(i,j,3) >190))
            mask(i,j,1) = 255; 
            mask(i,j,2) = 255; 
            mask(i,j,3) = 255; 
        else 
            mask(i,j,1) = 0; 
            mask(i,j,2) = 0;
            mask(i,j,3) = 0; 
        end 
    end 
end 
subplot(132);
imshow(mask); 
xlabel('mask');
imwrite(mask,'lena_mask.bmp');

n = 1; 
itertimes=10000; 
while n <= itertimes
    for i = 2:width-1
        for j = 2:height/3-1
           %if (mask(i,j+1) == 255)||(mask(i,j-1) == 255)||(mask(i+1,j) ==255)||(mask(i-1,j) == 255) %for grayscale image 
           if (mask(i,j+1,1) == 255)||(mask(i,j-1,1) == 255)||(mask(i+1,j,1) == 255)||(mask(i-1,j,1) == 255)
                for k=1:3 
                    grid_w(k) = (img(i,j,k)-img(i-1,j,k))^2+(1.0/16)*(img(i-1,j+1,k)+img(i,j+1,k)-img(i-1,j-1,k)-img(i,j-1,k))^2;
                    grid_e(k) = (img(i,j,k)-img(i+1,j,k))^2+(1.0/16)*(img(i,j+1,k)+img(i+1,j+1,k)-img(i,j-1,k)-img(i+1,j-1,k))^2;
                    grid_s(k) = (img(i,j,k)-img(i,j-1,k))^2+(1.0/16)*(img(i+1,j,k)+img(i+1,j-1,k)-img(i-1,j,k)-img(i-1,j-1,k))^2;
                    grid_n(k) = (img(i,j,k)-img(i,j+1,k))^2+(1.0/16)*(img(i+1,j,k)+img(i+1,j+1,k)-img(i-1,j,k)-img(i-1,j+1,k))^2;
                    w1(k) = 1/sqrt(1+grid_w(k));
                    w2(k) = 1/sqrt(1+grid_e(k));
                    w3(k) = 1/sqrt(1+grid_s(k));
                    w4(k) = 1/sqrt(1+grid_n(k));
                    img(i,j,k) =(w1(k)*img(i-1,j,k)+w2(k)*img(i+1,j,k)+w3(k)*img(i,j+1,k)+w4(k)*img(i,j-1,k))/(w1(k)+w2(k)+w3(k)+w4(k));
                end        
            end
        end
    end
    n = n+1;
end 
img = uint8(floor(img)); 
subplot(133);
imshow(img,[]);
xlabel('Reconstructed Image');
imwrite(img,'lena_result.bmp');


