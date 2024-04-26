%% Cleanliness is half of nobility

clear;clc;close all;
s = rng("default");

% Define the base directory and the specific directory name
baseDirectory = 'C:\Users\vasil\OneDrive\Υπολογιστής\Github projects\Second_Riemannian_Senario';
WorkspaceDirectory = 'Workspace';

% Create the full path to the specific directory
WorkspaceDirectoryPath = fullfile(baseDirectory, WorkspaceDirectory);

% Check if the specific directory exists, and if not, create it
if ~exist(WorkspaceDirectoryPath, 'dir')

    mkdir Workspace

end
%% In case you need man power

% delete(gcp('nocreate'))
% maxWorkers = maxNumCompThreads;
% disp("Maximum number of workers: " + maxWorkers);
% pool=parpool(maxWorkers/2);

%% Load the data
Covariance_matrices = load("CEDAR_covs10_v5_new_thlauto.mat");

% Right now the data, in the form of covariance matrices, can be though of as points on the
% Riemannian manifold.

% Sort out the Genuine from the Forgeries and delete the initial variable to save memory

for i = 1 : size(Covariance_matrices.CEDAR.G,1)
    
    for j = 1 : size(Covariance_matrices.CEDAR.G,2)
        
        G_CovMa{i,j} = struct2array(Covariance_matrices.CEDAR.G(i,j).cov(1,1));

    end

end

for i = 1 : size(Covariance_matrices.CEDAR.F,1)
    
    for j = 1 : size(Covariance_matrices.CEDAR.F,2)
        
        F_CovMa{i,j} = struct2array(Covariance_matrices.CEDAR.F(i,j).cov(1,1));

    end

end

clear Covariance_matrices

%% Create the vectors on the Tangent Plane

% Form the vectors of the covariances using as a common pole the I_{n-x-n}. That means that we have
% to use the logm function.
% G_Vecs = VecCell(G_CovMa);
% F_Vecs = VecCell(F_CovMa);

%% Learning Stage

numIters = 5;
numFolds = 2;

