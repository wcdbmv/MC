function lab03
    debug = true;

    a = 0;
    b = 1;
    eps = 1e-6;

    fplot(@(x) func(x), [a, b], 'b');
    hold on;

    run = 'p'; % p - parabola
               % g - golden ratio
               % a - all
    p1 = 0;
    p2 = 0;
    m1 = 'Метод парабол';
    m2 = 'Метод золотого сечения';
    global N;

    if (run == 'p' || run == 'a')
        N = 0;
        disp('Метод парабол');
        [x, f] = successiveParabolicInterpolation(a, b, eps, debug);
        fprintf('Минимум функции: (x=%12.10f, f=%12.10f)\n', x, f);
        fprintf('N = %d\n', N);
        p1 = plot(x, f, 'rx', 'MarkerSize', 15);
        if (run ~= a)
            legend((p1), m1, 'Location', 'northwest');
        end
    end
    if (run == 'g' || run == 'a')
        N = 0;
        disp('Метод золотого сечения');
        [x, f, ~, ~] = goldenSectionSearch(a, b, eps, debug);
        fprintf('Минимум функции: (x=%12.10f, f=%12.10f)\n', x, f);
        fprintf('N = %d\n', N);
        p2 = plot(x, f, 'bx', 'MarkerSize', 15);
        if (run ~= 'a')
            legend((p2), m2, 'Location', 'northwest');
        end
    end
    if (run == 'a')
        legend([p1 p2], {m1 m2}, 'Location', 'northwest');
    end

    hold off;
end

function y = func(x)
    global N;
    N = N + 1;

    x3 = power(x, 3);
    x2 = power(x, 2);
    sqrt2 = sqrt(2);

    ch = cosh((3 * x3 + 2 * x2 - 4 * x + 5) / 3);
    th = tanh((x3 - 3 * sqrt2 * x - 2) / (2 * x + sqrt2));

    y = ch + th - 2.5;
end

function [x, f] = successiveParabolicInterpolation(a, b, eps, debug)
    [xl, xr] = goldenSectionBoundaries(a, b);
    xm = (xl + xr) / 2;
    fl = func(xl);
    fm = func(xm);
    fr = func(xr);

    [x, f] = parabola(xl, fl, xm, fm, xr, fr);

    run = true;
    iteration = 1;

    while (run)
        if (debug)
            fprintf('Итерация %d: [x1=%12.10f, x3=%12.10f]\n', iteration, xl, xr);
            iteration = iteration + 1;
        end

        if (x < xm)
            if (f >= fm)
                xl = x;
                fl  = f;
            else
                xr = xm;
                fr = fm;
                xm = x;
                fm = f;
            end
        else
            if (f >= fm)
                xr = x;
                fr = f;
            else
                xl = xm;
                fl = fm;
                xm = x;
                fm = f;
            end
        end

        x0 = x;
        [x, f] = parabola(xl, fl, xm, fm, xr, fr);
        run = abs(x - x0) > eps;
    end

    if (debug)
        fprintf('Итерация %d: [x1=%10.8f, x3=%10.8f]\n', iteration, xl, xr);
    end
end

function [x, f] = parabola(xl, fl, xm, fm, xr, fr)
    a1 = (fm - fl) / (xm - xl);
    a2 = ((fr - fl) / (xr - xl) - a1) / (xr - xm);
    x = (xl + xm - a1 / a2) / 2;
    f = func(x);
end

function [xl, xr] = goldenSectionBoundaries(a, b)
    [~, ~, xl, xr] = goldenSectionSearch(a, b, 0.49, false);
end

function [x, f, x1, x2] = goldenSectionSearch(a, b, eps, debug)
    tau = (sqrt(5) - 1) / 2;
    delta = b - a;

    xl = b - tau * delta;
    xr = a + tau * delta;
    fl = func(xl);
    fr = func(xr);

    iteration = 1;
    while (delta > 2 * eps)
        if (debug)
            fprintf('Итерация %d: [a=%12.10f, b=%12.10f], (xl=%12.10f, xr=%12.10f)\n', iteration, a, b, xl, xr);
            iteration = iteration + 1;
        end

        if (fl > fr)
            a = xl;
            delta = b - a;
            xl = xr;
            fl = fr;
            xr = a + tau * delta;
            fr = func(xr);
        else
            b = xr;
            delta = b - a;
            xr = xl;
            fr = fl;
            xl = b - tau * delta;
            fl = func(xl);
        end
    end

    if (debug)
        fprintf('Итерация %d: [a=%12.10f, b=%12.10f], (xl=%12.10f, xr=%12.10f)\n', iteration, a, b, xl, xr);
    end

    x = (a + b) / 2;
    f = func(x);

    x1 = a;
    x2 = b;
end
