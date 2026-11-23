



        %%% Edgeworth Box %%%

        % runs through

        clear eps;
        clear;
        close all;
        clc;

        EconomyType = 'Exchange'; % Total fixed ressources
        % EconomyType = 'Production'; % Ressources can grow
        % to do: Pareto, Efficient Frontier, Skalenerträge

        % Code via Google request, simplified
        ModelName = 'Dynamic Stochastic Edgeworth Economy'
        fprintf('\n')
        fprintf('%\n',ModelName)
        fprintf('==================================')

        T = 4;
        NAgents = 2;
        NGoods = 2;
        NStates = 3;
        Periods = 1:T;
        
        StateNames = {'Bull','Neutral','Bear'};

        % Cobb Douglas Function
        InitialX = zeros(T,1);
        InitialY = zeros(T,1);
        Total_X = 10;
        Total_Y = 10;

        Endowment = zeros(T,NGoods,NAgents);

        Endowment(1,:,1) = [5 8];
        Endowment(1,:,2) = [Total_X-Endowment(1,1,1),
            Total_Y-Endowment(1,2,1)];

        %% Cobb Douglas Preferences

        Preference = zeros(NStates,NAgents,2);

        % Bull Market
        Preference(1,1,:) = [0.60 0.40];
        Preference(1,2,:) = [0.30 0.70];

        % Neutral Market
        Preference(2,1,:) = [0.50 0.50];
        Preference(2,2,:) = [0.35 0.65];

        % Bear Market
        Preference(3,1,:) = [0.40 0.60];
        Preference(3,2,:) = [0.45 0.55];


        %% Markov Transition Matrix

        Transition = [0.80 0.15 0.05
            0.20 0.60 0.20
            0.10 0.20 0.70];

        % Initial Market State
        CurrentState = 2;

            % State Dependent Interest Rates
            InterestRate = zeros(NStates,1);
            InterestRate(1) = 0.05;
            InterestRate(2) = 0.03;
            InterestRate(3) = 0.01;

            % Storage Matrices
            CurrentStateHistory = zeros(T,1);
            InterestHistory = zeros(T,1);
            CurrentStateHistory(1) = CurrentState;
            InterestHistory(1) = InterestRate(CurrentState);

        % Utility
        UtilityAgent1 = zeros(T,1);
        UtilityAgent2 = zeros(T,1);
        UtilityAgent3 = zeros(T,1);

        % Contract Curves
        ContractCurve = cell(T,1);

        % Efficient Allocations
        EfficientAllocations = cell(T,1);

        % Marginal Utilities
        MUX1 = cell(T,1);
        MUY1 = cell(T,1);
        MUX1 = cell(T,1);
        MUY2 = cell(T,1);

        % Marginal Rate of Substitution
        MRSXY1 = cell(T,1);
        MRSXY2 = cell(T,1);

        % Marginal Rate of Technical Substitution
        MRTS1 = cell(T,1);
        MRTS2 = cell(T,1);
        
        % Edgeworth Box Figures
        EdgewortFigure = gobjects(T,1);

        % Welfare
        ParetoEfficient = false(T,1);

        % Time Series Storage
        EndowmentHistoryAgent1 = zeros(T,2);
        EndowmentHistoryAgent2 = zeros(T,2);
        EndowmentHistoryAgent1(1,:) = Endowment(1,:,1);
        EndowmentHistoryAgent1(1,:) = Endowment(1,:,2);

        % Grid for Utility Calculations
        GridPoints = 100;
        xGrid = linspace(0.1,Total_X,GridPoints);
        yGrid = linspace(0.1,Total_Y,GridPoints);
        [X,Y] = meshgrid(xGrid,yGrid);

        % Randon number generator
        rng(1);

        % Model Summary
        fprintf('Number of periods      :   %d\n',T);
        fprintf('Number of Agents       :   %d\n',NAgents);
        fprintf('Number of Goods        :   %d\n',NGoods);
        fprintf('Number of Markov States:   %d\n',NStates);
        fprintf('Grid Size              :   %d x %d\n',GridPoints,GridPoints);
        fprintf('Initial States         :   %s\n',StateNames{CurrentState});
        fprintf('Initial Interest Rate  :   %2.f %%\n',100*InterestRate(CurrentState));
        fprintf('\n');
        disp('Transition Matrix')
        disp(Transition)
        fprintf('\n');
        disp('Initial Endowment Agent 1')
        disp(Endowment(1,:,1))
        disp('Initial Endowment Agent 2')
        disp(Endowment(1,:,2))
        fprintf('\n');
        disp('Initialization completed successfully.')
        fprintf('=====================================\n');


      
