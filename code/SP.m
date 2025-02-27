clear
% glc属性表
[glcdf, glctext, raw] = xlsread('F:/SDG15.1.2/GLCdf.xlsx');

glfdf = glcdf(:,1:6);
glctext = glctext(:,1:6);

sp_v = [50,51,52,61,62,71,72,81,82,91,92,120,121,122,130];

year = [2020, 2010, 2000];

% 定义滑动窗口大小和步长
window_size = 3; % 窗口
stepSize = 1;   % 步长为1像素
    
for y = year
    % 输出年份值
    disp(y);
    % 滑动窗口裁剪栅格
    filepath = sprintf('F:/Indo-China Peninsula//GLC/glc%d_ICP.tif',y);
    [raster, R] = geotiffread(filepath);
    proj = geotiffinfo(filepath);
    
    result = raster;
    result(:) = NaN;
    
    
    % 遍历栅格数据并进行滑动窗口计算
    for rn = round(window_size/2):size(raster, 1) - fix(window_size/2)
        for cn = round(window_size/2):size(raster, 2) - fix(window_size/2)
            % 计算占比
            move_window = raster(rn-floor(window_size/2):rn+floor(window_size/2),cn-floor(window_size/2):cn+floor(window_size/2));
            result(rn,cn) = sp(move_window,sp_v,window_size);
        end
    end
    % 保存裁剪的栅格数据，并命名为中心像元的坐标
    output_filename = sprintf('F:/Indo-China Peninsula/Sp/sp%d_ICP.tif', y);
    geotiffwrite(output_filename, result, R);
    
end
disp('end')

function sp = sp(move_window,sp_v,window_size)
spnsum = 0;
for k = sp_v
    spn = length(find(move_window == k));
    spnsum = spnsum+spn;
end
sp = roundn(spnsum/window_size^2, -2)*100;
end