function caseInfo = getDefaultSimulationCase(Crate, defaults)
%GETDEFAULTSIMULATIONCASE Resolve default metadata for a selected C-rate.

    arguments
        Crate (1, 1) double
        defaults struct
    end

    idx = find(defaults.crates == Crate, 1);

    if isempty(idx)
        error('getDefaultSimulationCase:UnknownCrate', ...
            'Crate %g is not listed in defaults.crates.', Crate);
    end

    caseInfo = struct();
    caseInfo.index = idx;
    caseInfo.Crate = defaults.crates(idx);
    caseInfo.soc_init = defaults.soc_inits(idx);

end
