filename = "redfire2.webm";


my_video = VideoReader(filename);
delaytime = 1/my_video.FrameRate;
numFrames = my_video.NumFrames;
frameHeight = my_video.Height;
frameWidth = my_video.Width;

ratio = double(frameHeight(1)) / double(frameWidth(1));

if ratio < 1
    width = 400;
    height = floor(width * ratio);
else
    height = 400;
    width = floor(height / ratio);
end




hashes = zeros(50,50,3,numFrames);

idx = 1;
while hasFrame(my_video)
    temp = imresize(readFrame(my_video) , [50,50],'bilinear');
    if max(max(max(temp))) < 200
        hashes(:,:,:,idx) = rand([50,50,3]);
    else
        hashes(:,:,:,idx) = temp - mod(temp,128);
    end

    idx = idx+1;
end

special_trim = 300;

tolerance = 50;
min_length = 30;

loopList = [];
start_suspect = 1 + special_trim;
while start_suspect < numFrames - special_trim
    end_suspect = start_suspect + min_length;
    while end_suspect < numFrames - special_trim

        if nnz(hashes(:,:,:,start_suspect) - hashes(:,:,:,end_suspect)) < tolerance
            % LOOP FOUND
            loopList = [loopList; start_suspect, end_suspect];
            loop_break = numFrames - special_trim;
            while loop_break > end_suspect
                if nnz(hashes(:,:,:,start_suspect) - hashes(:,:,:,loop_break)) < tolerance
                    % LOOP END FOUND
                    break;
                end
                loop_break = loop_break - 1;
            end
            start_suspect = loop_break;
            break;
        end

        end_suspect = end_suspect +1;
    end
    start_suspect = start_suspect +1;
end

%%

loop_number =2;
renderName = "redfire2.gif";

idx = loopList(loop_number,1);

currentFrame = read(my_video,idx);

resizedFrame = imresize(currentFrame, [height, width], 'nearest');

[mapped_frame, map] = rgb2ind(resizedFrame,256);

imwrite(mapped_frame,map,renderName,"gif","LoopCount",Inf,"DelayTime",delaytime);



for idx = (loopList(loop_number,1)+1):(loopList(loop_number,2)-1)
    currentFrame = readFrame(my_video);
    resizedFrame = imresize(currentFrame, [height, width], 'nearest');
    [mapped_frame, map] = rgb2ind(resizedFrame,256);
    imwrite(mapped_frame,map,renderName,"gif","WriteMode","append","DelayTime",delaytime);

end