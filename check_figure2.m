%% Recreate Figure 2 from paper
%
% This script loads in the processed data from this paper:
%
%  Winawer J, Witthoft N, Frank MC, Wu L, Wade AR, Boroditsky L. Russian
%  blues reveal effects of language on color discrimination. Proc Natl Acad
%  Sci U S A. 2007 May 8;104(19):7780-5. doi: 10.1073/pnas.0701644104. Epub
%  2007 Apr 30. PMID: 17470790; PMCID: PMC1876524.
%
% and then does simple computations (means and standard errors) to
% regenerate the summary data plotted in Figure 2 of the manuscript.
%
% See script "load_blues_data.m" for the generation of the processed data
% from the raw data.

stats = readtable('russian_blues_summary.csv');

mn  = NaN(4,3); col = 0; row = 0;
varnames = cell(1,4);
for language = {'russian' 'english'}
    for distance = {'near' 'far'}
        row = row+1; col = 0;
        for interference = {'no_interference' 'spatial_interference' 'verbal_interference'}
            col = col+1;
            varnames{row} = sprintf('%s %s', language{1}, distance{1});
            
            idx_b = strcmp(stats.language, language) & ...
                strcmp(stats.condition, interference) & ...
                strcmp(stats.distance, distance) & ...
                strcmp(stats.category, 'between');
            idx_w = strcmp(stats.language, language) & ...
                strcmp(stats.condition, interference) & ...
                strcmp(stats.distance, distance) & ...                
                strcmp(stats.category, 'within');
            
            mn(row,col)  = mean(stats.mean_response_time(idx_w)-stats.mean_response_time(idx_b));            
            
            % mn_diff = mean(stats.mean_response_time(idx_w) - stats.mean_response_time(idx_b));
        end
    end
    
end
figure(2),clf
cats = categorical(varnames);
cats = reordercats(cats, varnames);
b = bar(cats, mn);
b(1).FaceColor = [1 1 1];
b(2).FaceColor = .8*[1 1 1];
b(3).FaceColor = .4*[1 1 1];
legend('no interference', 'spatial interference', 'verbal Interference');
ylim([-100 200])
set(gca, 'YTick', -100:50:200, 'FontSize', 16)
set(gcf, 'Color', 'w', 'Position', [700 500 500 500])
% Note: To make the error bars, we need to compute  "one SE of the estimate
% of the three-way interaction among category, interference condition, and
% color distance."

% Note that in the original paper, for both Table 1 and figure 2, there
% appears to have been an erroneous switch such that the Russian-speakers'
% far data got swapped with the English-speakers' near data. This doesn't
% appear to have affected the statistics but only the visualization. And
% even for visualization, it appears to be a minor effect.