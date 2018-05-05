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

s = size(img);
ind = reshape(1:s(1) * s(2),s(1),s(2));
sz = [size(img,1) size(img,2)];
sourceRegion = ~fillRegion;
% Initialize isophote values
[Ix(:,:,3),Iy(:,:,3)] = gradient(img(:,:,3));
[Ix(:,:,2),Iy(:,:,2)] = gradient(img(:,:,2));
[Ix(:,:,1),Iy(:,:,1)] = gradient(img(:,:,1));
Ix = sum(Ix,3) / (3 * 255); 
Iy = sum(Iy,3) / (3 * 255);
temp = Ix; 
Ix = -Iy; 
Iy = temp;

% Initialize confidence and data terms
C = double(sourceRegion);
D = repmat(-0.1,sz);
iter = 1;

% Seed 'rng' for reproducible results
rng(0);
figure();
% Loop until entire fill region has been covered
while any(fillRegion(:))
  % Find contour & normalized gradients of fill region
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
  
  % Compute confidences along the fill front
  for k = dR'
    Hp = getpatch(sz,k);
    q = Hp(~(fillRegion(Hp)));
    C(k) = sum(C(q)) / numel(Hp);
  end
  
  % Compute patch priorities = confidence term * data term
  D(dR) = abs(Ix(dR) .* N(:,1) + Iy(dR) .* N(:,2)) + 0.001;
  priorities = C(dR) .*  D(dR);
  
  % Find patch with maximum priority, Hp
  [~,ndx] = max(priorities(:));
  p = dR(ndx(1));
  [Hp,rows,cols] = getpatch(sz,p);
  
  
  
  toFill = fillRegion(Hp);
  
  % Find exemplar that minimizes error, Hq
  Hq = bestexemplar(img,img(rows,cols,:),toFill',sourceRegion);
  
  % Update fill region
  toFill = logical(toFill);
  fillRegion(Hp(toFill)) = false;
  
  % Propagate confidence & isophote values
  C(Hp(toFill)) = C(p);
  Ix(Hp(toFill)) = Ix(Hq(toFill));
  Iy(Hp(toFill)) = Iy(Hq(toFill));
  
  % Copy image data from Hq to Hp
  ind(Hp(toFill)) = ind(Hq(toFill));
  img(rows,cols,:) = ind2img(ind(rows,cols),original_img);  

  iter = iter + 1;
  imshow(uint8(img));
end

inpainted_img = img;


%---------------------------------------------------------------------
% Scans over the entire image (with a sliding window)
% for the exemplar with the lowest error. Calls a MEX function.
%---------------------------------------------------------------------
function Hq = bestexemplar(img,Ip,toFill,sourceRegion)
m = size(Ip,1); 
mm = size(img,1); 
n = size(Ip,2); 
nn = size(img,2);
best = bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion);
Hq = sub2ndx(best(1):best(2),(best(3):best(4))',mm);


%---------------------------------------------------------------------
% Returns the indices for a 9x9 patch centered at pixel p.
%---------------------------------------------------------------------
function [Hp,rows,cols] = getpatch(sz,p)
w = 2;
p = p-1; 
y = floor(p / sz(1)) + 1; 
p = rem(p,sz(1)); 
x = floor(p) + 1;
rows = max(x - w,1):min(x + w,sz(1));
cols = (max(y - w,1):min(y + w,sz(2)))';
Hp = sub2ndx(rows,cols,sz(1));


%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);
Y = cols(:,ones(1,length(rows)));
N = X + (Y - 1) * nTotalRows;


%---------------------------------------------------------------------
% Converts an indexed image into an RGB image, using 'img' as a colormap
%---------------------------------------------------------------------
function img2 = ind2img(ind,img)
for i = 3:-1:1 
    temp = img(:,:,i); 
    img2(:,:,i) = temp(ind); 
end;