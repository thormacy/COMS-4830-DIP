clear all;
close all;
tic;

img=double(imread('/Users/shengwan/Desktop/DIP/lena512.jpg'));
[m n]=size(img);
figure(1),imshow(img,[]);

img(100:300,300:305)=0;
img(300:305,100:300)=0;
mask = zeros(m,n);
for i = 1:m
    for j = 1:n
        if img(i,j) == 0
            mask(i,j) = 0;
        else
            mask(i,j) = 255;
        end
    end
end
figure(2);imshow(img,[]);
imgn = img;
l = 1;
a=5;
lambda=0.2;
IterTimes=1000;
while l < IterTimes
    sum = 0;
    for i = 2:m-1
        for j = 2:n-1
            if mask(i,j) == 0
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

                k=Hon*img(i-1,j)+Hoe*img(i,j+1)+How*img(i,j-1)+Hos*img(i+1,j)+Hoo*img(i,j);

                Wn=k/sqrt(Un^2+a^2);
                We=k/sqrt(Ue^2+a^2);
                Ww=k/sqrt(Uw^2+a^2);
                Ws=k/sqrt(Us^2+a^2);
                
                Hon=Wn/((Wn+We+Ww+Ws)+lambda);
                Hoe=We/((Wn+We+Ww+Ws)+lambda);
                How=Ww/((Wn+We+Ww+Ws)+lambda);
                Hos=Ws/((Wn+We+Ww+Ws)+lambda);
                Hoo=lambda/((Wn+We+Ww+Ws)+lambda);

                imgn(i,j)=Hon*img(i-1,j)+Hoe*img(i,j+1)+How*img(i,j-1)+Hos*img(i+1,j)+Hoo*img(i,j);

            end
        end
    end
    l = l+1;
    img = imgn;
end
figure(3);imshow(img,[]);
toc


