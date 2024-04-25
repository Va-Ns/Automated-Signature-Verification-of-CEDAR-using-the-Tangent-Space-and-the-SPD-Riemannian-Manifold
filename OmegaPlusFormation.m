function [G_Training_set,G_Validation_set] = OmegaPlusFormation(G_Learning_Data,G_Metadata)
    
% This function implements the Dichotomy Transform for the Genuine-to-Genuine pairs of every Writer 
% with himself for the formation of the ω(+) class. 

    G_Training_set = [];
    G_Validation_set = [];
    
    %% For the Training set of Genuine Signatures

    % For every writer
    for curWriter = 1 : size(G_Learning_Data,1)
    
        % And for all the possible combinations
        for Comb = 1 : size(G_Metadata.Train_Combinations,1)
            
            % Here X is the basis to which we raise all the other points of the manifold to the
            % Tangent Space.
            X = G_Metadata.Training_Signature_pairs(curWriter).Pairs{Comb, 1};

            % While Y are the points to be raised in the tangent space
            Y = G_Metadata.Training_Signature_pairs(curWriter).Pairs{Comb, 2};
            
            X_s = sqrtm(X);

            % From theory we know that the logarithmic mapping corresponds to the subtraction
            % between two points. The first point is the basis and the next point is the one that is
            % raised to the tangent space (see Pennec et al. "A Riemannian Framework for Tensor
            % Computing"). 
            % 
            % We also know that the logarithmic mapping is given by:
            %                         
            %                          X^(1/2) * log( X^(-1/2)*Y*X^(-1/2) ) * X^(1/2)
            %
            % From [Tuzel et al]: "Pedestrian Detection via Classificationon Riemannian Manifolds"
            % we get that the orthonormal coordinates of a tangent vector y in the tangent space at
            % point X is given by the vector operator
            %
            %                           vec_X(y) = vec_I( X^(-1/2)*y*X^(-1//2) )
            %
            % So, given that y is the result of the logarithmic mapping, we can write that:
            %
            % vec_X(y) = vec_I( X^(-1/2)*(X^(1/2)*log( X^(-1/2)*Y*X^(-1/2) )*X^(1/2))*X^(-1//2))
            %
            %                        vec_X(y) = vec_I( log ( X^(-1/2)*Y*X^(-1/2) ) )
            %
            % So if we use the norm on the vec_X(y) we basically get the Affine Invariant Riemannian
            % Metric (AIRM)
            %
            % Then, since the result is a symmetric and not always positive definite matrix, in
            % order to create the vector representation of this matrix, we take the main diagonal
            % and multiply it's lower (or upper triangular- per user preference) with sqrt(2) to
            % negate the effects of the norm 


            G_Train_AIRM(curWriter).Per_pair{Comb} = logm(X_s\Y/X_s); % Due to MATLAB's nature
                                                                          % of handling matrices, it
                                                                          % is more efficient to use
                                                                          % the notation \Matrix/
                                                                          % than using inv(..)

            G_Train_Vec(curWriter).Per_pair{Comb} = ...
                          real(VecsOfTangentPlaneNV(G_Train_AIRM(curWriter).Per_pair{Comb}))';

        end
    
    end
    
    % Form the total Training Matrix by getting the content of each field of the structure
    % G_Train_Dichotomy, append them vertically and then append them again in the final variable
    % G_Training_set.
    
    for i = 1 : length(G_Train_AIRM)
    
        Current_data = G_Train_Vec(i).Per_pair;
        Merged_Current_data = vertcat(Current_data{:});
        G_Training_set = [G_Training_set;Merged_Current_data];
    
    end

%% For the Validation set of Genuine Signatures
    
    % For every writer
    for curWriter = 1 : size(G_Learning_Data,1)
    
        % And for all the possible combinations
        for Comb = 1 : size(G_Metadata.Validation_Combinations,1)
    
            X = G_Metadata.Validation_Signature_pairs(curWriter).Pairs{Comb, 1};
            Y = G_Metadata.Validation_Signature_pairs(curWriter).Pairs{Comb, 2};
            
            X_s = sqrtm(X);

            G_Val_AIRM(curWriter).Per_pair{Comb} = logm(X_s\Y/X_s);

            G_Val_Vec(curWriter).Per_pair{Comb} = ...
                          real(VecsOfTangentPlaneNV(G_Val_AIRM(curWriter).Per_pair{Comb}))';
    
        end
    
    end
    
    % Form the total Validation Matrix by getting the content of each field of the structure
    % Dichotomy, append them vertically and then append them again in the final variable
    % G_Validation_set.
    
    for i = 1 : length(G_Val_AIRM)
    
        Current_data = G_Val_Vec(i).Per_pair;
        Merged_Current_data = vertcat(Current_data{:});
        G_Validation_set = [G_Validation_set ;Merged_Current_data];
    
    end


end