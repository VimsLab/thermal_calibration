function [img_out] = preprocess_thermal(img, varargin)

%%%%
%Input:
%img, the image to process
%varargin:
%flip_flag Flip intensity value? In thermal, the black squares are hot (white).
%numIters = 10 Number of iterations for shape fitting and subtraction loop
%strel_sz=15 size of top hat filter. Large values are smoother, but weaker removal of nonuniform heating
%sharpen_amt = 0.8 Sharpening filter correction amount
%gamma_amt = 0.8 Gamma correction amount
%
%Output:
%img_out, the processed image
%
%Example call: img_out = preprocess_thermal(img, 1, 5, 20, 0.3, 1.2);
%


img_out = img;
img_dbl = im2double(img);

%%%Parameters
flip_flag = 1; %Flip intensity value? In thermal, the black squares are hot (white).
numIters = 10; %Number of iterations for shape fitting and subtraction loop
strel_sz=15;   %size of top hat filter. Large values are smoother, but weaker removal of nonuniform heating
sharpen_amt = 0.8; %Sharpening filter correction amount
gamma_amt = 0.8; %Gamma correction amount
if(nargin == 2)
   varargin = varargin{1}; 
end
if(length(varargin) >= 1)
    flip_flag = varargin{1}; 
end
if(length(varargin) >= 2)
    numIters = varargin{2}; 
end
if(length(varargin) >= 3)
    strel_sz = varargin{3}; 
end
if(length(varargin) >= 4)
    sharpen_amt = varargin{4}; 
end
if(length(varargin) >= 5)
    gamma_amt = varargin{5}; 
end

%Segment out calibration board with Otsu's method
img_out = img_dbl;
level = graythresh(img_dbl);
level = level -.05;
bw_img = img_dbl;
bw_img(find(bw_img < level)) = 0;
bw_img(find(bw_img >= level)) = 1;
CC = bwconncomp(bw_img);
[max_amt max_ind] = max(cellfun('length',CC.PixelIdxList));
pixel_ind = CC.PixelIdxList{max_ind};
mask = zeros(size(img_dbl));
mask(pixel_ind) = 1;

%Iteratively subtract out fitted shape
for jj = 1:numIters
    img_msked = img_out.*mask;
    [y x] = ind2sub(size(img_msked), pixel_ind);
    z = img_msked(pixel_ind)';
    sf = fit([x(:), y(:)],z(:),'poly33');
    img_out(pixel_ind) = img_out(pixel_ind) - sf(x,y);
end

%Top hat filter
img_out = imtophat(img_out.*mask,strel('disk', strel_sz));

%Normalization and Gamma correction
img_out = imadjust(img_out);
img_out = (img_out.^gamma_amt); img_out = img_out./max(img_out(:));

%Sharpen
img_out = imsharpen(img_out, 'Radius', 1, 'Amount', sharpen_amt);

%Flip the intensity
if(flip_flag)
    img_out(find(mask)) = 1 -img_out(find(mask));
end

end