%% ================================================================
% CHAPTER 2: DYNAMIC ECONOMIC EVOLUTION
% ================================================================

fprintf('\n');
fprintf('CHAPTER 2: DYNAMIC ECONOMIC EVOLUTION\n');
fprintf('=====================================\n');

%% 2.1 Economic parameters

ConsumptionRate = 0.05;
SavingsRate     = 0.10;
TradeShock      = 0.00;

% Additional productivity growth
GrowthRate = 0.02;

% Investment return premium
% This can later be replaced by asset-specific expected returns.
InvestmentPremium = 0.02;

% Cash/reserve return
CashReturn = 0.00;

% Capital depreciation (for future capital accumulation extension)
DepreciationRate = 0.03;

%% 2.2 Preallocation

Consumption       = zeros(T,NGoods,NAgents);
Savings           = zeros(T,NGoods,NAgents);
Investment        = zeros(T,NGoods,NAgents);
UninvestedReserve = zeros(T,NGoods,NAgents);

InvestmentReturn  = zeros(T,NGoods,NAgents);
ReserveReturn     = zeros(T,NGoods,NAgents);

Growth            = zeros(T,NGoods,NAgents);
Trade             = zeros(T,NGoods,NAgents);

AggregateResources = zeros(T,NGoods);

EndowmentHistoryAgent1 = zeros(T,NGoods);
EndowmentHistoryAgent2 = zeros(T,NGoods);

EndowmentHistoryAgent1(1,:) = Endowment(1,:,1);
EndowmentHistoryAgent2(1,:) = Endowment(1,:,2);

%% 2.3 Dynamic evolution

