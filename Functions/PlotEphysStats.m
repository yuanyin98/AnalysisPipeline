function PlotEphysStats(ExpName,Params,HomeDir)
% plot ephys statistics for MEA data
% author RCFeord July 2021
% Updated by Tim Sit 
%{

Parameters 
-----------
ExpName : str
Params : structure
    The following fields are used
    groupColors : (nGroup x 3 matrix)
        the RGB colors to use for each group during plotting
    
HomeDir : str

Returns
-------
None
%}

%% colours

% colour scheme for age groups DIV
ColOpt1 = [0.988 0.906 0.149];
ColOpt2 = [0.710 0.871 0.173];
ColOpt3 = [0.427 0.808 0.345];
ColOpt4 = [0.208 0.718 0.478];
ColOpt5 = [0.118 0.624 0.537];
ColOpt6 = [0.145 0.514 0.557];
ColOpt7 = [0.192 0.404 0.553];
ColOpt8 = [0.239 0.290 0.541];
ColOpt9 = [0.282 0.157 0.474];
ColOpt10 = [0.267 0.051 0.325];
nColOpt = 10;

% specify colours to use on the basis of the number of time points
nDIV = length(Params.DivNm);
if nDIV == 1
    cDiv1 = ColOpt5;
else
    for ii = 1:nDIV
        eval(['cDiv' num2str(ii) '= ColOpt' num2str(round(1+(nColOpt/nDIV)*(ii-1))) ';']);
    end
end

%% Custom bounds for y axis 

eMetCustomBounds = { ...
'mean firing rate (Hz)', [0, nan]; ...
'median firing rate (Hz)', [0, nan]; ...
'network burst rate (per minute)', [0, nan]; ... 
'mean network burst length (s)', [0, nan]; ...
'mean ISI within network burst (ms)', [0, nan]; ...
'mean ISI outside network bursts (ms)', [0, nan]; ...
'coefficient of variation of inter network burst intervals', [0, nan]; ...
'fraction of in network bursts', [0, 1]};

metricsWCustomBounds = eMetCustomBounds(:, 1);

%% groups and DIV

Grps = Params.GrpNm;
AgeDiv = Params.DivNm;

if strcmp(char(Grps{1}),'HET')&&strcmp(char(Grps{2}),'KO')&&strcmp(char(Grps{3}),'WT')
   clear Grps
   Grps{1} = 'WT'; Grps{2} = 'HET'; Grps{3} = 'KO';
end

%% Variable names

% whole experiment metrics (1 value per experiment)

% names of metrics
ExpInfoE = {'Grp','DIV'}; % info for both age and genotype
% list of metrics 
NetMetricsE = {'numActiveElec','FRmean','FRmedian','NBurstRate','meanNumChansInvolvedInNbursts', ... 
               'meanNBstLengthS','meanISIWithinNbursts_ms','meanISIoutsideNbursts_ms','CVofINBI','fracInNburst'}; 

% single cell/node metrics (1 value per cell/node)

% names of metrics
ExpInfoC = {'Grp','DIV'}; % info for both age and genotype
% list of metrics 
NetMetricsC = {'FR'};

%% Import data from all experiments - whole experiment  

cd(strcat('OutputData',Params.Date)); cd('ExperimentMatFiles')

for g = 1:length(Grps)
    % create structure for each group
    VN1 = cell2mat(Grps(g));
    eval([VN1 '= [];']);
    
    % add substructure for each DIV range
    for d = 1:length(AgeDiv)
        VN2 = strcat('TP',num2str(d));
        
        % add variable name
        for e = 1:length(NetMetricsE)
            VN3 = cell2mat(NetMetricsE(e));
            eval([VN1 '.' VN2 '.' VN3 '= [];']);
            clear VN3
        end
        clear VN2
    end
    clear VN1
end

% allocate numbers to relevant matrices
for i = 1:length(ExpName)
     Exp = strcat(char(ExpName(i)),'_',Params.Date,'.mat');
     load(Exp)
     for g = 1:length(Grps)
         if strcmp(cell2mat(Grps(g)),cell2mat(Info.Grp))
             eGrp = cell2mat(Grps(g));
         end       
     end
     for d = 1:length(AgeDiv)
         if cell2mat(Info.DIV) == AgeDiv(d)
             eDiv = strcat('TP',num2str(d));
         end    
     end
     for e = 1:length(NetMetricsE)
         eMet = cell2mat(NetMetricsE(e));
         VNs = strcat('Ephys.',eMet);
         eval(['DatTemp =' VNs ';']);
         clear VNs
         VNe = strcat(eGrp,'.',eDiv,'.',eMet);
         eval([VNe '= [' VNe '; DatTemp];']);
         clear DatTemp
     end
     clear Info NetMet adjMs
