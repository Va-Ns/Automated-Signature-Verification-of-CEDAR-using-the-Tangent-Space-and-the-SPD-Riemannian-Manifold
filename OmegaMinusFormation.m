function [F_Training_set, F_Val_set]= OmegaMinusFormation(G_Learning_Data,F_Learning_Data,F_Metadata)

    arguments
        
        G_Learning_Data             {mustBeNonempty,mustBeNonmissing}
        F_Learning_Data             {mustBeNonempty,mustBeNonmissing}
        F_Metadata                  {mustBeUnderlyingType(F_Metadata,"struct")}
        

    end

    F_Training_set = [];
    F_Val_set = [];
    
    % Define the size of signatures you'll get from each Writer.
    Signature_Training_Length = F_Metadata.Training_Length;

    for curWriter = 1 : size(G_Learning_Data,1)
    
        % Get the 17 Genuine signatures from the current Writer.
        Current_G_Data = G_Learning_Data(curWriter,1:Signature_Training_Length);

        % Get the 17 Forgery signatures from the current Writer.
        Current_F_Data = F_Learning_Data(curWriter,1:Signature_Training_Length);
        
        % So for the current Genuine Signature of the current Writer
        for CurGSign = 1 : length(Current_G_Data) 
            
            % And for the current Forgery Signature of the current Writer
            for CurFSign = 1 : length(Current_F_Data)
                
                % Assign the Dichotomy Transform between the Genuine and Forgery Signature of the
                % current Writer into a struct. The result will be a 1-by-17 structure where each
                % field is a 17-by-55 matrix that holds the Dichotomy Transform of the current
                % Genuine signature with the Forgery signatures of the current Writer.
                Sign_Dichotomy(CurGSign).Pairs(CurFSign,:) = abs(Current_G_Data{CurGSign}- ...
                                                                        Current_F_Data{CurFSign});
            end

        end
        
        % After the procedure ends, it's time to collect the data into a single matrix.
        Sign_Cur_Writer = [];

        for i = 1 : length(Sign_Dichotomy)

            Sign_Cur_Writer = [Sign_Cur_Writer;Sign_Dichotomy(i).Pairs];

        end

        % Now from the matrix that holds the combinations of the G-F pairs of the current Writer,
        % randomly select only 136 samples. This is done in order the Genuine and Forgery set to 
        % have an equal number of observations.
        
        % Create the random indices
        random_Indices = randperm(nchoosek(F_Metadata.Training_Length,2));
        
        % Randomly select 136 observations from the matrix of 289-by-55 size
        Cur_Selected_Data = Sign_Cur_Writer(random_Indices,:);
        
        % Append the current selected data into the Training set of the ω(-) class
        F_Training_set = [F_Training_set;Cur_Selected_Data];

    end

    %% For the Validation set of the Forgeries

    for curWriter = 1 : size(G_Learning_Data,1)
    
        % Get the 7 Genuine signatures from the current Writer.
        Current_G_Data = G_Learning_Data(curWriter,Signature_Training_Length+1:end);

        % Get the 7 Forgery signatures from the current Writer.
        Current_F_Data = F_Learning_Data(curWriter,Signature_Training_Length+1:end);
        
        % So for the current Genuine Signature of the current Writer
        for CurGSign = 1 : length(Current_G_Data) 
            
            % And for the current Forgery Signature of the current Writer
            for CurFSign = 1 : length(Current_F_Data)
                
                % Assign the Dichotomy Transform between the Genuine and Forgery Signature of the
                % current Writer into a struct. The result will be a 1-by-7 structure where each
                % field is a 7-by-55 matrix that holds the Dichotomy Transform of the current
                % Genuine signature with the Forgery signatures of the current Writer.
                Sign_Val_Dichotomy(CurGSign).Pairs(CurFSign,:) = abs(Current_G_Data{CurGSign}- ...
                                                                        Current_F_Data{CurFSign});
            end

        end
        
        % After the procedure ends, it's time to collect the data into a single matrix.
        Sign_Cur_Writer = [];

        for i = 1 : length(Sign_Val_Dichotomy)

            Sign_Cur_Writer = [Sign_Cur_Writer;Sign_Val_Dichotomy(i).Pairs];

        end

        % Create the random indices
        random_Indices = randperm(nchoosek(F_Metadata.Validation_Length,2));
        
        % Randomly select 21 observations from the matrix of 49-by-55 size
        Cur_Selected_Data = Sign_Cur_Writer(random_Indices,:);
        
        % Append the current selected data into the Training set of the ω(-) class
        F_Val_set = [F_Val_set;Cur_Selected_Data];

    end


end

