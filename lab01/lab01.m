function lab01
	% Режим работы
	debug = true;

	debug_disp = @(varargin) debug_generic(debug, @disp, varargin{:});
	debug_fprintf = @(varargin) debug_generic(debug, @fprintf, varargin{:});
	debug_disp_matrix = @(varargin) debug_generic(debug, @disp_matrix, varargin{:});

	% Матрица стоимостей
	C = [10  8  6  4  9;
			11  9 10  5  6;
			 5 10  8  6  4;
			 3 11  9  6  6;
			 8 10 11  8  7];

	debug_disp('Матрица стоимостей:');
	debug_disp(C);

	% Проверка квадратности матрицы стоимостей
	[height, width] = size(C);
	if height ~= width
		disp('Матрица не квадратная!');
		return;
	end

	% Проверка размерности матрицы стоимостей
	n = height;
	if n == 0
		disp('Матрица нулевой размерности!');
		return;
	end


	debug_disp('[I] Подготовительный этап');
	debug_disp('1. Из каждого столбца матрицы вычитаем его наименьший элемент');

	minInColumns = min(C);
	Ct = C - minInColumns;

	debug_disp('Наименьшие элементы в столбцах матрицы стоимостей:');
	debug_disp(minInColumns);
	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp(Ct);


	debug_disp('2. Из каждой строки матрицы вычитаем её наименьший элемент');

	minInRows = min(Ct, [], 2);
	Ct = Ct - minInRows;

	debug_disp('Наименьшие элементы в строках матрицы стоимостей:');
	debug_disp(minInRows);
	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp(Ct);


	debug_disp('3. Строим начальную СНН:');
	debug_disp('просматриваем столбцы теушей матрицы стоимостей (в порядке возрастания номера столбца) сверху вниз.');
	debug_disp('Первый в строке нуль, в одной строке с которым нет 0*, отмечаем 0*.');

	stars = zeros(n);
	colsBusy = zeros([1 n]); % Занятые столбцы
	rowsBusy = zeros([n 1]); % Занятые строки
	for col = 1:n
		for row = 1:n
			if Ct(row, col) == 0 && ~rowsBusy(row)
				stars(row, col) = 1;
				rowsBusy(row) = 1;
				colsBusy(col) = 1;
				break;
			end
		end
	end

	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp_matrix(Ct, stars, zeros(n), zeros([1 n]), zeros([n 1]));


	debug_disp('4. k := |СНН|');

	k = sum(rowsBusy);

	debug_fprintf('k = %d\n\n', k);


	debug_disp('[II] Основной этап венгерского метода');

	rowsBusy = zeros([n 1]);
	strokes = zeros(n);
	iteration = 1;
	while k ~= n
		debug_fprintf('-- Итерация %d\n', iteration);

		debug_disp('5. Столбцы с 0* отмечаем "+"');
		debug_disp_matrix(Ct, stars, zeros(n), colsBusy, zeros([n 1]));
		% TODO: maybe update colsBusy ?

		isThereFreeZeros = true;
		while isThereFreeZeros
			isBreak = false;
			for col = 1:n
				if colsBusy(col)
					continue;
				end

				for row = 1:n
					if rowsBusy(row)
						continue;
					end

					if Ct(row, col) == 0
						debug_disp("6. Среди невыделенных есть 0, отмечаем его 0'");
						strokes(row, col) = 1;
						debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);

						idx = find(stars(row, :), 1);
						if ~isempty(idx)
							debug_disp("7. В одной строке с текущим 0' есть 0*, поэтому");
							debug_disp("снимаем выделение со столбца с этим 0*, выделяем строку с этим 0'");

							colsBusy(idx(1)) = 0;
							rowsBusy(row) = 1;

							debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);
							isBreak = true;
							break;
						end

						debug_disp("8. В одной строке с текущим 0' нет 0*, поэтому");
						debug_disp("строим непродолжаемую L-цепочку: от текущего 0' по столбцу в 0* по строке ... по строке в 0'");

						% TODO
					end
				end

				if isBreak
					break;
				end
			end

			isThereFreeZeros = isBreak
		end
		k = n
		% Pluses =
	end
end

function debug_generic(debug, func, varargin)
	if debug
		func(varargin{:});
	end
end

function disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy)
	addition_symbols = [" ", "*", "'"];
	busy_symbols = [" ", "+"];
	[h, w] = size(Ct);
	for i = 1:h
		fprintf(' ');
		for j = 1:w
			fprintf('%5d', Ct(i, j));
			fprintf('%c', addition_symbols(1 + stars(i, j) + 2 * strokes(i, j)));
		end
		fprintf(' %c\n', busy_symbols(1 + rowsBusy(i)));
	end

	for j = 1:w
		fprintf('%6c', busy_symbols(1 + colsBusy(j)));
	end
	fprintf('\n');
end
