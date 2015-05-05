function [WP, DP, Z] = ldaBuildModel(WO, WS, DS, params)
% Build basic LDA model using Gibbs sampling
% WO: vocabulary
% WS: vector of word indices in vocabulary
% DS: vector of document index corresponding to each word index

modelFile = params.modelFile;
topicsFile = params.topicsFile;

if exist(modelFile, 'file')
    load(modelFile);
else
    % Set the number of topics
    T = params.T;
    
    % Set the hyperparameters
    BETA = params.BETA;
    ALPHA = params.ALPHA;
    
    % The number of iterations
    N = 1000; 

    % The random seed
    SEED = 3;

    % What output to show (0=no output; 1=iterations; 2=all output)
    OUTPUT = 1;

    % This function might need a few minutes to finish
    tic
    [ WP,DP,Z ] = GibbsSamplerLDA( WS , DS , T , N , ALPHA , BETA , SEED , OUTPUT );
    toc

    % Just in case, save the resulting information from this sample 
    save(modelFile, 'WP', 'DP', 'Z', 'ALPHA', 'BETA', 'SEED', 'N');
end

%%
% Put the most 7 likely words per topic in cell structure S
[S] = WriteTopics( WP , BETA , WO , 7 , 0.7 );

fprintf( '\n\nMost likely words in the first ten topics:\n' );

%%
% Show the most likely words in the first ten topics
S( 1:10 )  

%%
% Write the topics to a text file
WriteTopics( WP , BETA , WO , 10 , 0.7 , 4 , topicsFile );

fprintf( '\n\nInspect the file ''topics.txt'' for a text-based summary of the topics\n' ); 