end

%% Import data from all experiments - electrode-specific data 

for g = 1:length(Grps)
    % create structure for each group
    VN1 = cell2mat(Grps(g));

    % add substructure for each DIV range
    for d = 1:length(AgeDiv)
        VN2 = strcat('TP',num2str(d));
        
        % add variable name
        for e = 1:length(NetMetricsC)
            VN3 = cell2mat(NetMetricsC(e));
            eval([VN1 '.' VN2 '.' VN3 '= [];']);
            clear VN3
        end
        clear VN2
    end
    clear VN1
end

% allocate numbers to relevant matrices
for i = 1:length(ExpName)
     Exp = strcat(char(ExpName(i)),'_',Params.Date,'.mat');
     load(Exp)
     for g = 1:length(Grps)
         if strcmp(cell2mat(Grps(g)),cell2mat(Info.Grp))
             eGrp = cell2mat(Grps(g));
         end       
     end
     for d = 1:length(AgeDiv)
         if cell2mat(Info.DIV) == AgeDiv(d)
             eDiv = strcat('TP',num2str(d));
         end    
     end
     for e = 1:length(NetMetricsC)
         eMet = cell2mat(NetMetricsC(e));
         VNs = strcat('Ephys.',eMet);
         eval(['DatTemp =' VNs ';']);
         clear VNs
         VNe = strcat(eGrp,'.',eDiv,'.',eMet);
         eval([VNe '= [' VNe '; DatTemp''];']);
         clear DatTemp
     end
     clear Info NetMet adjMs
end


%% export to excel / csv
% TODO: export to csv as well

cd(HomeDir); cd(strcat('OutputData',Params.Date));

% network means
for g = 1:length(Grps)
    eGrp = cell2mat(Grps(g));
    for d = 1:length(AgeDiv)
        eDiv = strcat('TP',num2str(d));
        VNe = strcat(eGrp,'.',eDiv);
        VNet = strcat('TempStr.',eDiv);
        for e = 1:length(NetMetricsE)
            eval([VNet '.' char(NetMetricsE(e)) '=' VNe '.' char(NetMetricsE(e)) ';']);
        end
        eval(['DatTemp = ' VNet ';']);
        writetable(struct2table(DatTemp), strcat('NeuronalActivity_RecordingLevel_',eGrp,'.xlsx'),'FileType','spreadsheet','Sheet',strcat('Age',num2str(AgeDiv(d))));
    end
end

clear DatTemp TempStr

% electrode specific
for g = 1:length(Grps)
    eGrp = cell2mat(Grps(g));
    for d = 1:length(AgeDiv)
        eDiv = strcat('TP',num2str(d));
        VNe = strcat(eGrp,'.',eDiv);
        VNet = strcat('TempStr.',eDiv);
        for e = 1:length(NetMetricsC)
            eval([VNet '.' char(NetMetricsC(e)) '=' VNe '.' char(NetMetricsC(e)) ';']);
        end
        eval(['DatTemp = ' VNet ';']);
        writetable(struct2table(DatTemp), strcat('NeuronalActivity_NodeLevel_',eGrp,'.xlsx'),'FileType','spreadsheet','Sheet',strcat('Age',num2str(AgeDiv(d))));
    end
end


clear DatTemp TempStr




%% notBoxPlots - plots by group

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('3_RecordingsByGroup'); cd('NotBoxPlots');

eMet = NetMetricsE; 
eMetl = {'number of active electrodes','mean firing rate (Hz)','median firing rate (Hz)', ... 
    'network burst rate (per minute)','mean number of channels involved in network bursts', ...
    'mean network burst length (s)','mean ISI within network burst (ms)', ... 
    'mean ISI outside network bursts (ms)','coefficient of variation of inter network burst intervals', ... 
    'fraction of in network bursts'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

for n = 1:length(eMet)
    F1 = figure;
    eMeti = char(eMet(n));
    xt = 1:0.5:1+(length(AgeDiv)-1)*0.5;
    for g = 1:length(Grps)
        h(g) = subplot(1,length(Grps),g);
        eGrp = cell2mat(Grps(g));
        for d = 1:length(AgeDiv)
            eDiv = strcat('TP',num2str(d));
            VNe = strcat(eGrp,'.',eDiv,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];
            if isempty(PlotDat)
                continue
            else
                eval(['notBoxPlotRF(PlotDat,xt(d),cDiv' num2str(d) ',7)']);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{d} = num2str(AgeDiv(d));
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Age')
        ylabel(eMetl(n))
        title(eGrp)
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];
    set(findall(gcf,'-property','FontSize'),'FontSize',9)
    
    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);

    close(F1)
end

%% halfViolinPlots - plots by group

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('3_RecordingsByGroup'); cd('HalfViolinPlots');

