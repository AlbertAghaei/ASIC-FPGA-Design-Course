function QM()
    % Test case from the exercise
    % f = Σm(0,1,2,3,4,6,8,10,11,15)
    minterms = [0,1,2,3,4,6,8,10,11,15];
    numVars = 4;
    
    % Convert minterms to binary with x for don't care
    binTerms = dec2bin(minterms, numVars);
    
    % Group terms based on number of 1s
    groups = cell(numVars+1, 1);
    for i = 1:length(minterms)
        onesCount = sum(binTerms(i,:) == '1');
        if isempty(groups{onesCount+1})
            groups{onesCount+1} = {};
        end
        groups{onesCount+1}{end+1} = binTerms(i,:);
    end
    
    % Combine terms to find prime implicants
    primeImplicants = {};
    iteration = 1;
    
    while true
        fprintf('--- Iteration %d ---\n', iteration);
        newGroups = cell(numVars+1, 1);
        combined = false;
        marked = zeros(numVars+1, max(cellfun(@length, groups)));
        
        % Try to combine terms from adjacent groups
        for i = 1:(length(groups)-1)
            group1 = groups{i};
            group2 = groups{i+1};
            
            if isempty(group1) || isempty(group2)
                continue;
            end
            
            for j = 1:length(group1)
                for k = 1:length(group2)
                    [canCombine, combinedTerm] = combineTerms(group1{j}, group2{k});
                    if canCombine
                        combined = true;
                        marked(i,j) = 1;
                        marked(i+1,k) = 1;
                        
                        % Add to new group
                        onesCount = sum(combinedTerm == '1');
                        if isempty(newGroups{onesCount+1})
                            newGroups{onesCount+1} = {};
                        end
                        newGroups{onesCount+1}{end+1} = combinedTerm;
                    end
                end
            end
        end
        
        % Store uncombined terms as prime implicants
        for i = 1:length(groups)
            for j = 1:length(groups{i})
                if marked(i,j) == 0
                    term = groups{i}{j};
                    if ~isTermInList(term, primeImplicants)
                        primeImplicants{end+1} = term;
                    end
                end
            end
        end
        
        % Display new groups with x for don't care
        fprintf('New groups after combination:\n');
        for i = 1:length(newGroups)
            if ~isempty(newGroups{i})
                fprintf('Group %d (with %d ones):\n', i-1, i-1);
                for t = 1:length(newGroups{i})
                    disp(strrep(newGroups{i}{t}, '-', 'x'));
                end
            end
        end
        
        if ~combined
            break;
        end
        
        groups = newGroups;
        iteration = iteration + 1;
    end
    
    % Remove duplicates and replace - with x
    primeImplicants = unique(primeImplicants);
    primeImplicants = cellfun(@(x) strrep(x, '-', 'x'), primeImplicants, 'UniformOutput', false);
    
    % Display results
    disp('---------------------------');
    disp('Prime Implicants:');
    disp(primeImplicants');
    disp('---------------------------');
    
    % Find essential prime implicants and simplify expression
    [essentialPIs, simplifiedExpr] = findEssentialPIs(primeImplicants, minterms, numVars);
    
    disp('Essential Prime Implicants:');
    disp(essentialPIs');
    
    disp(['Simplified Expression: ' simplifiedExpr]);
end

function [tf, out] = combineTerms(a, b)
    diffPos = 0;
    diffCount = 0;
    out = '';
    
    for i = 1:length(a)
        if a(i) ~= b(i)
            diffPos = i;
            diffCount = diffCount + 1;
            if diffCount > 1
                tf = false;
                out = '';
                return;
            end
        end
    end
    
    if diffCount == 1
        out = a;
        out(diffPos) = 'x'; % Use x instead of - for don't care
        tf = true;
    else
        tf = false;
        out = '';
    end
end

function tf = isTermInList(term, termList)
    tf = false;
    for i = 1:length(termList)
        if strcmp(term, termList{i})
            tf = true;
            return;
        end
    end
end

function [essentialPIs, simplifiedExpr] = findEssentialPIs(primeImplicants, minterms, numVars)
    % Convert x back to - for comparison
    primeImplicants_dash = cellfun(@(x) strrep(x, 'x', '-'), primeImplicants, 'UniformOutput', false);
    
    % Build coverage table
    coverTable = false(length(primeImplicants), length(minterms));
    
    for i = 1:length(primeImplicants_dash)
        for j = 1:length(minterms)
            term = dec2bin(minterms(j), numVars);
            match = true;
            for k = 1:numVars
                if primeImplicants_dash{i}(k) ~= '-' && primeImplicants_dash{i}(k) ~= term(k)
                    match = false;
                    break;
                end
            end
            coverTable(i,j) = match;
        end
    end
    
    % Find essential PIs (columns with single 1)
    essentialPIs = {};
    essentialIndices = [];
    
    for j = 1:size(coverTable, 2)
        coveringPIs = find(coverTable(:,j));
        if length(coveringPIs) == 1
            essentialPIs{end+1} = primeImplicants{coveringPIs(1)};
            essentialIndices = [essentialIndices, coveringPIs(1)];
        end
    end
    
    essentialIndices = unique(essentialIndices);
    essentialPIs = unique(essentialPIs);
    
    % Generate simplified expression
    variables = 'abcd';
    simplifiedExpr = '';
    
    for i = 1:length(essentialPIs)
        term = essentialPIs{i};
        if i > 1
            simplifiedExpr = [simplifiedExpr ' + '];
        end
        
        for k = 1:length(term)
            if term(k) == '1'
                simplifiedExpr = [simplifiedExpr variables(k)];
            elseif term(k) == '0'
                simplifiedExpr = [simplifiedExpr variables(k) ''''];
            elseif term(k) == 'x'
                % Don't care - skip
            end
        end
    end
end