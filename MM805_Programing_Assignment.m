clear all
close all
clc

% 1. 3D Transformations

% 1.1
A = [0 0 0; 1 1 1; 2 2 2; 3 3 3];
B = [4 -5 6; 5 -4 7; 6 -3 8; 7 -2 9];

[transformationMatrix1, status1] = findTransformationMatrix(A, B);

% 1.2
A = [1 1 1; 2 2 2; 3 3 3; 4 4 4];
B = [1 2 3; 2 4 6; 3 6 9; 4 8 12];

[transformationMatrix2, status2] = findTransformationMatrix(A, B);

% 1.3
A = [5 5 1; 3 1 1; 4 3 1; 2 -1 1];
B = [-1 7 1; 1 3 1; 0 5 1; 2 1 1];

[transformationMatrix3, status3] = findTransformationMatrix(A, B);

% 2. Experiments
im = double (imread('./smile.png'));
[row_im, column_im] = size(im);

figure 
set (gcf, 'Color', [1 1 1])
for x = 1:column_im
    for y = 1:row_im
        if status1 == 0
            temp1 = transformationMatrix1 * [x;y;1;1];
        end
        if status2 == 0
            temp2 = transformationMatrix2 * [x;y;1;1];
        end
        if status3 == 0
            temp3 = transformationMatrix3 * [x;y;1;1];
        end
        if im(y, x) == 255
            plot3(x,y,1,'w.')
            grid on
        else
            plot3(x,y,1,'k.')
            if status1 == 0
                plot3(temp1(1), temp1(2), temp1(3), 'k.', 'Color', 'red');
            end
            if status2 == 0
                plot3(temp2(1), temp2(2), temp2(3), 'k.', 'Color', 'green');
            end
            if status3 == 0
                plot3(temp3(1), temp3(2), temp3(3), 'k.', 'Color', 'blue');
            end
            grid on
        end

        hold on
        drawnow
    end
end

% 3. Advance
data_A = readFile('A.txt');
data_B = readFile('B.txt');

ptCloud_A = pointCloud(data_A);
ptCloud_B = pointCloud(data_B);

figure
pcshowpair(ptCloud_A, ptCloud_B)
title("Point Clouds With Noise")

[ptCloud_A, inliersIndices]= pcdenoise(ptCloud_A, "Threshold", 0.01);
ptCloud_B = pointCloud(ptCloud_B.Location(inliersIndices, :));

figure
pcshowpair(ptCloud_A, ptCloud_B)
title("Point Clouds With Less Noise")

[tform, ~, ~] = pcregistericp(ptCloud_A, ptCloud_B);

disp(tform.A)
transformedPtCound_A = pctransform(ptCloud_A, tform);

figure
pcshowpair(ptCloud_A, transformedPtCound_A)
title("Point Clouds with transformation")

% utitlity function
function [transformationMatrix, status]= findTransformationMatrix(A, B)
    [tformEst, ~, status] = estgeotform3d(A, B,"similarity");
    transformationMatrix = zeros(4,4);
    if (status == 0)
        disp("Transformation matrix:")
        disp(tformEst.A);
        transformationMatrix = tformEst.A;
    elseif (status == 1)
        disp("Inputs do not contain enough points");
    else
        disp("Not enough inliers found");
    end
end

function [data] = readFile(file_path)
    fileID = fopen(file_path, 'r');
    data = textscan(fileID, '%f %f %f %f');
    fclose(fileID);
    data = cell2mat(data);
    data = data(:,1:3);
end