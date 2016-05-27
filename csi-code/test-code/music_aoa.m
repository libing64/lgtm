%read csi data

close all;
clear;
clc;

path(path, '~/source/sar/lgtm/csi-code/test-data/line-of-sight-localization-tests--in-room/');
path(path, '~/rosbag/csi_data/');

% log_file = 'los-test-desk-left.dat';
% log_file = 'csi_outdoor.txt';
% log_file = 'los-test-jennys-table.dat';
log_file = 'three_antenna_35.dat';
csi_cells = read_bf_file(log_file);


%% parameter fo doa estimation
m = 3; % number of antennas for receiving
ha = phased.ULA('NumElements',m,'ElementSpacing',0.03)
% Model the multichannel received signals at the array
fc = 5.32e9;                               % Operating frequency
lambda = physconst('LightSpeed')/fc;      % Wavelength
Nsamp = 30;      
%% Estimating the Direction of Arrival (DOA)
% We first assume that we know a priori that there are two sources. To
% estimate the DOA, we'll use the root MUSIC technique, so we construct a
% DOA estimator using the root MUSIC algorithm.
hdoaMusic = phased.RootMUSICEstimator('SensorArray',ha,...
            'OperatingFrequency',fc,...
            'NumSignalsSource','Property','NumSignals',2)
hdoaMusic.ForwardBackwardAveraging = true;
	
N = min(500, length(csi_cells) );


x = zeros(3, Nsamp);
for i = 1 : N

	if csi_cells{i}.Nrx ~= 3
		continue;
	end

	scaled_csi = get_scaled_csi(csi_cells{i});
	[Ntx, Nrx, nSubcarrer] = size(scaled_csi);
	if Ntx > 1
		x =  scaled_csi(1, :, :);
	else 
		x =  scaled_csi;
	end

	x = reshape(x, 3, Nsamp);

	ang = step(hdoaMusic, x')
	
end


release(hdoaMusic);