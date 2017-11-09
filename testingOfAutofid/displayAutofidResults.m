function displayAutofidResults
% just for testing/playing around


load('autoTestingResults')
load('manualResults')
load('autoResults')
close all





fidNames = {'qrs_start', 'qrs_end','t_start', 't_peak','t_end'};
filenameTags = {'Run0136-b10-all.mat','Run0136-b15-all.mat','Run0136-b16-all.mat','Run0136-b20-all.mat','Run0136-b21-all.mat',  'Run0136-b24-all.mat',    'Run0136-b4-all.mat','Run0136-b6-all.mat'    'Run0136-b7-all.mat'  'Run0136-b9-all.mat'};
numRepetetion = 3;

[fid3D, fidNames, filenameTags, numRepetetion] = getFid3DarrayFromResults(manualResults);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% plot differences, each fiducial in its own subplot
for fidEnum = 1:length(fidNames)
    fidName = fidNames{fidEnum};
    
    %%%% get data
    manFids = getDataFromResults(manualResults,fidName);
    autoFids = getDataFromResults(autoResults,fidName);
    dif=abs(manFids - autoFids);
    
    %%%% plot result
    subplot(3,2,fidEnum)
    plot(dif)
    title(fidName)
    xlabel('beat')
    ylabel('difference (frames)')
end
superTitle = 'differences between manual and auto for each fiducial';
annotation('textbox', [0 0.9 1 0.1], ...
    'String', superTitle, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center')






























% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% plot a lead in each supblot and show windows, manFid and autoFid
% beatIdx =2;  % which beats to plot
% fidIdx = 1;         % which index in fidsTypes = [2,4,5,7,6]
% fidType = 2;
% leads=[1 2 3 4 5 6 7 8 9 10];   % which leads in potvals
% plotWindow = testdata.ws(fidIdx):testdata.we(fidIdx);    % what frames to plot
% time = 1:size(testdata.reducedSeedPotvals,2);
% figure
% hold on
% pv = rbpv{beatIdx};
% for leadEnum = 1:length(leads)
%     leadIdx=leads(leadEnum);
%     
%     subplot(4,3,leadEnum)
%     
%     %%%% plot lead
%     plot(pv(leadIdx,:),'color','b')
%     Ylim =  ylim;
%     
%     %%%% plot window
%     line([testdata.ws(fidIdx) testdata.ws(fidIdx)], Ylim, 'color','r')
%     line([testdata.we(fidIdx) testdata.we(fidIdx)], Ylim, 'color','r')
%     
%     %%%% plot kernel
% %     line([testdata.fsk(fidIdx) testdata.fsk(fidIdx)], Ylim, 'color','b')
% %     line([testdata.fek(fidIdx) testdata.fek(fidIdx)], Ylim, 'color','b')
% 
%     %%%% plot autofound indivFiducial
%     autoFidValue = allIndFids{beatIdx}(fidIdx).value(leadIdx);
%     line([autoFidValue autoFidValue], Ylim, 'color','b')
%     
%     
%     %%%% plot manuFid
%     fid = manualResults(beatIdx).fiducials;
%     manFidValue = fid([fid.type] == fidType).value;
%     line([manFidValue manFidValue], Ylim, 'color','g')
%     
%     
%     %%%% plot seedLead
%     hold on
%     plot(testdata.reducedSeedPotvals(leadIdx,:),'color','r')
% end
% titlestring = 'each plot is a different lead, all of one beat, manfid is green, autofid is blue, window is red, seedLead in r, beatLead in blue';
% annotation('textbox', [0 0.9 1 0.1], ...
%     'String', titlestring, ...
%     'EdgeColor', 'none', ...
%     'HorizontalAlignment', 'center')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  show each lead in a supblot. multiple beats per subplot, display window and kernel
% figure
% for leadEnum = 1:length(leads)
%     leadIdx=leads(leadEnum);
%     
%     subplot(4,3,leadEnum)
%     hold on
%     for p = 1:4
%         plot(rbpv{p}(leadIdx,:))
%     end
%     Ylim =  ylim;
%     for p=1:4
%         line([testdata.ws(fidIdx) testdata.ws(fidIdx)], Ylim, 'color','r')
%         line([testdata.we(fidIdx) testdata.we(fidIdx)], Ylim, 'color','r')
% 
%         line([testdata.fsk(fidIdx) testdata.fsk(fidIdx)], Ylim, 'color','b')
%         line([testdata.fek(fidIdx) testdata.fek(fidIdx)], Ylim, 'color','b')
%     end
% end
% titlestring = 'each plot is a different lead and in each plot 4 different beats are shown';
% annotation('textbox', [0 0.9 1 0.1], ...
%     'String', titlestring, ...
%     'EdgeColor', 'none', ...
%     'HorizontalAlignment', 'center')



%%%% plot differences of two


















