%% Process Russian Blues Data
%
% This script loads in the raw data from this paper:
%
%  Winawer J, Witthoft N, Frank MC, Wu L, Wade AR, Boroditsky L. Russian
%  blues reveal effects of language on color discrimination. Proc Natl Acad
%  Sci U S A. 2007 May 8;104(19):7780-5. doi: 10.1073/pnas.0701644104. Epub
%  2007 Apr 30. PMID: 17470790; PMCID: PMC1876524.
%
% The raw data is stored as "russian_blues_data.csv". The script does some
% minimal organizing and processing as described in the manuscript (e.g.,
% labeling trials as "correct" or "incorrect", rejecting outlier trials)
% and saves out the processed data as "russian_blues_data_processed.csv".
% It also saves out the summary data used for statistics and visualization
% as "russian_blues_summary.csv". The summary data average trials within
% subjects and conditions.

%% Read in raw data

% read it in
opts = detectImportOptions('russian_blues_data.csv');
opts = setvartype(opts, 'target', 'char');
opts = setvartype(opts, 'left', 'char');
opts = setvartype(opts, 'right', 'char');
T = readtable('russian_blues_data.csv', opts);

%% Remove pilot subjects who did not do the categorization task
% English-speaking subjects 1-13 did not have categorization trials to
% measure border. These data were not analyzed.
ok = T.subject >= 14;
T = T(ok,:);

fprintf('Total number of subjects: %d\n', length(unique(T.subject)));
fprintf('Number of English-speaking subjects: %d\n', length(unique(T.subject(contains(T.language, 'english')))));
fprintf('Number of Russian-speaking subjects: %d\n', length(unique(T.subject(contains(T.language, 'russian')))));

%% Make condition names more readable 

% 3 types of discrimination trials (with spatial, verbal, or no interference)
T.condition(contains(T.condition, 'nomemRT_verbalint'))  = {'verbal_interference'};
T.condition(contains(T.condition, 'nomemRT_spatialint')) = {'spatial_interference'};
T.condition(contains(T.condition, 'nomemRT'))            = {'no_interference'};

% Spatial memory test (for spatial interfernce)
%   G = spatial Grid pattern to remember
T.condition(contains(T.left, 'G')) = {'spatial_test'};

% Numerical memory test (for verbal interference)  
%   N = 9-digit Number to remember
T.condition(contains(T.left, 'N'))  = {'verbal_test'};

% For some subjects, border trials seem to have been accidentally labeled "NULL"
T.condition(contains(T.condition, 'NULL'))  = {'border'};

%% Accurarcy: Identify correct trials

% Find the discrimination and interference trials
discrimination_trials = contains(T.condition, 'interference');
interference_trials   = contains(T.condition, 'test');

discrimination_accuracy = ...
    discrimination_trials & ... % it's a disrimintation trial AND ...
    (...
    cellfun(@isequal, T.target, T.left)  & contains(T.key, 'x') | ... 'x' for target_left
    cellfun(@isequal, T.target, T.right) & contains(T.key, '.') ...   '.' for target_right
    ); 

interference_accuracy = ...      
    interference_trials & ... % it's an interference trial AND ...
    (...
    contains(T.right, 'left') & contains(T.key, 'x') | ... 'x' for left
    contains(T.right, 'right') & contains(T.key, '.')  ... '.' for right
    ); 

% Each interference test followed 8 discrimination trials. Set those those
%   previous 8 trials to have interference accuracy matched to subsequent
%   interference trial
idx = find(interference_accuracy);
for ii = 1:8, interference_accuracy(idx-ii) = true; end
interference_accuracy = interference_accuracy | strcmp(T.condition, 'no_interference');

% Add the accuracy variables to the table
T = addvars(T, discrimination_trials, interference_trials, discrimination_accuracy, interference_accuracy);

% Check accuracy per subject
data = grpstats(T(T.discrimination_trials,:), 'subject', 'mean', 'DataVars','discrimination_accuracy');
figure, histogram(data.mean_discrimination_accuracy); 
xlim([.5 1]); ylabel('counts'); xlabel('Discrimination accuaracy')

