%% Recreate Table 1 from paper
%
% This script loads in the processed data from this paper:
%
%  Winawer J, Witthoft N, Frank MC, Wu L, Wade AR, Boroditsky L. Russian
%  blues reveal effects of language on color discrimination. Proc Natl Acad
%  Sci U S A. 2007 May 8;104(19):7780-5. doi: 10.1073/pnas.0701644104. Epub
%  2007 Apr 30. PMID: 17470790; PMCID: PMC1876524.
%
% and then does simple computations (means and standard errors) to 
% regenerate the summary data in Table 1 of the manuscript. See notes at
% the end of the script. And see script "load_blues_data.m" for the
% generation of the processed data from the raw data.

stats = readtable('russian_blues_summary.csv');

mn  = NaN(3,8); sem = NaN(3,8); col = 0;
varnames = cell(1,8);

for language = {'russian' 'english'}
    for distance = {'near' 'far'}
        for category = {'between' 'within'}
            col = col+1; row = 0;
            varnames{col} = sprintf('%s %s %s', language{1}, distance{1}, category{1});
            
            for interference = {'no_interference' 'spatial_interference' 'verbal_interference'}
                row = row+1;
                idx = strcmp(stats.language, language) & ...
                    strcmp(stats.distance, distance) & ...
                    strcmp(stats.condition, interference) & ...
                    strcmp(stats.category, category);
                
                mn(row, col)  = mean(stats.mean_response_time(idx));
                
                sem(row,col) = std(stats.mean_response_time(idx))/sqrt(sum(idx));               
                
            end
        end
    end
end

% Table 1
t1 = array2table(round(mn), 'VariableNames', varnames, 'RowNames', {'None' 'Spatial' 'Verbal'});

t1sem = array2table(round(sem), 'VariableNames', varnames, 'RowNames', {'None' 'Spatial' 'Verbal'});

disp(t1);
disp(t1sem);

% Computed here:
% 
%                russian near between    russian near within    russian far between    russian far within    english near between    english near within    english far between    english far within
%                ____________________    ___________________    ___________________    __________________    ____________________    ___________________    ___________________    __________________
%     None               1164                   1288                    900                   914                     998                    999                    758                   735        
%     Spatial            1162                   1270                    911                   922                    1095                   1096                    819                   835        
%     Verbal             1325                   1260                    952                   955                    1120                   1131                    830                   812        
%                russian near between    russian near within    russian far between    russian far within    english near between    english near within    english far between    english far within
%                ____________________    ___________________    ___________________    __________________    ____________________    ___________________    ___________________    __________________
%     None                66                     77                     51                     52                     55                     55                     36                     32        
%     Spatial             58                     56                     41                     46                     64                     53                     37                     43        
%     Verbal              55                     50                     41                     46                     59                     50                     41                     36        


%% Notes:
% - The position of columns 3 and 4 appear to have been swapped with
%       columns 5 and 6: The published table columns for Russian speakers,
%       Far-color (columns 3 and 4) actually contain data for English
%       spakers, Near-color, and vice versa. This is an error in the
%       published paper. The error appears to be in the published table but
%       not in the published statistics, which match the reproduced table
%       rather than the published table. For example, the results report a
%       mean response time of 926 msec for Russian speakers for the far
%       condition, which is equal to the mean of the values in columns 3
%       and 4 of the reproduced table, not the mean of the values in
%       columns 3 and 4 of the published table.
% - After swapping columns 3/4 for 5/6 in the published table, the data
%       for Russian speakers are matched between the published and
%       reproduced tables.
% - After swapping columns 3/4 for 5/6 in the published table, the data for
%       English speakers are close to matched, but some numbers differ
%       slightly: 1096 vs 1095 msec, 1146 vs 1120, 1132 vs 1131, 831 vs
%       830, 821 vs 812. These appear to be 