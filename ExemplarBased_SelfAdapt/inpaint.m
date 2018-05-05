function [inpainted_img,original_img,masked_img,C,D] = inpaint(original_img_filename,mask_img_filename)

img = double(imread(original_img_filename));
mask_img = im2double(rgb2gray(imread(mask_img_filename)));
mask_img = mask_img(:,:,1);
fillRegion = mask_img == 1;

original_img = img;
r = img(:,:,1); r(fillRegion)=0;
g = img(:,:,2); g(fillRegion)=0;
b = img(:,:,3); b(fillRegion)=0;
img(:,:,1)=r;img(:,:,2)=g;img(:,:,3)=b;

masked_img=img;
max_w=14;
min_w=3;
var_tol = 1400;
avg_tol = 4;
dist_tol = 120;

s = size(img);
ind = reshape(1:s(1) * s(2),s(1),s(2));
sz = [size(img,1) size(img,2)];
sourceRegion = ~fillRegion;
sourceRegion(1:max_w+1,:)=false;sourceRegion(end-max_w:end,:)=false;
sourceRegion(:,1:max_w+1)=false;sourceRegion(:,end-max_w:end)=false;

[Ix(:,:,3),Iy(:,:,3)] = gradient(img(:,:,3));
[Ix(:,:,2),Iy(:,:,2)] = gradient(img(:,:,2));
[Ix(:,:,1),Iy(:,:,1)] = gradient(img(:,:,1));
Ix = sum(Ix,3) / (3 * 255); 
Iy = sum(Iy,3) / (3 * 255);
temp = Ix; 
Ix = -Iy; 
Iy = temp;

C = double(sourceRegion);
D = repmat(-0.1,sz);
iter = 1;
rng(0);
figure();

while any(fillRegion(:))

  fillRegionD = double(fillRegion);
  dR = find(conv2(fillRegionD,[1,1,1;1,-8,1;1,1,1],'same')>0);
  
  [Nx,Ny] = gradient(double(~fillRegion));
  N = [Nx(dR(:)) Ny(dR(:))];
  
  N_temp = N;
  for i = 1:size(N,1)
      N_temp(i,:) = N(i,:) / norm(N(i,:));
  end
  N = N_temp;
    
  N(~isfinite(N)) = 0;
  

  for k = dR'
    Hp = getpatch(sz,k,4);
    q = Hp(~(fillRegion(Hp)));
    C(k) = sum(C(q)) / numel(Hp);
  end

  D(dR) = abs(Ix(dR) .* N(:,1) + Iy(dR) .* N(:,2)) + 0.001;
  priorities = C(dR) .*  D(dR);
  
 
  [~,ndx] = max(priorities(:));
  p = dR(ndx(1));
  
  w=min_w;
  [Hp,rows,cols] = getpatch(sz,p,w);
  test = (img(rows,cols,1)+img(rows,cols,2)+img(rows,cols,3))/3;
  test2 = test(:);
  test2 = test2(test2 ~=0);
  avg_init = mean(test2);
  var_init = var(test2);
  if (var_init<var_tol)
     while (w<max_w)
          w=w+1;
          [Hp_new,rows_new,cols_new] = getpatch(sz,p,w);
          test = (img(rows_new,cols_new,1)+img(rows_new,cols_new,2)+img(rows_new,cols_new,3))/3;
          test2 = test(:);
          test2 = test2(test2 ~=0);
          avg = mean(test2);
          vra = var(test2);
          if (abs(avg-avg_init)<avg_tol) && (vra<var_tol)
              Hp=Hp_new;rows=rows_new;cols=cols_new;
          else
              break;
          end
     end
  end
  toFill = fillRegion(Hp);
  
  
  Hq = bestexemplar(img,img(rows,cols,:),toFill',sourceRegion);
  cp = ceil(size(Hq,1)/2); cind = Hq(cp,cp);
  cpx = floor(cind/sz(1));
  cpy = cind - cpx * sz(1);
  cpx = cpx+1;
   
  
  while (cpy-w<0 || cpy+w>sz(1) || cpx-w<0 || cpx+w>sz(2))
      w=w-1;
      test = test(2:end-1,2:end-1);
      Hq = Hq(2:end-1,2:end-1);
      Hp = Hp(2:end-1,2:end-1);
      toFill = fillRegion(Hp);
  end
  q_area = img(cpy-w:cpy+w,cpx-w:cpx+w,:);
  q_area = (q_area(:,:,1)+q_area(:,:,2)+q_area(:,:,3))/3;
  diffqt = q_area - test;
  diffqt_v = diffqt((~toFill)');
  dist = sqrt(sum(diffqt_v.*diffqt_v));
  
  while (dist>dist_tol)
      if (w <= min_w+1)
          break
      end
      w=w-1;
      Hq = Hq(2:end-1,2:end-1);
      Hp = Hp(2:end-1,2:end-1);
      toFill = fillRegion(Hp);
      diffqt = diffqt(2:end-1,2:end-1);
      diffqt_v = diffqt((~toFill)'); 
      dist = sqrt(sum(diffqt_v.*diffqt_v));
  end
 
  
  toFill = logical(toFill);
  fillRegion(Hp(toFill)) = false;
  
  
  C(Hp(toFill)) = C(p);
  Ix(Hp(toFill)) = Ix(Hq(toFill));
  Iy(Hp(toFill)) = Iy(Hq(toFill));
  
  
  ind(Hp(toFill)) = ind(Hq(toFill));
  img(rows,cols,:) = ind2img(ind(rows,cols),masked_img);  

  iter = iter + 1;
  imshow(uint8(img));
end

inpainted_img = img;



function Hq = bestexemplar(img,Ip,toFill,sourceRegion)
m = size(Ip,1); 
mm = size(img,1); 
n = size(Ip,2); 
nn = size(img,2);
best = bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion);
Hq = sub2ndx(best(1):best(2),(best(3):best(4))',mm);



function [Hp,rows,cols] = getpatch(sz,p,w)
p = p-1; 
y = floor(p / sz(1)) + 1; 
p = rem(p,sz(1)); 
x = floor(p) + 1;
rows = max(x - w,1):min(x + w,sz(1));
cols = (max(y - w,1):min(y + w,sz(2)))';
Hp = sub2ndx(rows,cols,sz(1));


function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);
Y = cols(:,ones(1,length(rows)));
N = X + (Y - 1) * nTotalRows;


function img2 = ind2img(ind,img)
for i = 3:-1:1 
    temp = img(:,:,i); 
    img2(:,:,i) = temp(ind); 
end