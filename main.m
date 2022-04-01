% topic:    Optimization Methods Project
% TITLE:    Portfolio Genetic Optimization Algorithm
% author:   Luca Sanfilippo
% date:     29.05.2022
% notes: 


%% --- INITIALIZE ---
clear variables
close all
clc

% NOTICE: make sure all functions have been loaded;

%% --- 1) download market data and store it ---
startDate = datetime(addtodate(datenum(today),-3,'year'),'ConvertFrom','datenum');
%startDate =datetime(addtodate(datenum(today),-2,'day'),'ConvertFrom','datenum'); %JUST for test
%symbols = {'AAPL','CYDY','SPR', 'PLUG', 'FB','RACE', 'GE', 'RHHVF', 'AMT', 'AMZN','TM','TSLA' }; %JUST for test
NASDAQ100Tickers = {'AAPL','MSFT','AMZN','FB','GOOG','GOOGL','INTC','CMCSA','CSCO','PEP','COST','ADBE','AMGN','TXN','NFLX','PYPL','NVDA','AVGO','SBUX','CHTR','QCOM','BKNG','GILD','MDLZ','FISV','ADP','TMUS','INTU','CSX','WBA','MU','AMAT','TSLA','ILMN','VRTX','ATVI','ROST','BIIB','ADI','MAR','NXPI','LRCX','KHC','AMD','CTSH','XEL','REGN','ORLY','ADSK','MNST', 'PAYX','BIDU','SIRI','JD','DLTR','CTAS','MELI','KLAC','LULU','WDAY','VRSK','PCAR','IDXX','UAL','MCHP','VRSN','CERN','NTES','FAST','SNPS','EXPE','ASML','CDNS','WDC','ALGN','INCY','CHKP','HAS','SWKS','ULTA','TTWO','CTXS','NTAP','AAL','LBTYK','JBHT','WYNN','FOXA','HSIC','FOX','LBTYA'};
%###############################################################################
% define the benchmark as Nasdaq 100 index
Benchmark = getMarketDataViaYahoo('NQ=F', startDate, datetime('today'), '1d');
Benchmark = Benchmark(:,[1,end-1]);
BenchRet = table2array(Benchmark(:,2));
BenchRet = 100*diff(BenchRet)./BenchRet(1:end-1,:); % (P_t-P_t-1)/(P_t-1) *100
%###############################################################################

measureRows = getMarketDataViaYahoo(NASDAQ100Tickers{1}, startDate, datetime('today'), '1d');
ArrAdjPrices = ones(size(measureRows,1), length(NASDAQ100Tickers));
for t = 1: length(NASDAQ100Tickers)
    ticker = NASDAQ100Tickers{t};
    %disp(ticker)
    data = getMarketDataViaYahoo(ticker, startDate, datetime('today'), '1d');
    AdjClose = table2array(data(:,end-1)); %extract the column AdjClose

    %Delete first column
    ArrAdjPrices(:,t) = [AdjClose];
end

% CREATE A TABLE FOR A BETTER VIEW
TableAdjPrices = array2table(ArrAdjPrices);
TableAdjPrices.Properties.VariableNames(1:size(TableAdjPrices,2)) = NASDAQ100Tickers;
save tableAdjPrices.mat TableAdjPrices %uncomment to update the file
load('tableAdjPrices.mat')

%% --- 2) compute returns ---
ArrReturns = 100*diff(ArrAdjPrices)./ArrAdjPrices(1:end-1,:); % (P_t-P_t-1)/(P_t-1) *100
TableReturns = array2table(ArrReturns);
TableReturns.Properties.VariableNames(1:size(TableReturns,2)) = NASDAQ100Tickers;

%% --- 3) select randomly some stocks and create the portfolios ---
numberStocksPortfolio = 12;
numberPortfolios = 5;