for t = 1:T

    fprintf('\nPeriod %d\n',t);
    fprintf('--------------------------\n');

    % Current Markov state
    CurrentState = CurrentStateHistory(t);

    % Current interest rate
    CurrentInterestRate = InterestRate(CurrentState);

    % Current investment return
    CurrentInvestmentRate = ...
        CurrentInterestRate + InvestmentPremium;

    %% Current endowments

    for i = 1:NAgents

        CurrentEndowment = squeeze(Endowment(t,:,i));

        %% Consumption

        Consumption(t,:,i) = ...
            ConsumptionRate .* CurrentEndowment;

        AvailableResources = ...
            CurrentEndowment - Consumption(t,:,i);

        %% Savings and investment

        Savings(t,:,i) = ...
            SavingsRate .* AvailableResources;

        Investment(t,:,i) = Savings(t,:,i);

        UninvestedReserve(t,:,i) = ...
            AvailableResources - Investment(t,:,i);

        %% Investment returns

        InvestmentReturn(t,:,i) = ...
            Investment(t,:,i) .* CurrentInvestmentRate;

        ReserveReturn(t,:,i) = ...
            UninvestedReserve(t,:,i) .* CashReturn;

        %% Productivity growth

        if strcmpi(EconomyType,'Production')

            Growth(t,:,i) = ...
                GrowthRate .* CurrentEndowment;

        elseif strcmpi(EconomyType,'Exchange')

            Growth(t,:,i) = 0;

        else

            error('Unknown EconomyType.');

        end

    end

    %% Trade

    Trade(t,:,1) = [TradeShock,-TradeShock];
    Trade(t,:,2) = [-TradeShock,TradeShock];

    %% Aggregate resources before next period

    AggregateResources(t,:) = ...
        squeeze(Endowment(t,:,1)) + ...
        squeeze(Endowment(t,:,2));

    %% Update next period

    if t < T

        for i = 1:NAgents

            CurrentEndowment = squeeze(Endowment(t,:,i));

            % Unconsumed resources retain their principal.
            % Investment and reserve generate returns.
            NextEndowment = ...
                CurrentEndowment ...
                - Consumption(t,:,i) ...
                + InvestmentReturn(t,:,i) ...
                + ReserveReturn(t,:,i) ...
                + Growth(t,:,i) ...
                + Trade(t,:,i);

            Endowment(t+1,:,i) = NextEndowment;

        end

        %% Resource validation

        if any(Endowment(t+1,:,:) < 0,'all')

            error('Negative endowment detected in period %d.',t+1);

        end

        %% Record next-period endowments

        EndowmentHistoryAgent1(t+1,:) = Endowment(t+1,:,1);
        EndowmentHistoryAgent2(t+1,:) = Endowment(t+1,:,2);

        %% Markov transition

        CurrentState = find( ...
            rand <= cumsum(Transition(CurrentState,:)), ...
            1,'first');

        CurrentStateHistory(t+1) = CurrentState;

        InterestHistory(t+1) = InterestRate(CurrentState);

    end

    %% Reporting

    fprintf('State: %s\n',StateNames{CurrentStateHistory(t)});

    fprintf('Interest rate: %.2f%%\n', ...
        CurrentInterestRate*100);

    fprintf('Investment return: %.2f%%\n', ...
        CurrentInvestmentRate*100);

    fprintf('\nAgent 1:\n');
    fprintf('Consumption:\n');
    disp(Consumption(t,:,1));

    fprintf('Savings / Investment:\n');
    disp(Investment(t,:,1));

    fprintf('Investment return:\n');
    disp(InvestmentReturn(t,:,1));

    fprintf('\nAgent 2:\n');
    fprintf('Consumption:\n');
    disp(Consumption(t,:,2));

    fprintf('Savings / Investment:\n');
    disp(Investment(t,:,2));

    fprintf('Investment return:\n');
    disp(InvestmentReturn(t,:,2));

    fprintf('\nAggregate resources:\n');
    disp(AggregateResources(t,:));

end

fprintf('\nDynamic economic evolution completed.\n');


        %% Chapter 3
        % Dynamic Edgeworth Box Equilibrium

        fprintf('\n');
        fprintf('Edgeworth Equilibrium (Dynamic)');
        fprintf('=======================\n');
        
        % Numerical Parameters
        GridPoints = 100;
        BoundaryMargin = 1e-5;
        % Storage
        UtilityAgent1 = zeros(T,1);
        UtilityAgent2 = zeros(T,1);

        ContractCurve = cell(T,1);
        EfficientAllocation = cell(T,1);

        MUX1_All = cell(T,1);
        MUY1_All = cell(T,1);
        MUX2_All = cell(T,1);
        MUY2_All = cell(T,1);

        MRSXY1_Grid_All = cell(T,1);
MRSXY2_Grid_All = cell(T,1);

MRSXY1_Curve_All = cell(T,1);
MRSXY2_Curve_All = cell(T,1);

EdgeworthFigure = gobjects(T,1);
MRSFigure = gobjects(T,1);