eMet = NetMetricsE; 
eMetl = {'number of active electrodes','mean firing rate (Hz)','median firing rate (Hz)', ...
    'network burst rate (per minute)','mean number of channels involved in network bursts', ...
    'mean network burst length (s)','mean ISI within network burst (ms)', ... 
    'mean ISI outside network bursts (ms)','coefficient of variation of inter network burst intervals', ...
    'fraction of in network bursts'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

for n = 1:length(eMet)
    all_group_eMet_vals = [];
    F1 = figure;
    eMeti = char(eMet(n));
    xt = 1:length(AgeDiv);
    for g = 1:length(Grps)
        h(g) = subplot(1,length(Grps),g);
        eGrp = cell2mat(Grps(g));
        for d = 1:length(AgeDiv)
            eDiv = strcat('TP',num2str(d));
            VNe = strcat(eGrp,'.',eDiv,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];
            all_group_eMet_vals = [all_group_eMet_vals; PlotDat];
            if isempty(PlotDat)
                continue
            else
                eval(['HalfViolinPlot(PlotDat,xt(d),cDiv' num2str(d) ',0.3)']);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{d} = num2str(AgeDiv(d));
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Age')
        ylabel(eMetl(n))
        title(eGrp)
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];

    customBoundMatchVec = strcmp(eMetl(n), metricsWCustomBounds);
    if sum(customBoundMatchVec) == 1
        bound_idx = find(customBoundMatchVec);
        custom_bound_vec = eMetCustomBounds{bound_idx, 2};

        if isnan(custom_bound_vec(1))
            custom_bound_vec(1) = min(all_group_eMet_vals);
        end 
   
        if isnan(custom_bound_vec(2))
            custom_bound_vec(2) = max(all_group_eMet_vals);
        end 
        h(1).YLim = custom_bound_vec;
    end 

    set(findall(gcf,'-property','FontSize'),'FontSize',9)
    
    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);

    close(F1)
end

%% notBoxPlots - plots by DIV

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('4_RecordingsByAge'); cd('NotBoxPlots')

eMet = NetMetricsE; 
eMetl = {'number of active electrodes','mean firing rate (Hz)','median firing rate (Hz)', ... 
    'network burst rate (per minute)','mean number of channels involved in network bursts', ... 
    'mean network burst length (s)','mean ISI within network burst (ms)', ... 
    'mean ISI outside network bursts (ms)','coefficient of variation of inter network burst intervals', ... 
    'fraction of in network bursts'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

for n = 1:length(eMet)

    all_group_eMet_vals = [];

    F1 = figure;
    eMeti = char(eMet(n));
    xt = 1:0.5:1+(length(Grps)-1)*0.5;
    for d = 1:length(AgeDiv)
        h(d) = subplot(1,length(AgeDiv),d);
        eDiv = num2str(AgeDiv(d));
        for g = 1:length(Grps)
            eGrp = cell2mat(Grps(g));
            eDivTP = strcat('TP',num2str(d));
            VNe = strcat(eGrp,'.',eDivTP,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];

            all_group_eMet_vals = [all_group_eMet_vals; PlotDat];

            if isempty(PlotDat)
                continue
            else
                notBoxPlotRF(PlotDat,xt(g), Params.groupColors(g, :) , 7);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{g} = eGrp;
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Group')
        ylabel(eMetl(n))
        title(strcat('Age',eDiv))
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];
    
    customBoundMatchVec = strcmp(eMetl(n), metricsWCustomBounds);
    if sum(customBoundMatchVec) == 1
        bound_idx = find(customBoundMatchVec);
        custom_bound_vec = eMetCustomBounds{bound_idx, 2};

        if isnan(custom_bound_vec(1))
            custom_bound_vec(1) = min(all_group_eMet_vals);
        end 
   
        if isnan(custom_bound_vec(2))
            custom_bound_vec(2) = max(all_group_eMet_vals);
        end 
        h(1).YLim = custom_bound_vec;
    end 

    aesthetics
    set(gca,'TickDir','out');
    set(findall(gcf,'-property','FontSize'),'FontSize',9)

    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);

    close(F1)
end

%% halfViolinPlots - plots by DIV

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('4_RecordingsByAge'); cd('HalfViolinPlots')

