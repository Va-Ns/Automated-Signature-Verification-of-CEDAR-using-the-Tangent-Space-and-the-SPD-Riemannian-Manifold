function [Data,Metrics] = RefsQuestionNV(G_Testing_Data,F_Testing_Data,SVM,Options)

    arguments
        G_Testing_Data            {mustBeUnderlyingType(G_Testing_Data,"cell")}
        F_Testing_Data            {mustBeUnderlyingType(F_Testing_Data,"cell")}
        SVM                       {mustBeNonempty,mustBeUnderlyingType(SVM,"ClassificationSVM")}
        Options.numReferences     {mustBeNonnegative,mustBeInteger} = 10
        Options.numOfTestingIters {mustBePositive,mustBeInteger} = 10 % Per user's preference
    end

    % For every Writer
    for Writer = 1 : size(G_Testing_Data,1)
        
        % For the number of Testing iterations
        for Testing_Iter = 1 : Options.numOfTestingIters
    
            fprintf('    Now in Testing iteration: %d of Writer: %d \n',Testing_Iter,Writer)
    
            % Create the 10 random Reference Writers
            G_RandIndices = randsample(size(G_Testing_Data,2),Options.numReferences)';

            % Create 24 random indices for the Forgery data
            F_RandIndices = randperm(size(F_Testing_Data,2));
    
            % We now need to create the remaining indices (here 14) that will be used as part of the
            % Question set. To do that, we employ the same way as in the Learning Set, where we 
            % first create a vector of values that range from 1 to the length of the remaining 
            % Signatures and then using reverse logic, we erase those indices that have been formed 
            % by the previous step. In that way only the remaining indices are left for the 
            % Reference data.
            RemainRandInd = 1:size(G_Testing_Data,2);
            RemainRandInd(:,G_RandIndices) = [];
    
            % Create a struct that holds the G_testing_Data of the selected randomly generated 
            % indices for the Reference data, while for the Question data append the remaining 
            % data of the Reference data with randomly indexed Forgery data of the same Writer, per
            % Writer
            Data(Writer).Refs = G_Testing_Data(Writer,G_RandIndices);
            Data(Writer).Question = [G_Testing_Data(Writer,RemainRandInd),...
                F_Testing_Data(Writer,F_RandIndices)];
            
            % Create the Ground Truth labels 
            % Ref_Labels = ones(length(G_RandIndices),1);
            Quest_Labels = [ones(length(RemainRandInd),1);-ones(length(F_RandIndices),1)];
    
            % Having now created the necessary data for the Reference and Question data per Writer, 
            % we can employ Dichotomy Transform between the two aforementioned ones. Specifically, 
            % we change the point of view with which we perform the DT, and create the absolute 
            % difference between the current Question data with all the Reference data. That means 
            % that:
            %
            %
            %            Question                              Reference
            %      1 |   1-by-55   |-------------------- 1 |   1-by-55   |
            %      2 |   1-by-55   |             |------ 2 |   1-by-55   |
            %      3 |   1-by-55   |             |------ 3 |   1-by-55   |
            %      4 |   1-by-55   |
            %      .         .                   .       .         .
            %      .         .                   .       .         .
            %      .         .                   .       .         .
            %      .         .
            %      .         .                  |------ 10 |   1-by-55   |
            %      38 |   1-by-55   |
    
            for RefData = 1 :  Options.numReferences
    
                for numQuestion = 1 :  length(Data(Writer).Question)

                    X = Data(Writer).Refs{RefData};

                    Y = Data(Writer).Question{numQuestion};

                    X_s = sqrtm(X);
    
                    Data(Writer).AIRM{RefData,numQuestion} = logm(X_s\Y/X_s);

                    Data(Writer).Vecs{RefData,numQuestion} = ...
                               real(VecsOfTangentPlaneNV(Data(Writer).AIRM{RefData,numQuestion}))';

                end

                % Vertically concatenate the vectors of the Dichotomy Transform into a matrix to
                % feed it to predict with the SVM object
                Data(Writer).Vecs_Matrix{RefData} = vertcat(Data(Writer).DT{RefData,:});

                [Labels,Scores] = predict(SVM,Data(Writer).Vecs_Matrix{RefData});
                
                % Store the scores
                Data(Writer).Scores{RefData} = Scores;

                % Store the maximum value of Scores
                [Data(Writer).maxScore(RefData),Ind] = max(Scores(:,2),[],"all");

                % Select the label where the maximum score is found
                Data(Writer).Labels{RefData} = Labels(Ind,:);

            end

            [X,Y,T,AUC] = perfcurve(Quest_Labels, Data(Writer).maxScore',1);
         
            FAR = X;
            FRR = 1 - Y;

            % Find the point where the difference between FPR and FNR is minimum (i.e., FPR ~ FNR)
            [~,minIndex] = min(abs(FAR - FRR));

            EER = FAR(minIndex); % or EER = FNR(minIndex);

            Metrics(Writer).Writer_EER(Testing_Iter) = EER;
            Metrics(Writer).Writer_AUC(Testing_Iter) = AUC;

    
        end

        Metrics(Writer).mean_EER_per_Iter_per_Writer = mean(Metrics(Writer).Writer_EER,2);
    
    end
        
end