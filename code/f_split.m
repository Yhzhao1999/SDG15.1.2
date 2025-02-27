clear

% glc属性表
[glcdf, glctext, raw] = xlsread('F:/SDG15.1.2/GLCdf.xlsx');

year = [2010, 2000];

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
    result(:) = NaN;
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
            result(rn,cn) = fra_split(window_size, m, n, n_po)*1000;
        end
    end
    % %保存裁剪的栅格数据，并命名为中心像元的坐标
%     output_filename = sprintf('F:/Indo-China Preninsula/test/split%d.tif', y);
%     geotiffwrite(output_filename, SP, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);
    output_filename = sprintf('F:/Indo-China Peninsula/Fragstats/split%d_ICP2.tif',y);
    geotiffwrite(output_filename, result, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);

    
end

function frag_split = fra_split(window_size, m, n, n_po)
fenmu = 0;
% A = total landscape area (m2). Note, total landscape area (A) includes any internal background present.
A_fang = (window_size*30)^2^2;
for i = 1:size(m,1)
    bb = n_po{1,i};
    for j = 1:n(i) % size(bb,2)
        % numericArray = size(cell2mat(CC.PixelIdxList(2)),1);
        aij_fang = (900 * size(bb{1,j},1))^2;
        fenmu = fenmu+aij_fang;
    end
end
frag_split = A_fang/fenmu;
end

