function [resImage,houghImage,STI_colour_center,edgeCounter] = generateSTI(video, frameNumber, direction)

if(strcmp(direction,'row'))
    video = permute(video, [2 1 3 4]);
end    

frameNumber = frameNumber - 4;
height = size(video,1);
width = size(video,2);

res = zeros(width, frameNumber-1);
for col = 1 : width

    % get spatio-temporal image
    STI_colour = zeros(height,frameNumber,3);
    for i = 1:frameNumber
        STI_colour(:,i, :) = video(:,col,:,i);
    end

    % show STI image with colour
    if(col == width / 2)
        STI_colour_center = STI_colour/256;
    end

    % replace the colour, RGB, by the chromaticity
    STI_chrom = zeros(height,frameNumber,2);
    for i = 1:height
        for j = 1:frameNumber
            STI_colour_sum = STI_colour(i,j,1)+STI_colour(i,j,2)+STI_colour(i,j,3);
            if(STI_colour_sum ~= 0)
                STI_chrom(i,j,1) = STI_colour(i,j,1)/STI_colour_sum;
                STI_chrom(i,j,2) = STI_colour(i,j,2)/STI_colour_sum;
            else
                STI_chrom(i,j,1) = 0;
                STI_chrom(i,j,2) = 0;
            end   
        end
    end
    
    % build histogram
    N = floor(1+log2(height));
    edges = 0:(1/N):1;
    histogram = zeros(N,N,frameNumber);
    for frameIndex = 1:frameNumber
        data = STI_chrom(:, frameIndex,:);
        histogram(:,:,frameIndex) = histcounts2(data(:,1),data(:,2),edges,edges);
    end

    % normalize histogram
    for i = 1:frameNumber
        histogram(:,:,i) = histogram(:,:,i) / sum(sum(histogram(:,:,i)));% 
    end

    % calculate uniform intersection
    intersection = zeros(1,frameNumber - 1);
    for i = 1:frameNumber-1
        for r = 1 : N
            for g = 1:N
                intersection(i) = intersection(i) + min(histogram(r,g,i),histogram(r,g,i+1));
            end
        end
    end
    
    res(col,:) = intersection(1,:); 
end

% show result
[resImage,houghImage,edgeCounter] = findEdge(res, 0.65);