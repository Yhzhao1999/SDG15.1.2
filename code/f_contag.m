clear

% glc属性表
[glcdf, glctext, raw] = xlsread('F:/SDG15.1.2/GLCdf.xlsx');

year = [2020, 2010, 2000];

% 定义滑动窗口大小和步长
window_size = 3; % 窗口
stepSize = 1;   % 步长为1像素

for y = year
    % 滑动窗口裁剪栅格
    filepath = sprintf('F:/Indo-China Peninsula/glc%d_ICP.tif',y);
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
            result(rn,cn) = fra_contag(window_size, m, n, move_window)*1000;
        end
    end
    % %保存裁剪的栅格数据，并命名为中心像元的坐标
%     output_filename = sprintf('F:/Indo-China Preninsula/test/split%d.tif', y);
%     geotiffwrite(output_filename, SP, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);
    output_filename = sprintf('F:/Indo-China Peninsula/Fragstats/contag%d_ICP.tif',y);
    geotiffwrite(output_filename, result, R, 'GeoKeyDirectoryTag', proj.GeoTIFFTags.GeoKeyDirectoryTag);
    
end




function frag_contag= fra_contag(window_size, m, n, move_window)
chushijuzhen = 1:window_size^2;
chushijuzhen = reshape(chushijuzhen,window_size, window_size);
fenzi = 0;
if size(m,1)==1 && m(1) == 255
    frag_contag = NaN;
else
    for i = 1:size(m,1)
        if m(i) == 255 && sum(n)==1
            frag_contag = NaN;
        else
            % 有多少个patch type = i的像元
            mi_pixels =  sum(move_window == m(i),'all');
            % Pi = proportion of the landscape occupied by patch type (class) i.
            Pi = mi_pixels / window_size^2;
            % gik =number of adjacencies (joins) between pixels of patch types (classes) i and k based on the double-count method.
            i_po = find(move_window == m(i));
            % 遍历k之后的gik总和
            k_gik = 0;
            for k = 1:size(m,1)
                gik(k) = 0;
                for ii = 1:size(i_po,1)
                    ii_po = i_po(ii);
                    [r,c] = find(chushijuzhen==ii_po);
                    if r>0 && c-1>0
                        if move_window(r,c-1) == m(k)
                            gik(k) = gik(k)+1;
                        end
                    end
                    if r-1>0 && c>0
                        if move_window(r-1,c) == m(k)
                            gik(k) = gik(k)+1;
                        end
                    end
                    if r+1<(window_size+1) && c<(window_size+1)
                        if move_window(r+1,c) == m(k)
                            gik(k) = gik(k)+1;
                        end
                    end
                    if r<(window_size+1) && c+1<(window_size+1)
                        if move_window(r,c+1) == m(k)
                            gik(k) = gik(k)+1;
                        end
                    end
                end
            end
            k_gik = sum(gik,'all');
            for k = 1:size(m,1)
                s =  Pi*(gik(k)/k_gik)*log(Pi*(gik(k)/k_gik));
                if ~isnan(s)
                    fenzi = fenzi + s;
                    %             disp(fenzi)
                end
            end
        end
    end
    n_sum = sum(n);
    if n_sum == 1
        frag_contag = 100;
    else
        frag_contag = (1+ fenzi/(2*log(n_sum)))*100;
    end
end
end