% Period-by-period calculations
for t = 1:T

    fprintf('\nSolving Period %d\n',t);
    fprintf('--------------------------\n');

    %% 3.1 Current endowments

    Agent1 = squeeze(Endowment(t,:,1));
    Agent2 = squeeze(Endowment(t,:,2));

    CurrentX = Agent1(1);
    CurrentY = Agent1(2);

    Agent2X = Agent2(1);
    Agent2Y = Agent2(2);

    CurrentTotalX = CurrentX + Agent2X;
    CurrentTotalY = CurrentY + Agent2Y;

    if any([CurrentX,CurrentY,Agent2X,Agent2Y] < 0)

        error('Negative endowment in period %d.',t);

    end

    if CurrentTotalX <= 0 || CurrentTotalY <= 0

        error('Aggregate resources must be positive in period %d.',t);

    end

    %% 3.2 State-dependent preferences

    CurrentState = CurrentStateHistory(t);

    a1 = Preference(CurrentState,1,1);
    b1 = Preference(CurrentState,1,2);

    a2 = Preference(CurrentState,2,1);
    b2 = Preference(CurrentState,2,2);

    % Cobb-Douglas preference validation
    if any([a1,b1,a2,b2] <= 0)

        error('Preference coefficients must be positive.');

    end

    %% 3.3 Construct allocation grid

    x_1 = linspace(BoundaryMargin, ...
        CurrentTotalX-BoundaryMargin,GridPoints);

    y_1 = linspace(BoundaryMargin, ...
        CurrentTotalY-BoundaryMargin,GridPoints);

    [X_1,Y_1] = meshgrid(x_1,y_1);

    % Agent 2 receives the residual resources
    U2_ConsX = CurrentTotalX-X_1;
    U2_ConsY = CurrentTotalY-Y_1;

    %% 3.4 Utility functions

    IDC = X_1.^a1 .* Y_1.^b1;

    IDC2 = U2_ConsX.^a2 .* U2_ConsY.^b2;

    % Utility at current endowment
    U1_endowment = CurrentX^a1 * CurrentY^b1;

    U2_endowment = Agent2X^a2 * Agent2Y^b2;

    UtilityAgent1(t) = U1_endowment;
    UtilityAgent2(t) = U2_endowment;

    %% 3.5 Marginal utilities

    MUX1 = a1 .* X_1.^(a1-1) .* Y_1.^b1;
    MUY1 = b1 .* X_1.^a1 .* Y_1.^(b1-1);

    MUX2 = a2 .* U2_ConsX.^(a2-1) .* U2_ConsY.^b2;
    MUY2 = b2 .* U2_ConsX.^a2 .* U2_ConsY.^(b2-1);

    % Store marginal utilities
    MUX1_All{t} = MUX1;
    MUY1_All{t} = MUY1;

    MUX2_All{t} = MUX2;
    MUY2_All{t} = MUY2;

    %% 3.6 Marginal rate of substitution

    MRSXY1 = MUX1 ./ MUY1;
    MRSXY2 = MUX2 ./ MUY2;

    MRSXY1_Grid_All{t} = MRSXY1;
    MRSXY2_Grid_All{t} = MRSXY2;

    %% 3.7 Analytical contract curve

    % Pareto efficiency condition:
    % MRS Agent 1 = MRS Agent 2

    param_num = a1*b2*CurrentTotalY;

    param_den_const = b1*a2*CurrentTotalX;

    param_den_mult = (a1*b2)-(b1*a2);

    X_contract = linspace( ...
        BoundaryMargin, ...
        CurrentTotalX-BoundaryMargin, ...
        GridPoints);

    Denominator = param_den_const ...
        + param_den_mult.*X_contract;

    Y_contract = (param_num.*X_contract)./Denominator;

    % Keep only feasible allocations
    Feasible = isfinite(Y_contract) ...
        & Y_contract > BoundaryMargin ...
        & Y_contract < CurrentTotalY-BoundaryMargin;

    X_contract = X_contract(Feasible);
    Y_contract = Y_contract(Feasible);

    ContractCurve{t} = [X_contract(:),Y_contract(:)];

    %% 3.8 MRS along the contract curve

    MRSXY1_func = (a1/b1).*(Y_contract./X_contract);

    U2_X_contract = CurrentTotalX-X_contract;
    U2_Y_contract = CurrentTotalY-Y_contract;

    MRSXY2_func = (a2/b2).*(U2_Y_contract./U2_X_contract);

    MRSXY1_Curve_All{t} = MRSXY1_func;
    MRSXY2_Curve_All{t} = MRSXY2_func;

    %% 3.9 Efficient allocation table

    EfficientAllocations{t} = table( ...
        X_contract(:), ...
        Y_contract(:), ...
        U2_X_contract(:), ...
        U2_Y_contract(:), ...
        'VariableNames', ...
        {'Agent1_X','Agent1_Y','Agent2_X','Agent2_Y'});

    %% 3.10 Edgeworth Box visualization

    EdgeworthFigure(t) = figure( ...
        'Name',sprintf('Edgeworth Box - Period %d',t));

    hold on;

    axis equal;
    axis([0 CurrentTotalX 0 CurrentTotalY]);

    rectangle('Position',[0,0,CurrentTotalX,CurrentTotalY], ...
        'EdgeColor','k','LineWidth',1.5);

    % Indifference curves at current endowment
    contour(X_1,Y_1,IDC, ...
        [U1_endowment U1_endowment], ...
        'LineColor','b','LineWidth',1.5);

    contour(X_1,Y_1,IDC2, ...
        [U2_endowment U2_endowment], ...
        'LineColor','r','LineWidth',1.5);

    % Contract curve
    plot(X_contract,Y_contract,'k-', ...
        'LineWidth',2);

    % Initial/current endowment
    plot(CurrentX,CurrentY,'ko', ...
        'MarkerSize',8,'MarkerFaceColor','k');

    % Agent 2 origin
    plot(CurrentTotalX,CurrentTotalY,'ks', ...
        'MarkerSize',6,'MarkerFaceColor','w');

    xlabel('Good X allocated to Agent 1');
    ylabel('Good Y allocated to Agent 1');

    title(sprintf( ...
        'Dynamic Edgeworth Box - Period %d | %s', ...
        t,StateNames{CurrentState}));

    legend( ...
        'Resource boundary', ...
        'Agent 1 indifference curve', ...
        'Agent 2 indifference curve', ...
        'Pareto contract curve', ...
        'Current endowment', ...
        'Agent 2 origin', ...
        'Location','best');

    grid on;
    hold off;

    %% 3.11 MRS visualization

    MRSFigure(t) = figure( ...
        'Name',sprintf('MRS - Period %d',t));

    hold on;

    plot(X_contract,MRSXY1_func,'b-', ...
        'LineWidth',2, ...
        'DisplayName','Agent 1 MRS');

    plot(X_contract,MRSXY2_func,'r--', ...
        'LineWidth',2, ...
        'DisplayName','Agent 2 MRS');

    xlabel('Good X allocated to Agent 1');
    ylabel('Marginal Rate of Substitution');

    title(sprintf('MRS Along Contract Curve - Period %d',t));

    legend('show');
    grid on;
    hold off;

    %% 3.12 Period summary

    fprintf('Economic state: %s\n',StateNames{CurrentState});

    fprintf('Interest rate: %.2f%%\n', ...
        InterestHistory(t)*100);

    fprintf('Aggregate X resources: %.4f\n',CurrentTotalX);
    fprintf('Aggregate Y resources: %.4f\n',CurrentTotalY);

    fprintf('Agent 1 utility at endowment: %.4f\n',U1_endowment);
    fprintf('Agent 2 utility at endowment: %.4f\n',U2_endowment);

    fprintf('Number of efficient allocations: %d\n', ...
        length(X_contract));