PortfoliosComponents = table;
PortfoliosReturns = [];
namePortfolioList = [];
for i = 1:numberPortfolios
    %disp(i)
    %r = randi([1 length(NASDAQ100Tickers)],1,numberStocksPortfolio);
    r = randperm(length(NASDAQ100Tickers),numberStocksPortfolio); %without repetitions
    %disp(r)
    portfolio = [];
    stockNum = [];
    for v = 1:length(r)
        %disp(v)
        %disp(r(v));
        namePortfolio = 'Portfolio'+string(i);
        numStocks = 'Stock'+string(v);
        stockNum =[stockNum numStocks];
        List_tickers_portfolio= NASDAQ100Tickers(r(v));
        portfolio = [portfolio, List_tickers_portfolio];
    end
    disp(namePortfolio)
    disp(portfolio)
    portfolios = cell2table(portfolio(1:end),'VariableNames',stockNum);
    PortfoliosComponents = [PortfoliosComponents; portfolios];
    namePortfolioList = [namePortfolioList, namePortfolio];

    % compute the returns for the portfolio i    
    portRet = TableReturns(:,string(portfolio)); % extract the returns for the tickers selected
    portRet = table2array(portRet);
    portRet = portRet(:,:)*(1/numberStocksPortfolio);
    portRet = sum(portRet,2); %weighted portfolio returns
    
    % merge all the portfolios returns in a matrix
    PortfoliosReturns = [PortfoliosReturns portRet];

end

PortfoliosComponents = [array2table(namePortfolioList(:),'VariableNames',{'Portfolio'}), PortfoliosComponents]; % Table with portfolios and stocks' components
%PortfoliosReturns = mat2dataset(PortfoliosReturns,"VarNames",namePortfolioList) % dataset with returns for each portfolio
PortfoliosReturnsTable = array2table(PortfoliosReturns,"VariableNames",namePortfolioList);

%% --- ITERATION ----
Nsim = 1000;
finalResultsSRTable = [];
finalResultsComponentsTable=[];

