function capError = computeCapacityRelativeError(expData, simData)
%COMPUTECAPACITYRELATIVEERROR Compute relative end-capacity error.
%
% capError = computeCapacityRelativeError(expData, simData)
%
% Required fields:
%   expData.cap
%   simData.cap
%
% The capacities must be in the same units.

    arguments
        expData struct
        simData struct
    end

    validateCapacityData(expData, 'expData');
    validateCapacityData(simData, 'simData');

    expCap = expData.cap(:);
    simCap = simData.cap(:);

    expCap = expCap(~isnan(expCap));
    simCap = simCap(~isnan(simCap));

    if isempty(expCap)
        error('computeCapacityRelativeError:EmptyExpCapacity', ...
            'expData.cap contains no valid values.');
    end

    if isempty(simCap)
        error('computeCapacityRelativeError:EmptySimCapacity', ...
            'simData.cap contains no valid values.');
    end

    expCapEnd = expCap(end);
    simCapEnd = simCap(end);

    if expCapEnd == 0
        error('computeCapacityRelativeError:ZeroExperimentalCapacity', ...
            'Experimental final capacity is zero, so relative error is undefined.');
    end

    capError = struct();

    capError.exp_cap_end = expCapEnd;
    capError.sim_cap_end = simCapEnd;
    capError.abs_error = abs(simCapEnd - expCapEnd);
    capError.rel_error = capError.abs_error / abs(expCapEnd);
    capError.rel_error_percent = 100 * capError.rel_error;

end


function validateCapacityData(data, dataName)

    if ~isfield(data, 'cap')
        error('computeCapacityRelativeError:MissingField', ...
            '%s is missing required field "cap".', dataName);
    end

    if isempty(data.cap)
        error('computeCapacityRelativeError:EmptyField', ...
            '%s.cap is empty.', dataName);
    end

end