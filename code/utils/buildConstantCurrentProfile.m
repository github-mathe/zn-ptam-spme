function current = buildConstantCurrentProfile(currentValue, tEnd)
%BUILDCONSTANTCURRENTPROFILE Constant current profile with zero initial value.

    arguments
        currentValue (1, 1) double
        tEnd (1, 1) double {mustBePositive}
    end

    current = @(t) (t > 0 && t < tEnd + 1) * currentValue + (t == 0) * 0;

end