data = grpstats(T(T.interference_trials,:), 'subject', 'mean', 'DataVars','interference_accuracy');
figure, histogram(data.mean_interference_accuracy);
xlim([.5 1]); ylabel('counts'); xlabel('Inteference accuaracy')


%% Label discrimination distance ('near' or 'far')

% "The nonmatching/distracter color square was either very similar to the
% other two (two steps apart in our continuum of 20, a near-color
% comparison) or more different (four steps apart, a far-color
% comparison)."

target = str2double(T.target);
left   = str2double(T.left);
right  = str2double(T.right);

distance = cell(size(T.trial));

near = abs(left-right)==2;
far  = abs(left-right)==4;
assert(sum(near)+sum(far) == sum(discrimination_trials));

distance(far)  = {'far'};
distance(near) = {'near'};

T = addvars(T, distance);

%% Label trials as "within" or "between" category

% "Each subject’s data were analyzed relative to their own linguistic
% boundary. Trials were classified as within-category if the test stimuli
% fell on the same side of that subject’s boundary".

B = readtable('./borders.csv');
T = join(T, B); clear B;

border = T.borders;
category = cell(size(T.trial));
within = discrimination_trials & ...
    (left < border & right < border) | ...
   (left > border & right > border) ;
between = discrimination_trials & ...
    (left <= border & right >= border) | ...
    (left >= border & right <= border);
assert(sum(within)+sum(between) == sum(discrimination_trials));

category(within) = {'within'};
category(between) = {'between'};

T = addvars(T, category);

%% Include trials if stimuli are near the border, as per paper
% "For each subject, the nine near-color and the nine far-color comparisons
% closest to that subject’s boundary were included in the analysis. This
% ensured that the set of stimuli used was centered relative to each
% subject's category boundary."
%
% In practice, this meant keep trials in which the average of the left and
% right stimuli was within 4 steps of the border

mean_dist = (left+right)/2 - border;
include_by_stim = abs(mean_dist) < 4.5;
include_by_stim(~discrimination_trials) = false;

T = addvars(T, include_by_stim);

%% Include trials with acceptable performance, as per criteria in paper
% "Additionally, trials were excluded if the response to the interference
% stimulus was incorrect during the interference blocks, if the response to
% the color task was incorrect, or if the reaction time for the color
% discrimination was >3 sec; 12% of trials were so excluded."

include_by_performance = ...
    T.discrimination_accuracy & ...
    T.interference_accuracy & ...
    T.response_time <= 3000;

T = addvars(T, include_by_performance);

%% Exclude subjects, as per criteria in paper
% "Subjects were excluded entirely from analysis if the above criteria
% resulted in loss of 25% or more of the trials, leading to the exclusion
% of three English and five Russian speakers."

stats = grpstats(T(T.include_by_stim,:), 'subject', 'mean', 'DataVars', 'include_by_performance');
include = stats.mean_include_by_performance >= 0.745;

include_by_subject = ...
   ismember(T.subject, stats.subject(include));

% check - manuscript says we excluded 3 english-speaking and 5
% russian-speaking subjects
disp(stats.subject(~include))

T = addvars(T, include_by_subject);

% Note that it appears that one subject had 74.54% trials 'ok' by stated
% criteria and was retained when they should have been rejected due to the
% 75% threshold. (This was due to a rounding error - i.e., percent retained
% was as column 2 digit percents, eg 60%, 75%, 90% etc). 

%% Generate a new summary table
%
% This table should have has 504 rows, summarizing responses by
% within-subject means:
%
% x 2 language groups (English, Russian) 
% x 2 distances (near, far)
% x 3 conditions (no, spatial, verbal)
% x 2 categories (between, within)
% x 21 subjects 
% = 2 * 2* 3 * 2 * 21 = 504

ok = T.include_by_stim & T.include_by_performance & T.include_by_subject;
stats = grpstats(T(ok,:), {'language', 'distance', 'condition','category',  'subject'},...
    'mean', 'DataVars', {'response_time', 'discrimination_accuracy', 'interference_accuracy'});

%% Save the processed table, T, and the summary table, Stats
writetable(T, 'russian_blues_data_processed.csv');
writetable(stats, 'russian_blues_summary.csv');

