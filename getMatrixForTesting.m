function [video, frameNumber] = getMatrixForTesting(size, frameNumber)

height = size(1);
width = size(2);
video = zeros(height,width,3,frameNumber);
whiteTime = floor(frameNumber/3);
transitionEndTime = 2*floor(frameNumber/3);

for k = 1:frameNumber
    for i = 1:height
        for j = 1:width
            % Set image as a white whole before whiteTime
            if(k < whiteTime)
                video(i,j,:,k) = [255,255,255];
            end
            
            % TranstionTime
            if(k >= whiteTime && k <= transitionEndTime) 
                pos = (j/width)*(transitionEndTime-whiteTime)+35;
                if(pos < k)
                   video(i,j,:,k) = [0,0,0];
                else
                   video(i,j,:,k) = [255,255,255]; 
                end
            end
            
            % After transition, image is a black whole
            if(k > transitionEndTime)
                video(i,j,:,k) = [0,0,0];
            end
        end
    end
end