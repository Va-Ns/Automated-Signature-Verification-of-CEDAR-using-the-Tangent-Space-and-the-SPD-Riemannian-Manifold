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
    
            % Perform Dichotomy Transform between the Genuine pairs of the signatures per writer 
            % that have been employed.
            G_Train_Dichotomy(curWriter).Per_pair{Comb,:} = ...
                abs(G_Metadata.Training_Signature_pairs(curWriter).Pairs{Comb, 1}- ...
                    G_Metadata.Training_Signature_pairs(curWriter).Pairs{Comb, 2});
    
        end
    
    end
    
    % Form the total Training Matrix by getting the content of each field of the structure
    % G_Train_Dichotomy, append them vertically and then append them again in the final variable
    % G_Training_set.
    
    for i = 1 : length(G_Train_Dichotomy)
    
        Current_data = G_Train_Dichotomy(i).Per_pair;
        Merged_Current_data = vertcat(Current_data{:});
        G_Training_set = [G_Training_set;Merged_Current_data];
    
    end

%% For the Validation set of Genuine Signatures
    
    % For every writer
    for curWriter = 1 : size(G_Learning_Data,1)
    
        % And for all the possible combinations
        for Comb = 1 : size(G_Metadata.Validation_Combinations,1)
    
            % Perform Dichotomy Transform between the Genuine pairs of the signatures per writer 
            % that have been employed.
            G_Val_Dichotomy(curWriter).Per_pair{Comb,:} = ...
                abs(G_Metadata.Validation_Signature_pairs(curWriter).Pairs{Comb, 1}- ...
                    G_Metadata.Validation_Signature_pairs(curWriter).Pairs{Comb, 2});
    
        end
    
    end
    
    % Form the total Validation Matrix by getting the content of each field of the structure
    % Dichotomy, append them vertically and then append them again in the final variable
    % G_Validation_set.
    
    for i = 1 : length(G_Val_Dichotomy)
    
        Current_data = G_Val_Dichotomy(i).Per_pair;
        Merged_Current_data = vertcat(Current_data{:});
        G_Validation_set = [G_Validation_set ;Merged_Current_data];
    
    end


end