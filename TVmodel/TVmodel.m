close all;
clear all;
clc;

img=double(imread('/Users/shengwan/Desktop/DIP/lena512.jpg'));

subplot(1,3,1)
imshow(img,[])
title('original image')
[m n]=size(img);

%mask=rgb2gray(imread('/Users/shengwan/Desktop/DIP/mask.png'))>160;
mask = zeros(m,n);
mask(:,:)=255;
mask(100:110,100:200)=0;
mask(100:200,100:110)=0;

for i=1:m
    for j=1:n
        if mask(i,j)==0
           img(i,j)=0; 
        end
    end
end

subplot(1,3,2)
imshow(img,[])
title('damaged image')

lambda=0.2;
a=0.5;
imgn=img;
sum = 10;
l = 1;
while sum > 0.01
    sum = 0;
    for i=2:m-1
        for j=2:n-1
            if mask(i,j)==0     
                                            
                Un=sqrt((img(i,j)-img(i-1,j))^2+((img(i-1,j-1)-img(i-1,j+1))/2)^2);
                Ue=sqrt((img(i,j)-img(i,j+1))^2+((img(i-1,j+1)-img(i+1,j+1))/2)^2);
                Uw=sqrt((img(i,j)-img(i,j-1))^2+((img(i-1,j-1)-img(i+1,j-1))/2)^2);
                Us=sqrt((img(i,j)-img(i+1,j))^2+((img(i+1,j-1)-img(i+1,j+1))/2)^2);

                Wn=1/sqrt(Un^2+a^2);
                We=1/sqrt(Ue^2+a^2);
                Ww=1/sqrt(Uw^2+a^2);
                Ws=1/sqrt(Us^2+a^2);

                Hon=Wn/((Wn+We+Ww+Ws)+lambda);
                Hoe=We/((Wn+We+Ww+Ws)+lambda);
                How=Ww/((Wn+We+Ww+Ws)+lambda);
                Hos=Ws/((Wn+We+Ww+Ws)+lambda);

                Hoo=lambda/((Wn+We+Ww+Ws)+lambda);

                imgn(i,j)=Hon*img(i-1,j)+Hoe*img(i,j+1)+How*img(i,j-1)+Hos*img(i+1,j)+Hoo*img(i,j);
                sum = imgn(i,j)-img(i,j)+sum;
            end
        end
    end
    img=imgn;
    l=l+1;
end

subplot(1,3,3)
imshow(imgn,[])
title('reconstructed image')
