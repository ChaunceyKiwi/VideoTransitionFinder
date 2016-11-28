function [video, frameNumber] = getMatrixFromVideo(input, scale)

v = VideoReader(input);
frameNumber = floor(v.Duration*v.FrameRate);
video = zeros(v.Height,v.Width,3,frameNumber);

i = 1;
while hasFrame(v)
    video(:,:,:,i) = readFrame(v);
    i = i + 1;
end
    
video = imresize(video,scale);