end

%% ================================================================
% CHAPTER 3 SUMMARY
% ================================================================

PeriodSummary = table( ...
    Periods(:), ...
    CurrentStateHistory(:), ...
    InterestHistory(:), ...
    UtilityAgent1, ...
    UtilityAgent2, ...
    AggregateResources(:,1), ...
    AggregateResources(:,2), ...
    'VariableNames', ...
    {'Period','State','InterestRate', ...
     'UtilityAgent1','UtilityAgent2', ...
     'TotalX','TotalY'});

fprintf('\nDynamic Edgeworth Economy Summary\n');
disp(PeriodSummary);

fprintf('\nChapter 3 completed.\n');
        
        %% Chapter 4

        



        % Parameter Cobb Douglas Function
        % IDC
        % IDC2
        % Output elasticity of capital and labor/Utility 
        
        a1 = 0.50;
        b1 = 0.50;           % sum a1+b1 < 1 decreasing returns to scale, = 1 constant returns to scale, > 1 increasing returns to scale
        a2 = 0.35;
        b2 = 0.65;

        % Shifted or "initial" endowment of 1
        InitialX = 5;       % can be changed 
        InitialY = 8;
        % unexplained residual for IDC1
        % A = 0.6;
        
        figure(1);
        hold on;
        axis equal;
        axis([0 Total_X 0 Total_Y]);

        rectangle('Position',[0,0,Total_X,Total_Y],'EdgeColor','k','LineWidth',1.5);
        % rectangle('Position',[Total_X,Total_Y,-Total_X,-Total_Y],'EdgeColor','k','LineWidth',1.5);
        
        xlabel('Good X for Agent 1 (and Agent 2 from right to left)');
        ylabel('Good Y for Agent 1 (and Agent 2 from top to bottom)');
        title('Edgeworth Box');
        grid on;
        
        % Utility 1
        x_1 = linspace(0.1,Total_X,100);
        y_1 = linspace(0.1,Total_Y,100);
        [X_1,Y_1] = meshgrid(x_1,y_1);
        IDC = ((X_1.^a1)).*((Y_1.^b1));

        % contour(X_1,Y_1,IDC,10,'DisplayName','Utility 1 IDC','LineColor','blue');

        % Utility 2 - inverse attributes of graph

        % x_2 = linspace(0.1,Total_X,100);
        % y_2 = linspace(0.1,Total_Y,100);
        U2_ConsX = Total_X - X_1;
        U2_ConsY = Total_Y - Y_1;
