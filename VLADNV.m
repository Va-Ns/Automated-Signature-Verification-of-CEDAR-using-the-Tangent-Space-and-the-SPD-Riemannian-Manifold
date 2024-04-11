function VLAD_Encoding = VLADNV(Codebooks,Data)

    [numCenters,DimCenters] = size(Codebooks.G_Train_Codebook);
    numTrainingSamples = size(Data.G_Training_set, 1);
    numValidationSamples = size(Data.G_Val_set,1);


    G_Train_VLAD_Encoding = zeros(numTrainingSamples,numCenters*DimCenters);
    F_Train_VLAD_Encoding = zeros(numTrainingSamples,numCenters*DimCenters);
    G_Val_VLAD_Encoding = zeros(numValidationSamples,numCenters*DimCenters);
    F_Val_VLAD_Encoding = zeros(numValidationSamples,numCenters*DimCenters);

    %% For the Learning Set
        
        %% For the Genuine Signatures of the Training Set

        % Compute the distances from each vector in G_Training_set to each center in 
        % G_Train_Codebook

        % Here we pre-allocate a 3D matrix, where the first two dimensions will represent the
        % Codebook and the third will represent the current vector. This scheme is employed because
        % when we search for the 5 nearest centroids of a vector, there's a possibility some
        % centroids to be the same for more than one vectors. That would ultimately lead to
        % overwriting the residuals that were found per vector. So, the first two dimensions serve
        % as a place-hold of the residuals and the third dimensions is an "index" of the vector that
        % we process.

        G_Train_Representation = zeros(numCenters, DimCenters, numTrainingSamples);
        G_Train_index = cell(numTrainingSamples, 1);
        G_Train_Residual = cell(numTrainingSamples, 1);

        for Curr_data = 1:numTrainingSamples
            [~, G_Train_index{Curr_data}] = pdist2(Codebooks.G_Train_Codebook, ...
                                      Data.G_Training_set(Curr_data,:), "euclidean", "Smallest", 5);
            G_Train_Residual{Curr_data} = Data.G_Training_set(Curr_data,:) - ...
                                             Codebooks.G_Train_Codebook(G_Train_index{Curr_data},:);

            % Vectorize the inner loop
            G_Train_Representation(G_Train_index{Curr_data}, :, Curr_data) = ...
                                                                        G_Train_Residual{Curr_data};

            % Reshape the 3D matrix into a vector
            G_Train_VLAD_Encoding(Curr_data,:) = reshape(G_Train_Representation(:,:,Curr_data)', 1, ...
                                                                                                []);
        end

        %% For the Forgery Signatures of the Training Set

        F_Train_Representation = zeros(numCenters, DimCenters, numTrainingSamples);
        F_Train_index = cell(numTrainingSamples, 1);
        F_Train_Residual = cell(numTrainingSamples, 1);

        for Curr_data = 1:numTrainingSamples

            [~, F_Train_index{Curr_data}] = pdist2(Codebooks.F_Train_Codebook, ...
                                      Data.F_Training_set(Curr_data,:), "euclidean", "Smallest", 5);
            F_Train_Residual{Curr_data} = Data.F_Training_set(Curr_data,:) - ...
                                             Codebooks.F_Train_Codebook(F_Train_index{Curr_data},:);

            % Vectorize the inner loop
            F_Train_Representation(F_Train_index{Curr_data}, :, Curr_data) = ...
                                                                        F_Train_Residual{Curr_data};

            % Reshape the 3D matrix into a vector
            F_Train_VLAD_Encoding(Curr_data,:) = reshape(F_Train_Representation(:,:,Curr_data)', 1, ...
                                                                                                []);

        end
        
        %% Normalization for the Training Set

        % L2 Normalization
        G_Train_VLAD_Encoding_normed = G_Train_VLAD_Encoding/norm(G_Train_VLAD_Encoding);

        % L2 Normalization
        F_Train_VLAD_Encoding_normed = F_Train_VLAD_Encoding/norm(F_Train_VLAD_Encoding);



    %% For the Validation Set

        %% For the Genuine Signatures of the Validation Set

        G_Val_Representation = zeros(numCenters, DimCenters, numValidationSamples);
        G_Val_index = cell(numValidationSamples, 1);
        G_Val_Residual = cell(numValidationSamples, 1);

        for Curr_data = 1:numValidationSamples

            [~, G_Val_index{Curr_data}] = pdist2(Codebooks.G_Val_Codebook, ...
                                      Data.G_Val_set(Curr_data,:), "euclidean", "Smallest", 5);
            G_Val_Residual{Curr_data} = Data.G_Val_set(Curr_data,:) - ...
                                             Codebooks.G_Val_Codebook(G_Val_index{Curr_data},:);

            % Vectorize the inner loop
            G_Val_Representation(G_Val_index{Curr_data}, :, Curr_data) = G_Val_Residual{Curr_data};

            % Reshape the 3D matrix into a vector
            G_Val_VLAD_Encoding(Curr_data,:) = reshape(G_Val_Representation(:,:,Curr_data)', 1, []);
        end

        %% For the Forgery Signatures of the Validation Set

        F_Val_Representation = zeros(numCenters, DimCenters, numValidationSamples);
        F_Val_index = cell(numValidationSamples, 1);
        F_Val_Residual = cell(numValidationSamples, 1);

        for Curr_data = 1:numValidationSamples

            [~, F_Val_index{Curr_data}] = pdist2(Codebooks.F_Val_Codebook, ...
                                      Data.F_Val_set(Curr_data,:), "euclidean", "Smallest", 5);
            F_Val_Residual{Curr_data} = Data.F_Val_set(Curr_data,:) - ...
                                             Codebooks.F_Val_Codebook(F_Val_index{Curr_data},:);

            % Vectorize the inner loop
            F_Val_Representation(F_Val_index{Curr_data}, :, Curr_data) = F_Val_Residual{Curr_data};

            % Reshape the 3D matrix into a vector
            F_Val_VLAD_Encoding(Curr_data,:) = reshape(F_Val_Representation(:,:,Curr_data)', 1, []);

        end

        %% Normalization for the Training Set

        % L2 Normalization
        G_Val_VLAD_Encoding_normed = G_Val_VLAD_Encoding/norm(G_Val_VLAD_Encoding);

        % L2 Normalization
        F_Val_VLAD_Encoding_normed = F_Val_VLAD_Encoding/norm(F_Val_VLAD_Encoding);

    

    VLAD_Encoding.G_Train_VLAD_Encoding_normed =  G_Train_VLAD_Encoding_normed;
    VLAD_Encoding.F_Train_VLAD_Encoding_normed =  F_Train_VLAD_Encoding_normed;
    VLAD_Encoding.G_Val_VLAD_Encoding_normed = G_Val_VLAD_Encoding_normed;
    VLAD_Encoding.F_Val_VLAD_Encoding_normed = F_Val_VLAD_Encoding_normed;
end