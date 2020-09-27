function DATA = applyDepthThresholdRules(DATA,RULE1,RULE2,RULE3,RULE4,RULE5)
%5,0.9,50,0,0
dbstop if error
nChn = size(DATA{1}.BASERATE,2);
% RESTRUCTURE DATA TO BE A BIG LIST
s = size(DATA);
n = s(1) * s(2);
DATA = reshape(DATA,[n,s(3)]);
index = false(n,1);
F = fieldnames(DATA{1,1}); % Grab all the fieldnames of DATA
sanitisedF = [11:16,19:30]; % List of fields to be excluded
for i = 1:n
    if ~isempty(DATA{i,1})
        for c = 1:nChn
            % Rule 1: There is a cell here
            if DATA{i,1}.ISCELL(c) == 0 || DATA{i,1}.BASERATE(c) < RULE1
                % Remove the recording channel
                for nn = 1:s(3) % For all current levels
                    if ~isempty(DATA{i,nn})
                        for f = sanitisedF
                            DATA{i,nn}.(F{f})(c) = NaN;
                        end
                        DATA{i,nn}.(F{9})(c) = NaN;
                    end
                end
            end
            % Rule 2: r^2 must exceed RULE2
            if DATA{i,1}.RSQUARED(c) < RULE2
                % Remove the recording channel
                for nn = 1:s(3)
                    if ~isempty(DATA{i,nn})
                        for f = sanitisedF
                            DATA{i,nn}.(F{f})(c) = NaN;
                        end
                    end
                end
            end
            % Rule 3: Channel must saturate
            if DATA{i,1}.SATURATED(c) == RULE3
                % Remove the recording channel
                for nn = 1:s(3)
                    if ~isempty(DATA{i,nn})
                        for f = sanitisedF
                            DATA{i,nn}.(F{f})(c) = NaN;
                        end
                    end
                end
            end
            % Rule 4: Channel must reach RULE3 spikes per second
            for a = 1:s(3)
                if isempty(DATA{i,a})
                    if DATA{i,a-1}.FIRINGRATE(c) < RULE4
                        % Remove the recording channel
                        for nn = 1:s(3)
                            if ~isempty(DATA{i,nn})
                                for f = sanitisedF
                                    DATA{i,nn}.(F{f})(c) = NaN;
                                end
                            end
                        end
                    end
                    break;
                end
            end
            if ~isempty(DATA{i,a})
                if DATA{i,a-1}.FIRINGRATE(c) < RULE4
                    % Remove the recording channel
                    for nn = 1:s(3)
                        if ~isempty(DATA{i,nn})
                            for f = sanitisedF
                                DATA{i,nn}.(F{f})(c) = NaN;
                            end
                        end
                    end
                end
            end
        end
        % Rule 5: Rodent or Marmoset Data?
        if DATA{i,1}.CJ ~= RULE5
            % Remove entire entry
            index(i) = true;
        end
    else
        index(i) = true;
    end
end
DATA(index,:) = [];
end