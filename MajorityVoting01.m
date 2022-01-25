% MajorityVoting01.m
% Amin Zehtabian, Freie Universität Berlin
% amin.zehtabian@fu-berlin.de
clc; clear all; close all;
dir_Leon = 'C:\Users\Amin\Desktop\MajorityVoting\Leon';  % Directory of Leon's masks
dir_Lea = 'C:\Users\Amin\Desktop\MajorityVoting\Lea';    % Directory of Lea's masks
dir_Nadjia = 'C:\Users\Amin\Desktop\MajorityVoting\Nadja';    % Directory of Nadja's masks
dir_MajorityVoting = 'C:\Users\Amin\Desktop\MajorityVoting\MV';    % Directory where the masks created by Majority Voiting will be stored

names = dir(dir_Leon); % list of the tif files within the folders (Note: all 3 masks folders should contatin files with the same titles)
names = {names(~[names.isdir]).name};
numfiles = length(names);
data_Leon = cell(1, numfiles); data_Lea = cell(1, numfiles); data_Nadja = cell(1, numfiles);
SUM = cell(1, numfiles); MajorityVoting = cell(1, numfiles);

%% Reading images from each folder
cd(dir_Leon)
for k = 1:numfiles 
  data_Leon{k} = uint8(imread(string(names(k))));   % Reading the image 
  data_Leon_bw{k} = im2bw(data_Leon{k}, 0.000001);   % Binarizing the image 
end
cd(dir_Lea)
for k = 1:numfiles 
  data_Lea{k} = uint8(imread(string(names(k)))); 
  data_Lea_bw{k} = im2bw(data_Lea{k}, 0.000001);   % Binarizing the image 
end
cd(dir_Nadja)
for k = 1:numfiles 
  data_Nadja{k} = uint8(imread(string(names(k))));
  data_Nadja_bw{k} = im2bw(data_Nadja{k}, 0.000001);   % Binarizing the image 
end

display('*************************************');
display('All image have been read & binarized!');
display('*************************************');

%% Summing the images up + Majority Voting + Saving the final images
cd(dir_MajorityVoting)
for k = 1:numfiles 
  SUM{k} = data_Leon_bw{k} + data_Lea_bw{k} + data_Nadja_bw{k} ;
  temp = SUM{k};
  MajorityVoting{k} = temp >= 2;
  MajorityVoting{k} = bwlabel(MajorityVoting{k});
  MajorityVoting{k} = uint16(MajorityVoting{k});
  imwrite(MajorityVoting{k} , string(names(k)) ,'tif');
end
display('*************************************');
display('        Majority Voting is done      ');
display('*************************************');

% %% Example Result to visualize
% e = 5;    % Index of the image to show
% figure; 
% subplot 231; imshow(data_Leon{e},[]); title('Leon'); 
% subplot 232; imshow(data_Lea{e},[]); title('Lea'); 
% subplot 233; imshow(data_Nadja{e},[]); title('Nadja'); 
% % subplot 334; imshow(data_Leon_bw{e},[]); title('Leon'); 
% % subplot 335; imshow(data_Lea_bw{e},[]); title('Lea'); 
% % subplot 336; imshow(data_Nadja_bw{e},[]); title('Nadja');
% subplot 235; imshow(MajorityVoting{e} , []);    title('Majority Voting');