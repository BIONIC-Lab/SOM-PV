%function to produce smooth plots for traces, only used for visualization
%not analysis
function [xx, yy] = spline_fit(y_init, frate, sparam)

    buffer_size = 100;
    y = [zeros(1, buffer_size), y_init, zeros(1, buffer_size)];
    x = (1:length(y))*frate;

    % Approximate smoothing parameter
    nKnots = max(round(length(x) * sparam), 4); 
    knots = augknt(linspace(min(x), max(x), nKnots), 4);  % Cubic spline
    sp = spap2(knots, 4, x, y);
    x_constraints = [0];           % can constrain to pass through certain points - we really only conclusively have [0,0]
    y_constraints = [0];           % Desired y-values at those x-points

    % Evaluate original spline at constraint points
    y_current = fnval(sp, x_constraints);

    % Build basis matrix: each row is the spline basis at a constraint point
    A = zeros(length(x_constraints), length(sp.coefs));
    for i = 1:length(x_constraints)
        A(i, :) = spcol(sp.knots, sp.order, x_constraints(i));
    end

    % Compute delta in coefs: solve A * delta = (y_desired - y_current)
    rhs = y_constraints(:) - y_current(:);  % Column vector of errors
    delta = A \ rhs;  % Least-squares solution to underdetermined/overdetermined systems

    % Apply delta to spline coefficients
    sp.coefs = sp.coefs + delta';

    % Plot result
    xx = x(buffer_size + 1 : end - buffer_size);
    yy = fnval(sp, xx);

end