for k=1:Nsim
    disp('NumberSimulation: '+string(k))

    % --- 4) compute the statistics of the portfolio ---
    
    riskfree = 0; %assumption
    
    % For the portfolios:
    portfoliosStats = [];
    for c = 1:size(PortfoliosReturnsTable,2)
        disp('Portfolio: '+string(c));
        meanPort = mean(PortfoliosReturnsTable{:,c});
        stdPort = std(PortfoliosReturnsTable{:,c});
        sharpeRatioPort = (meanPort-riskfree)/stdPort %understand the return of an investment compared to its risk.
        %uses the standard deviation of returns in the denominator as its proxy of total portfolio risk, which assumes that returns are normally distributed. 
        %TreynorRatio 
        portfoliosStat = {string(PortfoliosReturnsTable.Properties.VariableNames(c)), 'SharpeRatio', sharpeRatioPort};
        %portfoliosStat = {namePortfolioList(c), 'SharpeRatio', sharpeRatioPort};
        portfoliosStats = [portfoliosStats; portfoliosStat]; %cell2mat(portfoliosStats(1,3)) 
    end
    
    %for the benchmark:
    disp('Benchmark: NASDAQ100');
    meanBench = mean(BenchRet);
    stdBench = std(BenchRet);
    sharpeRatioBench = (meanBench-riskfree)/stdBench
    
    % SAVE RESULTS
    finalResultsSRTable = [finalResultsSRTable; {'Number_Of_Simulation','---------->',k};portfoliosStats;{string('Benchmark_Nasdaq100'), 'SharpeRatio', sharpeRatioBench}];
    finalResultsComponentsTable = [finalResultsComponentsTable; array2table(string(PortfoliosComponents.Portfolio)+'_NSim_'+string(k),'VariableNames',{'Portfolio_#Sim'}), PortfoliosComponents];

    % --- 5) Selection of the best portfolios basing on the SR ---
    SortedPortfolios = sortrows(portfoliosStats,3); % sorting based on the sharpe ratio
    % we select only the best two portfolios
    % only the best portfolio will be duplicated
    
    SelectedPortfolios = [SortedPortfolios(end-1,:); SortedPortfolios(end,:); SortedPortfolios(end,:)];
    
    % --- 6) Recombination of the best portfolios ---
    
    % find the elements of the portfolios
    penultimateBestPort = string(SelectedPortfolios(1,1));
    bestPort = string(SelectedPortfolios(2,1));
    bestPortDuplicate = string(SelectedPortfolios(3,1));
    
    penultimateBestPortComp = PortfoliosComponents(PortfoliosComponents.Portfolio==penultimateBestPort,:); %table2array()
    penultimateBestPortComp = penultimateBestPortComp(:,2:end);
    bestPortComp = PortfoliosComponents(PortfoliosComponents.Portfolio==bestPort,:);
    bestPortComp = bestPortComp(:,2:end);
    bestPortDuplicateComp = PortfoliosComponents(PortfoliosComponents.Portfolio==bestPortDuplicate,:);
    bestPortDuplicateComp = bestPortDuplicateComp(:,2:end);
    
    % invert the last two stocks between the two portfolios
    lst_tick_PenBestPort = penultimateBestPortComp{1,end-1:end};
    lst_tick_BestPort =bestPortComp{1,end-1:end};
    penultimateBestPortComp{1,end-1:end}=lst_tick_BestPort
    bestPortComp{1,end-1:end}=lst_tick_PenBestPort
    
    % --- 7) Mutation ---
    % random draws from ticker list and replace an asset in one of the
    % portfolios in a random position
    draw = randperm(3,1)
    posDraw = randperm(numberStocksPortfolio,1)

    if draw ==1
        bestPortDuplicateComp{1,posDraw}= NASDAQ100Tickers(randperm(length(NASDAQ100Tickers),1));
    elseif draw == 2
        bestPortComp{1,posDraw}= NASDAQ100Tickers(randperm(length(NASDAQ100Tickers),1));
    else
        penultimateBestPortComp{1,posDraw}= NASDAQ100Tickers(randperm(length(NASDAQ100Tickers),1));
    end
    
    % --- 8) Save in the PortfolioReturnTable ---
    % compute the portfolio returns and update
    %PortfoliosComponents
    PortfoliosComponents = [penultimateBestPortComp; bestPortComp; bestPortDuplicateComp];
    PortfoliosComponents = [array2table({'Portfolio1';'Portfolio2';'Portfolio3'}, "VariableNames", {'Portfolio'}), PortfoliosComponents];
    
    %PortfoliosReturnsTable (example: TableReturns.AAPL)
    PortfoliosReturns = [];
    for i = 1:size(PortfoliosComponents,1)
        namePortfolio = 'Portfolio'+string(i)
        compPort = PortfoliosComponents{i,:}
        ret_single_stocks = TableReturns(:,string(PortfoliosComponents{i,2:end})); % extract the returns for the tickers selected
        % compute the returns for the portfolio i
        portRet = table2array(ret_single_stocks);
        portRet = portRet(:,:)*(1/numberStocksPortfolio);
        portRet = sum(portRet,2); %weighted portfolio returns
        % merge all the portfolios returns in a matrix
        PortfoliosReturns = [PortfoliosReturns portRet];
    end
    
    PortfoliosReturnsTable = array2table(PortfoliosReturns,"VariableNames",PortfoliosComponents.Portfolio);


    % --- PLOT 0 ----
   
    plot(datetime(data.Date(2:end)), cumsum(PortfoliosReturns/100)) 
    %Cumulative returns to get an idea of the relative performance of all the stocks
    title('Cumulative Returns Portfolios')
    legend(namePortfolioList,'Orientation','horizontal','location','southoutside')
    xlabel('Date') 
    ylabel('Cumulative Returns') 
    grid on
    
    
    
    % --- PLOT 1 ----
    initialAmount = 100;
    %divisionElement = 1+PortfoliosReturns(1, :)
    firstrow = initialAmount*(1+PortfoliosReturns(1, :)/100);
    prt = [firstrow ;(1+PortfoliosReturns(2:end, :)/100)]; 
    for j = 2:size(prt,1)
        %disp(j);
        prt(j,:) = prt(j,:).*prt(j-1,:);
    end
    
    plot(datetime(data.Date(2:end)), prt) 
    %Cumulative returns to get an idea of the relative performance of all the stocks
    title('Portfolios Values in $, NumSim:'+string(k))
    legend(namePortfolioList,'Orientation','horizontal','location','southoutside')
    xlabel('Date') 
    ylabel('Amount in $') 
    grid on
    saveas(gcf,string(k)+'_PortfolioValuesInDollars.png')
    
    % --- TESTING ---
%     warning('off','MATLAB:xlswrite:AddSheet'); %optional
%     writetable(TableAdjPrices,'PortfoliosValues.xlsx','Sheet',1);
%     writetable(table(PortfoliosReturns),'PortfoliosValues.xlsx','Sheet',2);
%     writetable(PortfoliosComponents,'PortfoliosValues.xlsx','Sheet',2, 'Range','L1'); %NOTE: change L if we add more that 10 Portfolios
%     
end


warning('off','MATLAB:xlswrite:AddSheet'); %optional
writetable(TableAdjPrices,'PortfoliosValues.xlsx','Sheet',1);
writetable(table(finalResultsSRTable),'PortfoliosValues.xlsx','Sheet',2);
writetable(finalResultsComponentsTable,'PortfoliosValues.xlsx','Sheet',2, 'Range','R1'); %NOTE: change L if we add more that 10 Portfolios


%% --- Useful links ---
%https://ch.mathworks.com/help/matlab/data-type-conversion.html

