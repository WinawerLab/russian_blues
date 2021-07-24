%% Recreate FIgure 1 from paper
%
% This script loads in the processed data from this paper:
%
%  Winawer J, Witthoft N, Frank MC, Wu L, Wade AR, Boroditsky L. Russian
%  blues reveal effects of language on color discrimination. Proc Natl Acad
%  Sci U S A. 2007 May 8;104(19):7780-5. doi: 10.1073/pnas.0701644104. Epub
%  2007 Apr 30. PMID: 17470790; PMCID: PMC1876524.
%
% and then does simple computations (means and standard errors) to
% regenerate the summary data plotted in Figure 1 of the manuscript.
%
% See script "load_blues_data.m" for the generation of the processed data
% from the raw data.

stats = readtable('russian_blues_summary.csv');

mn  = NaN(6,2); row = 0;
varnames = cell(1,6);

for language = {'russian' 'english'}
    for interference = {'no_interference' 'spatial_interference' 'verbal_interference'}
        row = row+1; 
        varnames{row} = sprintf('%s %s %s', language{1}, interference{1});
        
        idx_b = strcmp(stats.language, language) & ...
            strcmp(stats.condition, interference) & ...
            strcmp(stats.category, 'between');
        idx_w = strcmp(stats.language, language) & ...
            strcmp(stats.condition, interference) & ...
            strcmp(stats.category, 'within');
        
        mn(row,1)  = mean(stats.mean_response_time(idx_b));
        mn(row,2)  = mean(stats.mean_response_time(idx_w));
        
        % mn_diff = mean(stats.mean_response_time(idx_w) - stats.mean_response_time(idx_b));
    end
end


figure(1),clf 
cats = categorical(varnames);
cats = reordercats(cats, varnames);
b = bar(cats, mn);
b(1).FaceColor = [.8 .8 .8];
b(2).FaceColor = [1 1 1];
ylim([800 1200])
ylabel('mean reaction time (ms)')
xlabel('interference conidtion')
legend('cross category', 'within category');
set(gca, 'YTick', 800:100:1200, 'FontSize', 16)
set(gcf, 'Color', 'w', 'Position', [1 500 700 400]);
% Note: To make the error bars, we need to compute  "one SE of the estimate
% of the two-way interaction between category and interference condition."
