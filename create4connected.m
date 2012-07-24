function L = create4connected(m, n, mask)
% Create discrete Laplacian operator as a matrix
% 
% Inputs: 
%   m, n - size of image (including regions where the mask is zero)
%   mask - binary mask, marking pixels to consider or ignore
% 
% (Extracted from NIPS 2011 Intrinsic Images code)

mn = m*n;
a = ones(mn,1);
rng = m:m:mn-1;

% remove boundary pixels
A = spdiags(a,1,mn,mn);
A(rng,rng+1) = 0;

B = spdiags(a,-1,mn,mn);
B(rng+1,rng) = 0;

L = 4*speye(mn,mn) - spdiags(a,m,mn,mn) - spdiags(a,-m,mn,mn);
L = L - A - B;

if exist('mask','var') && any(mask(:)==0)
    maskInd = find(mask(:)~=0);
    L = L(maskInd,maskInd);
end

L = L - diag(sum(L,2));

assert(issparse(L));
