function U = doolittleWeights(X)
A      = X'*X;
tol    = 1e-15;
[n,  ~] = size(A);
L      = zeros(n,n);
U      = zeros(n,n);
% Doolittle row elimination with redundant row skipping
for k = 1:n
    L(k,k) = 1;
    for j = k:n
        U(k,j) = A(k,j);
        for s = 1:(k-1)
            U(k,j) = U(k,j) - L(k,s) * U(s,j);
        end
    end
    if U(k,k) > tol
        for i = (k+1):n
            L(i,k) = A(i,k);
            for s = 1:(k-1)
                L(i,k) = L(i,k) - L(i,s)*U(s,k);
            end
            L(i,k) = L(i,k) / U(k,k);
        end
    end
end
% Remove 0 diagonal rows
U(diag(U) < tol,:) = [];
% Scale the weights
for i = 1:size(U,1)
    U(i,:) = U(i,:) ./ max(U(i,:));
end
end