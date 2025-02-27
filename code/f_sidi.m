clear

% glc属性表
[glcdf, glctext, raw] = xlsread('F:/SDG15.1.2/GLCdf.xlsx');

year = [2020, 2010, 2000];

% 定义滑动窗口大小和步长
window_size = 3; % 窗口
stepSize = 1;   % 步长为1像素

for y = year
    % 滑动窗口裁剪栅格
    filepath = sprintf('F:/Indo-China Peninsula/GLC/glc%d_ICP.tif',y);
    [raster, R] = geotiffread(filepath);
    proj = geotiffinfo(filepath);
    % y = 2020;
    
    result = raster;
    result(:) = 101;
    % whos result
    
    % 遍历栅格数据并进行滑动窗口计算
    for rn = round(window_size/2):size(raster, 1) - fix(window_size/2)
        disp(rn)
        for cn = round(window_size/2):size(raster, 2) - fix(window_size/2)
            % m = patch types (classes)
            m = NaN;
            move_window = raster(rn-floor(window_size/2):rn+floor(window_size/2),cn-floor(window_size/2):cn+floor(window_size/2));
            % move_window = [1,1,3;1,1,6;7,8,9];
            % move_window = [1,1,2;1,1,2;2,2,2];
            % move_window = [1,1,1;1,1,1;1,1,1];
            m = unique(move_window);
            % n = patches
            n = zeros(size(m));
            n_po = {};
            % 统计唯一值数量和斑块数量
            for i = 1:length(m)
                patchi = move_window == m(i);
                CC = bwconncomp(patchi,4);
                n(i) = size(CC.PixelIdxList,2);
                n_po(i) = {CC.PixelIdxList};
            end
            % result= fra_split(window_size, m, n, n_po);
            % result= fra_sidi(window_size, m, move_window);
%             result= fra_contag(window_size, m, n, move_window);
            result(rn,cn) = fra_sidi(window_size, m, move_window)*100;
        end
    end
    % %保存裁剪的栅格数据，并命名为中心像元的坐标
%     output_filename = sprintf('F:/Indo-China Preninsula/test/split%d.tif', y);
%     geotiffwrite(output_filename, SP, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);
    output_filename = sprintf('F:/Indo-China Peninsula/Frastats/sidi%d_ICP_0.tif',y);
    geotiffwrite(output_filename, result, R);
    
end


function frag_sidi= fra_sidi(window_size, m, move_window)
sum_Pi = 0;
for i = 1:size(m,1)
    Pi = 0;
    if i ~= 255
        % 有多少个patch type = i的像元
        mi_pixels =  sum(move_window == m(i),'all');
%         % 去除背景的有效cells
%         allcells = window_size^2 - sum(move_window == 255, 'all');
        % Pi = proportion of the landscape occupied by patch type (class) i.
%         if allcells == 0
%             Pi = NaN;
%         else
%             Pi = mi_pixels / allcells;
%         end
        Pi = mi_pixels / window_size^2;
        sum_Pi = sum_Pi+(Pi)^2;
    end
end
frag_sidi = 1-sum_Pi;
end