tic
for Iter = 1 : numIters

    fprintf('Now in Iteration: %d \n',Iter)

    % Randomly sample the indices every time for every folder. In this way, we retrieve half of
    % the dataset's writers in a randomly sampled manner, here 27 Writers
    randIndices = randsample(size(G_CovMa,1),floor(0.5*size(G_CovMa,1)));

    % Use the random indices to shuffle the cell array
    G_Learning_Data = G_CovMa(randIndices,:);
    F_Learning_Data = F_CovMa(randIndices,:);

    % Using reverse logic, we keep for the Testing Data the Writers that are not present in the
    % random indices created above by deleting the sampled ones. So here we would have the
    % remaining 28 Writers
    G_Testing_Data = G_CovMa;
    G_Testing_Data (randIndices,:) = [];

    F_Testing_Data = F_CovMa;
    F_Testing_Data(randIndices,:) = [];

    for Fold = 1 : numFolds

        fprintf('      Now in Fold: %d \n',Fold)

        % Partition the Genuine data into Training and Validation
        G_Metadata = Train_Val_Split(G_Learning_Data,"GetAllMetadata",true);

        % Partition the Forgery data into Training and Validation
        F_Metadata  = Train_Val_Split(F_Learning_Data,"GetAllMetadata",true);

        %% Form the ω(+) class

        % In order to form the ω(+) class, we need to perform Dichotomy Transform between the
        % Genuine signatures per writer. That means that if a writer has 17 training signatures
        % references, we need to perform Dichotomy Transform between every possible combination
        % of those 17 references.

        [G_Training_set,G_Val_set] = OmegaPlusFormation(G_Learning_Data,G_Metadata);


        %% Form the ω(-) class

        % The ω(-) class can be formed by different types. For example, Random Forgeries of a
        % person can be formed by pairing a Genuine sample of the questioned Writer with the
        % Genuine sample of another Writer. Here we employ a pairing between a Genuine sample
        % of a Writer with the simulated-or-skilled sample of the same Writer.

        [F_Training_set, F_Val_set] = OmegaMinusFormation(G_Learning_Data,F_Learning_Data, ...
            F_Metadata);

        %% Create the labels for the data
         
         % Create the labels for the Training set of both Genuine and Forgery
         G_Training_Label = ones([1 size(G_Training_set,1)])';
         F_Training_Label = -ones([1 size(F_Training_set,1)])';

         % Create the labels for the Validation set of both Genuine and Forgery
         G_Val_Label = ones([1 size(G_Val_set,1)])';
         F_Val_Label = -ones([1 size(F_Val_set,1)])';
         
         % Append them into a unified matrix of labels
         Training_Labels = [G_Training_Label;F_Training_Label];
         Validation_Labels  = [G_Val_Label;F_Val_Label];
        

        %% Scenario 2 - One total matrix

         Training_Matrix = [G_Training_set;F_Training_set];
         Validation_Matrix = [G_Val_set;F_Val_set];

        %% Perform Hyperparameter Optimization on the SVM
           
         Mdl = fitcsvm(gpuArray(Training_Matrix),Training_Labels, ...
                            'OptimizeHyperparameters','all', ...
                            'HyperparameterOptimizationOptions', ...
                            struct('Optimizer','gridsearch','NumGridDivisions',20, ...
                            'MaxObjectiveEvaluations',60,'ShowPlots',false));

         % Create a struct that stores the Hyperparameters

         BestHyperparams(Iter).BoxConstraint{Fold} = ...
                                                          Mdl.ModelParameters.BoxConstraint;

         BestHyperparams(Iter).KernelFunction{Fold} = ... 
                                                          Mdl.ModelParameters.KernelFunction;

         BestHyperparams(Iter).KernelScale{Fold} = ... 
                                                          Mdl.ModelParameters.KernelScale;

         BestHyperparams(Iter).PolynomialOrder{Fold} = ... 
                                                          Mdl.ModelParameters.KernelPolynomialOrder;

         BestHyperparams(Iter).KernelOffset{Fold} = ... 
                                                          Mdl.ModelParameters.KernelOffset;

         BestHyperparams(Iter).Standardize{Fold} = ... 
                                                          Mdl.ModelParameters.StandardizeData;
   
        %% Retrain the best found SVM

         Best_Mdl(Iter).Best_Model{Fold} = fitcsvm(gpuArray(Training_Matrix),Training_Labels, ...
                             'BoxConstraint'  ,     BestHyperparams(Iter).BoxConstraint{Fold}, ...
                             'KernelFunction' ,     BestHyperparams(Iter).KernelFunction{Fold}, ...
                             'KernelScale'    ,     BestHyperparams(Iter).KernelScale{Fold}, ...
                             'PolynomialOrder',     BestHyperparams(Iter).PolynomialOrder{Fold}, ...
                             'KernelOffset'   ,     BestHyperparams(Iter).KernelOffset{Fold}, ...
                             'Standardize'    ,     BestHyperparams(Iter).Standardize{Fold});

         fprintf('      Finished training the SVM for subfold %d of fold %d\n',Fold,Iter);

        %% Validation Stage

         [Predicted_Labels,Predicted_Scores] = predict(Best_Mdl(Iter).Best_Model{Fold}, ...
                                                                                 Validation_Matrix);

         [X,Y,T,AUC] = perfcurve(Validation_Labels,Predicted_Scores(:,2),1);
         
         FAR = X;
         FRR = 1 - Y;

         % Find the point where the difference between FPR and FNR is minimum (i.e., FPR ~ FNR)
         [~,minIndex] = min(abs(FAR - FRR));

         EER = FAR(minIndex); % or EER = FNR(minIndex);
         
        %% Store the data 
         
         % Create the testing indices by creating a vector with values from 1 to 55 and subtracting
         % the indices that were used for the Learning set. 
         Testing_Indices = 1:size(G_CovMa,1); 
         Testing_Indices(randIndices) = [];

         Best_Mdl(Iter).X{Fold} = X;
         Best_Mdl(Iter).Y{Fold} = Y;
         Best_Mdl(Iter).Scores{Fold} = Predicted_Scores;
         Best_Mdl(Iter).AUC(Fold) = AUC;
         Best_Mdl(Iter).EER(Fold) = EER;
         Best_Mdl(Iter).Learning_Indices = randIndices;
         Best_Mdl(Iter).Testing_Indices = Testing_Indices';
        
         % Plot the ROC
         % figure
         % 
         % plot(X,Y);
         % hold on
         % plot(EER,1-EER,'ro')
         % 
         % xlabel('False positive rate')
         % ylabel('True positive rate')
         % title(['ROC Curve of fold ' num2str(Iter) ' of subfold ' num2str(Fold)])
         % legend('ROC curve', 'EER point')
         % 
         % hold off
         % grid on;

        %% Change between the Testing and Learning Data for the K-Fold Cross Validation scheme

         % Here we transpose the Learning Data with the Testing Data, because in a 2-Fold cross
         % validation setup, the two sets are just flipped between them.

         tmp = G_Learning_Data;
         G_Learning_Data = G_Testing_Data; % <=  So here we expect G_Learning_Data to have 28 
                                           %     Writers now
         G_Testing_Data = tmp; % <= Respectively, we expect G_Testing_Data to have 27 Writers now

         tmp = F_Learning_Data;
         F_Learning_Data = F_Testing_Data;
         F_Testing_Data = tmp;

    end