eMet = NetMetricsE; 
eMetl = {'number of active electrodes','mean firing rate (Hz)','median firing rate (Hz)','network burst rate (per minute)','mean number of channels involved in network bursts','mean network burst length (s)','mean ISI within network burst (ms)','mean ISI outside network bursts (ms)','coefficient of variation of inter network burst intervals','fraction of in network bursts'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

for n = 1:length(eMet)
    F1 = figure;
    eMeti = char(eMet(n));
    all_group_eMet_vals = [];
    xt = 1:length(Grps);
    for d = 1:length(AgeDiv)
        h(d) = subplot(1,length(AgeDiv),d);
        eDiv = num2str(AgeDiv(d));
        for g = 1:length(Grps)
            eGrp = cell2mat(Grps(g));
            eDivTP = strcat('TP',num2str(d));
            VNe = strcat(eGrp,'.',eDivTP,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];
            all_group_eMet_vals = [all_group_eMet_vals; PlotDat];
            if isempty(PlotDat)
                continue
            else
                HalfViolinPlot(PlotDat,xt(g), Params.groupColors(g, :), 0.3);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{g} = eGrp;
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Group')
        ylabel(eMetl(n))
        title(strcat('Age',eDiv))
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];

    customBoundMatchVec = strcmp(eMetl(n), metricsWCustomBounds);
    if sum(customBoundMatchVec) == 1
        bound_idx = find(customBoundMatchVec);
        custom_bound_vec = eMetCustomBounds{bound_idx, 2};

        if isnan(custom_bound_vec(1))
            custom_bound_vec(1) = min(all_group_eMet_vals);
        end 
   
        if isnan(custom_bound_vec(2))
            custom_bound_vec(2) = max(all_group_eMet_vals);
        end 
        h(1).YLim = custom_bound_vec;
    end 

    aesthetics
    set(gca,'TickDir','out');
    set(findall(gcf,'-property','FontSize'),'FontSize',9)

    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);
    close(F1)
end

%% halfViolinPlots - plots by group

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('1_NodeByGroup'); 

eMet = NetMetricsC; 
eMetl = {'mean firing rate per electrode (Hz)'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

for n = 1:length(eMet)
    F1 = figure;
    eMeti = char(eMet(n));
    xt = 1:length(AgeDiv);
    for g = 1:length(Grps)
        h(g) = subplot(1,length(Grps),g);
        eGrp = cell2mat(Grps(g));
        for d = 1:length(AgeDiv)
            eDiv = strcat('TP',num2str(d));
            VNe = strcat(eGrp,'.',eDiv,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];
            if isempty(PlotDat)
                continue
            else
                eval(['HalfViolinPlot(PlotDat,xt(d),cDiv' num2str(d) ',0.3)']);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{d} = num2str(AgeDiv(d));
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Age')
        ylabel(eMetl(n))
        title(eGrp)
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];
    aesthetics
    set(gca,'TickDir','out');
    set(findall(gcf,'-property','FontSize'),'FontSize',9)

    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);
    close(F1)
end

%% halfViolinPlots - plots by DIV : mean firing rate per electrode 

cd(HomeDir); cd(strcat('OutputData',Params.Date));
cd('2_NeuronalActivity'); cd('2B_GroupComparisons'); 
cd('2_NodeByAge')

eMet = NetMetricsC; 
eMetl = {'mean firing rate per electrode (Hz)'}; 

p = [100 100 1300 600]; 
set(0, 'DefaultFigurePosition', p)

all_eMet_vals = [];

for n = 1:length(eMet)
    F1 = figure;
    eMeti = char(eMet(n));
    xt = 1:length(Grps);
    for d = 1:length(AgeDiv)
        h(d) = subplot(1,length(AgeDiv),d);
        eDiv = num2str(AgeDiv(d));
        for g = 1:length(Grps)
            eGrp = cell2mat(Grps(g));
            eDivTP = strcat('TP',num2str(d));
            % TODO: fix this
            VNe = strcat(eGrp,'.',eDivTP,'.',eMeti);
            eval(['DatTemp = ' VNe ';']);
            PlotDat = DatTemp;
            PlotDat(isnan(PlotDat)) = [];
            
            % concateenate to a store to get ylim 
            all_eMet_vals = [all_eMet_vals; PlotDat];

            if isempty(PlotDat)
                continue
            else
                HalfViolinPlot(PlotDat, xt(g), Params.groupColors(g, :), 0.3);
            end
            clear DatTemp ValMean ValStd UpperStd LowerStd
            xtlabtext{g} = eGrp;
        end
        xticks(xt)
        xticklabels(xtlabtext)
        xlabel('Group')
        ylabel(eMetl(n))
        title(strcat('Age',eDiv))
        aesthetics
        set(gca,'TickDir','out');
    end
    linkaxes(h,'xy')
    h(1).XLim = [min(xt)-0.5 max(xt)+0.5];
    h(1).YLim = [0, max(all_eMet_vals)];
    aesthetics
    set(gca,'TickDir','out');
    set(findall(gcf,'-property','FontSize'),'FontSize',9)

    % Export figure
    figName = strcat(num2str(n),'_',char(eMetl(n)));
    pipelineSaveFig(figName, Params.figExt, Params.fullSVG, F1);

    close(F1)
end

end