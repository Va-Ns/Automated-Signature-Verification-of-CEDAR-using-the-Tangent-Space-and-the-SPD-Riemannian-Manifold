function nvc = VecsOfTangentPlaneNV(vc)

arguments
    vc {mustBeSPD,mustBeNonempty,mustBeNonmissing,mustBeNonNan}
end


    vc = logm(vc);
    [rows, cols] = size(vc);
    [i, j] = ndgrid(1:rows, 1:cols);  % Create a grid of row and column indices
    idx = i >= j;  % Create a mask for the lower triangular part of the matrix
    nvc = vc(idx);  % Extract the lower triangular part of vc
    off_diag_idx = i ~= j & idx;  % Create a mask for the off-diagonal elements
    off_diag_idx = off_diag_idx(idx);  % Convert to a 1D logical array
    nvc(off_diag_idx) = nvc(off_diag_idx) * sqrt(2);  % Multiply off-diagonal elements by sqrt(2)
end