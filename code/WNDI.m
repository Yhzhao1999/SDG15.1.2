clear


currentDir = pwd; % 获取当前工作目录
year = [2010, 2000];

% 定义滑动窗口大小和步长
window_size =  3; % 窗口
stepSize = 1;   % 步长为1像素

for y = year
    % 输出年份值
    disp(y);
    % 滑动窗口裁剪栅格
    relativePath = sprintf('WNDI/GAMLSW30_%d_ICP.tif',y); 
    fullPath = fullfile(currentDir, relativePath); 
    [raster, R] = geotiffread(fullPath);
    proj = geotiffinfo(fullPath); 
    result = raster;
    result(:) = NaN;
    
    % 遍历栅格数据并进行滑动窗口计算
    for rn = round(window_size/2):size(raster, 1) - fix(window_size/2)
        for cn = round(window_size/2):size(raster, 2) - fix(window_size/2)
            % 计算占比
            move_window = raster(rn-floor(window_size/2):rn+floor(window_size/2),cn-floor(window_size/2):cn+floor(window_size/2));
            if all(move_window(:) == 15)
                result(rn,cn) = 10;
            else
                result(rn,cn) = roundn(length(find(move_window == 2))/window_size^2, -2)*100;
            end
        end
    end
    
    % 保存裁剪的栅格数据，并命名为中心像元的坐标
    output_filename = fullfile(currentDir, sprintf('WNDI/WNDI_%d_ICP.tif',y));
    geotiffwrite(output_filename, result, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);
    
end
disp('end')

