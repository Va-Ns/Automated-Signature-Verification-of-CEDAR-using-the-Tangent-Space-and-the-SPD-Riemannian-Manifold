function mustBeSPD(M)
    
%% Conditions for a matrix to be SPD include:

% 1) The matrix to be Symmetric (if it's Symmetric, it's also Square)

    if ~issymmetric(M)
            throwAsCaller(MException("InputMatrix:mustBeSymmetric", ...
                "Matrix is not symmetric or square"))
    end

% 2) The matrix to be Positive Definite

    eigenvalues = eig(M);

    if any(eigenvalues <= 0) 

        throwAsCaller(MException("InputMatrix:mustHavePositiveEigevalues", ...
                "Matrix does not have all of it's eigenvalues positive"))
    end
    
end