size(U2_ConsX)
size(U2_ConsY)
size(X_1)
size(Y_1)
which eps -all

%%

        U2_ConsX(U2_ConsX <= 0) = eps;
        U2_ConsY(U2_ConsY <= 0) = eps;
        % [X_2,Y_2] = meshgrid(x_2,y_2);
        IDC2 = (U2_ConsX.^a2).*(U2_ConsY.^b2);

        % plot(X_contract,Y_contract,'k-','LineWidth',2.5,'DisplayName','Contract Curve (Pareto Set)');

        % Endowment Point
        % plot(InitialX,InitialY,'ko','MarkerSize',8,'MarkerFaceColor','k','DisplayName','Initial Endowment');

        U1_endowment = (InitialX^a1)*(InitialY^b1);
        contour(X_1,Y_1,IDC,[U1_endowment U1_endowment],'LineColor','cyan','LineWidth',1.5,'DisplayName','U1 at Endowment');

        U2_endowment = ((Total_X-InitialX)^a2)*((Total_Y-InitialY)^b2);
        contour(X_1,Y_1,IDC2,[U2_endowment U2_endowment],'LineColor','cyan','LineWidth',1.5,'DisplayName','U2 at Endowment');
       
        % Contract curve
        param_num = a1*b2*Total_Y;
        param_den_const = b1*a2*Total_X;
        param_den_mult = (a1*b2)-(b1*a2);

        X_contract = linspace(0.1,Total_X-0.1,100);
        % Contract curve
        % Y = (a1*b2*Ty*Xcontract)/(b1*a2*Tx+(a1*b2-b1*a2)Xcontract)
        Y_contract = (param_num.*X_contract)./(param_den_const+param_den_mult.*X_contract);
        plot(X_contract,Y_contract,'k-','LineWidth',1.5,'DisplayName','Contract Curve (Pareto Set)');

        plot(InitialX,InitialY,'ko','MarkerSize',8,'MarkerFaceColor','k','DisplayName','Vector of Endowment');
        
        hold off;
        legend show;
        
        text(Total_X*0.55, Total_Y*0.5, ...
            '$\mathrm{MRS}_{XY1} = \frac{a1}{b1}\frac{Y}{X}$', ...
            'Interpreter','latex', ...
            'FontSize',12, ...
            'Color','blue');
        text(Total_X*0.05, Total_Y*0.1, ...
            '$\mathrm{MRS}_{XY2} = \frac{a2}{b2}\frac{Y_2}{X_2}$', ...
            'Interpreter','latex', ...
            'FontSize',12, ...
            'HorizontalAlignment','left', ...
            'Color','red');

        % Efficient
        efficient_sets_table = table(X_contract',Y_contract','VariableNames',{'X_Agent','Y_Agent'});
        disp('Table of Efficient Parameter Sets (Coordinates along the Contract Curve:');
        disp(efficient_sets_table);
        figure;
        plot(X_contract,Y_contract,'ko','MarkerSize',4,'MarkerFaceColor','k','DisplayName','Efficient Parameter Set (Points)');
        
        % Utility function 1:
        % Regressionsgerade: Aktien (n), Correlationskoeffizient als Potenz
        % Regressionsgerade: Wechselkurse, Correlationskoeffizienten und
        % Zinsen (Covered Interest rate partität)

        % MRS
        MUX1 = a1.*(X_1.^(a1-1)).*(Y_1.^b1);
        MUY1 = b1.*(X_1.^a1).*(Y_1.^(b1-1));

        MUX2 = a2.*(U2_ConsX.^(a2-1)).*(U2_ConsY.^b2);
        MUY2 = b2.*(U2_ConsX.^a2).*(U2_ConsY.^(b2-1));

        MRSXY1 = MUX1./MUY1
        MRSYX1 = MUY1./MUX1

        MRSXY2 = MUX2./MUY2
        MRSYX2 = MUY2./MUX2

        % Marginal rate of Substitution
        MRSXY1_func = (a1/b1).*(Y_contract./X_contract);
        U2_X_contract = Total_X - X_contract;
        U2_Y_contract = Total_Y - Y_contract;
        MRSXY2_func = (a2/b2).*(U2_Y_contract./U2_X_contract);


        figure(2);
        hold on;
        plot(X_contract,MRSXY1_func,'b-','LineWidth',2,'DisplayName','MRSXY Agent 1 Function (along CC)');
        plot(X_contract,MRSXY2_func,'r--','LineWidth',1.5,'DisplayName','MRSXY Agent 2 Function (along CC)');
        hold off;

        xlabel('Good X allocation to Agent 1');
        ylabel('Marginal Rate of Substitution (MRSXY)');
        title('MRS Function - along the contract curve (non-linear relationship)');
        grid on;
        legend show;

        str1 = sprintf('$$MRS_{XY1} = (%.2f/%.2f) \\ cdot(Y/X)$$',a1,b1);
        str2 = sprintf('$$MRS_{XY2} = (%.2f/%.2f) \\ cdot(Y_2/X_2)$$',a2,b2);

        text(2,max(MRSXY1_func)*0.5,str1, ...
            'Interpreter','latex', ...
            'FontSize',12, ...
            'Color','blue');
        text(6,max(MRSXY2_func)*0.6,str2, ...
            'Interpreter','latex', ...
            'FontSize',12, ...
            'Color','red');

        %% Utility function
        % Testing wether bull or bear phase


        % piecewise linear regression function, incremental
        % increase/decrease to regression function

        % Utility function a - bull, long term trend
        % demand/supply zones, fibo RT above 200, MACD and RSI (daily,
        % weekly)
        
        

        % Utility function b - bear, short term trend
        % demand/supply zones, fibo RT above 200, MACD and RSI (daily,
        % 4h,1h,weekly)


        %% Marginal rate of substitution


        %% Marginal rate of technical substitution
        
