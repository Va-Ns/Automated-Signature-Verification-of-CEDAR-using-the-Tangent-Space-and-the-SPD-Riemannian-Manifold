function Metadata = Train_Val_Split(Data,Options) 
    
    arguments
    
        Data                        {mustBeNonempty,mustBeNonmissing}
        Options.Train_Portion       {mustBeFloat} = 0.7;
        Options.GetTheCombinations  {mustBeNumericOrLogical} = false;
        Options.GetTheRefsPerWriter {mustBeNumericOrLogical} = false;
        Options.GetAllMetadata      {mustBeNumericOrLogical} = false;

    end

    %% Forming the Training Set

    % Define the size of signatures you'll get from each Writer.
    Training_Length = round(size(Data,2)*Options.Train_Portion);

    for curWriter = 1 : size(Data,1)
    
        % Get the 17 signatures from the current Writer.
        TrainingData = Data(curWriter,1:Training_Length);
    
        % Generate all combinations of pairwise observations.
        Train_Combinations = nchoosek(1:Training_Length, 2);
    
        % Initialize a cell array to hold the pairs of observations.
        Training_Signature_pairs(curWriter).Pairs = cell(size(Train_Combinations, 1), 2);
    
        % For each combination, get the corresponding observations.
        for i = 1:size(Train_Combinations, 1)
    
            % Create all the possible combinations of Signatures per Writer, e.g since every writer 
            % has 17 signatures, 136 possible combinations for every writer's signature should be 
            % employed for the training set.
            Training_Signature_pairs(curWriter).Pairs(i, 1) = ...
                                       TrainingData(:, Train_Combinations(i, 1));
            Training_Signature_pairs(curWriter).Pairs(i, 2) = ...
                                       TrainingData(:, Train_Combinations(i, 2));
    
        end
    
    end
    
     %% Forming the Validation Set

    % Define the size of signatures you'll get from each Writer
    Validation_Length = round(size(Data,2)*(1-Options.Train_Portion));

    for curWriter = 1 : size(Data,1)
    
        % Get the 7 remaining signatures from the current Writer
        ValidationData = Data(curWriter,Training_Length+1:end);
    
        % Generate all combinations of 2 observations
        Validation_Combinations = nchoosek(1:Validation_Length, 2);
    
        % Initialize a cell array to hold the pairs of observations
        Validation_Signature_pairs(curWriter).Pairs = ...
                                            cell(size(Validation_Combinations , 1), 2);
    
        % For each combination, get the corresponding observations
        for i = 1:size(Validation_Combinations , 1)
    
            % Create all the possible combinations of Signatures per Writer, e.g here since every 
            % writer has 7 signatures, 21 possible combinations for every writer's signature should
            % be employed for the validation set
            Validation_Signature_pairs(curWriter).Pairs(i, 1) = ... 
                                     ValidationData(:, Validation_Combinations (i, 1));
            Validation_Signature_pairs(curWriter).Pairs(i, 2) = ...
                                     ValidationData(:, Validation_Combinations (i, 2));

        end
    
    end

%% Check the Options variable and return the corresponding output per user preference

    if Options.GetTheCombinations == true
        
        Metadata.Training_Signature_pairs = Training_Signature_pairs;
        Metadata.Validation_Signature_pairs = Validation_Signature_pairs;
        Metadata.Train_Combinations = Train_Combinations;
        Metadata.Validation_Combinations = Validation_Combinations;
        

    elseif  Options.GetTheRefsPerWriter == true
        
        Metadata.Training_Signature_pairs = Training_Signature_pairs;
        Metadata.Validation_Signature_pairs = Validation_Signature_pairs;
        Metadata.Training_Length = Training_Length;
        Metadata.Validation_Length = Validation_Length;

    elseif Options.GetAllMetadata == true
        
        Metadata.Training_Signature_pairs = Training_Signature_pairs;
        Metadata.Validation_Signature_pairs = Validation_Signature_pairs;
        Metadata.Train_Combinations = Train_Combinations;
        Metadata.Validation_Combinations = Validation_Combinations;
        Metadata.Training_Length = Training_Length;
        Metadata.Validation_Length = Validation_Length;
    
    end

end

