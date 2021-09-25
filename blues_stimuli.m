% Check Russian Blues Stimuli
%
% This visualizes the color stimuli used for
%
%  Winawer J, Witthoft N, Frank MC, Wu L, Wade AR, Boroditsky L. Russian
%  blues reveal effects of language on color discrimination. Proc Natl Acad
%  Sci U S A. 2007 May 8;104(19):7780-5. doi: 10.1073/pnas.0701644104. Epub
%  2007 Apr 30. PMID: 17470790; PMCID: PMC1876524.
%

T = readtable('./Russian Blues stimuli.csv');
displays = unique(T.displayname);

%% Plot the x-y values of the stimuli as measured on 4 displays
figure(1); clf;
set(gcf, 'Color', 'w'); 

subplot(2,1,1)
% chroma only
for ii =1:length(displays)
   idx = contains(T.displayname, displays{ii});
   scatter(T.x(idx), T.y(idx)); hold on;
end
xlabel('cie-x'); ylabel('cie-y'); axis square
legend(displays, 'Location', 'best')

subplot(2,1,2) 
% xyY
for ii =1:length(displays)
   idx = contains(T.displayname, displays{ii});
   scatter3(T.x(idx), T.y(idx), T.Y(idx)); hold on;
end
legend(displays)
xlabel('cie-x'); ylabel('cie-y'); zlabel('cie-Y')
