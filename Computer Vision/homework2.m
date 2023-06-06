
%%
%Q1
clc;
clear;
close all;
Image1=imread("image1.jpg");
Image2=imread("image2.jpg");
Image_gray=rgb2gray(Image2);
Imatch=rgb2gray(Image1);
match=imhist(Imatch);
Iout=histeq(Image_gray,match);
figure;
subplot(1,3,1),imshow(Image_gray);title('原图像');
subplot(1,3,2),imshow(Imatch);title('匹配图像');
subplot(1,3,3),imshow(Iout);title('匹配后图像');
figure;
subplot(3,1,1),imhist(Image_gray);title('原图像直方图');
subplot(3,1,2),imhist(Imatch);title('匹配图图像直方图');
subplot(3,1,3),imhist(Iout);title('匹配后图像直方图');
%%
%Q2
clc;
clear;
close all;
Image=imread('image1.jpg');
Image_gray=rgb2gray(Image);
f1=[0 0 0;0 2 0;0 0 0];
f2=1/9*ones(3);
f=[1 0 0;0 1 0;20 30 1];
transform=maketform('affine',f);
Iout1=imfilter(Image_gray,f1+f2);
Iout2=imfilter(Image_gray,f1)+imfilter(Image_gray,f2);
Iout3=imfilter(Image_gray,f1*f);
Iout4=imtransform(imfilter(Image_gray,f1),transform);
figure;
subplot(2,2,1),imshow(Iout1);title('imfilter(I, f1 + f2) ')
subplot(2,2,2),imhist(Iout1);title('直方图')
subplot(2,2,3),imshow(Iout2);title('imfilter(I,f1) + imfilter(I,f2)')
subplot(2,2,4),imhist(Iout2);title('直方图')
figure;
subplot(2,2,1),imshow(Iout3);title('imfilter(I,shift(f))')
subplot(2,2,2),imhist(Iout3);title('直方图')
subplot(2,2,3),imshow(Iout4);title('shift(imfilter(I,f))')
subplot(2,2,4),imhist(Iout4);title('直方图')
%%
%Q3
clc;
clear;
close all;
Image=imread('image1.jpg');
f=fspecial('gaussian',3,1);
Iout1=imfilter(Image,f,'corr');
Iout2=imfilter(Image,f,'conv');
Iout3=imfilter(Image,f,'conv','full');
Iout4=imfilter(Image,f,'conv','same');
figure;
subplot(2,1,1),imshow(Iout1);title("互相关")
subplot(2,1,2),imshow(Iout2);title("卷积")
figure;
subplot(2,1,1),imshow(Iout1);title("full")
subplot(2,1,2),imshow(Iout1);title("same")
%%
%Q4
clc;
clear;
close all;
Image=imread('image1.jpg');
Image_gray=rgb2gray(Image);
Input1=imnoise(Image_gray,'salt & pepper');
Input2=imnoise(Image_gray,'gaussian');
f1=fspecial('gaussian',3,1);
f3=fspecial('average',3);
Output11=imfilter(Input1,f1,'corr');
Output12=medfilt2(Input1,[3,3]);
Output13=imfilter(Input1,f3,'corr');
Output21=imfilter(Input2,f1,'corr');
Output22=medfilt2(Input2,[3,3]);
Output23=imfilter(Input2,f3,'corr');
figure;
subplot(4,1,1),imshow(Input1);title("椒盐噪声")
subplot(4,1,2),imshow(Output11);title("高斯滤波")
subplot(4,1,3),imshow(Output12);title("中值滤波")
subplot(4,1,4),imshow(Output13);title("均值滤波")
figure;
subplot(4,1,1),imshow(Input2);title("椒盐噪声")
subplot(4,1,2),imshow(Output21);title("高斯滤波")
subplot(4,1,3),imshow(Output22);title("中值滤波")
subplot(4,1,4),imshow(Output23);title("均值滤波")
%%
%Q5 (1) (2)
Image_raw=imread("Faces.JPG");
Image_match=imread('Face_one.jpg');
Image=rgb2gray(Image_raw);
Match=rgb2gray(Image_match);
Match1=im2double(Match);
Match2=Match1-mean(mean(Match1));
Iout1=imfilter(Image,Match1);
Iout2=imfilter(Image,Match2);
subplot(2,1,1),imshow(Iout1);title("use template as filter kernel")
subplot(2,1,2),imshow(Iout2);title("use zero-mean template")
%%
%Q5
Image_raw=imread("Faces.JPG");
Image_match=imread('Face_one.jpg');
[a,b,c]=size(Image_raw);
[m,n,p]=size(Image_match);
Image=rgb2gray(Image_raw);
Match=rgb2gray(Image_match);
result=zeros(a-m,b-n);
Match=im2double(Match); 
for i=1:a-m
    for j=1:b-n
        temp=Image(i:i+m-1,j:j+n-1);
        temp=im2double(temp);
        temp_m=mean(mean(temp));
        match_m=mean(mean(Match));
        %.........................................................................
        %NCC
        %x=sum(sum((temp-temp_m).*(Match-match_m)));    
        %y=sqrt(sum(sum(((temp-temp_m).^2))))*sum(sum(((Match-match_m).^2))); 
        %result(i,j)=x/y;
        %.........................................................................
        %use square differences
        x=sum(sum(((Match-temp).^2)));
        result(i,j)=x;
    end
end
%max=max(max(result));
%[x,y]=find(result==max);%NCC
min=min(min(result));%use square differences
[x,y]=find(result==min);
figure;
imshow(Match);title('模板');
figure;
imshow(Image);
hold on;
rectangle('position',[y,x,n-1,m-1],'edgecolor','r');
hold off;title('搜索结果图');