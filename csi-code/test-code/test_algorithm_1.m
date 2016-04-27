%% Tests Algorithm 1 using the passed in data_file
% data_file -- the data file to use for testing Algorithm 1
% function test_algorithm_1(data_file)
% function test_algorithm_1

    % global DEBUG_BRIDGE_CODE_CALLING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % globals_init();
    % Get the full path to the currently executing file and change the
    % pwd to the folder this file is contained in...

    close all;
    [current_directory, ~, ~] = fileparts(mfilename('fullpath'));
    cd(current_directory);
    pwd
    % Path to data used in this test
    path('..', path);
    path('../../csi-code/test-data/localization-tests--in-room', path);
    path('../../csi-code/test-data/line-of-sight-localization-tests--in-room', path);
    % Paths for the csitool functions provided
    path('../../../linux-80211n-csitool-supplementary/matlab', path);
    path('../../../linux-80211n-csitool-supplementary/matlab/sample_data', path);


    %% First localization tests, without strict line of sight
    %data_files = {
    %    'csi-5ghz-10cm-desk-spacing-printer.dat', ...
    %    'csi-5ghz-10cm-desk-spacing-on-book-shelf-2.dat', ...
    %    'csi-5ghz-10cm-desk-spacing-clothes-hamper.dat', ...
    %    'csi-5ghz-10cm-desk-spacing-on-bed.dat', ...
    %    'csi-5ghz-10cm-desk-spacing-bed-side-power-block.dat', ...
    %    'csi-5ghz-10cm-desk-spacing-bed-side-table.dat'
    %};
    data_files = {
        'los-test-heater.dat' ...
        'los-test-desk-left.dat' ...
        'los-test-desk-right.dat' ...
        'los-test-printer.dat' ...
        'los-test-nearby-long-bookshelf.dat' ...
        'los-test-tall-bookshelf.dat' ...
        'los-test-jennys-table.dat' ...
    };
    

    data_file = data_files{2}


    fprintf('Testing Algorithm 1\n')
    % Read data file in
    fprintf('Running on data file: %s\n', data_file)
    csi_trace = read_bf_file(data_file);
    % Extract CSI information for each packet
    fprintf('Have CSI for %d packets\n', length(csi_trace))


    delta_f = 40 * 10^6 / 30;
    packet_one_phase_matrix = [];
    csi_1 = [];
    figure('Name', 'Unmodified CSI Phase', 'NumberTitle', 'off')
    hold on
    xlabel('Subcarrier Index')
    ylabel('Unwrapped CSI Phase')
    title('Unmodified CSI Phase')

    n = 10;%length(csi_trace);
    for i = 1 : n

        csi_entry = csi_trace{i};
        csi = get_scaled_csi(csi_entry);
        % Only consider CSI from transmission on 1 antenna
        csi = csi(1, :, :);
        % Remove the single element dimension
        csi = squeeze(csi);

        csi_phase = unwrap(angle(csi), pi, 2);
        plot(1:1:30, csi_phase(1, :), '-k')
        plot(1:1:30, csi_phase(2, :), '-r')
        plot(1:1:30, csi_phase(3, :), '-g')
    end
    grid on;
    hold off;


    % Modified CSI Phase
    figure('Name', 'Modified CSI Phase', 'NumberTitle', 'off')
    hold on   

    for i = 1 : n
        % Get CSI for the first packet
        csi_entry = csi_trace{i};
        csi = get_scaled_csi(csi_entry);

        % Only consider CSI from transmission on 1 antenna
        csi = csi(1, :, :);
        % Remove the single element dimension
        csi = squeeze(csi);

        if  i == 1
            csi_1 = csi;
        end

        % [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f);


        % if i == 1
        %     [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f);
        % else 
        %     [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f, unwrap(angle(csi_1), pi, 2));
        % end

        % dp = angle( csi_1(1, 1) ) - angle(csi(1, 1));
        dp = angle( csi_1(:, 1) ) - angle(csi(:, 1));

        if i == 1
            [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f);
        else 
            % [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f, unwrap(angle(csi_1), pi, 2));
            [modified_csi, phase_matrix] = spotfi_algorithm_1(csi, delta_f);
        end
        modified_csi_phase = unwrap(angle(modified_csi), pi, 2);
        modified_csi_phase = modified_csi_phase + repmat(dp, 1, 30);
        plot(1:1:30, modified_csi_phase(1, :), '-k')
        plot(1:1:30, modified_csi_phase(2, :), '-r')
        plot(1:1:30, modified_csi_phase(3, :), '-g')

    end

    grid on;
    hold off;



    %todo, it seems that the relative phase of antenna2 and antenna3 is the same? why?
    %relative phase is right, just the scale is different
    % relateive CSI Phase
    figure('Name', 'relative phase', 'NumberTitle', 'off')
    hold on   

    for i = 1 : n
        % Get CSI for the first packet
        csi_entry = csi_trace{i};
        csi = get_scaled_csi(csi_entry);

        % Only consider CSI from transmission on 1 antenna
        csi = csi(1, :, :);
        % Remove the single element dimension
        csi = squeeze(csi);
        
        csi_1 = csi(1, :);
        csi_2 = csi(2, :);
        csi_3 = csi(3, :);
        r12 = csi_2.*conj(csi_1);
        r23 = csi_3.*conj(csi_2);

        relative_csi_phase_1 = angle(r12);
        relative_csi_phase_2 = angle(r23);

        plot(1:1:30, relative_csi_phase_1, '-k')
        plot(1:1:30, relative_csi_phase_2, '-r')
    end
    axis([0 30 -pi pi])
    grid on;
    hold off;



    % % Get CSI for the first packet
    % csi_entry_1 = csi_trace{1};
    % csi_entry_2 = csi_trace{2};
    % csi_1 = get_scaled_csi(csi_entry_1);
    % csi_2 = get_scaled_csi(csi_entry_2);
    % % Only consider CSI from transmission on 1 antenna
    % csi_1 = csi_1(1, :, :);
    % csi_2 = csi_2(1, :, :);
    % % Remove the single element dimension
    % csi_1 = squeeze(csi_1);
    % csi_2 = squeeze(csi_2);
    % % Sanitize ToFs with Algorithm 1
    % % delta_f for HT20
    % %delta_f = 20 * 10^6 / 30;
    % % delta_f for HT40
    % delta_f = 40 * 10^6 / 30;
    % fprintf('Running SpotFi Algorithm 1\n')
    % [modified_csi_1, packet_one_phase_matrix] = spotfi_algorithm_1(csi_1, delta_f);
    % [modified_csi_2, packet_two_phase_matrix] = spotfi_algorithm_1(csi_2, delta_f, unwrap(angle(csi_1), pi, 2));
    % %modified_csi_1 = pin_loc_sanitization_algorithm(csi_1);
    % %modified_csi_2 = pin_loc_sanitization_algorithm(csi_1);
    
    % % Unmodified figures
    % figure('Name', 'Unmodified CSI Phase', 'NumberTitle', 'off')
    % hold on
    % csi_1_phase = unwrap(angle(csi_1), pi, 2);
    % plot(1:1:30, csi_1_phase(1, :), '-k')
    % plot(1:1:30, csi_1_phase(2, :), '-r')
    % plot(1:1:30, csi_1_phase(3, :), '-g')
    
    % csi_2_phase = unwrap(angle(csi_2), pi, 2);
    % plot(1:1:30, csi_2_phase(1, :), '--k')
    % plot(1:1:30, csi_2_phase(2, :), '--r')
    % plot(1:1:30, csi_2_phase(3, :), '--g')
    % xlabel('Subcarrier Index')
    % ylabel('Unwrapped CSI Phase')
    % title('Unmodified CSI Phase')
    % legend('Packet 1, Antenna 1', 'Packet 1, Antenna 2', 'Packet 1, Antenna 3', ...
    %         'Packet 2, Antenna 1', 'Packet 2, Antenna 2', 'Packet 2, Antenna 3')
    % grid on
    % hold off
    
    % % Modified CSI Phase
    % figure('Name', 'Modified CSI Phase', 'NumberTitle', 'off')
    % hold on
    
    % modified_csi_1_phase = unwrap(angle(modified_csi_1), pi, 2);
    % plot(1:1:30, modified_csi_1_phase(1, :), '-k')
    % plot(1:1:30, modified_csi_1_phase(2, :), '-r')
    % plot(1:1:30, modified_csi_1_phase(3, :), '-g')
    
    % modified_csi_2_phase = unwrap(angle(modified_csi_2), pi, 2);
    % plot(1:1:30, modified_csi_2_phase(1, :), '^--k', 'LineWidth', 3)
    % plot(1:1:30, modified_csi_2_phase(2, :), '^--r', 'LineWidth', 3)
    % plot(1:1:30, modified_csi_2_phase(3, :), '^--g', 'LineWidth', 3)
    
    % xlabel('Subcarrier Index')
    % ylabel('Modified Unwrapped CSI Phase')
    % title('Modified CSI Phase')
    % legend('Antenna 1, Packet 1', 'Antenna 2, Packet 1', 'Antenna 3, Packet 1', ...
    %         'Antenna 1, Packet 2', 'Antenna 2, Packet 2', 'Antenna 3, Packet 2')
    % grid on
    % hold off
    
    % return
% end