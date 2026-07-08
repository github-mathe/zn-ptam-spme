function varargout = ElectrochemCache(action, t, state)
    persistent t_log state_log

    switch action
        case 'store'
            t_log(end+1,1) = t;
            state_log{end+1,1} = state;

        case 'get'
            varargout = {t_log, state_log};

        case 'clear'
            t_log = [];
            state_log = [];

        otherwise
            error('Unknown action for ElectrochemCache');
    end
end
