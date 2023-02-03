function I = codeInterxVars(A, B)
% Check that n-rows in A and B are equal
if size(A, 1) ~= size(B, 1)
    error('Dummy variable matrices must have equal number of rows')
end
I = zeros(size(A, 1), size(A, 2)*size(B, 2));
cnt = 0;
for m = 1:size(A, 2)
    for n = 1:size(B, 2)
        cnt = cnt+1;
        I(:, cnt) = A(:, m) .* B(:, n);
    end
end

end