end

Learning_Stage_time(Neighbor) = toc


%% Save the Training Data

    %% For the Model

fprintf('Saving Best Model \n')
FilenameBestMdl = 'Best_Mdl.mat';

% Create the full file path
fullFilePathBestMdl = fullfile(WorkspaceDirectory, FilenameBestMdl );

save(fullFilePathBestMdl,"Best_Mdl")

    %% For the Hyperparameters

fprintf('Saving Hyperparameters \n')
FilenameBestHyperparams = 'BestHyperparams.mat';

% Create the full file path
fullFilePathBestHyperparam = fullfile(WorkspaceDirectory, FilenameBestHyperparams);

save(fullFilePathBestHyperparam,"BestHyperparams")


%% Testing Stage

tic
for Iter = 1 : numIters

    % Here the internal iteration refers to the 5 iterations performed during the Learning Stage
    fprintf('Now in internal iteration: %d \n',Iter)
    
    % Create the Testing data per Fold per Iteration using the saved indices
    G_curr_fold =  G_Vecs(Best_Mdl(Iter).Testing_Indices',:);
    F_curr_fold =  F_Vecs(Best_Mdl(Iter).Testing_Indices',:);

    for Fold = 1 : numFolds

        fprintf('Now in Fold: %d of Iter: %d \n',Fold,Iter)

    %% Get the SVM classifier per fold

        % Use max as a way to find the maximum AUC per iteration per fold and using the created
        % index, collect the classificationSVM object from the corresponding variable of the struct
        % [~,Index] = (max(Best_Mdl(Iter).AUC,[],"all"));

        SVM = Best_Mdl(Iter).Best_Model{Fold};

    
   %% Create the Reference and Question Data
   
        [Data,Metrics] = RefsQuestionNV(G_curr_fold,F_curr_fold,SVM);
    
        Iter_Data(Iter).Data = Data;
        Iter_Data(Iter).Metrics = Metrics;

        EER_matrix{Iter,Fold} = horzcat(Iter_Data(Iter).Metrics(:).mean_EER_per_Iter_per_Writer);
        Mean_EER_per_iter_per_fold(Iter,Fold) = 100*mean(EER_matrix{Iter,Fold});
        
        % Change the data in order the next fold to contain the indices of the Learning-Testing of
        % the other folder.
       
        G_curr_fold = G_Vecs(Best_Mdl(Iter).Learning_Indices,:);
        F_curr_fold = F_Vecs(Best_Mdl(Iter).Learning_Indices,:);


    end

end
Testing_time = toc % With the use of for: time = 751.0769 secs | parfor time = 437.9042
Total_mean = mean(Mean_EER_per_iter_per_fold,"all");